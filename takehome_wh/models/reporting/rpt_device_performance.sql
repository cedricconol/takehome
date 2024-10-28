with
    -- import CTEs
    transactions as (select * from {{ ref('fct_transactions') }}),

    devices as (select * from {{ ref('dim_devices') }}),

    -- logical CTEs
    final as (
        select
            transactions.* exclude (dbt_updated_at),
            devices.* exclude (dbt_updated_at, pk_device_id),
            {{ dbt.current_timestamp() }} as dbt_updated_at
        from transactions
        left join devices on devices.pk_device_id = transactions.device_id
    )

select *
from final