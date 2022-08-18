--- DATA CLEANING PROJECT
------------------------------------------------------------------------
select *
from DA_Projects..NashvilleHousing

------------------------------------------------------------------------x-------------------------------------------------------------------------
-- Standardise the date format

select nh.SaleDate, nh.SaleDate_Converted
from DA_Projects..NashvilleHousing nh

alter table DA_Projects..NashvilleHousing
add SaleDate_Converted Date

update NashvilleHousing
set SaleDate_Converted = CONVERT(date, SaleDate)

-------------------------------------------------------------------------x-------------------------------------------------------------------------
-- Populate the null values(address data)
select * 
from DA_Projects..NashvilleHousing nh
where nh.PropertyAddress is null
order by nh.ParcelID 

-- here we can populate the address from the row with same parcel id
select x.ParcelID,x.PropertyAddress,y.ParcelID,y.PropertyAddress, ISNULL(x.PropertyAddress,y.PropertyAddress)
from DA_Projects..NashvilleHousing x 
join DA_Projects..NashvilleHousing y
on x.ParcelID = y.ParcelID
and x.[UniqueID ]<>y.[UniqueID ]
where x.PropertyAddress is null



-- update the data
update x
set x.PropertyAddress = ISNULL(x.PropertyAddress,y.PropertyAddress)
from DA_Projects..NashvilleHousing x 
join DA_Projects..NashvilleHousing y
on x.ParcelID = y.ParcelID
and x.[UniqueID ]<>y.[UniqueID ]
where x.PropertyAddress is null

-------------------------------------------------------------------------x-------------------------------------------------------------------------
-- Splitting Address column into Atomic values(1NF)
select nh.PropertyAddress
from DA_Projects..NashvilleHousing nh

select SUBSTRING(nh.PropertyAddress,1,CHARINDEX(',',nh.PropertyAddress)-1) as Address1,
		SUBSTRING(nh.PropertyAddress, CHARINDEX(',',nh.PropertyAddress)+1,len(nh.PropertyAddress)) as Address2
from DA_Projects..NashvilleHousing nh

--- add new columns
alter table DA_Projects..NashvilleHousing
add Address1 nvarchar(255),
Address2 nvarchar(255)
--- update column values
update DA_Projects..NashvilleHousing
set Address1 = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

update DA_Projects..NashvilleHousing
set Address2 = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

--sp_rename 'DA_Projects..NashvilleHousing.Address2','Property Address2','column'
select * from DA_Projects..NashvilleHousing

--- Splitting owner Address (Using PARSENAME)
select nh.OwnerAddress
from DA_Projects..NashvilleHousing nh

select PARSENAME(REPLACE(OwnerAddress,',','.'),1),PARSENAME(REPLACE(OwnerAddress,',','.'),2),
		PARSENAME(REPLACE(OwnerAddress,',','.'),3)
from DA_Projects..NashvilleHousing

alter table DA_Projects..NashvilleHousing
add [Owner Address] nvarchar(255), [Owner City] nvarchar(255),[Owner State] nvarchar(255)

update DA_Projects..NashvilleHousing
set [Owner Address] = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

update DA_Projects..NashvilleHousing
set [Owner City] = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

update DA_Projects..NashvilleHousing
set [Owner State] = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from DA_Projects..NashvilleHousing

-------------------------------------------------------------------------x-------------------------------------------------------------------------
-- Replace 'Y' and 'N' with 'Yes' and 'No' in SoldAsVacant
select distinct nh.SoldAsVacant, count(*)
from DA_Projects..NashvilleHousing nh
group by nh.SoldAsVacant


-- using replace
select nh.SoldAsVacant, REPLACE(nh.SoldAsVacant,'N','No')
from DA_Projects..NashvilleHousing nh
where nh.SoldAsVacant = 'N'

-- using case statement
select nh.SoldAsVacant,
		case 
			when nh.SoldAsVacant = 'N' then 'No'
			when nh.SoldAsVacant = 'Y' then 'Yes'
			else nh.SoldAsVacant
		end as soldV
from DA_Projects..NashvilleHousing nh

update DA_Projects..NashvilleHousing 
set SoldAsVacant = case 
						when SoldAsVacant = 'N' then 'No'
						when SoldAsVacant = 'Y' then 'Yes'
						else SoldAsVacant
				    end 

select distinct SoldAsVacant from DA_Projects..NashvilleHousing

-------------------------------------------------------------------------x-------------------------------------------------------------------------
-- Delete unwanted data
alter table DA_Projects..NashvilleHousing
drop column PropertyAddress,OwnerAddress,SaleDate

-------------------------------------------------------------------------x-------------------------------------------------------------------------
-- Remove duplicates

with Row_Num_CTE as
(
select *,
		ROW_NUMBER() over 
		(
		partition by 
			ParcelID,
			SaleDate_Converted,
			[Property Address1],
			[Property Address2],
			SalePrice,
			LegalReference
		order by UniqueID		
		)[Row number]
from DA_Projects..NashvilleHousing
)
--select *
delete
from Row_Num_CTE
where [Row number]>1
