-- Daily client performance aggregations from trades
-- Granularity: One row per client per day
-- Aggregated metrics: commission, realized_pnl, net_pnl (sum) and trade count

with fact_trades as (
    select * from {{ ref('fact_trades') }}
),

dim_client as (
    select * from {{ ref('dim_client') }}
),

-- Join trades with client dimension to get client_id
trades_with_client as (
    select
        t.*,
        c.client_id,
        -- Extract date from open_time for daily aggregation
        date(t.open_time) as trade_date
        
    from fact_trades t
    left join dim_client c
        on t.client_external_id = c.client_external_id
),

-- Aggregate daily performance metrics by client
daily_client_performance as (
    select
        -- Granularity keys
        c.client_id                 as client_id,
        client_external_id,
        trade_date as date,
        
        -- Aggregated financial metrics (sum)
        sum(commission) as total_commission,
        sum(realized_pnl) as total_realized_pnl,
        sum(net_pnl) as total_net_pnl,
        
        -- Trade activity metrics
        count(*) as total_trades,
        
        -- Metadata
        current_timestamp() as _transformed_at
        
    from trades_with_client
    where client_id is not null  -- Only include trades with valid client linkage
      and trade_date is not null  -- Only include trades with valid dates
    
    group by 
        client_id,
        client_external_id,
        trade_date
)

select * from daily_client_performance
