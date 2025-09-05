{{ config(
    materialized='table',
    schema='trading_marts'
) }}

-- Daily client and account activity statistics
-- Business question: What is the daily trading activity by client and account?
-- Granularity: One row per client_id + account_id + date combination

with trades_data as (
    select * from {{ ref('fact_trades') }}
),

-- Extract date from close_time and aggregate by client_id, account_id, and date
daily_activity_aggregated as (
    select
        client_id,
        account_id,
        client_external_id,
        
        -- Date from close_time
        date(close_time) as trade_date,
        
        -- Aggregated P&L metrics
        sum(net_pnl) as total_net_pnl,
        sum(realized_pnl) as total_realized_pnl,
        sum(commission) as total_commission,
        
        -- Trade activity metrics
        count(*) as total_trades,
        sum(volume) as total_volume,
        
        -- Trade timing
        min(close_time) as first_close_time,
        max(close_time) as last_close_time,
        
        -- Metadata
        current_timestamp() as _created_at
        
    from trades_data
    where close_time is not null  -- Only include trades with valid close times
      and client_id is not null   -- Only include trades with valid client linkage
      and account_id is not null  -- Only include trades with valid accounts
    
    group by 
        client_id,
        account_id, 
        client_external_id,
        date(close_time)
)

select * from daily_activity_aggregated
order by trade_date desc, client_id, account_id
