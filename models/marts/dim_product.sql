-- What margin does each product have?
-- 1 row per SKU

with products as (

    select * from {{ ref('stg_products') }}

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
        products.sku,
        products.product_name,
        products.type                                                                    as product_type,
        products.price,
        coalesce(supply_costs.total_supply_cost, 0)                                      as total_supply_cost,
        products.price - coalesce(supply_costs.total_supply_cost, 0)                     as gross_margin,
        safe_divide(
            products.price - coalesce(supply_costs.total_supply_cost, 0),
            products.price
        )                                                                                as margin_pct,
        coalesce(supply_costs.has_perishable_supply, false)                              as has_perishable_supply

    from products
    left join supply_costs using (sku)

)

select * from final
