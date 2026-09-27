# E-commerce Sales & Customer Analytics

An end-to-end analytics portfolio project using **PostgreSQL, SQL, Python, pandas, matplotlib, and scikit-learn**.

The project analyzes a synthetic e-commerce database and demonstrates the full analytics workflow: database design, SQL analysis, exploratory data analysis, customer segmentation, profitability analysis, visualization, and predictive modeling.

## Project Objectives

The goal of the project was to answer practical business questions such as:

- How much revenue and gross profit is the business generating?
- Which categories and products contribute most to revenue and profit?
- Which products generate high revenue but low margins?
- How do discounts affect profitability?
- What is the customer value distribution?
- Which customers are most valuable or at risk?
- Can customer behavior be used to identify High Value customers?

## Dataset

The PostgreSQL database contains five relational tables:

- `customers` – 5,000 customers
- `categories` – 8 product categories
- `products` – 250 products
- `orders` – 20,000 orders
- `order_items` – 59,791 order lines

The dataset is synthetic and was generated in Python for portfolio purposes.

## Tools Used

- PostgreSQL
- pgAdmin
- SQL
- Python
- pandas
- NumPy
- matplotlib
- SQLAlchemy
- scikit-learn
- Jupyter Notebook
- VS Code

## SQL Analysis

The SQL portion of the project includes:

- Revenue and Average Order Value
- Gross profit and gross margin
- Revenue and profitability by category
- Top products and customers
- Repeat customer analysis
- Monthly revenue trends
- Year-over-Year revenue and profit growth
- 3-month rolling revenue averages
- Product profitability analysis
- High-revenue / low-margin product identification
- Customer value segmentation
- RFM segmentation
- Order status analysis
- Payment method analysis
- Order-size distribution
- Discount impact analysis
- Realized vs lost/reversed revenue

Advanced SQL techniques used include:

- JOINs
- CTEs
- CASE expressions
- Aggregate functions
- Subqueries
- Window functions
- `LAG()`
- `ROW_NUMBER()`
- `NTILE()`
- Rolling windows
- Conditional aggregation

## Python Analysis

Python was used for:

- Loading PostgreSQL data directly into pandas
- Data type validation
- Missing-value checks
- Duplicate detection
- Descriptive statistics
- Feature engineering
- Revenue and profit calculations
- Customer-level aggregation
- RFM segmentation
- Visualization
- Predictive modeling

## Key Business Insights

- Total revenue was approximately **34.7M**, with gross profit of approximately **11.1M** and an overall gross margin of about **32%**.

- **Toys, Home & Kitchen, and Books** generated the highest revenue, while **Home & Kitchen** generated the highest gross profit.

- Product profitability varied significantly. Several products with high revenue had gross margins below **20%**, while others with similar revenue achieved margins above **40–50%**.

- Gross margin decreased consistently as discounts increased, falling from approximately **36.8% at 0% discount** to approximately **21.1% at 20% discount**.

- Most customers belonged to the Low or Medium Value segments. Only **191 customers (3.9%)** were classified as High Value.

- RFM analysis identified valuable customer groups such as **Champions**, as well as **At Risk** customers who historically spent and purchased frequently but had not purchased recently.

- Monthly revenue remained relatively stable throughout the observation period, with short-term fluctuations smoothed using a 3-month rolling average.

## Predictive Modeling

A logistic regression model was built to identify High Value customers using:

- Recency
- Purchase frequency

`total_spent` was intentionally excluded from the predictors to avoid target leakage because High Value status was defined using customer spending.

Model performance:

- ROC-AUC: **0.958**
- High Value recall: **0.85**
- High Value precision: **0.28**
- High Value F1-score: **0.42**

The model successfully identified most High Value customers, although the low prevalence of High Value customers created a class-imbalance challenge.

Purchase frequency was the strongest predictor of High Value customer status.

## Project Structure

```text
ecommerce_sql_python/
│
├── README.md
├── ecommerce_analysis.ipynb
├── generate_data.py
│
├── 01_basic_analysis.sql
├── 02_customer_analysis.sql
├── 03_sales_trends.sql
├── 04_product_analysis.sql
├── 05_order_analysis.sql
│
└── .env