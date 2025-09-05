-- Symbol dimension - passthrough from staging with minimal transformation
-- No additional business rules applied beyond staging layer

with staging_symbols as (
    select * from {{ ref('stg_symbols_ref') }}
),

symbol_dimension as (
    select
        -- Platform and symbol identifiers
        platform,
        platform_symbol,
        std_symbol,
        
        -- Symbol attributes
        asset_class,
        quote_currency,
        
        -- Technical details
        tick_value,
        
        -- Metadata
        _loaded_at,
        current_timestamp() as _transformed_at
        
    from staging_symbols
)

select * from symbol_dimension
