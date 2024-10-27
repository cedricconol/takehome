with
    stores as (select * from {{ source('product', 'store') }}),

    final as (
        select
            id as pk_store_id,
            name as store_name,
            address as store_address,
            city as store_city,
            country as store_country,
            typology as store_typology,
            customer_id,

            created_at as store_created_at,
            {{ dbt.current_timestamp() }} as dbt_updated_at
        from
            stores
    )

select *
from final