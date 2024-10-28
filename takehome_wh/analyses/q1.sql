with
    store_performance  as (
        select
            store_id,
            store_name,
            sum(transaction_amount_eur) as total_transaction_amount_eur
        from {{ ref('rpt_device_performance') }}
        where transaction_status = 'accepted'
        group by 1,2
    )

select
    *
from store_performance 
order by total_transaction_amount_eur desc
limit 10