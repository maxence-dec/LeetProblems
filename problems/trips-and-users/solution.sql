with
cte_clients as(
    select
        *
    from
        Users as u
        inner join Trips as t on t.client_id = u.users_id
    where
        u.role = 'client'
        and u.banned = 'No'
        and t.status <> 'completed'
        and exists (select 1 from Users as uSub where uSub.users_id = t.driver_id and uSub.banned = 'No')
        and t.request_at between '2013-10-01'and '2013-10-03'
),
cte_drivers as(
    select
        *
    from
        Users as u
        inner join Trips as t on t.client_id = u.users_id
    where
        u.role = 'client'
        and u.banned = 'No'
        and t.status <> 'completed'
        and exists (select 1 from Users as uSub where uSub.users_id = t.client_id and uSub.banned = 'No')
        and t.request_at between '2013-10-01'and '2013-10-03'
),
cte_dates as (
    select
        t.request_at
    from
        Trips as t
    where
        t.request_at between '2013-10-01'and '2013-10-03'
    group by
        t.request_at
)

select
    cte_dates.request_at as 'Day', CAST( ROUND(count(DISTINCT temp.id) *1.00 / count(DISTINCT t.id), 2) AS FLOAT) as  'Cancellation Rate'
from
    cte_dates
    left join (
        select * from cte_clients
        union
        select * from cte_drivers
)
    as temp on cte_dates.request_at = temp.request_at
    left join Trips as t on cte_dates.request_at = t.request_at
where
    t.driver_id in (select subUsers.users_id from Users as subUsers where subUsers.banned = 'No')
    and t.client_id in (select subUsers.users_id from Users as subUsers where subUsers.banned = 'No')
group by cte_dates.request_at


-- refacto
with
cte as(
        select t.request_at, count(t.status) as totalTrip, sum(t.status<>'completed') as canceledTrip
    from
        Trips as t
        inner join Users as u on t.client_id = u.users_id or t.driver_id = u.users_id
    where
        u.role <> 'partner'
        and u.banned = 'No'
        and exists (select 1 from Users as uSub where uSub.users_id = t.client_id and uSub.banned = 'No')
        and exists (select 1 from Users as uSub where uSub.users_id = t.driver_id and uSub.banned = 'No')
        and t.request_at between '2013-10-01'and '2013-10-03'
    group by t.request_at
)
select
    cte.request_at as 'Day', ROUND( cte.canceledTrip*1.00 / cte.totalTrip, 2) as  'Cancellation Rate'
from
    cte