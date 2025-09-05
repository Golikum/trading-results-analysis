{{ config(
    materialized='table',
    schema='trading_marts'
) }}

-- Client performance ranking mart based on total net P&L
-- Business question: Who are the top and bottom performing clients?
-- Granularity: One row per client, ordered from best to worst performer

with client_daily_performance as (
    select * from {{ ref('fact_client_performance_daily') }}
),

-- Aggregate lifetime performance by client from daily facts
client_performance_totals as (
    select
        client_external_id,
        client_id,
        
        -- Performance metrics (lifetime totals from daily aggregations)
        sum(total_net_pnl) as total_net_pnl,
        sum(total_realized_pnl) as total_realized_pnl,
        sum(total_commission) as total_commission,
        
        -- Activity metrics (lifetime totals from daily aggregations)
        sum(total_trades) as total_trades,
        
        -- Performance indicators
        round(sum(total_net_pnl) / sum(total_trades), 2) as avg_net_pnl_per_trade,
        min(date) as first_trade_date,
        max(date) as last_trade_date
        
    from client_daily_performance
    
    group by 
        client_external_id,
        client_id
),

-- Add performance ranking
client_performance_ranked as (
    select
        -- Performance ranking (1 = best performer)
        row_number() over (order by total_net_pnl desc) as performance_rank,
        *,
        
        -- Performance categorization
        case 
            when total_net_pnl > 0 then 'Profitable'
            when total_net_pnl = 0 then 'Break-even'
            else 'Loss-making'
        end as performance_category,
        
        -- Current timestamp
        current_timestamp() as _created_at
        
    from client_performance_totals
)

select * from client_performance_ranked
order by performance_rank
