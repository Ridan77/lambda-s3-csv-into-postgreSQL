with source as (

    select
        category_id,
        category_code,
        category_name,
        category_name_hebrew,
        parent_category_id,
        category_type,
        created_at

    from {{ source('ingestion', 'item_categories') }}

)

select
    -- internal identifiers
    category_id,

    -- business keys
    category_code,

    -- descriptive attributes
    category_name,
    category_name_hebrew,
    category_type,

    -- hierarchy
    parent_category_id,

    -- metadata
    created_at

from source
