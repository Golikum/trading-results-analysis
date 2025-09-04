-- Staging model for end-of-day balances with basic cleaning
-- Simple transformations: trimming, type casting, date handling

with source_data as (
    select * from {{ source('raw_trading_data', 'balances_eod_raw') }}
),

cleaned_balances as (
    select
        -- Primary identifiers
        trim(account_id) as account_id,
        lower(trim(platform)) as platform,
        
        -- Date handling
        cast(date as date) as date,
        
        -- Financial metrics - cast to proper numeric types
        cast(balance as float64) as balance,
        cast(equity as float64) as equity,
        cast(floating_pnl as float64) as floating_pnl,
        cast(credit as float64) as credit,
        cast(margin_level as float64) as margin_level,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source_data
    
    -- Basic data quality filters
    where account_id is not null
      and trim(account_id) != ''
      and date is not null
)

select * from cleaned_balances
