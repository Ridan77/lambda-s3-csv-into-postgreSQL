with source as (

    select
        line_id,
        line_code,
        line_name,
        line_name_hebrew,
        location_id,
        line_type,
        capacity_per_hour,
        capacity_uom_id,
        status,
        last_maintenance_date,
        next_maintenance_date,
        created_at,
        updated_at
    from {{ source('ingestion', 'production_lines') }}

)

select
    -- internal identifiers
    line_id,

    -- business keys
    line_code,

    -- descriptive attributes
    line_name,
    line_name_hebrew,
    line_type,

    -- references
    location_id,
    capacity_uom_id,

    -- capacity
    cast(capacity_per_hour as numeric(18,2)) as capacity_per_hour,

    -- lifecycle
    status,
    last_maintenance_date,
    next_maintenance_date,

    -- metadata
    created_at,
    updated_at

from source
