/*

Cleaning Data in SQL Queries

*/


-- Standardize Date Format
Select *
From [Data Cleaning]..NashvilleHousing

Select SaleDate, CONVERT(Date,SaleDate)
From [Data Cleaning]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


--------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From [Data Cleaning]..NashvilleHousing
--where PropertyAddress is null;
order by ParcelID;


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [Data Cleaning]..NashvilleHousing a
JOIN [Data Cleaning]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Data Cleaning]..NashvilleHousing a
JOIN [Data Cleaning]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------

--Breaking out Address into individual Columns (Address, City, State)

 Select PropertyAddress
From [Data Cleaning]..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as rest_address
From [Data Cleaning]..NashvilleHousing

ALTER TABLE [Data Cleaning]..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [Data Cleaning]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE [Data Cleaning]..NashvilleHousing
Add PropertyCityAddress Nvarchar(255);

Update [Data Cleaning]..NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)); 


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [Data Cleaning]..NashvilleHousing

ALTER TABLE [Data Cleaning]..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Data Cleaning]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE [Data Cleaning]..NashvilleHousing
Add OwnerCityAddress Nvarchar(255);

Update [Data Cleaning]..NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),2); 

ALTER TABLE [Data Cleaning]..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Data Cleaning]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1); 



--------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Data Cleaning]..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Data Cleaning]..NashvilleHousing

Update [Data Cleaning]..NashvilleHousing
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
 Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num
From [Data Cleaning]..NashvilleHousing
)
Delete 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

----------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE [Data Cleaning]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



