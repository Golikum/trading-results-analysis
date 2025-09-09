{{ config(
    materialized='table',
    schema='trading_marts'
) }}

-- Account risk analysis
-- Business question: Which clients/accounts are at risk
-- Accounts marked is_deleted = true but still trading.

with trades_data as (
    select * from {{ ref('fact_trades') }}
)

select 
    any_value(client_id)                                    as client_id,
    account_id,
    count(trade_id)                                         as trades_number,
    if(sum(cast(account_is_deleted as INT64)) > 0, 1, 0)    as is_account_deleted
from
    trades_data
group by
    account_id
having
    is_account_deleted = 1
order by
    client_id