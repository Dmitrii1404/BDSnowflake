-- измерение покупатели
CREATE TABLE dim_customers (
    customer_id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    age INT,
    country TEXT,
    postal_code TEXT,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- измерение продавцы
CREATE TABLE dim_sellers (
    seller_id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    country TEXT,
    postal_code TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- измерение поставщики
CREATE TABLE dim_suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    contact_person TEXT,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- измерение магазины
CREATE TABLE dim_stores (
    store_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- измерение категории питомцев
CREATE TABLE dim_pet_categories (
category_id SERIAL PRIMARY KEY,
name TEXT UNIQUE NOT NULL,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- измерение продукты
CREATE TABLE dim_products (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    weight NUMERIC(10,2),
    color TEXT,
    size TEXT,
    brand TEXT,
    material TEXT,
    description TEXT,
    rating NUMERIC(3,1),
    reviews_count INT,
    release_date DATE,
    expiry_date DATE,
    supplier_id INT REFERENCES dim_suppliers(supplier_id),
    pet_category_id INT REFERENCES dim_pet_categories(category_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- измерение даты
CREATE TABLE dim_dates (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name TEXT NOT NULL,
    month_name TEXT NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN DEFAULT FALSE
);

-- факт продажи
CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES dim_customers(customer_id),
    seller_id INT REFERENCES dim_sellers(seller_id),
    product_id INT REFERENCES dim_products(product_id),
    store_id INT REFERENCES dim_stores(store_id),
    date_id INT REFERENCES dim_dates(date_id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) NOT NULL,
    original_sale_id BIGINT, -- ID из исходных данных
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);