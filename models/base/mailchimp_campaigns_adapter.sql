with base as (

    select *
    from {{ var('campaign') }}
    where _fivetran_deleted = false

), fields as (

    select 
        id as campaign_id,
        segment_id,
        create_time as create_timestamp,
        send_time as send_timestamp, 
        list_id,
        reply_to as reply_to_email,
        type as campaign_type,
        title
    from base

)

select *
from fields