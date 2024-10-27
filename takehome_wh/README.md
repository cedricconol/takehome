Notes:
warehouse:
1. setup wh
use role accountadmin;

create warehouse takehome_wh with warehouse_size='x-small';
create database takehome_db;
create role takehome_role;

show grants on warehouse takehome_wh;

grant usage on warehouse takehome_wh to role takehome_role;
grant role takehome_role to user footymcfoot;
grant all on database takehome_db to role takehome_role;

use role takehome_role;

create schema takehome_db.takehome_schema;

setup product db:
use role accountadmin;

grant usage on database read_replica to role takehome_role;
grant usage on all schemas in database read_replica to role takehome_role;
grant select on all tables in schema product to role takehome_role;
grant select on future tables in schema product to role takehome_role;

show grants on schema product;

use role takehome_role;

select * from read_replica.product.device;

dbt:
1. Setup dev env only

2. create a product/ops "read replica" database to store device, store, transaction tables. this is to mimic
real-world scenario where data team is given access to product and ops data via data read replication. The
assumption is that the replica refreshes at the start of each day 00:00 UTC - giving data team access to D-1
data which should be enough for analysis and reporting purposes.

EDA on product_name duplicated field in transactions table:
with base as (
select distinct
product_name, product_sku
from read_replica.product.transactions)
select * from base group by 1,2 having count(*)>1
;

security:
1. card numbers and cvv should be encrypted in product database

assume one product per transaction

product names is not 1:1 with skus

rpt only accepted transactions

Analysis
with store_performance  as (
select store_id, store_name, sum(transaction_amount_eur) as total_transaction_amount_eur from takehome_schema_reporting.rpt_device_performance
group by 1,2)
select * from store_performance order by total_transaction_amount_eur desc limit 10;

with product_performance  as (
select transaction_product_sku, customer_id, count(*) as number_of_transactions from takehome_schema_reporting.rpt_device_performance
group by 1,2)
select * from product_performance order by number_of_transactions desc limit 10;

select store_typology, store_country, avg(transaction_amount_eur) as avg_transaction_amount_eur from takehome_schema_reporting.rpt_device_performance
group by 1,2;

with device_performance as (
select device_type, count(*) as number_of_transactions from takehome_schema_reporting.rpt_device_performance
group by 1)
select device_type, number_of_transactions, 100*ratio_to_report(number_of_transactions) over() from device_performance;


with first_five as (
select *, count(*) over (partition by store_id) as total_transactions_store from takehome_schema_reporting.rpt_device_performance
qualify row_number() over (partition by store_id order by transaction_happened_at) <= 5),
transaction_days as (
select
    store_id,
    min(transaction_happened_at) over (partition by store_id) as first_transaction_ts,
    max(transaction_happened_at) over (partition by store_id) as last_transaction_ts,
    datediff(day, first_transaction_ts, last_transaction_ts) as first_five_transactions_days
from first_five
where total_transactions_store >=5
)
select avg(first_five_transactions_days) from transaction_days
;

Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
