-- 1. Общие продажи по годам
SELECT 
    d.year,
    COUNT(f.sale_id) AS total_sales,
    SUM(f.total_price) AS total_revenue,
    AVG(f.total_price) AS avg_sale_amount
FROM fact_sales f
JOIN dim_date d ON f.sale_date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;

-- 2. Топ-10 покупателей по сумме покупок
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.country,
    COUNT(f.sale_id) AS purchase_count,
    SUM(f.total_price) AS total_spent
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Продажи по категориям продуктов
SELECT 
    pc.category_name,
    COUNT(f.sale_id) AS sales_count,
    SUM(f.total_price) AS total_revenue,
    AVG(f.quantity) AS avg_quantity
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_product_category pc ON p.category_id = pc.category_id
GROUP BY pc.category_name
ORDER BY total_revenue DESC;

-- 4. Продажи по магазинам
SELECT 
    s.store_name,
    s.city,
    s.country,
    COUNT(f.sale_id) AS sales_count,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.store_name, s.city, s.country
ORDER BY total_revenue DESC;

-- 5. Продажи по типам питомцев
SELECT 
    pt.pet_type_name,
    COUNT(f.sale_id) AS sales_count,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_pet_type pt ON f.pet_type_id = pt.pet_type_id
GROUP BY pt.pet_type_name
ORDER BY total_revenue DESC;

-- 6. Топ-10 продавцов по выручке
SELECT 
    s.seller_id,
    s.first_name || ' ' || s.last_name AS seller_name,
    s.country,
    COUNT(f.sale_id) AS sales_count,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_seller s ON f.seller_id = s.seller_id
GROUP BY s.seller_id, s.first_name, s.last_name, s.country
ORDER BY total_revenue DESC
LIMIT 10;

-- 7. Продажи по брендам
SELECT 
    b.brand_name,
    COUNT(f.sale_id) AS sales_count,
    SUM(f.total_price) AS total_revenue,
    AVG(p.rating) AS avg_rating
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_brand b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY total_revenue DESC;

-- 8. Продажи по месяцам (тренд)
SELECT 
    d.year,
    d.month,
    d.month_name,
    COUNT(f.sale_id) AS total_sales,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.sale_date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- 9. Продажи по поставщикам
SELECT 
    sup.supplier_name,
    sup.country,
    COUNT(f.sale_id) AS sales_count,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_supplier sup ON f.supplier_id = sup.supplier_id
GROUP BY sup.supplier_name, sup.country
ORDER BY total_revenue DESC;

-- 10. Анализ по размерам продуктов
SELECT 
    sz.size_name,
    COUNT(f.sale_id) AS sales_count,
    SUM(f.total_price) AS total_revenue,
    SUM(f.quantity) AS total_units_sold
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_size sz ON p.size_id = sz.size_id
GROUP BY sz.size_name
ORDER BY total_revenue DESC;

-- 11. Продажи по странам покупателей
SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) AS unique_customers,
    COUNT(f.sale_id) AS total_sales,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;

-- 12. Продажи по кварталам
SELECT 
    d.year,
    d.quarter,
    COUNT(f.sale_id) AS total_sales,
    SUM(f.total_price) AS total_revenue,
    AVG(f.total_price) AS avg_sale_amount
FROM fact_sales f
JOIN dim_date d ON f.sale_date_id = d.date_id
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- 13. Топ-20 продуктов по продажам
SELECT 
    p.product_name,
    pc.category_name,
    b.brand_name,
    COUNT(f.sale_id) AS times_sold,
    SUM(f.sale_quantity) AS total_quantity_sold,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_product_category pc ON p.category_id = pc.category_id
LEFT JOIN dim_brand b ON p.brand_id = b.brand_id
GROUP BY p.product_name, pc.category_name, b.brand_name
ORDER BY total_revenue DESC
LIMIT 20;

-- 14. Продажи в выходные vs будние дни
SELECT 
    d.is_weekend,
    CASE WHEN d.is_weekend THEN 'Выходной' ELSE 'Будний' END AS day_type,
    COUNT(f.sale_id) AS total_sales,
    SUM(f.total_price) AS total_revenue,
    AVG(f.total_price) AS avg_sale_amount
FROM fact_sales f
JOIN dim_date d ON f.sale_date_id = d.date_id
GROUP BY d.is_weekend
ORDER BY d.is_weekend;

-- 15. Комплексный анализ продаж (OLAP-куб)
SELECT 
    d.year,
    d.quarter,
    d.month_name,
    c.country AS customer_country,
    pc.category_name,
    pt.pet_type_name,
    COUNT(f.sale_id) AS sales_count,
    SUM(f.quantity) AS total_quantity,
    SUM(f.total_price) AS total_revenue,
    AVG(f.total_price) AS avg_sale_amount
FROM fact_sales f
JOIN dim_date d ON f.sale_date_id = d.date_id
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_product_category pc ON p.category_id = pc.category_id
JOIN dim_pet_type pt ON f.pet_type_id = pt.pet_type_id
GROUP BY 
    CUBE(
        (d.year, d.quarter, d.month_name),
        (c.country),
        (pc.category_name),
        (pt.pet_type_name)
    )
ORDER BY total_revenue DESC;
