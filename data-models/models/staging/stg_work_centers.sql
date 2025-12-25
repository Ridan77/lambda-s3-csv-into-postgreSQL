with source as (

    select
        work_center_id,
        work_center_code,
        work_center_name,
        work_center_name_hebrew,
        line_id,
        work_center_type,
        capacity_per_hour,
        capacity_uom_id,
        cost_per_hour,
        status,
        created_at,
        updated_at
    from {{ source('ingestion', 'work_centers') }}

)

select
    -- internal identifiers
    work_center_id,

    -- business keys
    work_center_code,

    -- descriptive attributes
    work_center_name,
    work_center_name_hebrew,
    work_center_type,

    -- references
    line_id,
    capacity_uom_id,

    -- capacity & cost
    cast(capacity_per_hour as numeric(18,2)) as capacity_per_hour,
    cast(cost_per_hour as numeric(18,2)) as cost_per_hour,

    -- lifecycle
    status,

    -- metadata
    created_at,
    updated_at

from source
