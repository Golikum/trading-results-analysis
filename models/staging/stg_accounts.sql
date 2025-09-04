-- Staging model for accounts with basic cleaning and validation
-- Simple transformations: trimming, type casting, status derivation

with source_data as (
    select * from {{ source('raw_trading_data', 'accounts_raw') }}
),

cleaned_accounts as (
    select
        -- Primary identifiers
        trim(account_id) as account_id,
        lower(trim(platform)) as platform,
        trim(client_id) as client_id,
        
        -- Account details
        upper(trim(base_currency)) as base_currency,
        
        -- Timestamps
        cast(created_at as timestamp) as created_at,
        cast(closed_at as timestamp) as closed_at,
        
        -- Additional identifiers
        trim(salesforce_account_id) as salesforce_account_id,
        
        -- Flags - ensure boolean type
        cast(is_system as boolean) as is_system,
        cast(is_deleted as boolean) as is_deleted,
        
        -- Derived account status (simple business logic)
        case
            when cast(is_deleted as boolean) = true then 'deleted'
            when cast(closed_at as timestamp) is not null then 'closed'
            when cast(is_system as boolean) = true then 'system'
            else 'active'
        end as account_status,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source_data
    
    -- Basic data quality filters
    where account_id is not null
      and trim(account_id) != ''
)

select * from cleaned_accounts
