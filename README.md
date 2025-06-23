# 🛒 Superstore SQL EDA - Analisis Profitabilitas & Penjualan

## 📌 Ringkasan Proyek

Proyek ini bertujuan untuk mengeksplorasi data retail menggunakan SQL dalam rangka memahami pola penjualan, profitabilitas produk, efektivitas diskon, serta performa tiap wilayah (region) dan kategori. Analisis ini dilakukan menggunakan **query SQL** dan **Common Table Expressions (CTE)** untuk mendapatkan insight mendalam tentang performa bisnis retail.

Dataset berasal dari tabel `spstore_staging`, yang berisi data historis transaksi retail dengan informasi lengkap tentang penjualan, profit, diskon, dan segmentasi produk.

---

## 📁 Informasi Dataset

| **Field** | **Deskripsi** |
|-----------|---------------|
| **Nama Tabel** | `spstore_staging` |
| **Periode Data** | [`2014-05-13` & `2017-12-30`] |
| **Total Record** | [`173` Record] |

### **Kolom Utama:**
- `Order Date` – Tanggal pemesanan
- `Ship Date` – Tanggal pengiriman
- `Sales` – Nilai penjualan
- `Profit` – Keuntungan per transaksi
- `Discount` – Persentase diskon
- `Product Name` – Nama produk
- `Category` – Kategori produk utama
- `Sub-Category` – Sub-kategori produk
- `Region` – Wilayah penjualan
- `Quantity` – Jumlah produk terjual

---

## 🎯 Pertanyaan Bisnis Utama & Insight

### **🗓️ Analisis Temporal**

#### **1. Pengaruh Tanggal Pemesanan & Pengiriman**
```sql
-- Analisis Ship Date
SELECT `Ship Date`, COUNT(*) as total_ship, 
       ROUND(AVG(`Profit`),2) as avg_profit
FROM spstore_staging
GROUP BY `Ship Date`
ORDER BY total_ship DESC;

-- Analisis Order Date
SELECT `Order Date`, COUNT(*) as total_order,
       ROUND(AVG(`Profit`),2) as avg_profit
FROM spstore_staging
GROUP BY `Order Date`
ORDER BY total_order DESC;
```
**💡 Insight:** Order date dan ship date berpengaruh terhadap tingkat profitabilitas produk

#### **2. Periode Transaksi**
```sql
SELECT MIN(`Order Date`), MAX(`Order Date`) FROM spstore_staging;
SELECT MIN(`Ship Date`), MAX(`Ship Date`) FROM spstore_staging;
```
**💡 Insight:** Periode transaksi mencakup data dari awal hingga akhir tahun

---

### **💰 Analisis Profitabilitas**

#### **3. Produk dengan Kerugian**
```sql
SELECT `Product Name`, Sales, Discount, Profit
FROM spstore_staging
WHERE Profit < 0;
```
**💡 Insight:** Terdapat produk dengan profit negatif, sebagian besar memiliki diskon tinggi → indikasi bahwa diskon besar tidak selalu meningkatkan profit.

#### **4. Produk Paling Menguntungkan**
```sql
SELECT `Product Name`, `Profit`
FROM spstore_staging
ORDER BY `Profit` DESC
LIMIT 5;
```

#### **5. Rasio Profitabilitas**
```sql
SELECT `Product Name`, 
       SUM(`Profit`) / NULLIF(SUM(`Sales`),0) as profit_per_sales
FROM spstore_staging
GROUP BY `Product Name`
ORDER BY profit_per_sales DESC
LIMIT 5;
```
**💡 Insight:** Produk dengan rasio tinggi merupakan produk ideal untuk difokuskan dalam penjualan

---

### **🌍 Analisis Regional**

#### **6. Total Profit per Region**
```sql
SELECT `Region`, SUM(`Profit`) as total_profit
FROM spstore_staging
GROUP BY `Region`
ORDER BY total_profit DESC;
```
**💡 Insight:** Region tertentu berkontribusi besar terhadap total profit. Region lainnya membutuhkan strategi perbaikan distribusi atau pricing.

---

### **🏷️ Analisis Kategori & Produk**

#### **7. Penjualan Berdasarkan Kategori**
```sql
SELECT `Category`, SUM(`Sales`) as total_sales
FROM spstore_staging
GROUP BY `Category`
ORDER BY total_sales DESC;
```
**💡 Insight:** Kategori Office Supplies mendominasi penjualan, perlu dibandingkan dengan profitabilitasnya.

#### **8. Sub-Category: Diskon vs Profit**
```sql
SELECT `Sub-Category`, 
       ROUND(AVG(`Discount`),2) as avg_diskon,
       ROUND(AVG(`Profit`),2) as avg_profit
FROM spstore_staging
GROUP BY `Sub-Category`
ORDER BY avg_profit;
```
**💡 Insight:** Sub-kategori dengan diskon tinggi cenderung memiliki profit rendah → butuh evaluasi efektivitas promosi.

#### **9. Produk Terbanyak Terjual**
```sql
SELECT `Row ID`, `Product Name`, SUM(`Quantity`) as qty_total
FROM spstore_staging
GROUP BY `Row ID`, `Product Name`
ORDER BY qty_total DESC
LIMIT 10;
```
**💡 Insight:** Produk terlaris belum tentu menjadi produk paling menguntungkan, penting mengevaluasi margin per-produk.

