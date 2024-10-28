with
    device_performance as (
        select
            device_type,
            transaction_status,
            count(*) as number_of_transactions
        from {{ ref('rpt_device_performance') }}
        group by 1,2
    )

select
    device_type, 
    sum(number_of_transactions) as number_of_transactions,
    100*ratio_to_report(sum(number_of_transactions)) over() as pct_of_total,
    sum(case when transaction_status='accepted' then number_of_transactions end) as number_of_accepted_transactions,
    100*ratio_to_report(sum(case when transaction_status='accepted' then number_of_transactions end)) over() as accepted_pct_of_total,
from device_performance
group by 1
order by device_type