# Retail-Superstore-SQL-EDA-Profitability-Sales-Analysis
## 📌 Project Overview

Proyek ini bertujuan untuk mengeksplorasi data retail menggunakan SQL dalam rangka memahami pola penjualan, profitabilitas produk, efektivitas diskon, serta performa tiap wilayah (region) dan kategori. Analisis ini dilakukan menggunakan query SQL dan Common Table Expressions (CTE).

Dataset ini berasal dari tabel `spstore_staging`, yang berisi data historis transaksi retail seperti `Order Date`, `Sales`, `Profit`, `Discount`, `Product Name`, `Category`, `Sub-Category`, dan `Region`.

---

## 🧠 Key Questions & Insights

### 🗓️ Periode Transaksi
```sql
select min(`Order Date`), max(`Order Date`) from spstore_staging;
select min(`Ship Date`), max(`Ship Date`) from spstore_staging;
📍 Insight :
- Periode transaksi mencakup data dari awal hingga akhir tahun
```
## ❌ Produk dengan Kerugian
```sql
select `Product Name`, Sales,Discount,Profit
from spstore_staging
where Profit < 0;
📍 Insight :
- Terdapat sejumlah produk dengan nilai profit negatif, sebagian besar diantaranya memiliki diskon yang tinggi -> indikasi bahwa diskon besar tidak selalu meningkatkan profit.
```
## 🌎 Total Profit per Region
```sql
select Region, sum(Profit) as total_profit
from spstore_staging
group by Region
order by total_profit desc;
🎈 Insight :
- Region tertentu berkontribusi besar terhadap total profit. Region lainnya mungkin membutuhkan strategi perbaikan distribusi atau pricing.
```
## 🏷️ Penjualan Berdasarkan Kategori
```sql
select Category, sum(sales) as total_sales
from spstore_staging
group by Category
order by total_sales desc;
🎈 insight :
- Kategori Office Supplies mendominasi penjualan, namun perlu dibandingkan lagi dengan tingkat profitabilitasnya.
```
