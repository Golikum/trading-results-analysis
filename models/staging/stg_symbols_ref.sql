-- Staging model for symbol reference data with basic cleaning
-- Simple transformations: trimming, case standardization

with source_data as (
    select * from {{ source('raw_trading_data', 'symbols_ref') }}
),

cleaned_symbols as (
    select
        -- Platform and symbol identifiers
        lower(trim(platform)) as platform,
        trim(platform_symbol) as platform_symbol,
        upper(trim(std_symbol)) as std_symbol,
        
        -- Symbol attributes (preserve original values, just clean)
        trim(asset_class) as asset_class,
        upper(trim(quote_currency)) as quote_currency,
        
        -- Technical details
        cast(tick_value as float64) as tick_value,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source_data
    
    -- Basic data quality filters
    where platform is not null
      and trim(platform) != ''
      and platform_symbol is not null
      and trim(platform_symbol) != ''
      and std_symbol is not null
      and trim(std_symbol) != ''
)

select * from cleaned_symbols
