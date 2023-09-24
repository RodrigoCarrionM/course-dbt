select
    user_id
    ,min(created_at) as first_order_created_at
    ,max(created_at) as last_order_created_at
    ,sum(order_cost) as total_spend
    ,count(order_id) as orders
from {{ ref('stg_postgres__orders') }}
group by 1