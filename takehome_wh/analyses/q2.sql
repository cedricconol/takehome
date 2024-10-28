with
    product_performance as (
        select
            transaction_product_sku,
            customer_id,
            transaction_status,
            count(*) as number_of_transactions
        from {{ ref('rpt_device_performance') }}
        group by 1,2,3
    )

select
    *
from product_performance
order by transaction_status, number_of_transactions desc
limit 10