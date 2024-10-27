with
    devices as (select * from {{ source('product', 'device') }}),

    final as (
        select
            id as pk_device_id,
            type as device_type,
            store_id,
            {{ dbt.current_timestamp() }} as dbt_updated_at
        from
            devices
    )

select *
from final