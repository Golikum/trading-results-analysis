-- Fact table for end-of-day account balances with client linkage
-- Business improvements:
-- 1. Link accounts to clients using dim_account

with staging_balances_eod as (
    select * from {{ ref('stg_balances_eod') }}
),

account_dimension as (
    select * from {{ ref('dim_account') }}
),

final_fact_account_eod as (
    select
        -- Primary identifiers
        b.account_id            as account_id,
        client_id,
        b.platform              as platform,
        date,
        
        -- Financial metrics
        balance,
        equity,
        floating_pnl,
        credit,
        margin_level,
        
        -- Metadata
        b._loaded_at            as _loaded_at,
        current_timestamp() as _transformed_at
        
    from staging_balances_eod b
    left join account_dimension a
        on b.account_id = a.account_id
)

select * from final_fact_account_eod
