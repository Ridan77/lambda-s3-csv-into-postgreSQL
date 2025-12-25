with source as (

    select
        employee_id,
        employee_code,
        first_name,
        first_name_hebrew,
        last_name,
        last_name_hebrew,
        email,
        phone,
        role,
        role_hebrew,
        department,
        department_hebrew,
        default_shift_id,
        hire_date,
        is_active,
        created_at,
        updated_at
    from {{ source('ingestion', 'employees') }}

)

select
    -- internal identifiers
    employee_id,

    -- business keys
    employee_code,

    -- identity
    first_name,
    first_name_hebrew,
    last_name,
    last_name_hebrew,

    -- contact
    email,
    phone,

    -- org
    role,
    role_hebrew,
    department,
    department_hebrew,
    default_shift_id,

    -- employment
    hire_date,
    cast(is_active as boolean) as is_active,

    -- metadata
    created_at,
    updated_at

from source
