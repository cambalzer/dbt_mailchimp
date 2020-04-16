with base as (

    select *
    from {{ var('campaign_recipient_activity')}}

), fields as (

    select 
        "action" as action_type,
        campaign_id,
        member_id,
        list_id,
        timestamp as activity_timestamp,
        ip as ip_address,
        url
    from base

), unique_key as (

    select 
        *, 
        {{ dbt_utils.surrogate_key(['action_type', 'campaign_id', 'member_id', 'activity_timestamp']) }} as id
    from fields

)

select *
from unique_key