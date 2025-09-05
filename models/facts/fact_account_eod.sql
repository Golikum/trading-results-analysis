-- Fact table for end-of-day account balances - passthrough from staging
-- No additional business rules applied beyond staging layer

with staging_balances_eod as (
    select * from {{ ref('stg_balances_eod') }}
),

final_fact_account_eod as (
    select
        -- Primary identifiers
        account_id,
        platform,
        date,
        
        -- Financial metrics
        balance,
        equity,
        floating_pnl,
        credit,
        margin_level,
        
        -- Metadata
        _loaded_at,
        current_timestamp() as _transformed_at
        
    from staging_balances_eod
)

select * from final_fact_account_eod
