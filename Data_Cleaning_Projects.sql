
USE Portfolio_project3
--Cleaning Data 
select *
FROM NashvilleHousing

select SaleDate
FROM NashvilleHousing

--Standarize date format
select SaleDate
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDate,SaleDateConverted
FROM NashvilleHousing

--Populate Property Address data
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null
order by ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b on a.ParcelID = b.ParcelID 
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]

--Breaking out Address into Individual Columns (Address,City,State)
SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress)-1) as ADDRESS ,
SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 


select
SUBSTRING(PropertyAddress,1,10)
from NashvilleHousing

select * from NashvilleHousing

--Breaking owner address
SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
OwnerAddress
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


--Change Y and N Yes and No in "Sold as Vacant" field
select DISTINCT(SoldAsVacant),count(SoldAsVacant)
FROM NashvilleHousing
group by SoldAsVacant
order by 2


select 
SoldAsVacant,
CASE 
	when SoldAsVacant ='Y ' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	Else SoldAsVacant
	END
FROM NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE 
	when SoldAsVacant ='Y ' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	Else SoldAsVacant
	END

select DISTINCT(SoldAsVacant)
FROM NashvilleHousing

--Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId, PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueId) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
where row_num > 1


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueId) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
where row_num = 1
order by [UniqueID ]

--DELETE UNUSED COLUMNS

select *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate