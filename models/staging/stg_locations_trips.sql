{{ config(materialized='view') }}

with trips_zones as (
    select
        cast(zone_id as integer) as location_id,
        zone_name as location_name,
        borough
    from {{ source('staging', 'taxi_zone_geom') }}
),

final as (
    select
        location_id,
        location_name,
        borough
    from trips_zones
    where location_name is not null
)

select * from final