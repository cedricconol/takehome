with
    first_five as (
        select
            *,
            count(*) over (partition by store_id) as total_transactions_store
        from {{ ref('rpt_device_performance') }}
        qualify row_number() over (partition by store_id order by transaction_happened_at) <= 5
    ),
    transaction_days as (
        select
            store_id,
            store_name,
            min(transaction_happened_at) over (partition by store_id) as first_transaction_ts,
            max(transaction_happened_at) over (partition by store_id) as last_transaction_ts,
            datediff(day, first_transaction_ts, last_transaction_ts) as first_five_transactions_days
        from first_five
        -- include stores with over 5 transactions already
        where total_transactions_store >=5
    )

select
    store_id,
    store_name,
    max(first_five_transactions_days) as first_five_transactions_days
    from transaction_days
group by store_id, store_name