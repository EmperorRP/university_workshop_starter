with source as (

    select * from {{ source('jaffle_shop', 'raw_orders') }}

),

renamed as (

    select
        id as order_id,
        customer as customer_id,
        ordered_at,
        store_id,
        subtotal as order_subtotal,
        tax_paid as order_tax_paid,
        order_total

    from source

)

select * from renamed