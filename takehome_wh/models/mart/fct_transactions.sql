with
    -- import CTEs
    transactions as (select * from {{ ref('stg_product__transactions') }}),

    stores as (select * from {{ ref('stg_product__stores') }}),

    devices as (select * from {{ ref('stg_product__devices') }}),

    -- logical CTEs
    final as (
        select
            transactions.pk_transaction_id,
            transaction_happened_at,
            transaction_status,
            transaction_product_name,
            transaction_product_sku,
            transaction_amount_eur,

            device_id,
            {{ dbt.current_timestamp() }} as dbt_updated_at
        from transactions
        left join devices on transactions.device_id = devices.pk_device_id
    )

select *
from final