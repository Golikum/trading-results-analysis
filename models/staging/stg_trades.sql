-- Staging model for trades with basic cleaning and standardization
-- This model cleanses raw trade data and prepares it for downstream processing

with source_data as (
    select * from {{ source('raw_trading_data', 'trades_raw') }}
),

cleaned_trades as (
    select
        -- Primary identifiers
        trade_id,
        lower(trim(platform)) as platform,
        account_id,
        nullif(trim(client_external_id), '') as client_external_id,
        
        -- Trade details
        trim(symbol) as symbol,
        trim(side) as side,
        cast(volume as float64) as volume,
        
        -- Timestamps (convert to proper datetime if needed)
        cast(open_time as timestamp) as open_time,
        cast(close_time as timestamp) as close_time,
        
        -- Pricing
        cast(open_price as float64) as open_price,
        cast(close_price as float64) as close_price,
        
        -- Financial metrics
        cast(commission as float64) as commission,
        cast(realized_pnl as float64) as realized_pnl,
        
        -- Calculate net P&L (business rule: realized_pnl + commission)
        cast(realized_pnl as float64) + cast(commission as float64) as net_pnl,
        
        -- Additional fields
        trim(book_flag) as book_flag,
        trim(counterparty) as counterparty,
        trim(quote_currency) as quote_currency,
        trim(status) as status,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source_data
    
    -- Basic data quality filters
    where trade_id is not null
      and account_id is not null
      and symbol is not null
      and volume > 0
      and side is not null
)

select * from cleaned_trades
