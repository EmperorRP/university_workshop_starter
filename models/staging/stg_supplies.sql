with source as (

    select * from {{ source('jaffle_shop', 'raw_supplies') }}

),

renamed as (

    select
        id as supply_id,
        name as supply_name,
        cost as supply_cost,
        perishable,
        sku

    from source

)

select * from renamed