-- dim_customer
INSERT INTO dim_customer (first_name, last_name, age, email, country, postal_code, pet_type, pet_name, pet_breed)
SELECT DISTINCT ON (customer_email)
    customer_first_name, customer_last_name, customer_age, customer_email,
    customer_country, customer_postal_code, customer_pet_type, customer_pet_name, customer_pet_breed
FROM mock_data
WHERE customer_email IS NOT NULL
ORDER BY customer_email, id;

-- dim_seller
INSERT INTO dim_seller (first_name, last_name, email, country, postal_code)
SELECT DISTINCT ON (seller_email)
    seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code
FROM mock_data
WHERE seller_email IS NOT NULL
ORDER BY seller_email, id;

-- dim_supplier
INSERT INTO dim_supplier (supplier_name, contact_person, email, phone, address, city, country)
SELECT DISTINCT
    supplier_name, supplier_contact, supplier_email, supplier_phone,
    supplier_address, supplier_city, supplier_country
FROM mock_data
WHERE supplier_name IS NOT NULL;

-- dim_store
INSERT INTO dim_store (store_name, location, city, state, country, phone, email)
SELECT DISTINCT ON (store_name)
    store_name, store_location, store_city, store_state, store_country,
    store_phone, store_email
FROM mock_data
WHERE store_name IS NOT NULL
ORDER BY store_name, id;

-- dim_product
INSERT INTO dim_product (
    product_name, product_category, pet_category, product_price,
    product_weight, product_color, product_size, product_brand,
    product_material
)
SELECT DISTINCT ON (product_name, product_price)
    product_name, product_category, pet_category, product_price,
    product_weight, product_color, product_size, product_brand,
    product_material
FROM mock_data
WHERE product_name IS NOT NULL
ORDER BY product_name, product_price, id;

-- dim_date
INSERT INTO dim_date (full_date, year, month, day, quarter, weekday, is_weekend)
SELECT DISTINCT
    sale_date::DATE,
    EXTRACT(YEAR FROM sale_date::DATE),
    EXTRACT(MONTH FROM sale_date::DATE),
    EXTRACT(DAY FROM sale_date::DATE),
    EXTRACT(QUARTER FROM sale_date::DATE),
    TO_CHAR(sale_date::DATE, 'Day'),
    CASE WHEN EXTRACT(DOW FROM sale_date::DATE) IN (0,6) THEN TRUE ELSE FALSE END
FROM mock_data
WHERE sale_date IS NOT NULL AND sale_date <> '';

-- fact_sales
ALTER TABLE fact_sales DISABLE TRIGGER ALL;
INSERT INTO fact_sales (customer_id, seller_id, product_id, store_id, date_id, sale_quantity, sale_total_price, original_sale_date)
SELECT 
    c.customer_id,
    s.seller_id,
    pr.product_id,
    st.store_id,
    d.date_id,
    md.sale_quantity,
    md.sale_total_price,
    md.sale_date::DATE
FROM mock_data md
JOIN dim_customer c ON c.email = md.customer_email
JOIN dim_seller s ON s.email = md.seller_email
JOIN dim_product pr ON pr.product_name = md.product_name AND pr.product_price = md.product_price
JOIN dim_store st ON st.store_name = md.store_name
JOIN dim_date d ON d.full_date = md.sale_date::DATE;
ALTER TABLE fact_sales ENABLE TRIGGER ALL;

SELECT 'Заполнение снежинки завершено' AS status;
SELECT 'fact_sales rows:' as info, COUNT(*) FROM fact_sales;