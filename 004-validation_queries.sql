-- 1.1. Проверка общего количества строк в исходной таблице (должно быть 10000)
SELECT 
    'mock_data' AS table_name,
    COUNT(*) AS row_count,
    CASE WHEN COUNT(*) = 10000 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM mock_data;

-- 1.2. Проверка количества записей в таблице фактов (должно совпадать с mock_data)
SELECT 
    'fact_sales' AS table_name,
    COUNT(*) AS row_count,
    CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM mock_data) THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales;

-- 1.3. Проверка количества уникальных покупателей
SELECT 
    'dim_customer' AS table_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id) AS unique_ids,
    CASE WHEN COUNT(*) = COUNT(DISTINCT customer_id) THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM dim_customer;

-- 1.4. Проверка количества уникальных продавцов
SELECT 
    'dim_seller' AS table_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT seller_id) AS unique_ids,
    CASE WHEN COUNT(*) = COUNT(DISTINCT seller_id) THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM dim_seller;

-- 1.5. Проверка количества уникальных продуктов
SELECT 
    'dim_product' AS table_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT product_id) AS unique_ids,
    CASE WHEN COUNT(*) = COUNT(DISTINCT product_id) THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM dim_product;

-- 1.6. Проверка количества записей в dim_date
SELECT 
    'dim_date' AS table_name,
    COUNT(*) AS row_count,
    CASE WHEN COUNT(*) > 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM dim_date;

-- 2.1. Проверка: все sale_date_id из fact_sales существуют в dim_date
SELECT 
    'fact_sales → dim_date (date_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_date d ON f.sale_date_id = d.date_id
WHERE d.date_id IS NULL;

-- 2.2. Проверка: все customer_id из fact_sales существуют в dim_customer
SELECT 
    'fact_sales → dim_customer (customer_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 2.3. Проверка: все seller_id из fact_sales существуют в dim_seller
SELECT 
    'fact_sales → dim_seller (seller_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_seller s ON f.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 2.4. Проверка: все product_id из fact_sales существуют в dim_product
SELECT 
    'fact_sales → dim_product (product_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_product p ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 2.5. Проверка: все store_id из fact_sales существуют в dim_store
SELECT 
    'fact_sales → dim_store (store_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_store s ON f.store_id = s.store_id
WHERE s.store_id IS NULL;

-- 2.6. Проверка: все supplier_id из fact_sales существуют в dim_supplier
SELECT 
    'fact_sales → dim_supplier (supplier_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_supplier s ON f.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;

-- 2.7. Проверка: все pet_type_id из fact_sales существуют в dim_pet_type
SELECT 
    'fact_sales → dim_pet_type (pet_type_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_pet_type pt ON f.pet_type_id = pt.pet_type_id
WHERE pt.pet_type_id IS NULL;

-- 2.8. Проверка: все pet_breed_id из fact_sales существуют в dim_pet_breed
SELECT 
    'fact_sales → dim_pet_breed (pet_breed_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_pet_breed pb ON f.pet_breed_id = pb.pet_breed_id
WHERE pb.pet_breed_id IS NULL;

-- 2.9. Проверка: все pet_category_id из fact_sales существуют в dim_pet_category
SELECT 
    'fact_sales → dim_pet_category (pet_category_id)' AS relationship,
    COUNT(*) AS orphan_records,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM fact_sales f
LEFT JOIN dim_pet_category pc ON f.pet_category_id = pc.pet_category_id
WHERE pc.pet_category_id IS NULL;

-- 3.1. Проверка: сумма total_price в fact_sales должна совпадать с суммой из mock_data
SELECT 
    'Total price sum match' AS check_name,
    (SELECT SUM(total_price) FROM fact_sales) AS fact_sales_sum,
    (SELECT SUM(sale_total_price) FROM mock_data) AS mock_data_sum,
    CASE 
        WHEN ABS((SELECT SUM(total_price) FROM fact_sales) - (SELECT SUM(sale_total_price) FROM mock_data)) < 0.01 
        THEN '✓ PASS' 
        ELSE '✗ FAIL' 
    END AS status;

-- 3.2. Проверка: сумма sale_quantity в fact_sales должна совпадать с суммой product_quantity из mock_data
SELECT 
    'Quantity sum match' AS check_name,
    (SELECT SUM(sale_quantity) FROM fact_sales) AS fact_sales_sum,
    (SELECT SUM(product_quantity) FROM mock_data) AS mock_data_sum,
    CASE 
        WHEN (SELECT SUM(sale_quantity) FROM fact_sales) = (SELECT SUM(product_quantity) FROM mock_data)
        THEN '✓ PASS' 
        ELSE '✗ FAIL' 
    END AS status;

-- 3.3. Проверка: диапазон дат в fact_sales и dim_date должен совпадать
SELECT 
    'Date range match' AS check_name,
    (SELECT MIN(full_date) FROM dim_date) AS min_date_dim,
    (SELECT MAX(full_date) FROM dim_date) AS max_date_dim,
    CASE 
        WHEN (SELECT MIN(full_date) FROM dim_date) IS NOT NULL 
         AND (SELECT MAX(full_date) FROM dim_date) IS NOT NULL
        THEN '✓ PASS' 
        ELSE '✗ FAIL' 
    END AS status
FROM fact_sales;

