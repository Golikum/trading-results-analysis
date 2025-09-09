-- Daily client performance aggregations from trades
-- Granularity: One row per client per day
-- Aggregated metrics: commission, realized_pnl, net_pnl (sum) and trade count

with fact_trades as (
    select * from {{ ref('fact_trades') }}
),

-- Aggregate daily performance metrics by client
daily_client_performance as (
    select
        -- Granularity keys
        client_id,
        client_external_id,
        date(open_time) as date,
        
        -- Aggregated financial metrics (sum)
        sum(commission) as total_commission,
        sum(realized_pnl) as total_realized_pnl,
        sum(net_pnl) as total_net_pnl,
        
        -- Trade activity metrics
        count(*) as total_trades,
        
        -- Metadata
        current_timestamp() as _transformed_at
        
    from fact_trades
    where client_id is not null  -- Only include trades with valid client linkage
      and 'date' is not null  -- Only include trades with valid dates
    
    group by 
        client_id,
        client_external_id,
        date
)

select * from daily_client_performance   
