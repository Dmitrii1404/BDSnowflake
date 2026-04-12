-- Заполнение измерения: Дата
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, week_number, day_of_week, day_name, month_name, is_weekend, is_holiday)
SELECT DISTINCT
    (EXTRACT(YEAR FROM sale_date) * 10000 +
    EXTRACT(MONTH FROM sale_date) * 100 +
    EXTRACT(DAY FROM sale_date))::INT AS date_id,
    sale_date AS full_date,
    EXTRACT(DAY FROM sale_date)::INT AS day,
    EXTRACT(MONTH FROM sale_date)::INT AS month,
    EXTRACT(YEAR FROM sale_date)::INT AS year,
    EXTRACT(QUARTER FROM sale_date)::INT AS quarter,
    EXTRACT(WEEK FROM sale_date)::INT AS week_number,
    EXTRACT(DOW FROM sale_date)::INT AS day_of_week,
    TO_CHAR(sale_date, 'Day') AS day_name,
    TO_CHAR(sale_date, 'Month') AS month_name,
    CASE WHEN EXTRACT(DOW FROM sale_date) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend,
    FALSE AS is_holiday
FROM mock_data;

-- Заполнение измерения: Покупатель
INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country, postal_code)
SELECT DISTINCT ON (sale_customer_id)
    sale_customer_id AS customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM mock_data
WHERE sale_customer_id IS NOT NULL
ORDER BY sale_customer_id, id;

-- Заполнение измерения: Продавец
INSERT INTO dim_seller (seller_id, first_name, last_name, email, country, postal_code)
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id AS seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
WHERE sale_seller_id IS NOT NULL
ORDER BY sale_seller_id, id;

-- Заполнение измерения: Магазин
INSERT INTO dim_store (store_id, store_name, location, city, state, country, phone, email)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(store_name || store_location || store_city) FROM 1 FOR 8))::bit(32)::int AS store_id,
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data;

-- Заполнение измерения: Поставщик
INSERT INTO dim_supplier (supplier_id, supplier_name, contact_person, email, phone, address, city, country)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(supplier_name || supplier_contact || supplier_email) FROM 1 FOR 8))::bit(32)::int AS supplier_id,
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data;

-- Заполнение измерения: Категория продукта
INSERT INTO dim_product_category (category_id, category_name, parent_category_id)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(product_category) FROM 1 FOR 8))::bit(32)::int AS category_id,
    product_category,
    NULL::INT AS parent_category_id
FROM mock_data;

-- Заполнение измерения: Бренд продукта
INSERT INTO dim_brand (brand_id, brand_name)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(product_brand) FROM 1 FOR 8))::bit(32)::int AS brand_id,
    product_brand
FROM mock_data
WHERE product_brand IS NOT NULL AND product_brand != '';

-- Заполнение измерения: Размер продукта
INSERT INTO dim_size (size_id, size_name)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(product_size) FROM 1 FOR 8))::bit(32)::int AS size_id,
    product_size
FROM mock_data
WHERE product_size IS NOT NULL AND product_size != '';

-- Заполнение измерения: Цвет продукта
INSERT INTO dim_color (color_id, color_name)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(product_color) FROM 1 FOR 8))::bit(32)::int AS color_id,
    product_color
FROM mock_data
WHERE product_color IS NOT NULL AND product_color != '';

-- Заполнение измерения: Материал продукта
INSERT INTO dim_material (material_id, material_name)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(product_material) FROM 1 FOR 8))::bit(32)::int AS material_id,
    product_material
FROM mock_data
WHERE product_material IS NOT NULL AND product_material != '';

-- Заполнение измерения: Тип питомца
INSERT INTO dim_pet_type (pet_type_id, pet_type_name)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(customer_pet_type) FROM 1 FOR 8))::bit(32)::int AS pet_type_id,
    customer_pet_type
FROM mock_data;

