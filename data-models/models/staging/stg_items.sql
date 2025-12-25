with source as (

    select
        item_id,
        item_code,
        item_name,
        item_name_hebrew,
        item_description,
        item_description_hebrew,
        category_id,
        item_type,
        brand,
        brand_hebrew,
        primary_uom_id,
        secondary_uom_id,
        uom_conversion_factor,
        weight_kg,
        volume_liters,
        shelf_life_days,
        min_order_qty,
        standard_cost,
        list_price,
        safety_stock_qty,
        reorder_point,
        is_kosher,
        is_active,
        created_at,
        updated_at

    from {{ source('ingestion', 'items') }}

)

select
    -- internal identifiers
    item_id,

    -- business keys
    item_code,

    -- descriptive attributes
    item_name,
    item_name_hebrew,
    item_description,
    item_description_hebrew,
    item_type,

    -- classification
    category_id,

    -- branding
    brand,
    brand_hebrew,

    -- units of measure (internal references resolved upstream)
    primary_uom_id,
    secondary_uom_id,
    cast(uom_conversion_factor as numeric(18,6)) as uom_conversion_factor,

    -- physical properties
    cast(weight_kg as numeric(18,4)) as weight_kg,
    cast(volume_liters as numeric(18,4)) as volume_liters,
    cast(shelf_life_days as integer) as shelf_life_days,

    -- commercial parameters
    cast(min_order_qty as numeric(18,2)) as min_order_qty,
    cast(standard_cost as numeric(18,4)) as standard_cost,
    cast(list_price as numeric(18,4)) as list_price,

    -- inventory planning
    cast(safety_stock_qty as numeric(18,2)) as safety_stock_qty,
    cast(reorder_point as numeric(18,2)) as reorder_point,

    -- flags
    cast(is_kosher as boolean) as is_kosher,
    cast(is_active as boolean) as is_active,

    -- metadata
    created_at,
    updated_at

from source
