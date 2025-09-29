SELECT id AS product_id, name AS product_name, category, retail_price
FROM `bigquery-public-data.thelook_ecommerce.products`
LIMIT {limit}