-- 4.1. Проверка дубликатов в dim_customer (по email)
SELECT 
    'dim_customer: duplicate emails' AS check_name,
    COUNT(*) AS duplicate_count,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM (
    SELECT customer_email, COUNT(*) as cnt
    FROM dim_customer
    GROUP BY customer_email
    HAVING COUNT(*) > 1
) duplicates;

-- 4.2. Проверка дубликатов в dim_seller (по email)
SELECT 
    'dim_seller: duplicate emails' AS check_name,
    COUNT(*) AS duplicate_count,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM (
    SELECT email, COUNT(*) as cnt
    FROM dim_seller
    GROUP BY email
    HAVING COUNT(*) > 1
) duplicates;

-- 4.3. Проверка дубликатов в dim_brand (по brand_name)
SELECT 
    'dim_brand: duplicate names' AS check_name,
    COUNT(*) AS duplicate_count,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM (
    SELECT brand_name, COUNT(*) as cnt
    FROM dim_brand
    GROUP BY brand_name
    HAVING COUNT(*) > 1
) duplicates;

-- 4.4. Проверка дубликатов в dim_product (по product_name)
SELECT 
    'dim_product: duplicate names' AS check_name,
    COUNT(*) AS duplicate_count,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM (
    SELECT product_name, COUNT(*) as cnt
    FROM dim_product
    GROUP BY product_name
    HAVING COUNT(*) > 1
) duplicates;

-- 5.1. Проверка NULL значений в критических полях fact_sales
SELECT 
    'fact_sales: NULL checks' AS check_name,
    SUM(CASE WHEN sale_date_id IS NULL THEN 1 ELSE 0 END) AS null_date_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN total_price IS NULL THEN 1 ELSE 0 END) AS null_total_price,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    CASE 
        WHEN SUM(CASE WHEN sale_date_id IS NULL OR customer_id IS NULL OR seller_id IS NULL 
                      OR product_id IS NULL OR total_price IS NULL OR quantity IS NULL THEN 1 ELSE 0 END) = 0 
        THEN '✓ PASS' 
        ELSE '✗ FAIL' 
    END AS status
FROM fact_sales;

-- 5.2. Проверка NULL значений в критических полях dim_customer
SELECT 
    'dim_customer: NULL checks' AS check_name,
    SUM(CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS null_first_name,
    SUM(CASE WHEN last_name IS NULL THEN 1 ELSE 0 END) AS null_last_name,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country,
    CASE 
        WHEN SUM(CASE WHEN first_name IS NULL OR last_name IS NULL OR country IS NULL THEN 1 ELSE 0 END) = 0 
        THEN '✓ PASS' 
        ELSE '✗ FAIL' 
    END AS status
FROM dim_customer;

-- 5.3. Проверка NULL значений в критических полях dim_product
SELECT 
    'dim_product: NULL checks' AS check_name,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN category_id IS NULL THEN 1 ELSE 0 END) AS null_category_id,
    CASE 
        WHEN SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) = 0 
        THEN '✓ PASS' 
        ELSE '✗ FAIL' 
    END AS status
FROM dim_product;

-- 6.1. Проверка: у каждой породы питомца должен быть связан тип питомца
SELECT 
    'dim_pet_breed → dim_pet_type integrity' AS check_name,
    COUNT(*) AS orphan_breeds,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM dim_pet_breed pb
LEFT JOIN dim_pet_type pt ON pb.pet_type_id = pt.pet_type_id
WHERE pb.pet_type_id IS NULL;

-- 6.2. Проверка: у каждого продукта должна быть категория
SELECT 
    'dim_product → dim_product_category integrity' AS check_name,
    COUNT(*) AS products_without_category,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END AS status
FROM dim_product p
LEFT JOIN dim_product_category pc ON p.category_id = pc.category_id
WHERE p.category_id IS NOT NULL AND pc.category_id IS NULL;

-- 6.3. Проверка: количество уникальных категорий в продуктах
SELECT 
    'Product category coverage' AS check_name,
    (SELECT COUNT(*) FROM dim_product_category) AS category_count,
    (SELECT COUNT(DISTINCT category_id) FROM dim_product) AS used_categories,
    CASE 
        WHEN (SELECT COUNT(*) FROM dim_product_category) >= 
             (SELECT COUNT(DISTINCT category_id) FROM dim_product)
        THEN '✓ PASS' 
        ELSE '✗ FAIL' 
    END AS status;

-- Сводная таблица всех проверок
SELECT 
    '=== ИТОГОВАЯ СВОДКА ===' AS summary,
    (SELECT COUNT(*) FROM mock_data) AS mock_data_rows,
    (SELECT COUNT(*) FROM fact_sales) AS fact_sales_rows,
    (SELECT COUNT(*) FROM dim_customer) AS dim_customer_rows,
    (SELECT COUNT(*) FROM dim_seller) AS dim_seller_rows,
    (SELECT COUNT(*) FROM dim_product) AS dim_product_rows,
    (SELECT COUNT(*) FROM dim_date) AS dim_date_rows,
    (SELECT COUNT(*) FROM dim_store) AS dim_store_rows,
    (SELECT COUNT(*) FROM dim_supplier) AS dim_supplier_rows,
    CASE 
        WHEN (SELECT COUNT(*) FROM mock_data) = (SELECT COUNT(*) FROM fact_sales)
        THEN '✓ Количество записей совпадает'
        ELSE '✗ Количество записей НЕ совпадает'
    END AS row_count_status;
