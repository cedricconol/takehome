{{
    config(
        materialized='incremental',
        unique_key='pk_transaction_id'
    )
}}

with
    -- import CTEs
    transactions as (
        select * 
        from {{ ref('stg_product__transactions') }}

        {% if is_incremental() %}
            where transaction_created_at >= (
                select coalesce(max(transaction_created_at), current_timestamp)
                from {{ this }}
            )
        {% endif %}
    ),

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