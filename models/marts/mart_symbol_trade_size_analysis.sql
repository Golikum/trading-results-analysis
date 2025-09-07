{{ config(
    materialized='table',
    schema='trading_marts'
) }}

-- Symbol trade size analysis with three different size metrics averaged per day
-- Business question: What are the average trade sizes by symbol across different measurement approaches?
-- Metrics: Volume, Trade Value, and Risk Amount - all averaged per trading day

with trades_data as (
    select * from {{ ref('fact_trades') }}
),

-- CTE 1: Calculate total number of trading days in the dataset
total_trading_days as (
    select count(distinct date(open_time)) as total_days
    from trades_data
    where open_time is not null
),

-- CTE 2: Aggregate metrics for the whole period by symbol, then calculate averages
symbol_trade_size_metrics as (
    select
        t.symbol,
        ttd.total_days as total_dataset_days,
        
        -- Count trading days for this symbol
        count(distinct date(t.open_time)) as trading_days,
        
        -- Total aggregations for the whole period
        count(*) as total_trades,
        round(sum(t.volume),0) as total_volume,
        round(sum(t.volume * t.open_price),0) as total_trade_value,
        round(sum(abs(t.net_pnl)),0) as total_risk_amount,
        
        -- Trade Size Metric 1: Average Volume per Day
        round(sum(t.volume) / ttd.total_days, 2) as avg_trade_size_volume,
        
        -- Trade Size Metric 2: Average Trade Value per Day
        round(sum(t.volume * t.open_price) / ttd.total_days, 2) as avg_trade_value,
        
        -- Trade Size Metric 3: Average Risk Amount per Day
        round(sum(abs(t.net_pnl)) / ttd.total_days, 2) as avg_trade_size_risk,
        
        -- Supporting metrics
        round(count(*) / ttd.total_days, 1) as avg_trades_per_day,
        
        -- Date range
        min(date(t.open_time)) as first_trade_date,
        max(date(t.open_time)) as last_trade_date,
        
        -- Trading frequency (what percentage of days was this symbol traded)
        round(
            count(distinct date(t.open_time)) / ttd.total_days, 
            2
        ) as trading_frequency_pct,
        
        -- Metadata
        current_timestamp() as _created_at
        
    from trades_data t
    cross join total_trading_days ttd
    where t.symbol is not null
      and t.open_time is not null
      and t.volume > 0
      and t.open_price > 0
    
    group by 
        t.symbol,
        ttd.total_days
)

select * from symbol_trade_size_metrics
order by avg_trade_value desc
