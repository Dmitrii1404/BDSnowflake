-- заполнение таблицы категорий питомцев
INSERT INTO dim_pet_categories (name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL;

-- заполнение таблицы поставщиков
INSERT INTO dim_suppliers (
    name, contact_person, email, phone, address, city, country
)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data
WHERE supplier_name IS NOT NULL;

-- заполнение таблицы магазинов
INSERT INTO dim_stores (
    name, location, city, state, country, phone, email
)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data
WHERE store_name IS NOT NULL;

-- заполнение таблицы продавцов
INSERT INTO dim_sellers (
    first_name, last_name, email, country, postal_code
)
SELECT DISTINCT
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
WHERE seller_first_name IS NOT NULL;

-- заполнение таблицы покупателей
INSERT INTO dim_customers (
    first_name, last_name, email, age, country, postal_code, pet_type, pet_name, pet_breed
)
SELECT DISTINCT
    customer_first_name,
    customer_last_name,
    customer_email,
    customer_age,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM mock_data
WHERE customer_first_name IS NOT NULL;

-- заполнение таблицы продуктов
INSERT INTO dim_products (
    name, category, price, weight, color, size, brand, material,
    description, rating, reviews_count, release_date, expiry_date,
    supplier_id, pet_category_id
)
SELECT DISTINCT ON (product_name, product_category)
    m.product_name,
    m.product_category,
    m.product_price,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_brand,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    m.product_release_date,
    m.product_expiry_date,
    s.supplier_id,
    pc.category_id
FROM mock_data m
         LEFT JOIN dim_suppliers s ON
    m.supplier_name = s.name AND
    m.supplier_email = s.email
         LEFT JOIN dim_pet_categories pc ON
    m.pet_category = pc.name
WHERE m.product_name IS NOT NULL;

-- заполнение таблицы дат
INSERT INTO dim_dates (
    full_date, day, month, year, quarter, day_of_week, day_name, month_name, is_weekend
)
SELECT DISTINCT
    sale_date,
    EXTRACT(DAY FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    EXTRACT(YEAR FROM sale_date),
    EXTRACT(QUARTER FROM sale_date),
    EXTRACT(DOW FROM sale_date),
    TO_CHAR(sale_date, 'Day'),
    TO_CHAR(sale_date, 'Month'),
    EXTRACT(DOW FROM sale_date) IN (0, 6)
FROM mock_data
WHERE sale_date IS NOT NULL;

-- заполнение таблицы фактов продаж
INSERT INTO fact_sales (
    customer_id, seller_id, product_id, store_id, date_id,
    quantity, unit_price, total_price, original_sale_id
)
SELECT
    c.customer_id,
    s.seller_id,
    p.product_id,
    st.store_id,
    d.date_id,
    m.sale_quantity,
    m.product_price,
    m.sale_total_price,
    m.id
FROM mock_data m
         JOIN dim_customers c ON
    m.customer_email = c.email
         JOIN dim_sellers s ON
    m.seller_email = s.email
         JOIN dim_products p ON
    m.product_name = p.name AND
    m.product_category = p.category
         JOIN dim_stores st ON
    m.store_name = st.name AND
    m.store_email = st.email
         JOIN dim_dates d ON
    m.sale_date = d.full_date
WHERE m.sale_date IS NOT NULL;