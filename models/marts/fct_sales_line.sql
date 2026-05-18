-- How much profit did we make? 
--  1 row per item sold

select * from {{ ref('int_sales_enriched') }}
