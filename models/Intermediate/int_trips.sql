{{ config(materialized='view') }}

with unioned as (
    select *, 'Green' as service_type from {{ ref('stg_green_trips') }}
    union all
    select *, 'Yellow' as service_type from {{ ref('stg_yellow_trips') }}
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by vendor_id,
            pickup_datetime,
            service_type,
            dropoff_datetime,
            pickup_location_id,
            dropoff_location_id,
            total_amount
            order by pickup_datetime
        ) as rn
    from unioned
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'vendor_id',
            'pickup_datetime',
            'dropoff_datetime',
            'pickup_location_id',
            'total_amount'
        ]) }} as tripid,
        *,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) as trip_duration_minutes
    from deduplicated
    where rn = 1
      and total_amount > 0
      and trip_distance > 0
)

select * from final