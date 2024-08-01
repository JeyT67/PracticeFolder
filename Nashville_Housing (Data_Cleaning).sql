/*
Cleaning Data in SQL Queries
*/
SELECT *
FROM PortfolioProject..NashvilleHousing$

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing$

--UPDATE method
UPDATE PortfolioProject.dbo.NashVilleHousing$
SET SaleDate = CONVERT(Date, SaleDate)
--ALTER method
ALTER TABLE PortfolioProject.dbo.NashVilleHousing$
Add SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashVilleHousing$
SET SaleDateConverted = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------
 -- Populate Property Address data
SELECT *
FROM PortfolioProject..NashvilleHousing$
WHERE PropertyAddress is null
--Certain property address are null, in order to solve is to join parcelId with property address cause the information relate
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing$ a 
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing$ a 
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
--PropertyAddress has 2 things to split: address and city
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing$

SELECT
SUBSTRING(PropertyAddress, /*position 1*/1 , CHARINDEX(',',PropertyAddress) -1 /*-1 is to remove the last position which is ','*/) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing$

--In order to separate the address, have to alter table base on number of separation
ALTER TABLE PortfolioProject.dbo.NashVilleHousing$
ADD PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashVilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashVilleHousing$
ADD PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashVilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing$

--OwnerAddress has 3 things to split: address, city and state
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing$

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject.dbo.NashvilleHousing$

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.NashvilleHousing$

--------------------------------------------------------------------------------------------------------------------------
-- Changing 'Y' and 'N' into 'Yes' and 'No' in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing$

Update PortfolioProject.dbo.NashvilleHousing$
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
--Removing these duplicates can be done based on differentiating row number, rank etc
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER ( /*partition fields that are content sensitive and can't have duplicates*/
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) Row_Num
From PortfolioProject.dbo.NashvilleHousing$
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress;

--The above query shows the entries of duplicate that are row_num 2, so have to delete them
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER ( /*partition fields that are content sensitive and can't have duplicates*/
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) Row_Num
From PortfolioProject.dbo.NashvilleHousing$
)
DELETE 
FROM RowNumCTE
WHERE Row_Num > 1;

Select *
From PortfolioProject.dbo.NashvilleHousing$

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
--Once made alteration to add new entry into table, can delete the redundant fields in table
Select *
From PortfolioProject.dbo.NashvilleHousing$

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

