with
    -- import CTEs

    stores as (select * from {{ ref('stg_product__stores') }}),

    devices as (select * from {{ ref('stg_product__devices') }}),

    -- logical CTEs
    final as (
        select
            devices.pk_device_id,
            devices.device_type,
            devices.store_id,
            stores.store_name,
            stores.store_address,
            stores.store_city,
            stores.store_country,
            stores.store_typology,
            stores.store_created_at,
            stores.customer_id,
            
            {{ dbt.current_timestamp() }} as dbt_updated_at
        from devices
        left join stores on devices.store_id = stores.pk_store_id
    )

select *
from final