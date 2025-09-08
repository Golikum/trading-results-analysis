{{ config(
    materialized='table',
    schema='trading_marts'
) }}

-- Account drawdown analysis
-- Business question: What is the current drawdown status for each account?
-- Metrics: High water mark, current equity, drawdown value and ratio
-- Granularity: One row per account

with account_eod as (
    select * from {{ ref('fact_account_eod') }}
)

select
    account_id,
    max(equity)                         as high_water_mark,
    max_by(equity, date)                as current_equity,
    max_by(equity, date) - max(equity)  as drawdown_value,
    round(
        (max_by(equity, date) - max(equity)) / max(equity),
        6
    )                                   as drawdown_ratio
from account_eod
where equity is not null
group by 
    account_id
order by 
    drawdown_ratio asc
