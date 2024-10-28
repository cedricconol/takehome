with
    -- import CTEs
    transactions as (select * from {{ ref('fct_transactions') }}),

    devices as (select * from {{ ref('dim_devices') }}),

    -- logical CTEs
    final as (
        select
            devices.* exclude dbt_updated_at,
            transactions.* exclude (dbt_updated_at),
            {{ dbt.current_timestamp() }} as dbt_updated_at
        from devices
        left join transactions on devices.pk_device_id = transactions.device_id
    )

select *
from final