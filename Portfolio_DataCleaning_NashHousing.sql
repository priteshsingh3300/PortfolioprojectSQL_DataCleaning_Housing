/*
Cleaning data in SQL queries
*/

select * 
from Portfolio_Housing_DataCleaning.dbo.NashvilleHousingDataforDataCleaning

-------------------------------------------------------------------

--Standardize date format

select SaleDate, convert(date, SaleDate) as filteredDate
from NashvilleHousingDataforDataCleaning

update NashvilleHousingDataforDataCleaning
set SaleDate = convert(date, SaleDate)

--above query is not working so we need to add a new coloumn and then Format the Date
alter table NashvilleHousingDataforDataCleaning
add SaleDateConverted date

update NashvilleHousingDataforDataCleaning
set SaleDateConverted = convert(date, SaleDate)

select SaleDate, convert(date, SaleDate) as filteredDate, SaleDateConverted
from NashvilleHousingDataforDataCleaning

-------------------------------------------------------------------

-- Populate property address data

select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ],  b.ParcelID, b.PropertyAddress
from NashvilleHousingDataforDataCleaning a
--where PropertyAddress is null
inner join NashvilleHousingDataforDataCleaning b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

-- we are updating null property address section with the address by using join
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousingDataforDataCleaning a
inner join NashvilleHousingDataforDataCleaning b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] = b.[UniqueID ]
where a.PropertyAddress is null


-------------------------------------------------------------------

-- merged addresses need to be splitted in 2 different columns

select PropertyAddress, 
substring(PropertyAddress, 1 /*this argument is to start the characters from 1*/, CHARINDEX(',',propertyaddress)-1) as HouseAddress, 
--> charindex is use to extract characters till "comma" and -1 is use to delete last character from extraction
substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) as StateAddress
--> charindex is used here to start characters from "comma" and +1 is use to shift the first character after 'comma'
from NashvilleHousingDataforDataCleaning


--now let's create 2 different columns for address

alter table NashvilleHousingDataforDataCleaning
add HomeAddress nvarchar(255)

alter table NashvilleHousingDataforDataCleaning
add CityAddress nvarchar(255)

update NashvilleHousingDataforDataCleaning
set HomeAddress = substring(PropertyAddress, 1, CHARINDEX(',',propertyaddress)-1)

update NashvilleHousingDataforDataCleaning
set CityAddress = substring(PropertyAddress, CHARINDEX(',',propertyaddress) +1, len(PropertyAddress)) 

select HomeAddress, CityAddress
from NashvilleHousingDataforDataCleaning

-------------------------------------------------------------------

-- Split Owner's address by using parseName instead of substring

select 
ownerAddress,
PARSENAME(replace(ownerAddress,',','.'), 3),
PARSENAME(replace(ownerAddress,',','.'), 2),
PARSENAME(replace(ownerAddress,',','.'), 1)
from NashvilleHousingDataforDataCleaning


--create a specific tables for all splited data
alter table NashvilleHousingDataforDataCleaning
add OwnerhomeAddress Varchar(255)

alter table NashvilleHousingDataforDataCleaning
add OwnerCityAddress Varchar(255)

alter table NashvilleHousingDataforDataCleaning
add OwnerStateAddress Varchar(255)

update NashvilleHousingDataforDataCleaning
set OwnerhomeAddress = PARSENAME(replace(ownerAddress,',','.'), 3)

update NashvilleHousingDataforDataCleaning
set OwnerCityAddress = PARSENAME(replace(ownerAddress,',','.'), 2)

update NashvilleHousingDataforDataCleaning
set OwnerStateAddress = PARSENAME(replace(ownerAddress,',','.'), 1)

select OwnerhomeAddress, OwnerCityAddress, OwnerStateAddress
from NashvilleHousingDataforDataCleaning

-------------------------------------------------------------------

 --Change "Y" and "N" to "YES" & "NO" using case statement in SoldasVacant field

 select distinct(SoldAsVacant), count(SoldAsVacant)
 from NashvilleHousingDataforDataCleaning
 group by SoldAsVacant
 order by SoldAsVacant

 select SoldAsVacant, 
		case 
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'NO'
			else SoldAsVacant
		end as SoldAsVacant_converted
 from NashvilleHousingDataforDataCleaning
 --group by SoldAsVacant
 --order by SoldAsVacant

 update NashvilleHousingDataforDataCleaning
 set SoldAsVacant = case 
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'NO'
						else SoldAsVacant
					end
 from NashvilleHousingDataforDataCleaning

 -- check the updated values now
 select distinct(SoldAsVacant), count(SoldAsVacant)
 from NashvilleHousingDataforDataCleaning
 group by SoldAsVacant
 order by SoldAsVacant

-------------------------------------------------------------------



-------------------------------------------------------------------



-------------------------------------------------------------------
