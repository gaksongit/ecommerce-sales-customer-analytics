CREATE TABLE IF NOT EXISTS customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(200),
    country varchar(100),
    city varchar(100),
    signup_date date
);

CREATE TABLE IF NOT EXISTS categories (
    category_id integer PRIMARY KEY,
    category_name varchar(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    product_id integer PRIMARY KEY,
    product_name varchar(100) NOT NULL,
    category_id integer NOT NULL REFERENCES categories(category_id),
    price numeric(12, 2) NOT NULL,
    cost numeric(12, 2) NOT NULL,
    stock_quantity integer NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    order_id integer PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES customers(customer_id),
    order_date date NOT NULL,
    order_status varchar(30) NOT NULL,
    payment_method varchar(50) NOT NULL,
    shipping_country varchar(100),
    shipping_city varchar(100)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id integer PRIMARY KEY,
    order_id integer NOT NULL REFERENCES orders(order_id),
    product_id integer NOT NULL REFERENCES products(product_id),
    quantity integer NOT NULL,
    unit_price numeric(12, 2) NOT NULL,
    discount_pct integer NOT NULL
);
