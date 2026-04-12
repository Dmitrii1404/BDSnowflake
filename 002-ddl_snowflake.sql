-- DDL скрипты для модели данных "Снежинка" (Snowflake Schema)

-- Измерение: Дата
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    week_number INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name TEXT NOT NULL,
    month_name TEXT NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN DEFAULT FALSE
);

-- Измерение: Покупатель
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INT,
    email TEXT,
    country TEXT NOT NULL,
    postal_code TEXT
);

-- Измерение: Продавец
CREATE TABLE dim_seller (
    seller_id INT PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL,
    country TEXT NOT NULL,
    postal_code TEXT
);

-- Измерение: Магазин
CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_name TEXT NOT NULL,
    location TEXT,
    city TEXT,
    state TEXT,
    country TEXT NOT NULL,
    phone TEXT,
    email TEXT
);

-- Измерение: Поставщик
CREATE TABLE dim_supplier (
    supplier_id INT PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT NOT NULL
);

-- Измерение: Категория продукта
CREATE TABLE dim_product_category (
    category_id INT PRIMARY KEY,
    category_name TEXT NOT NULL,
    parent_category_id INT REFERENCES dim_product_category(category_id)
);

-- Измерение: Бренд продукта
CREATE TABLE dim_brand (
    brand_id INT PRIMARY KEY,
    brand_name TEXT NOT NULL UNIQUE
);

-- Измерение: Размер продукта
CREATE TABLE dim_size (
    size_id INT PRIMARY KEY,
    size_name TEXT NOT NULL UNIQUE
);

-- Измерение: Цвет продукта
CREATE TABLE dim_color (
    color_id INT PRIMARY KEY,
    color_name TEXT NOT NULL UNIQUE
);

-- Измерение: Материал продукта
CREATE TABLE dim_material (
    material_id INT PRIMARY KEY,
    material_name TEXT NOT NULL UNIQUE
);

-- Измерение: Тип питомца
CREATE TABLE dim_pet_type (
    pet_type_id INT PRIMARY KEY,
    pet_type_name TEXT NOT NULL UNIQUE
);

-- Измерение: Порода питомца
CREATE TABLE dim_pet_breed (
    pet_breed_id INT PRIMARY KEY,
    pet_breed_name TEXT NOT NULL,
    pet_type_id INT REFERENCES dim_pet_type(pet_type_id)
);

-- Измерение: Категория питомца
CREATE TABLE dim_pet_category (
    pet_category_id INT PRIMARY KEY,
    pet_category_name TEXT NOT NULL UNIQUE
);

-- Измерение: Продукт (нормализованное)
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INT REFERENCES dim_product_category(category_id),
    brand_id INT REFERENCES dim_brand(brand_id),
    size_id INT REFERENCES dim_size(size_id),
    color_id INT REFERENCES dim_color(color_id),
    material_id INT REFERENCES dim_material(material_id),
    weight DECIMAL,
    description TEXT,
    rating DECIMAL,
    reviews_count INT,
    release_date DATE,
    expiry_date DATE
);

-- Таблица фактов
CREATE TABLE fact_sales (
    sale_id BIGINT PRIMARY KEY,
    sale_date_id INT REFERENCES dim_date(date_id),
    customer_id INT REFERENCES dim_customer(customer_id),
    seller_id INT REFERENCES dim_seller(seller_id),
    store_id INT REFERENCES dim_store(store_id),
    product_id INT REFERENCES dim_product(product_id),
    supplier_id INT REFERENCES dim_supplier(supplier_id),
    pet_type_id INT REFERENCES dim_pet_type(pet_type_id),
    pet_breed_id INT REFERENCES dim_pet_breed(pet_breed_id),
    pet_category_id INT REFERENCES dim_pet_category(pet_category_id),
    quantity INT NOT NULL,
    unit_price DECIMAL NOT NULL,
    total_price DECIMAL NOT NULL,
    sale_quantity INT NOT NULL
);

CREATE INDEX idx_fact_sales_date ON fact_sales(sale_date_id);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_sales_seller ON fact_sales(seller_id);
CREATE INDEX idx_fact_sales_store ON fact_sales(store_id);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_id);
CREATE INDEX idx_fact_sales_supplier ON fact_sales(supplier_id);
