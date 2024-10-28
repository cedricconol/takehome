# SellerX Takehome Challenge

## Objective

Create reporting model that can answer questions related to device efficiency and performance.

## Steps:
1. Setup Snowflake "read replica" database to hold Stores, Devices, Transactions data. This is to mimic real-world scenario where data team are given access to Ops and Product database. **Assumption: Product team is responsible for maintaining Stores, Devices, Transactions data and have set up a "Read Replica" database refreshed once a day in which data team can access and get data from.**
2. Create Product schema in Read Replica DB with tables named Stores, Devices, Transactions respecitvely holding the data coming from Stores, Devices, Transactions excel files.
3. Setup Snowflake warehouse with one database having separate schemas for staging, mart, reporting dbt models.
4. Setup dbt-core with dbt-snowflake adapter.
5. Create staging models reading from "read replica" database.
6. Create fct, dim, and rpt models.
7. Create SQL queries using the rpt model that can be used by analysts to answer the questions

## Step by Step Details

Each item above will be broken down into detailed steps below including assumptions, observations, and codes.

### Step 1

```sql
use role accountadmin;
create role takehome_role;

grant usage on database read_replica to role takehome_role;
grant usage on all schemas in database read_replica to role takehome_role;
grant select on all tables in schema product to role takehome_role;
grant select on future tables in schema product to role takehome_role;

grant role takehome_role to user footymcfoot;

use role takehome_role;

create schema read_replica.product;

```

### Step 2

Using Snowflake's Add Data via Staging feature, upload Stores, Devices, Transactions excel files and create separate tables in `read_replica.product` schema.

### Step 3

**Date Warehouse**

```sql
use role accountadmin;

create warehouse takehome_wh with warehouse_size='x-small';
create database takehome_db;
create role takehome_role;

show grants on warehouse takehome_wh;

grant usage on warehouse takehome_wh to role takehome_role;
grant role takehome_role to user footymcfoot;
grant all on database takehome_db to role takehome_role;

use role takehome_role;

create schema takehome_db.takehome_schema_staging;
create schema takehome_db.takehome_schema_mart;
create schema takehome_db.takehome_schema_reporting;

```

### Step 4
I've used my `dbt - snowflake` (`dbt-core` + `dbt-snowflake`) environment I already have in my personal machine. Although best practice and highly recommended for maximum compatibility is to use Dockerized container with Python 3 (slim should do in this challenge) environment, `dbt-core`, and `dbt-snowflake` packages using a Dockerfile.

Limitation: I dont have enough computing power to run a Docker image.

Pls refer to `profiles.yml` and `dbt_project.yml` for configurations used in this project.

__Note: I only setup a single profile, dev, in this challenge. When deployed, needs a production profile too.__ 

### Step 5

Create staging models, that's 1:1 with the data source.

- `stg_product__devices`
- `stg_product__stores`
- `stg_product__transactions`

__Note: I've created a `docs` folder to hold common field docs. This is a reusable doc used in definitions in yml files.__

1. All fields are renamed to reflect its entity. eg `devices.type` is renamed to `devices.device_type`. FKs are exempted from this renaming rule.
2. Primary keys, are renamed to `pk_{transaction}_id`
3. `dbt_updated_at` is added to all models in this project to reflect the timestamp when the model was last ran.
4. **Transactions table contain highly sensitive data such as `card_number` and `cvv` and it is not recommended to store such data in the warehouse due to high security risks and stringent compliance requirements (like PCI-DSS). Both are not used in any analysis, in case, needed in the future such as rewards and discounts use cases, best to encrypt data in-transit and at-rest.**
5. There are 2 `product_name`s fields, per my EDA (see below), neither corresponds uniquely to SKU. This will result in possible modeling mistakes and confusing reports. **My assumption is that inventory are inputted by the customers and not by the product or ops team, regardless it is best to clarify with whoever is responsible for product names.**
6. Each transaction have one SKU so this means there's only one product per transaction. It will be a good idea to be able to know which transactions were purchased together.

**Product Name EDA**

```sql
with base as (
select distinct
product_name, product_sku, device_id
from read_replica.product.transactions)
select device_id, product_sku from base group by 1,2 having count(*)>1
;
```

### Step 6

Create `dim_devices` which contains all devices and store information where the device is deployed.

Create `fct_transactions` where one row corresponds to one transaction.

Create `rpt_device_performance` based on transactions. This includes all transactions regardless of their status. In a study of efficiency, it is also worth analyzing how often transactions fail as this affect adoption.

### Step 7

Create SQL queries to answer challenge questions. Pls refer to `analyses` folder.

- Question 1: Assumption is "transacted" means successful transactions. So only 'accepted' transactions makes sense in this question.

- Question 2: This analysis is best done using a pivot table in the BI tool and or any spreadsheet tool. This is so the analyst can deep dive which products fail often as this may be an opportunity to improve the devices. Therefore, `customer_id`, and `transaction_status` are included.

- Question 3: Same assumption as 1 to only include accepted transactions

- Question 4: Another question that is better answered by isolating accepted transactions to see which devices fail often.

- Question 5: Analysis is used to measure adoption, therefore, it is helpful to look at the entire picture including all transactions regardless of status. Failed transactions are also sign of adoption and should be considered an opportunity for improvement. **This analysis usually results in deep diving into the dataset and is best done in a BI tool or spreadsheet. The output of the query prepares this deep dive for the analyst to perform hence grouoped by Stores.**
