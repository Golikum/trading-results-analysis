-- Account dimension - passthrough from staging with minimal transformation
-- No additional business rules applied beyond staging layer

with staging_accounts as (
    select * from {{ ref('stg_accounts') }}
),

account_dimension as (
    select
        -- Primary identifiers
        account_id,
        platform,
        client_id,
        
        -- Account details
        base_currency,
        
        -- Timestamps
        created_at,
        closed_at,
        
        -- Additional identifiers
        salesforce_account_id,
        
        -- Flags
        is_system,
        is_deleted,
        
        -- Derived status (from staging)
        account_status,
        
        -- Metadata
        _loaded_at,
        current_timestamp() as _transformed_at
        
    from staging_accounts
)

select * from account_dimension