-- Заполнение измерения: Порода питомца
INSERT INTO dim_pet_breed (pet_breed_id, pet_breed_name, pet_type_id)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(customer_pet_breed) FROM 1 FOR 8))::bit(32)::int AS pet_breed_id,
    customer_pet_breed,
    ('x' || SUBSTRING(MD5(customer_pet_type) FROM 1 FOR 8))::bit(32)::int AS pet_type_id
FROM mock_data;

-- Заполнение измерения: Категория питомца
INSERT INTO dim_pet_category (pet_category_id, pet_category_name)
SELECT DISTINCT
    ('x' || SUBSTRING(MD5(pet_category) FROM 1 FOR 8))::bit(32)::int AS pet_category_id,
    pet_category
FROM mock_data;

-- Заполнение измерения: Продукт
INSERT INTO dim_product (
    product_id, product_name, category_id, brand_id, size_id, color_id, 
    material_id, weight, description, rating, reviews_count, release_date, expiry_date
)
SELECT DISTINCT ON (sale_product_id)
    sale_product_id AS product_id,
    product_name,
    (SELECT category_id FROM dim_product_category WHERE category_name = m.product_category LIMIT 1) AS category_id,
    (SELECT brand_id FROM dim_brand WHERE brand_name = m.product_brand LIMIT 1) AS brand_id,
    (SELECT size_id FROM dim_size WHERE size_name = m.product_size LIMIT 1) AS size_id,
    (SELECT color_id FROM dim_color WHERE color_name = m.product_color LIMIT 1) AS color_id,
    (SELECT material_id FROM dim_material WHERE material_name = m.product_material LIMIT 1) AS material_id,
    product_weight,
    product_description,
    product_rating,
    product_reviews,
    product_release_date AS release_date,
    product_expiry_date AS expiry_date
FROM mock_data m
WHERE sale_product_id IS NOT NULL
ORDER BY sale_product_id, id;

-- Заполнение фактов
INSERT INTO fact_sales (
    sale_id, sale_date_id, customer_id, seller_id, store_id, product_id,
    supplier_id, pet_type_id, pet_breed_id, pet_category_id,
    quantity, unit_price, total_price, sale_quantity
)
SELECT
    ('x' || SUBSTRING(MD5(
        mock_data.id::TEXT || 
        mock_data.sale_date::TEXT || 
        mock_data.sale_customer_id::TEXT || 
        mock_data.sale_seller_id::TEXT || 
        mock_data.sale_product_id::TEXT
    ) FROM 1 FOR 8))::bit(32)::bigint AS sale_id,
    (EXTRACT(YEAR FROM mock_data.sale_date) * 10000 +
    EXTRACT(MONTH FROM mock_data.sale_date) * 100 +
    EXTRACT(DAY FROM mock_data.sale_date))::INT AS sale_date_id,
    mock_data.sale_customer_id AS customer_id,
    mock_data.sale_seller_id AS seller_id,
    ('x' || SUBSTRING(MD5(mock_data.store_name || mock_data.store_location || mock_data.store_city) FROM 1 FOR 8))::bit(32)::int AS store_id,
    mock_data.sale_product_id AS product_id,
    ('x' || SUBSTRING(MD5(mock_data.supplier_name || mock_data.supplier_contact || mock_data.supplier_email) FROM 1 FOR 8))::bit(32)::int AS supplier_id,
    ('x' || SUBSTRING(MD5(mock_data.customer_pet_type) FROM 1 FOR 8))::bit(32)::int AS pet_type_id,
    ('x' || SUBSTRING(MD5(mock_data.customer_pet_breed) FROM 1 FOR 8))::bit(32)::int AS pet_breed_id,
    ('x' || SUBSTRING(MD5(mock_data.pet_category) FROM 1 FOR 8))::bit(32)::int AS pet_category_id,
    mock_data.product_quantity AS quantity,
    mock_data.product_price AS unit_price,
    mock_data.sale_total_price AS total_price,
    mock_data.sale_quantity AS sale_quantity
FROM mock_data;
