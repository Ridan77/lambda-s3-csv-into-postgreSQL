with source as (

    select
        location_id,
        location_code,
        location_name,
        location_name_hebrew,
        location_type,
        address_city,
        address_city_hebrew,
        address_street,
        address_street_hebrew,
        capacity_units,
        capacity_uom_id,
        is_active,
        created_at,
        updated_at
    from {{ source('ingestion', 'inventory_locations') }}

)

select
    -- internal identifiers
    location_id,

    -- business keys
    location_code,

    -- descriptive attributes
    location_name,
    location_name_hebrew,
    location_type,

    -- address
    address_city,
    address_city_hebrew,
    address_street,
    address_street_hebrew,

    -- capacity
    cast(capacity_units as integer) as capacity_units,
    capacity_uom_id,

    -- flags
    cast(is_active as boolean) as is_active,

    -- metadata
    created_at,
    updated_at

from source
