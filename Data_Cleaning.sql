/*
Cleaning Data in SQL Queries:

*/

select
 *
from
 msba23..[Nashville-Housing]

--Standardize Date Format:

update [Nashville-Housing]
set SaleDateConverted = convert(date,SaleDate)

alter table [Nashville-Housing]
add SaleDateConverted date;


--Populate Property Address Data

select
 nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, isnull(nh1.PropertyAddress,nh2.PropertyAddress)
from
 msba23..[Nashville-Housing] as nh1
 join msba23..[Nashville-Housing] as nh2
 on nh1.ParcelID = nh2.ParcelID
 and nh1.[UniqueID ] <> nh2.[UniqueID ]
where
 nh1.PropertyAddress is null

update nh1
set PropertyAddress = isnull(nh1.PropertyAddress,nh2.PropertyAddress)
from
 msba23..[Nashville-Housing] as nh1
 join msba23..[Nashville-Housing] as nh2
 on nh1.ParcelID = nh2.ParcelID
 and nh1.[UniqueID ] <> nh2.[UniqueID ]
where
 nh1.PropertyAddress is null



--Breaking out Address into individual columns (Address, City, and State)
--Starting with the propertyaddress column
select
 PropertyAddress
from
 msba23..[Nashville-Housing]
--where
--PropertyAddress is null
--order by
--ParcelID

select
 substring(PropertyAddress,1, charindex(',', PropertyAddress) -1) as Address,
 substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from
 msba23..[Nashville-Housing]


alter table [Nashville-Housing]
add PropertySplitAddress nvarchar(255);

update [Nashville-Housing]
set PropertySplitAddress = substring(PropertyAddress,1, charindex(',', PropertyAddress) -1)


alter table [Nashville-Housing]
add PropertySplitCity nvarchar(255);

update [Nashville-Housing]
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Similar work as directly above but working with even more information in a column:
select
 owneraddress
from
[Nashville-Housing]

select
 parsename(replace(owneraddress,',','.'),3),
 parsename(replace(owneraddress,',','.'),2),
 parsename(replace(owneraddress,',','.'),1)
from
 [Nashville-Housing]


alter table [Nashville-Housing]
add OwnerSplitAddress nvarchar(255);

update [Nashville-Housing]
set OwnerSplitAddress = parsename(replace(owneraddress,',','.'),3)


alter table [Nashville-Housing]
add OwnerSplitCity nvarchar(255);

update [Nashville-Housing]
set OwnerSplitCity = parsename(replace(owneraddress,',','.'),2)

alter table [Nashville-Housing]
add OwnerSplitState nvarchar(255);

update [Nashville-Housing]
set OwnerSplitState = parsename(replace(owneraddress,',','.'),1)



--Changing Y and N values to Yes and No:
select
 distinct(soldasvacant), count(soldasvacant)
from
 [Nashville-Housing]
group by
 SoldAsVacant
order by
 2

select
 SoldAsVacant,
 case 
 when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end
from
 [Nashville-Housing]

update [Nashville-Housing]
set SoldAsVacant =  case 
 when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end



--Removing Duplicates:
with row_numCTE as(
select
 *,
 ROW_NUMBER() Over(
 partition by parcelid,
			  propertyaddress,
			  saleprice,
			  saledate,
			  legalreference
			  order by
			  uniqueid
			  ) row_num
from 
 [Nashville-Housing]
--order by
--ParcelID
)
delete
from
 row_numCTE
where
 row_num > 1



--Removing unused columns:
Select
 *
from
 [Nashville-Housing]

alter table msba23..[Nashville-Housing]
drop column owneraddress, taxdistrict, propertyaddress, saledate







