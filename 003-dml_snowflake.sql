-- Заполнение измерения: Дата
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, week_number, day_of_week, day_name, month_name, is_weekend, is_holiday)
SELECT DISTINCT
    EXTRACT(YEAR FROM TO_DATE(sale_date, 'MM/DD/YYYY')) * 10000 +
    EXTRACT(MONTH FROM TO_DATE(sale_date, 'MM/DD/YYYY')) * 100 +
    EXTRACT(DAY FROM TO_DATE(sale_date, 'MM/DD/YYYY')) AS date_id,
    TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date,
    EXTRACT(DAY FROM TO_DATE(sale_date, 'MM/DD/YYYY')) AS day,
    EXTRACT(MONTH FROM TO_DATE(sale_date, 'MM/DD/YYYY')) AS month,
    EXTRACT(YEAR FROM TO_DATE(sale_date, 'MM/DD/YYYY')) AS year,
    EXTRACT(QUARTER FROM TO_DATE(sale_date, 'MM/DD/YYYY')) AS quarter,
    EXTRACT(WEEK FROM TO_DATE(sale_date, 'MM/DD/YYYY')) AS week_number,
    EXTRACT(DOW FROM TO_DATE(sale_date, 'MM/DD/YYYY')) AS day_of_week,
    TO_CHAR(TO_DATE(sale_date, 'MM/DD/YYYY'), 'Day') AS day_name,
    TO_CHAR(TO_DATE(sale_date, 'MM/DD/YYYY'), 'Month') AS month_name,
    CASE WHEN EXTRACT(DOW FROM TO_DATE(sale_date, 'MM/DD/YYYY')) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend,
    FALSE AS is_holiday
FROM mock_data;

-- Заполнение измерения: Покупатель
INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country, postal_code)
SELECT DISTINCT
    id AS customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM mock_data;

-- Заполнение измерения: Продавец
INSERT INTO dim_seller (seller_id, first_name, last_name, email, country, postal_code)
SELECT DISTINCT
    id AS seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data;

-- Заполнение измерения: Магазин
INSERT INTO dim_store (store_id, store_name, location, city, state, country, phone, email)
SELECT DISTINCT
    MD5(store_name || store_location || store_city) AS store_id,
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
    MD5(supplier_name || supplier_contact || supplier_email) AS supplier_id,
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
    MD5(product_category) AS category_id,
    product_category,
    NULL AS parent_category_id
FROM mock_data;

-- Заполнение измерения: Бренд продукта
INSERT INTO dim_brand (brand_id, brand_name)
SELECT DISTINCT
    MD5(product_brand) AS brand_id,
    product_brand
FROM mock_data
WHERE product_brand IS NOT NULL AND product_brand != '';

-- Заполнение измерения: Размер продукта
INSERT INTO dim_size (size_id, size_name)
SELECT DISTINCT
    MD5(product_size) AS size_id,
    product_size
FROM mock_data
WHERE product_size IS NOT NULL AND product_size != '';

-- Заполнение измерения: Цвет продукта
INSERT INTO dim_color (color_id, color_name)
SELECT DISTINCT
    MD5(product_color) AS color_id,
    product_color
FROM mock_data
WHERE product_color IS NOT NULL AND product_color != '';

-- Заполнение измерения: Материал продукта
INSERT INTO dim_material (material_id, material_name)
SELECT DISTINCT
    MD5(product_material) AS material_id,
    product_material
FROM mock_data
WHERE product_material IS NOT NULL AND product_material != '';

-- Заполнение измерения: Тип питомца
INSERT INTO dim_pet_type (pet_type_id, pet_type_name)
SELECT DISTINCT
    MD5(customer_pet_type) AS pet_type_id,
    customer_pet_type
FROM mock_data;

-- Заполнение измерения: Порода питомца
INSERT INTO dim_pet_breed (pet_breed_id, pet_breed_name, pet_type_id)
SELECT DISTINCT
    MD5(customer_pet_breed) AS pet_breed_id,
    customer_pet_breed,
    MD5(customer_pet_type) AS pet_type_id
FROM mock_data;

-- Заполнение измерения: Категория питомца
INSERT INTO dim_pet_category (pet_category_id, pet_category_name)
SELECT DISTINCT
    MD5(pet_category) AS pet_category_id,
    pet_category
FROM mock_data;

-- Заполнение измерения: Продукт
INSERT INTO dim_product (
    product_id, product_name, category_id, brand_id, size_id, color_id, 
    material_id, weight, description, rating, reviews_count, release_date, expiry_date
)
SELECT DISTINCT
    id AS product_id,
    product_name,
    (SELECT category_id FROM dim_product_category WHERE category_name = mock_data.product_category LIMIT 1) AS category_id,
    (SELECT brand_id FROM dim_brand WHERE brand_name = mock_data.product_brand LIMIT 1) AS brand_id,
    (SELECT size_id FROM dim_size WHERE size_name = mock_data.product_size LIMIT 1) AS size_id,
    (SELECT color_id FROM dim_color WHERE color_name = mock_data.product_color LIMIT 1) AS color_id,
    (SELECT material_id FROM dim_material WHERE material_name = mock_data.product_material LIMIT 1) AS material_id,
    product_weight,
    product_description,
    product_rating,
    product_reviews,
    TO_DATE(product_release_date, 'MM/DD/YYYY') AS release_date,
    TO_DATE(product_expiry_date, 'MM/DD/YYYY') AS expiry_date
FROM mock_data;

-- Заполнение фактов
INSERT INTO fact_sales (
    sale_id, sale_date_id, customer_id, seller_id, store_id, product_id,
    supplier_id, pet_type_id, pet_breed_id, pet_category_id,
    quantity, unit_price, total_price, sale_quantity
)
SELECT
    MD5(
        mock_data.id || 
        mock_data.sale_date || 
        mock_data.sale_customer_id || 
        mock_data.sale_seller_id || 
        mock_data.sale_product_id
    ) AS sale_id,
    EXTRACT(YEAR FROM TO_DATE(mock_data.sale_date, 'MM/DD/YYYY')) * 10000 +
    EXTRACT(MONTH FROM TO_DATE(mock_data.sale_date, 'MM/DD/YYYY')) * 100 +
    EXTRACT(DAY FROM TO_DATE(mock_data.sale_date, 'MM/DD/YYYY')) AS sale_date_id,
    mock_data.sale_customer_id AS customer_id,
    mock_data.sale_seller_id AS seller_id,
    (SELECT MD5(store_name || store_location || store_city) FROM mock_data m2 
     WHERE m2.id = mock_data.id LIMIT 1) AS store_id,
    mock_data.sale_product_id AS product_id,
    (SELECT MD5(supplier_name || supplier_contact || supplier_email) FROM mock_data m3 
     WHERE m3.id = mock_data.id LIMIT 1) AS supplier_id,
    (SELECT MD5(customer_pet_type) FROM mock_data m4 
     WHERE m4.id = mock_data.id LIMIT 1) AS pet_type_id,
    (SELECT MD5(customer_pet_breed) FROM mock_data m5 
     WHERE m5.id = mock_data.id LIMIT 1) AS pet_breed_id,
    (SELECT MD5(pet_category) FROM mock_data m6 
     WHERE m6.id = mock_data.id LIMIT 1) AS pet_category_id,
    mock_data.product_quantity AS quantity,
    mock_data.product_price AS unit_price,
    mock_data.sale_total_price AS total_price,
    mock_data.sale_quantity AS sale_quantity
FROM mock_data;
