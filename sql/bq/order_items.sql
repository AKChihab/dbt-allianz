SELECT
  oi.id AS order_item_id,
  o.order_id,
  o.user_id AS customer_id,
  oi.product_id,
  o.created_at AS order_ts,
  oi.sale_price,
  oi.quantity
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.orders` o USING(order_id)
LIMIT {limit}