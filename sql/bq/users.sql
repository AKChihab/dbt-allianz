SELECT user_id, first_name, last_name, email, created_at
FROM `bigquery-public-data.thelook_ecommerce.users`
LIMIT {limit}