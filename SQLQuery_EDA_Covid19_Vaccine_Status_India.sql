-- EDA of Covid19 vaccination status data of India
----------------------------------------------------------------
select *
from DA_Projects..covid_vaccine_statewise cvi
----------------------------------------------------------------
-- Total doses administered and total individuals vaccinated per state, and the rate of vaccination 
select cvi.State, sum(cvi.[Total Doses Administered])as [Total Doses Administered],
		sum(cvi.[Total Individuals Vaccinated]) as[Total Individuals Vaccinated],
		(sum(cvi.[Total Individuals Vaccinated])/sum(cvi.[Total Doses Administered]))*100 as [Vaccination rate per Total Doses(%)]
from DA_Projects..covid_vaccine_statewise cvi
group by cvi.State
order by [Vaccination rate per Total Doses(%)] desc

-- Vaccination rate by gender of India
select cvi.State, sum(cvi.[Female(Individuals Vaccinated)])as Females,
		sum(cvi.[Male(Individuals Vaccinated)])as Males,
		sum(cvi.[Transgender(Individuals Vaccinated)])as Transgender
from DA_Projects..covid_vaccine_statewise cvi
where cvi.State = 'India'
group by cvi.State

-- Statistics of each vaccines used
select sum(cast(cvi.[ Covaxin (Doses Administered)]as bigint))as Covaxin,
		sum(cast(cvi.[CoviShield (Doses Administered)]as bigint))as CoviShield,
		sum(cast(cvi.[Sputnik V (Doses Administered)]as bigint))as [Sputnik V]
from DA_Projects..covid_vaccine_statewise cvi 
where cvi.State = 'India'
------------------------------------------------------------------------------------------------------
-- Vaccination count by age group for each state
select cvi.State, sum(cast(cvi.[18-44 Years(Individuals Vaccinated)]as bigint))as [18-44 yrs],
				sum(cast(cvi.[45-60 Years(Individuals Vaccinated)]as bigint))as [45-60 yrs],
				sum(cast(cvi.[60+ Years(Individuals Vaccinated)]as bigint))as [60+ yrs]
from DA_Projects..covid_vaccine_statewise cvi
group by cvi.State
having cvi.State<>'India'

-- Age group which has highest vaccination count
-----using CTE
with AgeGroupMax ([Age group],[Count])
as
(
select cast('18-44' as nvarchar(20)),sum(cast(cvi.[18-44 Years(Individuals Vaccinated)]as bigint))
from DA_Projects..covid_vaccine_statewise cvi
union
select	cast('18-44' as nvarchar(20)),sum(cast(cvi.[45-60 Years(Individuals Vaccinated)]as bigint))
from DA_Projects..covid_vaccine_statewise cvi
union
select	cast('18-44' as nvarchar(20)),sum(CAST(cvi.[60+ Years(Individuals Vaccinated)]as bigint))
from DA_Projects..covid_vaccine_statewise cvi
)
select a.[Age group],a.Count
from AgeGroupMax  a
where a.Count = (select MAX([Count])
				 from AgeGroupMax 	
					)
---- OR ----
---------- using case statement
select 
	case
		when tb.[18-44 yrs]>tb.[45-60 yrs] and tb.[18-44 yrs]>tb.[60+ yrs] then tb.[18-44 yrs] 
		when tb.[45-60 yrs]>tb.[18-44 yrs] and tb.[45-60 yrs]>tb.[60+ yrs] then tb.[45-60 yrs] 
		else tb.[60+ yrs] 
	end [Max count Age Group]
from
(select sum(cast(cvi.[18-44 Years(Individuals Vaccinated)]as bigint))[18-44 yrs],
		sum(cast(cvi.[45-60 Years(Individuals Vaccinated)]as bigint))[45-60 yrs],
		sum(CAST(cvi.[60+ Years(Individuals Vaccinated)]as bigint))[60+ yrs]
from DA_Projects..covid_vaccine_statewise cvi) tb
--------------------------------------------------------------------------------------------------------------

--- Vaccination count per day
select cvi.[Updated On], sum(cvi.[Total Individuals Vaccinated])as [Total vaccinations taken]
from DA_Projects..covid_vaccine_statewise cvi
group by cvi.[Updated On]

--- Day on which highest vaccination was reported
select top 1 cvi.[Updated On], sum(cvi.[Total Individuals Vaccinated])as [Total vaccinations taken(all India level)]
from DA_Projects..covid_vaccine_statewise cvi
group by cvi.[Updated On]
order by [Total vaccinations taken(all India level)] desc

-- Highest vaccination count of each state and percent wrt total vaccination count
select c.State,c.[Total vaccinations taken(State-wise)], 
		(c.[Total vaccinations taken(State-wise)]/c.[Total Vaccinations])*100 as [Vaccination Rate(all india)]
from
(
select cvi.State, sum(cvi.[Total Individuals Vaccinated])as [Total vaccinations taken(State-wise)],
		(
		 select sum(cvi.[Total Individuals Vaccinated])
		 from DA_Projects..covid_vaccine_statewise cvi
		 where cvi.State <> 'India'
		 ) 
		 as [Total Vaccinations]
from DA_Projects..covid_vaccine_statewise cvi
group by cvi.State
having cvi.State<>'India'
)c
order by 2

--- JOINING two tables
select ci.Date, ci.[State/UnionTerritory], ci.Confirmed as [Total cases], ci.Cured,
		ci.Deaths, cvi.[Total Doses Administered],cvi.[Total Individuals Vaccinated] 
from DA_Projects..covid_19_india ci
inner join DA_Projects..covid_vaccine_statewise cvi
on ci.[State/UnionTerritory]=cvi.State 
and ci.Date = cvi.[Updated On]
where ci.Date between '2021-01-01' and '2021-12-31'



