# E-commerce Sales & Customer Analytics

A portfolio case study using **PostgreSQL, SQL, Python, pandas, and scikit-learn** to explore product profitability, purchasing patterns, customer segments, and a simple classification model. The data is **synthetic**; the findings demonstrate an analytical workflow rather than evidence about a real business.

## At a glance

| Measure | Result |
| --- | ---: |
| Orders | 20,000 |
| Order lines | 59,791 |
| Customers | 5,000 |
| Sales value across all order statuses | 34,735,722.70 |
| Gross profit across all order statuses | 11,106,636.81 |
| Gross margin | 31.97% |
| Average order value | 1,736.79 |

**Metric scope:** The headline sales and profit calculations sum all order lines, including orders marked cancelled or returned. They should be read as transaction value in this synthetic dataset, not recognized revenue. The SQL scripts also examine order status separately.

## Questions and findings

- Which categories and products drive sales and profit? Toys, Home & Kitchen, and Books lead sales value; Home & Kitchen has the highest gross profit.
- How do discounts relate to margins? The observed gross margin declines from about 36.8% for items without discounts to about 21.1% at a 20% discount. This is a descriptive comparison, not a causal estimate.
- How is customer value distributed? 191 customers (3.9% of customers with purchases) are classified as High Value under the project's spending based segmentation.
- Which customers merit follow-up? RFM analysis distinguishes groups including Champions and At Risk customers.
- Can behavior flag High Value customers? A logistic regression using recency and frequency achieved ROC-AUC 0.958, recall 0.85, precision 0.28, and F1 0.42 on a held out test split. This is a demonstration on synthetic data, not a production forecast. Spending was excluded from predictors because it defines the target.

## Repository guide

| File | Purpose |
| --- | --- |
| [`schema.sql`](schema.sql) | PostgreSQL tables, primary keys, and relationships |
| [`generate_data.py`](generate_data.py) | Seeded synthetic data generation and database loading |
| [`01_basic_analysis.sql`](01_basic_analysis.sql) | Overall metrics, category sales, and customer basics |
| [`02_customer_analysis.sql`](02_customer_analysis.sql) | Customer value and RFM segments |
| [`03_sales_trends.sql`](03_sales_trends.sql) | Monthly trends, year over year change, and rolling averages |
| [`04_product_analysis.sql`](04_product_analysis.sql) | Product revenue, profit, and discounts |
| [`05_order_analysis.sql`](05_order_analysis.sql) | Order status, payment method, and order patterns |
| [`ecommerce_analysis.ipynb`](ecommerce_analysis.ipynb) | Python exploration, visualizations, and classification |
| [`requirements.txt`](requirements.txt) | Python package dependencies |
| [`.env.example`](.env.example) | Example local database configuration without credentials |

## Reproduce the analysis

Requires Python 3, PostgreSQL running locally on port 5432, and a local PostgreSQL user named `postgres` with permission to create tables.

1. Clone this repository and install its Python packages:

   ```bash
   git clone https://github.com/gaksongit/ecommerce-sales-customer-analytics.git
   cd ecommerce-sales-customer-analytics
   python -m pip install -r requirements.txt
   ```

2. Create an **empty** PostgreSQL database named `ecommerce_analytics`. For example, use pgAdmin or run `CREATE DATABASE ecommerce_analytics;` while connected to another database.
3. Copy `.env.example` to `.env` and replace the example value with your own local PostgreSQL password. `.env` is ignored by Git. Do not commit credentials.
4. Run `python generate_data.py`. It creates the five related tables and loads synthetic records. It refuses to load into a database that already contains rows, to avoid duplicates.
5. Open the SQL files in pgAdmin, or run the notebook with `jupyter notebook ecommerce_analysis.ipynb` after the database has been populated.

The generator uses a fixed random seed and a fixed observation end date (27 September 2026) so future runs remain comparable. The notebook shows saved outputs from the original analysis; rerun its cells against your freshly generated database to refresh them.

## Methods and limitations

SQL queries use joins, CTEs, conditional aggregation, `LAG`, `ROW_NUMBER`, `NTILE`, and rolling windows. Python covers validation, feature engineering, customer aggregation, RFM segmentation, charts, and logistic regression.

The data generating process is synthetic, order statuses are randomly assigned, and the model's target is based on spending within this same dataset. Neither the relationships nor model performance should be generalized to real customers. No personal customer data is used; generated email addresses use `example.com`.
