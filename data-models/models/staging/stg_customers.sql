with source as (

    select
        customer_id,
        customer_code,
        customer_name,
        customer_name_hebrew,
        customer_type,
        contact_name,
        contact_name_hebrew,
        email,
        phone,
        address_city,
        address_city_hebrew,
        address_street,
        address_street_hebrew,
        payment_terms_days,
        credit_limit,
        priority_level,
        is_active,
        created_at,
        updated_at

    from {{ source('ingestion', 'customers') }}

)

select
    -- internal identifiers
    customer_id,

    -- business keys
    customer_code,

    -- descriptive attributes
    customer_name,
    customer_name_hebrew,
    customer_type,

    -- contact details
    contact_name,
    contact_name_hebrew,
    email,
    phone,

    -- address
    address_city,
    address_city_hebrew,
    address_street,
    address_street_hebrew,

    -- commercial terms
    cast(payment_terms_days as integer) as payment_terms_days,
    cast(credit_limit as numeric(18,2)) as credit_limit,
    priority_level,

    -- system flags
    cast(is_active as boolean) as is_active,

    -- metadata
    created_at,
    updated_at

from source
