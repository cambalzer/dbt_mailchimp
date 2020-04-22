with recipients as (
    
    select *
    from {{ ref('mailchimp_campaign_recipients_adapter') }}

), activities as (

    select *
    from {{ ref('campaign_activities_by_email') }}

), unsubscribes as (

    select *
    from {{ ref('mailchimp_unsubscribes_adapter') }}

), campaigns as (

    select *
    from {{ ref('mailchimp_campaigns_adapter') }}

), joined as (

    select 
        recipients.*,
        campaigns.segment_id
    from recipients
    left join campaigns
        on recipients.campaign_id = campaigns.campaign_id

), metrics as (

    select
        joined.*,
        coalesce(activities.opens) as opens,
        coalesce(activities.unique_opens) as unique_opens,
        coalesce(activities.clicks) as clicks,
        coalesce(activities.unique_clicks) as unique_clicks,
        activities.was_opened,
        activities.was_clicked,
        activities.first_open_timestamp,
        activities.time_to_open_minutes,
        activities.time_to_open_hours,
        activities.time_to_open_days
    from joined
    left join activities
        on joined.email_id = activities.email_id

), unsubscribes_xf as (

    select 
        member_id,
        campaign_id
    from unsubscribes
    group by 1,2

), metrics_xf as (

    select 
        metrics.*,
        case when unsubscribes_xf.member_id is not null then True else False end as was_unsubscribed
    from metrics
    left join unsubscribes_xf
        on metrics.member_id = unsubscribes_xf.member_id
        and metrics.campaign_id = unsubscribes_xf.campaign_id

)

select * 
from metrics_xf