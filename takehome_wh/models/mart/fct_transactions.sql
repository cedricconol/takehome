with
    -- import CTEs
    transactions as (select * from {{ ref('stg_product__transactions') }}),

    -- logical CTEs
    final as (
        select
            pk_transaction_id,
            transaction_happened_at,
            transaction_created_at,
            transaction_status,
            transaction_product_name,
            transaction_product_sku,
            transaction_amount_eur,
            device_id,
            {{ dbt.current_timestamp() }} as dbt_updated_at
        from transactions
    )

select *
from final