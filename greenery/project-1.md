1. How many users do we have?

Answer: 130 users

SQL:
```
select 
    count(distinct user_id) as number_of_users
from dev_db.dbt_rodrigocarrionaudibenede.stg_postgres__users
```


2. How many hourly orders do we have on average?

Answer: 7.5 hourly orders

SQL:
```
with clean_orders as (
    select 
        order_id
        , created_at
        , hour(created_at) as created_hour
        , created_at::date as created_date
        , concat(created_date,concat('-',created_hour)) as created_date_hour
    from dev_db.dbt_rodrigocarrionaudibenede.stg_postgres__orders
    ),

hourly_orders as (
    select 
        created_date_hour
        , count(distinct order_id) as orders
    from clean_orders
    group by created_date_hour
    order by created_date_hour
    ),

hourly_average as (
    select
        avg(orders) as avg_hourly_orders
    from hourly_orders
    )

select * from hourly_average;
```


3. How long does it take an order from placing to delivery on average?

Answer: 3.89 days, or 93.4 hours, or 5604 minutes on average from placing to delivery

SQL:
```
with delivered_orders as (
    select 
        order_id
        , created_at
        , delivered_at
        , order_status
        , timestampdiff('minute',created_at,delivered_at)   as delivery_time_min
        , timestampdiff('hour',created_at,delivered_at)     as delivery_time_hour
        , timestampdiff('day',created_at,delivered_at)      as delivery_time_day
    from dev_db.dbt_rodrigocarrionaudibenede.stg_postgres__orders
    where order_status = 'delivered'
    ),

avg_time_to_delivery as (
    select 
        avg(delivery_time_min)     as avg_mins_to_delivery
        ,avg(delivery_time_hour)   as avg_hours_to_delivery
        ,avg(delivery_time_day)    as avg_days_to_delivery
    from delivered_orders
)
    
select * from avg_time_to_delivery;
```


4. How many users have only made one, two, or three more purchases?

Answer: 

SQL: 25 with one purchase, 28 with two purchases and 71 with 3 or more purchases.
```
with joined as(
    select 
        users.user_id
        ,orders.order_id
    from dev_db.dbt_rodrigocarrionaudibenede.stg_postgres__users as users
    left join dev_db.dbt_rodrigocarrionaudibenede.stg_postgres__orders as orders
    on users.user_id = orders.user_id
    order by user_id),

grouped as (
    select
        user_id,
        count(distinct order_id) as orders_per_user
    from joined
    group by user_id
    order by orders_per_user
),

buckets as (
    select
        count(distinct case when orders_per_user = 1 then user_id end) as users_with_one_purchase
        ,count(distinct case when orders_per_user = 2 then user_id end) as users_with_two_purchases
        ,count(distinct case when orders_per_user >= 3 then user_id end) as users_with_three_purchases_or_more
    from grouped
)
    
select * from buckets;
```

5. How many unique sessions do we have on average per hour?

Answer: 16.32 average unique sessions per hour

SQL:
```
with clean_events as (
    select 
        session_id
        ,created_at
        , hour(created_at) as created_hour
        , created_at::date as created_date
        , concat(created_date,concat('-',created_hour)) as created_date_hour
    from dev_db.dbt_rodrigocarrionaudibenede.stg_postgres__events),

hourly_sessions as (
    select 
        created_date_hour
        ,count(distinct session_id) as hourly_sessions
    from clean_events
    group by created_date_hour
),

hourly_avg as (
    select
        avg(hourly_sessions) as avg_hourly_sessions
    from hourly_sessions
)
    
select * from hourly_avg
```