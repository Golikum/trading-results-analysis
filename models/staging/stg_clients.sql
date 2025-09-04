-- Staging model for clients with basic cleaning and standardization
-- Simple transformations: trimming, case standardization

with source_data as (
    select * from {{ source('raw_trading_data', 'clients_raw') }}
),

cleaned_clients as (
    select
        -- Primary identifiers
        trim(client_id) as client_id,
        nullif(trim(client_external_id), '') as client_external_id,
        
        -- Geographic and business details (preserve original values, just clean)
        trim(jurisdiction) as jurisdiction,
        trim(segment) as segment,
        
        -- Timestamps
        cast(created_at as timestamp) as created_at,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source_data
    
    -- Basic data quality filters
    where client_id is not null
      and trim(client_id) != ''
)

select * from cleaned_clients
