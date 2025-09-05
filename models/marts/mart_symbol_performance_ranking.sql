{{ config(
    materialized='table',
    schema='trading_marts'
) }}

-- Symbol performance ranking mart based on total net P&L
-- Business question: Which symbols perform best and worst across all clients?
-- Granularity: One row per symbol, ordered from best to worst performing symbol

with symbol_trades as (
    select * from {{ ref('fact_trades') }}
),

-- Aggregate total performance by symbol
symbol_performance_totals as (
    select
        symbol,
        
        -- Performance metrics (lifetime totals)
        sum(net_pnl) as total_net_pnl,
        sum(realized_pnl) as total_realized_pnl,
        sum(commission) as total_commission,
        
        -- Activity metrics
        count(*) as total_trades,
        count(distinct client_external_id) as unique_clients,
        
        -- Performance indicators
        round(sum(net_pnl) / count(*), 2) as avg_net_pnl_per_trade,
        round(sum(volume), 2) as total_volume,
        min(open_time) as first_trade_date,
        max(open_time) as last_trade_date
        
    from symbol_trades
    where symbol is not null
    
    group by symbol
),

-- Add performance ranking
symbol_performance_ranked as (
    select
        *,
        -- Performance ranking (1 = best performing symbol)
        row_number() over (order by total_net_pnl desc) as performance_rank,
        
        -- Performance categorization
        case 
            when total_net_pnl > 0 then 'Profitable'
            when total_net_pnl = 0 then 'Break-even'
            else 'Loss-making'
        end as performance_category,
        
        -- Trading intensity
        case 
            when total_trades >= 100 then 'High Volume'
            when total_trades >= 50 then 'Medium Volume'
            else 'Low Volume'
        end as trading_intensity,
        
        -- Current timestamp
        current_timestamp() as _created_at
        
    from symbol_performance_totals
)

select * from symbol_performance_ranked
order by performance_rank