---

## 🧠 Analisis Lanjutan dengan CTE

### **🏆 Top 5 Produk Terbaik per Kategori**
```sql
WITH ranked_profit AS (
    SELECT `Category`, `Product Name`,
           SUM(`Profit`) as total_profit,
           RANK() OVER(PARTITION BY `Category` ORDER BY SUM(`Profit`) DESC) as rank_profit
    FROM spstore_staging
    GROUP BY `Category`, `Product Name`
)
SELECT * FROM ranked_profit
WHERE rank_profit <= 5;
```
**💡 Insight:** Produk unggulan berbeda antar kategori, bisa jadi dasar strategi bundling atau cross-sell.


### **🔻 Produk Rugi dengan Diskon Tinggi**
```sql
WITH loss_product AS (
    SELECT `Product Name`, `Discount`, `Profit`
    FROM spstore_staging
    WHERE `Profit` < 0
)
SELECT `Product Name`, Profit, AVG(`Discount`) as diskon_rata2
FROM loss_product
GROUP BY `Product Name`, `Profit`
ORDER BY diskon_rata2 DESC;
```
**💡 Insight:** Menunjukkan pola diskon yang tidak efektif atau over-discounting.


### **🧭 Profit per Region & Sub-Category**
```sql
WITH profit_per_region AS (
    SELECT Region, `Sub-Category`, 
           ROUND(AVG(`Profit`),2) as profit_rata2
    FROM spstore_staging
    GROUP BY `Region`, `Sub-Category`
)
SELECT * FROM profit_per_region 
ORDER BY profit_rata2 DESC;
```
**💡 Insight:** Preferensi pelanggan antar region berbeda. Beberapa region unggul dalam sub-kategori tertentu.

### **📈 Tren Bulanan (Quantity & Profit)**
```sql
WITH laporan_bulanan AS (
    SELECT LEFT(`Order Date`,7) as `Month`,
           SUM(`Quantity`) as total_qty,
           SUM(`Profit`) as total_profit
    FROM spstore_staging
    GROUP BY `Month`
)
SELECT * FROM laporan_bulanan
ORDER BY `Month` ASC;
```
**💡 Insight:** Menunjukkan tren musiman atau bulanan dalam penjualan dan profit.

---

## 📊 Ringkasan Temuan Utama

### **🎯 Key Performance Indicators:**
- **Kategori Terlaris:** Office Supplies
- **Produk Paling Menguntungkan:** `AT&T CL83451 4-Handset Telephone`
- **Region Terbaik:** `West` -> Total Profit `1337.8457`
- **Masalah Utama:** Over-discounting pada beberapa produk

### **📈 Rekomendasi Bisnis:**
1. **Optimasi Diskon:** Review kebijakan diskon untuk produk dengan profit negatif
2. **Fokus Regional:** Tingkatkan strategi pemasaran di region dengan profit rendah
3. **Portfolio Produk:** Prioritaskan produk dengan rasio profit/sales tinggi
4. **Strategi Musiman:** Manfaatkan tren bulanan untuk planning inventory

---

## 🛠️ Stack Teknologi

| **Komponen** | **Teknologi** |
|--------------|---------------|
| **Database** | MySQL |
| **Query Language** | SQL |
| **Fitur Lanjutan** | Common Table Expressions (CTE) |
| **Pemrosesan Data** | Table staging (`spstore_staging`) |
| **Analisis** | Query-based analysis |

---

## 📂 Struktur Repository

```
├── SQL-Files/
│   └── [eda_superstore.csv]
├── Screenshots/
│   ├── Profit vs Sales ratio.png
│   ├── top5_product.png
│   ├── Produk merugi dengan diskon tinggi.png
│   ├── Profit rata-rata per region.png
│   └── Tren Bulanan.png
├── README.md
└── [Other project files]
```

---

## 🚀 Cara Menggunakan

1. **Clone repository:**
   ```bash
   git clone https://github.com/TachooDa/Superstore-SQL-EDA-Profitability-Sales-Analysis.git
   ```

2. **Setup database** dengan tabel `spstore_staging`

3. **Jalankan query SQL** sesuai dengan analisis yang diinginkan

4. **Review hasil** dan visualisasi di folder Screenshots

---

## 🎯 Pengembangan Masa Depan

- [ ] Dashboard interaktif dengan Power BI/Tableau
- [ ] Predictive analytics untuk forecasting
- [ ] Customer segmentation analysis
- [ ] Real-time monitoring dashboard
- [ ] Machine learning untuk optimasi pricing

---

## 📧 Kontak

**Author:** Faraj Hafidh  
**GitHub:** [TachooDa](https://github.com/TachooDa)  
**Project Link:** [Superstore Analysis](https://github.com/TachooDa/Superstore-SQL-EDA-Profitability-Sales-Analysis)

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan buka Issue atau kirim Pull Request untuk perbaikan dan pengembangan lebih lanjut.

---

## 📄 Lisensi

Proyek ini bersifat edukatif dan open source untuk pengembangan lebih lanjut.

---
