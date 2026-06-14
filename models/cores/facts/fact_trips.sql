{{ config (materialized='view') }}

with trips as (
    select * from {{ ref('int_trips') }}
),

pickup_zone as (
    select * from {{ ref('dim_locations') }}
),

dropoff_zone as (
    select * from {{ ref('dim_locations') }}
)

select
    t.tripid,
    t.vendor_id,
    t.service_type,
    t.pickup_location_id,
    t.dropoff_location_id,
    t.pickup_datetime,
    t.dropoff_datetime,
    t.passenger_count,
    t.trip_distance,
    t.trip_duration_minutes,
    t.fare_amount,
    t.total_amount,
    t.payment_type,
    pz.location_name as pickup_location,
    pz.borough as pickup_borough,
    dz.location_name as dropoff_location,
    dz.borough as dropoff_borough
from trips t
left join pickup_zone pz
    on cast(t.pickup_location_id as integer) = cast(pz.location_id as integer)
left join dropoff_zone dz
    on cast(t.dropoff_location_id as integer) = cast(dz.location_id as integer)
