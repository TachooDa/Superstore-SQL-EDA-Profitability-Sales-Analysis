select * from spstore_staging;
-- Periode waktu order dan ship
select min(`Order Date`), max(`Order Date`)
from spstore_staging;
select min(`Ship Date`), max(`Ship Date`)
from spstore_staging;
-- 1. cek kerugian
select `Product Name`, Sales,Discount,Profit
from spstore_staging
where Profit < 0;
-- 2. cek total profit per region
select Region, sum(Profit) as total_profit
from spstore_staging
group by Region
order by total_profit desc;

-- 3. total penjualan / kategori
select Category, sum(sales) as total_sales
from spstore_staging
group by Category
order by total_sales desc;

-- 4. rata-rata diskon/sub-category
select `Sub-Category`, round(avg(Discount),2) as avg_diskon,
round(avg(Profit),2)as avg_profit
from spstore_staging
group by `Sub-Category`
order by avg_profit;

-- 5. Product paling menguntungkan
select `Product Name`, Profit
from spstore_staging
order by Profit desc
limit 5;

-- 6. Product terbanyak terjual
select `Row ID`,`Product Name`, sum(Quantity) as total_kuan
from spstore_staging
group by `Row ID`,`Product Name`
order by total_kuan desc
limit 10;

-- 7. Rasio profit ke penjualan
select `Product Name`,
sum(Profit) / nullif(sum(Sales),0) as profit_per_sales
from spstore_staging
group by `Product Name`
order by profit_per_sales desc
limit 5;

-- CTE SECTION
select * from spstore_staging;
-- 1. 5 Produk tertinggi per category
with ranked_profit as (
select Category, `Product Name`,
sum(Profit) as total_profit,
rank() over(partition by Category order by sum(Profit) desc) as rank_profit
from spstore_staging
group by Category, `Product Name`
)
select * from ranked_profit
where rank_profit <=5;

-- 2. Produk merugi tapi diskonnya tinggi
with less_product as (
select `Product Name`, Discount, Profit
from spstore_staging
where Profit < 0
)
select `Product Name`,Profit, avg(Discount) as diskon_rata2
from less_product
group by `Product Name`,Profit
order by diskon_rata2 desc;

-- 3. region dengan avg profit tertinggi per sub category
select * from spstore_staging;
with profit_per_region as (
select Region, `Sub-Category`, round(avg(Profit),2) as profit_rata2
from spstore_staging
group by Region, `Sub-Category`
)
select * from profit_per_region 
order by profit_rata2 desc;

-- 4. Rasio profit terhadap penjualan ( profitability ) - limit 5 produk
with profitability as (
select `Product Name`,
sum(Profit) as total_profit,
sum(Sales) as total_sales,
sum(Profit) / nullif(sum(sales),0) as profit_per_sales
from spstore_staging
group by `Product Name`
)
select * from profitability
order by profit_per_sales desc
limit 5;

-- 5. Trend quantity dan profit gabungan 
with laporan_bulanan as (
select left(`Order Date`,7) as `Month`,
sum(Quantity) as total_qty,
sum(Profit) as total_profit
from spstore_staging
group by  `Month`
)
select * from laporan_bulanan
order by `Month` desc