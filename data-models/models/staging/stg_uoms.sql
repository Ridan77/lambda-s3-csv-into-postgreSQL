with source as (

    select
        uom_id,
        uom_code,
        uom_name,
        uom_name_hebrew,
        uom_type,
        base_uom_id,
        conversion_factor,
        created_at,
        updated_at

    from {{ source('ingestion', 'uoms') }}

)

select
    -- internal identifiers
    uom_id,

    -- business keys
    uom_code,

    -- descriptive attributes
    uom_name,
    uom_name_hebrew,
    uom_type,

    -- hierarchy / conversion
    base_uom_id,
    cast(conversion_factor as numeric(18,6)) as conversion_factor,

    -- metadata
    created_at,
    updated_at

from source
