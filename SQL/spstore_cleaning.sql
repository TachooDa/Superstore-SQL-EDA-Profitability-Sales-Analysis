create database superstore_data;
select * from spstore_staging;
-- buat staging table 
create table spstore_staging
like superstore;
-- masukan data ke staging
insert spstore_staging
select * from superstore;

-- Remove duplicate data (any)
select * from spstore_staging;
select `Order ID`, `Product ID`,
row_number() over(partition by `Row Id`,`Order ID`,`Product ID`) as row_num
 from spstore_staging;
 
 -- cek with cte
 with duplicate_cte as (
 select *,
row_number() over(partition by `Row Id`,`Order ID`,`Product ID`) as row_num
 from spstore_staging
 )
 select * from duplicate_cte
 where row_num >1;
 
-- 2. standardize data
-- update tipe data
select `Ship Date` from spstore_staging;
-- update Order Date
update spstore_staging
set  `Order Date` = str_to_date(`Order Date`, '%m/%d/%Y');
-- update Ship date
update spstore_staging
set `Ship Date` = str_to_date(`Ship Date`,'%m/%d/%Y');
-- Modify tipe data untuk order date dan ship date dari text -> date
alter table spstore_staging
modify column `Ship Date` date;
--
select replace(`Product Name`, '#','') as liat
from spstore_staging
where `Product Name` like '%#%';
update spstore_staging
set `Product Name` = replace(`Product Name`, '#','') 
where `Product Name` like '%#%';
--
-- 3. Null dan blank values
select * from spstore_staging;
select `Postal Code`
from spstore_staging
where `Postal Code` is null
and `Postal Code` = '';



