with items as (

    select * from {{ ref('stg_items') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

stores as (

    select * from {{ ref('stg_stores') }}

),

supply_costs as (

    select
        sku,
        sum(supply_cost)       as total_supply_cost,
        logical_or(perishable) as has_perishable_supply
    from {{ ref('stg_supplies') }}
    group by sku

),

final as (

    select
        items.item_id,
        orders.order_id,
        orders.ordered_at,
        orders.customer_id,
        stores.store_id,
        stores.store_name,
        products.sku,
        products.product_name,
        products.type                                                    as product_type,
        products.price,
        coalesce(supply_costs.total_supply_cost, 0)                      as total_supply_cost,
        products.price - coalesce(supply_costs.total_supply_cost, 0)     as gross_margin,
        coalesce(supply_costs.has_perishable_supply, false)              as has_perishable_supply

    from items
    left join orders       on items.order_id  = orders.order_id
    left join products     on items.sku       = products.sku
    left join stores       on orders.store_id = stores.store_id
    left join supply_costs on items.sku       = supply_costs.sku

)

select * from final