with source as (

    select
        supplier_id,
        supplier_code,
        supplier_name,
        supplier_name_hebrew,
        supplier_type,
        contact_name,
        contact_name_hebrew,
        email,
        phone,
        address_city,
        address_city_hebrew,
        address_country,
        lead_time_days,
        payment_terms_days,
        quality_rating,
        is_active,
        created_at,
        updated_at
    from {{ source('ingestion', 'suppliers') }}

)

select
    -- internal identifiers
    supplier_id,

    -- business keys
    supplier_code,

    -- descriptive attributes
    supplier_name,
    supplier_name_hebrew,
    supplier_type,

    -- contact
    contact_name,
    contact_name_hebrew,
    email,
    phone,

    -- address
    address_city,
    address_city_hebrew,
    address_country,

    -- commercial terms
    cast(lead_time_days as integer) as lead_time_days,
    cast(payment_terms_days as integer) as payment_terms_days,
    cast(quality_rating as numeric(3,2)) as quality_rating,

    -- flags
    cast(is_active as boolean) as is_active,

    -- metadata
    created_at,
    updated_at

from source
