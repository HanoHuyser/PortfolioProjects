

SELECT *
FROM Nashville_Housing.dbo.NashvilleHousing


--Standardize the Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Nashville_Housing.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data

SELECT* --PropertyAddress
FROM Nashville_Housing.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT Table1.ParcelID, Table1.PropertyAddress, Table2.ParcelID, Table2.PropertyAddress, ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
FROM Nashville_Housing.dbo.NashvilleHousing Table1
JOIN Nashville_Housing.dbo.NashvilleHousing Table2
 ON Table1.ParcelID = Table2.ParcelID 
 AND Table1.[UniqueID ] <> Table2.[UniqueID ] 
 WHERE Table2.PropertyAddress is null 

 UPDATE Table1
 SET PropertyAddress = ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
 FROM Nashville_Housing.dbo.NashvilleHousing Table1
JOIN Nashville_Housing.dbo.NashvilleHousing Table2
 ON Table1.ParcelID = Table2.ParcelID 
 AND Table1.[UniqueID ] <> Table2.[UniqueID ] 
 WHERE Table1.PropertyAddress is null 

 --Breaking out Address into Individual Columns (Address, City, State)

 SELECT PropertyAddress
FROM Nashville_Housing.dbo.NashvilleHousing

SELECT  
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS City

FROM Nashville_Housing.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Address nvarchar(255);


UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD City nvarchar(255);


UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT*
FROM Nashville_Housing.dbo.NashvilleHousing

SELECT OwnerAddress
FROM Nashville_Housing.dbo.NashvilleHousing

	SELECT
		PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Owner_Address
		,PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS Owner_City
		,PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS Owner_State
	FROM Nashville_Housing.dbo.NashvilleHousing
	
ALTER TABLE NashvilleHousing
ADD Owner_Address nvarchar(255);


UPDATE NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD Owner_City nvarchar(255);


UPDATE NashvilleHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD Owner_State nvarchar(255);


UPDATE NashvilleHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in "Sold as vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)	
FROM Nashville_Housing.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 


SELECT SoldAsVacant
	, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		   WHEN SoldAsVacant = 'N' THEN 'NO'	
		   ELSE SoldAsVacant
		   END
FROM Nashville_Housing.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		   WHEN SoldAsVacant = 'N' THEN 'NO'	
		   ELSE SoldAsVacant
		   END


--Remove Duplicates
WITH RowNumCTE AS(
SELECT*, 
		ROW_NUMBER() OVER (
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) row_num


 
 FROM Nashville_Housing.DBO.NashvilleHousing 

 )
 --SELECT*
 DELETE
 FROM RowNumCTE
 WHERE row_num > 1
 --ORDER BY PropertyAddress



 --Delete Unused Columns

 SELECT*
 FROM Nashville_Housing.dbo.NashvilleHousing

 ALTER TABLE Nashville_Housing.dbo.NashvilleHousing
 DROP COLUMN Owner_Address, TaxDistrict, PropertyAddress





