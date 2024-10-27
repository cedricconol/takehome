with
    transactions as (select * from {{ source("product", "transactions") }}),

    final as (
        select
            id as pk_transaction_id,
            device_id,
            product_name as transaction_product_name,
            product_sku as transaction_product_sku,
            amount as transaction_amount_eur,
            status as transaction_status,

            -- ideally, sensitive information such as credit card numbers
            -- and CVVs should not be stored in a data warehouse
            -- these sensitive information will not be included in downstream
            -- models in this project
            
            -- if an analysis requires these two fields, and product
            -- database remain unencrypted, perform tokenization

            created_at as transaction_created_at,
            happened_at as transaction_happened_at,
            {{ dbt.current_timestamp() }} as dbt_updated_at
        from transactions
    )

select *
from final
