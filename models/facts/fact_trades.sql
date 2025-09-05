-- Fact table for trades with enriched client linking and standardized symbols
-- Business improvements:
-- 1. Resolve missing client_external_id values by joining through accounts and clients
-- 2. Replace platform-specific symbols with standardized symbols from symbols reference
-- 3. Calculate net P&L (realized_pnl + commission) at the fact layer

with staging_trades as (
    select * from {{ ref('stg_trades') }}
),

staging_accounts as (
    select * from {{ ref('stg_accounts') }}
),

staging_clients as (
    select * from {{ ref('stg_clients') }}
),

staging_symbols as (
    select * from {{ ref('stg_symbols_ref') }}
),

-- Enrich trades with missing client_external_id and standardized symbols
trades_enriched as (
    select
        t.*,
        -- Use existing client_external_id or look it up via account -> client chain
        coalesce(
            t.client_external_id,
            c.client_external_id
        ) as resolved_client_external_id,
        -- Add client_id from dimension
        c.client_id,
        -- Use standardized symbol from symbols reference
        s.std_symbol
        
    from staging_trades t
    left join staging_accounts a
        on t.account_id = a.account_id
    left join staging_clients c
        on a.client_id = c.client_id
    left join staging_symbols s
        on t.platform = s.platform 
        and t.symbol = s.platform_symbol
),

final_fact_trades as (
    select
        -- Primary identifiers
        trade_id,
        platform,
        account_id,
        resolved_client_external_id as client_external_id,
        client_id,
        
        -- Trade details
        std_symbol as symbol,
        side,
        volume,
        
        -- Timestamps
        open_time,
        close_time,
        
        -- Pricing
        open_price,
        close_price,
        
        -- Financial metrics
        commission,
        realized_pnl,
        -- Calculate net P&L (business rule: realized_pnl + commission)
        realized_pnl + commission as net_pnl,
        
        -- Additional fields
        book_flag,
        counterparty,
        quote_currency,
        status,
        
        -- Metadata
        _loaded_at,
        current_timestamp() as _transformed_at
        
    from trades_enriched
)

select * from final_fact_trades
