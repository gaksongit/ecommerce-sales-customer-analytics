import os
import random
from datetime import date
from pathlib import Path
import pandas as pd
import numpy as np

from dotenv import load_dotenv
from sqlalchemy import create_engine, URL
from sqlalchemy import text
from faker import Faker


# -----------------------------
# SETTINGS
# -----------------------------

fake = Faker()

random.seed(42)
np.random.seed(42)
Faker.seed(42)

# Freeze the observation window so reruns do not change the results over time.
AS_OF_DATE = date(2026, 9, 27)

load_dotenv()

db_password = os.getenv("DB_PASSWORD")

url = URL.create(
    "postgresql+psycopg2",
    username="postgres",
    password=db_password,
    host="localhost",
    port=5432,
    database="ecommerce_analytics"
)

engine = create_engine(url)

with engine.connect() as connection:
    print("PostgreSQL connection successful!")


# -----------------------------
# CUSTOMERS
# -----------------------------

num_customers = 5000

customers = []

for customer_id in range(1, num_customers + 1):
    first_name = fake.first_name()
    last_name = fake.last_name()

    customers.append({
        "customer_id": customer_id,
        "first_name": first_name,
        "last_name": last_name,
        "email": f"{first_name.lower()}.{last_name.lower()}.{customer_id}@example.com",
        "country": fake.country(),
        "city": fake.city(),
        "signup_date": fake.date_between(
            start_date=date(2021, 9, 27),
            end_date=AS_OF_DATE
        )
    })

customers_df = pd.DataFrame(customers)


# -----------------------------
# CATEGORIES
# -----------------------------

categories = [
    "Electronics",
    "Home & Kitchen",
    "Sports",
    "Books",
    "Beauty",
    "Clothing",
    "Toys",
    "Office Supplies"
]

categories_df = pd.DataFrame({
    "category_id": range(1, len(categories) + 1),
    "category_name": categories
})


# -----------------------------
# PRODUCTS
# -----------------------------

num_products = 250

products = []

for product_id in range(1, num_products + 1):
    category_id = random.randint(1, len(categories))

    price = round(random.uniform(10, 500), 2)
    cost = round(price * random.uniform(0.45, 0.80), 2)

    products.append({
        "product_id": product_id,
        "product_name": f"Product {product_id}",
        "category_id": category_id,
        "price": price,
        "cost": cost,
        "stock_quantity": random.randint(0, 500)
    })

products_df = pd.DataFrame(products)


# -----------------------------
# ORDERS
# -----------------------------

num_orders = 20000

orders = []

for order_id in range(1, num_orders + 1):
    customer_id = random.randint(1, num_customers)

    orders.append({
        "order_id": order_id,
        "customer_id": customer_id,
        "order_date": fake.date_between(
            start_date=date(2022, 9, 27),
            end_date=AS_OF_DATE
        ),
        "order_status": random.choice(
            [
                "Completed",
                "Completed",
                "Completed",
                "Shipped",
                "Cancelled",
                "Returned"
            ]
        ),
        "payment_method": random.choice(
            [
                "Credit Card",
                "PayPal",
                "Bank Transfer",
                "Cash on Delivery"
            ]
        ),
        "shipping_country": fake.country(),
        "shipping_city": fake.city()
    })

orders_df = pd.DataFrame(orders)


# -----------------------------
# ORDER ITEMS
# -----------------------------

order_items = []
order_item_id = 1

for order_id in range(1, num_orders + 1):

    items_in_order = random.randint(1, 5)

    selected_products = random.sample(
        range(1, num_products + 1),
        items_in_order
    )

    for product_id in selected_products:

        product_row = products_df.loc[
            products_df["product_id"] == product_id
        ].iloc[0]

        quantity = random.randint(1, 4)

        discount_pct = random.choice(
            [0, 0, 0, 5, 10, 15, 20]
        )

        order_items.append({
            "order_item_id": order_item_id,
            "order_id": order_id,
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": product_row["price"],
            "discount_pct": discount_pct
        })

        order_item_id += 1

order_items_df = pd.DataFrame(order_items)


# -----------------------------
# CHECK DATA
# -----------------------------

print("\nCustomers:", len(customers_df))
print("Categories:", len(categories_df))
print("Products:", len(products_df))
print("Orders:", len(orders_df))
print("Order items:", len(order_items_df))


# -----------------------------
# CHECK TEXT LENGTHS
# -----------------------------

print("\nMaximum text lengths in customers:")

for col in ["first_name", "last_name", "country", "city"]:
    max_len = customers_df[col].astype(str).str.len().max()

    longest_value = customers_df.loc[
        customers_df[col].astype(str).str.len().idxmax(),
        col
    ]

    print(col, max_len, longest_value)

schema_path = Path(__file__).with_name("schema.sql")
statements = [statement.strip() for statement in schema_path.read_text().split(";") if statement.strip()]

with engine.begin() as conn:
    for statement in statements:
        conn.execute(text(statement))

    table_names = ["customers", "categories", "products", "orders", "order_items"]
    if any(conn.execute(text(f"SELECT COUNT(*) FROM {name}")).scalar_one() for name in table_names):
        raise RuntimeError("Database already contains data. Use an empty database for generation.")

    for table_name, frame in [
        ("customers", customers_df),
        ("categories", categories_df),
        ("products", products_df),
        ("orders", orders_df),
        ("order_items", order_items_df),
    ]:
        frame.to_sql(table_name, conn, if_exists="append", index=False, chunksize=500)
        print(f"Loaded {len(frame):,} rows into {table_name}.")
