--- EDA Covid19 India
-------------------------------------------------------------
select *
from DA_Projects..covid_19_india


select *
from DA_Projects..covid_vaccine_statewise as v
----------------------------------------------------------------
-- 1.Total number of infected people in India in 2020
select sum(ci.Confirmed) as [Total cases]
from DA_Projects..covid_19_india ci
where ci.Date between '2020-01-01' and '2020-12-31'

-- 2.Total number of people infected in each state
select ci.[State/UnionTerritory], SUM(ci.Confirmed) as [Total covid cases] 
from DA_Projects..covid_19_india ci
group by ci.[State/UnionTerritory]

-- 3.State with highest covid cases
select top 1 ci.[State/UnionTerritory], SUM(ci.Confirmed) as [Total covid cases] 
from DA_Projects..covid_19_india ci
group by ci.[State/UnionTerritory]
order by [Total covid cases] desc

-- 4.Top 3 states with highest covid cases
-- select top 3 ci.[State/UnionTerritory], SUM(ci.Confirmed) as [Total covid cases] 
select ci.[State/UnionTerritory], SUM(ci.Confirmed) as [Total covid cases] 
from DA_Projects..covid_19_india ci
group by ci.[State/UnionTerritory]
order by [Total covid cases] desc
offset 0 row
fetch first 3 rows only

-- 5.death per infected percent 
select ci.Date, ci.[State/UnionTerritory], ci.Deaths, ci.Confirmed as [Total cases], (ci.Deaths/nullif(ci.Confirmed,0))*100 [Death per infected percent]
from DA_Projects..covid_19_india ci
order by ci.Date
-- 6.highest death percent
select top 1 ci.Date, ci.[State/UnionTerritory], ci.Deaths, ci.Confirmed as [Total cases], (ci.Deaths/nullif(ci.Confirmed,0))*100 [Death per infected percent]
from DA_Projects..covid_19_india ci
order by [Death per infected percent] desc

-- 7.max death percent in each state
select ci.[State/UnionTerritory], 
		max((ci.Deaths/nullif(ci.Confirmed,0))*100) [Max Death per infected percent]
from DA_Projects..covid_19_india ci
group by ci.[State/UnionTerritory] 
order by ci.[State/UnionTerritory]

-- 8.min death percent state with date on which it was observed
with MaxDP ( Date,State, DP)
as
(
select ci.Date, ci.[State/UnionTerritory], (ci.Deaths/nullif(ci.Confirmed,0))*100 [Death per infected percent]
from DA_Projects..covid_19_india ci
--order by [Death per infected percent] desc
)
select Date,State,DP 
from MaxDP
where DP=
	(
	select min(DP)
	from MaxDP
	where DP <>0
	)

------------------------------------------------
-- 9.Total patients who recovered from covid19
select sum(ci.Cured) as [Recovered patients]
from DA_Projects..covid_19_india ci

-- 10.state with highest recovery count
select top 1 ci.[State/UnionTerritory], sum(ci.Cured) as [Total recovered Patients]
from DA_Projects..covid_19_india ci
group by ci.[State/UnionTerritory]
order by [Total recovered Patients] desc

-- 11.infection rate in each month 2020
select 
	case
		when Datepart(MONTH, ci.Date)= 1 then 'January'
		when DATEPART(MONTH,ci.Date)= 2 then 'Febraury'
		when DATEPART(MONTH,ci.Date)= 3 then 'March'
		when DATEPART(MONTH,ci.Date)= 4 then 'April'
		when DATEPART(MONTH,ci.Date)= 5 then 'May'
		when DATEPART(MONTH,ci.Date)= 6 then 'June'
		when DATEPART(MONTH,ci.Date)= 7 then 'July'
		when DATEPART(MONTH,ci.Date)= 8 then 'August'
		when DATEPART(MONTH,ci.Date)= 9 then 'September'
		when DATEPART(MONTH,ci.Date)= 10 then 'October'
		when DATEPART(MONTH,ci.Date)= 11 then 'November'
		when DATEPART(MONTH,ci.Date)= 12 then 'December'
end as [Month], sum(ci.Confirmed) as [Total cases reported]
from DA_Projects..covid_19_india ci
where ci.date between '2020-01-01' and '2020-12-31'
group by DATEPART(MONTH, ci.Date)
order by DATEPART(MONTH, ci.Date)

-- 12.Month with maximum infection rate in 2021
select top 1
	case
		when Datepart(MONTH, ci.Date)= 1 then 'January'
		when DATEPART(MONTH,ci.Date)= 2 then 'Febraury'
		when DATEPART(MONTH,ci.Date)= 3 then 'March'
		when DATEPART(MONTH,ci.Date)= 4 then 'April'
		when DATEPART(MONTH,ci.Date)= 5 then 'May'
		when DATEPART(MONTH,ci.Date)= 6 then 'June'
		when DATEPART(MONTH,ci.Date)= 7 then 'July'
		when DATEPART(MONTH,ci.Date)= 8 then 'August'
		when DATEPART(MONTH,ci.Date)= 9 then 'September'
		when DATEPART(MONTH,ci.Date)= 10 then 'October'
		when DATEPART(MONTH,ci.Date)= 11 then 'November'
		when DATEPART(MONTH,ci.Date)= 12 then 'December'
end as [Month], sum(ci.Confirmed) as [Total cases reported]
from DA_Projects..covid_19_india ci
where ci.date between '2021-01-01' and '2021-12-31'
group by DATEPART(MONTH, ci.Date)
order by [Total cases reported] desc


--- 13.states with total recovery and death rate in a particular month or date range
select ci.[State/UnionTerritory], format((sum(ci.Cured)/sum(ci.Confirmed))*100, 'N6') as [Recovery rate(june 2021)],
		format((sum(ci.Deaths)/sum(ci.Confirmed))*100, 'N6') as [Death rate(june 2021)]	
from DA_Projects..covid_19_india ci
where DATEPART(Month, ci.Date) = 6 and DATEPART(YEAR, ci.Date)= 2021 
group by ci.[State/UnionTerritory]

select *
from DA_Projects..covid_19_india ci
where DATEPART(Month, ci.Date) = 6 and DATEPART(YEAR, ci.Date)= 2021 
---------------------------------------------------------------------------------------

-- Analysing trends with population of india (1,393,409,038)approx.
declare @population bigint
set @population = 1393409038

-- 14. Max Recovery rate of India with respect to population in 2020
select (max(ci.Cured)/@population)*100 as [Recovery rate(%)]
from DA_Projects..covid_19_india ci
where Date between '2020-01-01' and '2020-12-31' 

-- 15.Total infection, death and recovery rate with respect to population of India in 2020
select (sum(Confirmed)/(@population))*100 as [Total infection rate(2020)],
		(sum(Deaths)/(@population))*100 as [Total death rate(2020)], 
		(sum(Cured)/(@population))*100 as [Total recovery rate(2020)]
from DA_Projects..covid_19_india 
where Date between '2020-01-01' and '2020-12-31' 

-- 16.Total recovery and death rate of India in 2020
select (sum(cured)/sum(confirmed))*100 as [Total recovery rate(2020)],
		(sum(Deaths)/sum(Confirmed))*100 as [Total death rate(2020)]
from DA_Projects..covid_19_india 
where Date between '2020-01-01' and '2020-12-31' 

