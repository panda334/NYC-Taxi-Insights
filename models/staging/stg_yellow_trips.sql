{{ config(materialized='view') }}

{% set cols = ' vendor_id,
        pickup_datetime,
        dropoff_datetime,
        passenger_count,
        trip_distance,
        rate_code,
        store_and_fwd_flag,
        pickup_location_id,
        dropoff_location_id,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        imp_surcharge,
        total_amount' %}

with trips_union as (
    select {{ cols }} from {{ source('staging', 'tlc_yellow_trips_2020') }}
    union all
    select {{ cols }} from {{ source('staging', 'tlc_yellow_trips_2021') }}
    union all
    select {{ cols }} from {{ source('staging', 'tlc_yellow_trips_2022') }}
    union all
    select {{ cols }} from {{ source('staging', 'tlc_yellow_trips_2023') }}
),
final as (
  select
    * except(rate_code),
    rate_code as rate_code_id
  from trips_union
  where vendor_id is not null
)

select * from final 