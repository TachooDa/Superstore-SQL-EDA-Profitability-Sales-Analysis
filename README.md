# Superstore-SQL-EDA-Profitability-Sales-Analysis
## 📌 Project Overview

Proyek ini bertujuan untuk mengeksplorasi data retail menggunakan SQL dalam rangka memahami pola penjualan, profitabilitas produk, efektivitas diskon, serta performa tiap wilayah (region) dan kategori. Analisis ini dilakukan menggunakan query SQL dan Common Table Expressions (CTE).

Dataset ini berasal dari tabel `spstore_staging`, yang berisi data historis transaksi retail seperti `Order Date`, `Sales`, `Profit`, `Discount`, `Product Name`, `Category`, `Sub-Category`, dan `Region`.

---

# 🧠 Key Questions & Insights
## 🔥  cek Order dan ship date 
```sql
--Ship Date
select `Ship Date`, count(*) as total_ship, 
round(avg(`Profit`),2) as avg_profit
from spstore_staging
group by `Ship Date`
order by total_ship desc;
-- Order Date
select `Order Date`, count(*) as total_order,
round(avg(`Profit`),2) as avg_profit
from spstore_staging
group by `Order Date`
order by total_order desc;
🎈 Insight :
> Order date dan ship date berpengaruh terhadap tingkat profitabilitas produk
```
### 🗓️ Periode Transaksi
```sql
select min(`Order Date`), max(`Order Date`) from spstore_staging;
select min(`Ship Date`), max(`Ship Date`) from spstore_staging;
📍 Insight :
> Periode transaksi mencakup data dari awal hingga akhir tahun
```
## ❌ Produk dengan Kerugian
```sql
select `Product Name`, Sales,Discount,Profit
from spstore_staging
where Profit < 0;
📍 Insight :
- Terdapat sejumlah produk dengan nilai profit negatif, sebagian besar diantaranya memiliki diskon yang tinggi
-> indikasi bahwa diskon besar tidak selalu meningkatkan profit.
```
## 🌎 Total Profit per Region
```sql
select Region, sum(Profit) as total_profit
from spstore_staging
group by Region
order by total_profit desc;
🎈 Insight :
> Region tertentu berkontribusi besar terhadap total profit. Region lainnya mungkin membutuhkan strategi perbaikan distribusi atau pricing.
```
## 🏷️ Penjualan Berdasarkan Kategori
```sql
select Category, sum(sales) as total_sales
from spstore_staging
group by Category
order by total_sales desc;
🎈 insight :
> Kategori Office Supplies mendominasi penjualan, namun perlu dibandingkan lagi dengan tingkat profitabilitasnya.
```
## 📊 Sub-Category: Diskon vs Profit
```sql
select `Sub-Category`, round(avg(Discount),2) as avg_diskon,
round(avg(Profit),2)as avg_profit
from spstore_staging
group by `Sub-Category`
order by avg_profit;
🎈 Insight :
> Sub-kategori dengan diskon tinggi cenderung memiliki profit yang rendah
→ butuh evaluasi efektivitas promosi.
```
## 💰 Produk paling menguntungkan
```sql
select `Product Name`, Profit
from spstore_staging
order by Profit desc
limit 5;
```
## 📦 Produk terbanyak terjual
```sql
select `Row ID`,`Product Name`, sum(Quantity) as total_kuan
from spstore_staging
group by `Row ID`,`Product Name`
order by total_kuan desc
limit 10;
🎈 Insight :
> Produk terlaris belum tentu menjadi produk paling menguntungkan, penting meng-evaluasi margin per-produk
```
## ⚖ Rasio profit terhadap penjualan (Profitability)
```sql
select `Product Name`,sum(Profit) / nullif(sum(Sales),0) as profit_per_sales
from spstore_staging
group by `Product Name`
order by profit_per_sales desc
limit 5;
🎈 insight :
> Produk dengan rasio tinggi merupakan produk yang ideal untuk difokuskan dalam penjualan
```

# CTE-Based deeper analysis
## 🏆 5 Produk Terbaik per-kategori
```sql
with ranked_profit as (
select Category, `Product Name`,
sum(Profit) as total_profit,
rank() over(partition by Category order by sum(Profit) desc) as rank_profit
from spstore_staging
group by Category, `Product Name`
)
select * from ranked_profit
where rank_profit <=5;
🎈 Insight :
> Produk unggulan berbeda antar kategori, bisa jadi dasar strategi bundlind atau cross-sell
```
##  🔻 Produk rugi dengan diskon tinggi
```sql
with less_product as (
select `Product Name`, Discount, Profit
from spstore_staging
where Profit < 0
)
select `Product Name`,Profit, avg(Discount) as diskon_rata2
from less_product
group by `Product Name`,Profit
order by diskon_rata2 desc;
🎈 Insight :
> Menunjukan adanya pola diskon yang tidak efektif atau over-discounting
```
## 🧭 Profit per Region & Sub-Category
```sql
select * from spstore_staging;
with profit_per_region as (
select Region, `Sub-Category`, round(avg(Profit),2) as profit_rata2
from spstore_staging
group by Region, `Sub-Category`
)
select * from profit_per_region 
order by profit_rata2 desc;
🎈 Insight :
> Preferensi pelanggan antar region berbeda. Beberapa region unggul dalam sub-kategori tertentu.
```
## 💹 Rasio Profitability Produk
```sql
with profitability as (
select `Product Name`, sum(Profit) as total_profit, sum(Sales) as total_sales,
sum(Profit) / nullif(sum(sales),0) as profit_per_sales
from spstore_staging
group by `Product Name`
)
select * from profitability
order by profit_per_sales desc
limit 5;
🎈 Insight :
> Rasio profit terhadap sales memperjelas produk mana yang efisien secara finansial, bukan hanya populer.
```
## 📈 Tren Bulanan (Quantity & Profit)
```sql
with laporan_bulanan as (
select left(`Order Date`,7) as `Month`,
sum(Quantity) as total_qty,
sum(Profit) as total_profit
from spstore_staging
group by  `Month`
)
select * from laporan_bulanan
order by `Month` asc;
🎈 Insight :
> Menunjukan tren musiman atau bulanan dalam hal penjualan dan profit
```
# 🧰 Tools & Technologies
```
- SQL Query (Mysql)
- CTE (Common Table Expression)
- Analisis berbasis query tanpa visualisasi
```
# ✍️ Author
Faraj Hafidh
[Github link for-project]
https://github.com/TachooDa/Retail-Superstore-SQL-EDA-Profitability-Sales-Analysis/edit/main/README.md
