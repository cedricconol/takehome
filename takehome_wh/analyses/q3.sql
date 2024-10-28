select
    store_typology,
    store_country,
    avg(transaction_amount_eur) as avg_transaction_amount_eur
from {{ ref('rpt_device_performance') }}
where transaction_status = 'accepted'
group by 1,2