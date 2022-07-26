select * 
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing

--standerdize Date Format
select SaleDateConverted
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing


-- Added a column named SaleDateConverted
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
--Update this column by adding saledate
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property address data where its null
-- self joing the table to get all records where parcel id are repeated. Isnull copies the b.propertyaddress to a.propertyaddress
select a.parcelid, a.propertyaddress , b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing a
JOIN PROJECT_DATA_CLEANING.dbo.NashvilleHousing b
ON a.parcelId = b.parcelId
AND a.[UniqueID] <> b.[UniqueId]
where a.propertyAddress is null

--updating the table
update a 
SET Propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing a
JOIN PROJECT_DATA_CLEANING.dbo.NashvilleHousing b
ON a.parcelId = b.parcelId
AND a.[UniqueID] <> b.[UniqueId]
where a.propertyAddress is null

-- Breaking out address into individual columns (Address, City, State), The charindex command takes the string upto , and then -1. 
select SUBSTRING(propertyaddress, 1 , CHARINDEX(',', propertyaddress)-1) AS Address ,
	   SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, Len(propertyaddress)) AS CITY 
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing

--updating the table
ALTER TABLE NashvilleHousing
ADD Address Nvarchar(255);


Update NashvilleHousing
SET Address = SUBSTRING(propertyaddress, 1 , CHARINDEX(',', propertyaddress)-1)

ALTER TABLE NashvilleHousing
ADD City Nvarchar(255);

Update NashvilleHousing
SET City = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, Len(propertyaddress))

--breaking owner address different method
select PARSENAME(REPLACE(owneraddress,',','.'),3),
 PARSENAME(REPLACE(owneraddress,',','.'),2),
 PARSENAME(REPLACE(owneraddress,',','.'),1)
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing

--update the table
ALTER TABLE NashvilleHousing
ADD HomeAddress nvarchar(255);
--Update this column by adding saledate
Update NashvilleHousing
SET HomeAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD County nvarchar(255);
--Update this column by adding saledate
Update NashvilleHousing
SET County = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD State nvarchar(255);
--Update this column by adding saledate
Update NashvilleHousing
SET State = PARSENAME(REPLACE(owneraddress,',','.'),1)

-- Changing y and n to yes and no in column soldasvacant
select SoldAsvacant, 
	CASE 
	WHEN SOLDASVACANT = 'N' THEN 'No' 
	WHEN SOLDASVACANT = 'Y' THEN 'Yes' 
	ELSE SOLDASVACANT
	END
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing

--updating the table
Update PROJECT_DATA_CLEANING.dbo.NashvilleHousing
SET SoldAsvacant = CASE 
	WHEN SOLDASVACANT = 'N' THEN 'No' 
	WHEN SOLDASVACANT = 'Y' THEN 'Yes' 
	ELSE SOLDASVACANT
	END
-- Validating the result
SELECT DISTINCT(SOLDASVACANT)
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing


-- Removing duplicates
WITH RowNumCTE AS (
select * , 
ROW_NUMBER() OVER (
	Partition  by Parcelid,
				 Propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by 
					uniqueid
					) row_num
from PROJECT_DATA_CLEANING.dbo.NashvilleHousing

)
select *
FROM RowNumCTE
where row_num > 1
order by propertyaddress

--deleting columns

ALTER TABLE PROJECT_DATA_CLEANING.dbo.NashvilleHousing
DROP COLUMN OWNERADDRESS;