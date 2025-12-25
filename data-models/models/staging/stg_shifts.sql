with source as (

    select
        shift_id,
        shift_code,
        shift_name,
        shift_name_hebrew,
        start_time,
        end_time,
        is_active,
        created_at
    from {{ source('ingestion', 'shifts') }}

)

select
    -- internal identifiers
    shift_id,

    -- business keys
    shift_code,

    -- descriptive attributes
    shift_name,
    shift_name_hebrew,

    -- schedule
    start_time,
    end_time,

    -- flags
    cast(is_active as boolean) as is_active,

    -- metadata
    created_at

from source
