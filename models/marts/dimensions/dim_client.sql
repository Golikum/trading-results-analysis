-- Client dimension with standardized segments and validated jurisdictions
-- Business rules applied:
-- 1. Segment standardization: Retail, Pro, VIP with proper casing
-- 2. Jurisdiction validation: NULL values converted to "Unknown"

with staging_clients as (
    select * from {{ ref('stg_clients') }}
),

client_dimension as (
    select
        -- Primary identifiers
        client_id,
        client_external_id,
        
        -- Geographic details with validation
        case 
            when jurisdiction is null or trim(jurisdiction) = '' then 'Unknown'
            else trim(jurisdiction)
        end as jurisdiction,
        
        -- Business segment standardization
        case 
            when lower(segment) = 'retail' then 'Retail'
            when lower(segment) = 'pro' then 'Pro'
            when lower(segment) = 'vip' then 'VIP'
            else 'Unknown'  -- Fallback for any unexpected values
        end as segment,
        
        -- Timestamps
        created_at,
        
        -- Metadata
        _loaded_at,
        current_timestamp() as _transformed_at
        
    from staging_clients
)

select * from client_dimension
