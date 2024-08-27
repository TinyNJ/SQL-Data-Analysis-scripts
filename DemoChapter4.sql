---CountFunction demo--
--The foundation query--
SELECT 
*
FROM Member;

--Policy manager wants a count of members by gender--
SELECT 
COUNT(*) as NoofMembers
,GENDER
FROM Member
GROUP BY gender;

----Policy manager wants a count of distinct occupations--
SELECT
COUNT(distinct(OCCUPATION)) AS CountOfDistinctOcc
FROM Member;

--Policy manager wants a list of duplicated member biz keys--
--this helps test for duplicates for especially primary keys, primary keys shouldn't have duplicates
SELECT
count([member_biz_key]) as CountMemberbizkey
,[member_biz_key]
FROM Member
GROUP BY [member_biz_key]
Having count ([member_biz_key]) >1
order by 2;

---Policy manager wants a count of members spread across countries--
SELECT
count([country]) as CountCountry
FROM Member;--230 countries

-----USE Chapter3 Sales--
--The sales manager wants a list of product count in each online sales order
--to evaluate the greatest product count overrall

use [Chapter 3 - Sales (Keyed) ]

SELECT 
distinct count([ProductKey]) OVER(PARTITION BY[SalesOrderNumber] ) as ProductCount
,[SalesOrderNumber]
FROM OnlineSales
ORDER BY 1 DESC;

---Write a query to return the count of claims where the notification date is in the year 2014 and the claimants age is between 33 and 48
use [Chapter 4 - Insurance]

SELECT
count(claims.[MemberKey]) as CountOfClaims
--,m.age
FROM [dbo].[MemberClaims] claims
JOIN[dbo].[Member] m on claims.[MemberKey] = m.[MemberKey]
--where claims.[claimnotificationdate] between '2014-01-01' and '2014-12-31' and m.age between 33 and 48;---this also works
where YEAR(claims.[claimnotificationdate]) = 2014 and m.age between 33 and 48;
----group by m.age
--order by 1 desc;

---SUM function demo--

--The foundation query--
SELECT
*
FROM [dbo].[MemberClaims]
ORDER BY claimpaiddate DESC;
---The claims manager requested the total claims $ paid for death and TPO claim type during the year 2014
SELECT
YEAR([claimpaiddate]) AS [Year]
,[ClaimType]
,sum([claimpaidamount]) as TotalClaimPaid
FROM [dbo].[MemberClaims] claim
WHERE YEAR([claimpaiddate]) = 2014 and [ClaimType] in ('DTH','TPD')
GROUP BY YEAR([claimpaiddate]), [ClaimType]
ORDER BY YEAR([claimpaiddate]) DESC;

---The claims manager has requested a list of the top 5 claim cause categories for claim type TPD in 2014
-- and grouped by the member gender

SELECT
TOP(5) YEAR([claimpaiddate]) AS [Year]
,cl.[ClaimCauseCategory]
,sum([claimpaidamount]) as TotalClaimPaid
,m.[gender]
,cl.[ClaimType]
FROM [dbo].[MemberClaims] cl
JOIN [dbo].[Member] m on cl.[MemberKey] = m.[MemberKey]
where YEAR([claimpaiddate]) = 2014
and [ClaimType] = 'TPD'
GROUP BY YEAR([claimpaiddate]), cl.[ClaimCauseCategory], m.[gender],cl.[ClaimType]
order by TotalClaimPaid desc;

--or-
SELECT
TOP(5) YEAR([claimpaiddate]) AS [Year]
,cl.[ClaimCauseCategory]
,[ClaimType]
,sum([claimpaidamount]) as TotalClaimPaid
,gender
FROM [dbo].[MemberClaims] cl
JOIN [dbo].[Member] m on cl.[MemberKey] = m.[MemberKey]
WHERE YEAR([claimpaiddate]) = 2014 and [ClaimType] = 'TPD'
GROUP BY YEAR([claimpaiddate]), cl.[ClaimCauseCategory],[ClaimType], gender
ORDER BY TotalClaimPaid desc

---Write a query to aggregate the Claim paid for the year 2010 where the claimants reside in postal code 4061, ensure Claim Cause is returned in the query

SELECT
SUM([claimpaidamount]) AS TotalClaimPaid
,[ClaimCause]
,[postal_code]
,YEAR([claimpaiddate]) AS [Year]
FROM [dbo].[MemberClaims] cl
JOIN[dbo].[Member] m ON cl.[MemberKey] = m.[MemberKey]
where [postal_code] = '4061'
Group By [ClaimCause],[postal_code], YEAR([claimpaiddate])
order by TotalClaimPaid desc--

--Average function--
--Product manager wants to get an idea of the mean of the insurance covers and premium paid across the age groups in year 2014
--Foundation query
SELECT
AVG([total_death_cover]) AS AverageDeathCover
,AVG([total_death_cover_premium]) AS AverageDeathCPre
,AVG([total_ip_cover]) AS AverageIPCover
,AVG([total_ip_cover_premium]) AS AverageIPCPre
,AVG([total_tpd_cover]) AS AverageTPDCover
,AVG([total_tpd_cover_premium]) AS AverageTPDPre
,m.age
,[underwriting_year]
FROM [dbo].[MemberCover] mc
join[dbo].[Member] m on mc.[MemberKey] = m.MemberKey
where [underwriting_year] = 2014
GROUP BY m.age, [underwriting_year]
ORDER BY m.age;---DO A VISUAL ON POWER BI FOR THIS TOO

------Write a query to find the average Claim Paid amount and Total Death Cover amount where claimants have insurance cover for death in 
--the underwriting year of 2012 and were paid (hint status). The claim type to return is 'DTH' and the Cause Category is 'FATALITY'

SELECT
AVG([claimpaidamount]) AS AverageClaimPaid
,SUM([total_death_cover]) AS TOTAL
,[underwriting_year]
,[claimstatus]
,[ClaimType]
,[ClaimCauseCategory]
FROM [dbo].[MemberClaims] cl
JOIN[dbo].[MemberCover] mc ON cl.[MemberKey] = mc.[MemberKey]
where [underwriting_year] = 2012
AND [ClaimType] = 'DTH'
AND [ClaimCauseCategory] = 'FATALITY'
AND [claimstatus] = 'Paid'
group by [total_death_cover]
,[underwriting_year]
,[claimstatus]
,[ClaimType]
,[ClaimCauseCategory]
order by AverageClaimPaid;---REVISIT THIS


-----MIN Function demo--
---The policy manager wants to know the lowest annual salary of our members--
--Foundation query
SELECT
* FROM
[dbo].[Member];


SELECT
MIN([annual_salary]) AS MinSalary
FROM
[dbo].[Member];

--------Claims manager is looking for detail around the claim categories/causes that paid the smallest amount, and
---what was the % contribution of claims paid by the cause--(so what the smallest claims amount is across the category causes)

SELECT
[ClaimCauseCategory]
,[ClaimCause]
,[claimstatus]
,MIN([claimpaidamount]) AS SMALLESTCLAIMPAID
,SUM([claimpaidamount]) AS TOTALCLAIMSPAID
,COUNT([ClaimCause]) AS CLAIMCOUNT
,(MIN([claimpaidamount])/ SUM([claimpaidamount])) * 100 AS PctOfAllCauses
FROM [dbo].[MemberClaims]
WHERE [claimstatus] = 'Paid'
GROUP BY [ClaimCauseCategory]
,[ClaimCause]
,[claimstatus]
order by 1;

---Write a query to find the minimum salary and date joined fund for the members with the status of '2) Medium Earner'
SELECT
MIN([annual_salary]) AS MinSalary
,[date_joined_fund]
,[employee_status]
FROM [dbo].[Member]
where [employee_status] = '2) Medium Earner'
group by [date_joined_fund]
,[employee_status]
order by 1;--Min salary = R55 182,95.

----MAX Function--
--The product manager needs to know the max salary for the members--

SELECT
MAX([annual_salary]) AS MaxSalary
FROM[dbo].[Member];--R726 669,74

----Marketing wants to understand the Counts, Max, Min, Mean Salaries for all members of age range 19 -65 grouped by age--
SELECT
COUNT([MemberKey]) AS CountMember
,MAX([annual_salary]) AS MaxSalary
,MIN([annual_salary]) AS MinSalary
,AVG([annual_salary]) AS AvgSalary
,[age]
FROM [dbo].[Member]
where [age] between 19 and 65
group by [age]
order by [age] asc;

---Write a query to return the maximum IP cover premium for the underwriting year of 2012--
SELECT
MAX([total_ip_cover_premium]) AS TotalIPCoverPre
,[underwriting_year]
FROM [dbo].[MemberCover]
where[underwriting_year] = 2012
Group by [underwriting_year];---R26 232, 78

--Marketing manager asked me to add the MEDIAN salary to the data set.--
SELECT
COUNT([MemberKey]) AS CountMember
,MAX([annual_salary]) AS MaxSalary
,MIN([annual_salary]) AS MinSalary
,AVG([annual_salary]) AS AvgSalary
,mem.[age]
, (select TOP(1) PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY[annual_salary] DESC) OVER (PARTITION BY age) from [dbo].[Member] mem1 where mem1.age = mem.age) as MedianSalary
FROM [dbo].[Member] mem
where [age] between 19 and 65
group by [age]
order by [age] asc;

---To test the median, to prove it--
SELECT
[annual_salary]
FROM [dbo].[Member]
WHERE AGE = 19
ORDER BY 1;----5 SALARIES AND THE MEDIAN IS 57929,54, which is correct.

-------Write a query to sum all claim paid amounts for the cause of 'Shoulder Injury' and calculate the Median claim paid amount for this cause--
SELECT
SUM([claimpaidamount]) AS TotalClaimsPaid
,mc.[ClaimCause]
,(Select TOP(1) PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [claimpaidamount] DESC) OVER (PARTITION BY [ClaimCause]) FROM [dbo].[MemberClaims] mc1 where mc1.ClaimCause = mc.[ClaimCause]) as MedianClaimPaid
FROM [dbo].[MemberClaims] mc
where [ClaimCause] = 'Shoulder Injury'
group by mc.[ClaimCause]
order by mc.[ClaimCause] asc;

---Using the CASE Statement--
--The policy manager has observed that the data in member cover does not show a column for CoverType
--How can we create a list of member covers that shows the cover type abbreviation e.g. DTH, for the underwriting year year 2014

---Searched Case Expression (within a select statement, the searched CASE expression allows for values to be replaced in the result set based on comparison values)
SELECT
MemberKey
,[total_death_cover]
, 'Cover Type' =
	case
	   when [total_death_cover] <>0 then 'DTH'
	end
FROM[dbo].[MemberCover]
WHERE [underwriting_year] = 2014
AND [total_death_cover] <> 0;

---Simple case expression (WITHIN a select statement, a simple CASE expression allows for only an equality check; no other comparisons are made)

SELECT
[MemberKey]
,gender
	, CASE gender
	when 'Male' then 'M'
	when 'Female' then 'F'
	else
	'?'
	END as GenderAbbre
FROM [dbo].[Member]

------------Write a query to use a search case to create an abbreviated band where the age band is '(49 - 58) Baby boomers' , set the new band equal to 'Boomer' and ensure the else is included for the non matched age bands otherwise a NULL will appear in the band value , include the member key in the column and order by this key
SELECT
[MemberKey]
,AGE
,'Age Band' =
		case
		when AGE between 49 and 58 then 'Boomer'
		else
		'?'
		end
FROM [dbo].[Member]
order by 
[MemberKey];

------ Demo SQL NTILE() ranking function


use [Chapter 3 - Sales (Keyed) ] ;					--<<< Sales db for this excercise

-- The Senior data analyst requires a list of Customer sales by quartile across Country/Province for France			

-- Base query from the purpose created view
-- The view is a list of all sales totals across the globe

SELECT
*
FROM [dbo].[CustomerPurchasesAllTime];

/*
	Quartiles tell us about the spread of a data by breaking the data set into quarters, just like the median breaks it in half (2 Groups).
		
	In SQL we can use the NTILE() ranking function

	The groups are numbered, starting at one. 
	For each row, NTILE returns the number of the group to which the row belongs i.e. the Quartile.

	
*/

	-- Base view, these can be useful when abstracting the complexity of an SQL query
	-- Learn about creating a view in the last chapter of this course

	select
		*
	from
		[dbo].[CustomerPurchasesAllTime]

	-- Summary query answers part of the question 

	select
		sum(cp.[PurchaseTotal]) as TotalPurchased
		,geo.CountryRegionName
		,geo.StateProvinceName
	from
		[dbo].CustomerPurchasesAllTime cp inner join
		[dbo].[Geography] geo on cp.GeographyKey = geo.GeographyKey and 
								 geo.CountryRegionName='France'
	group by	
		 geo.CountryRegionName
		,geo.StateProvinceName
	order by
   		 geo.CountryRegionName

	-- Introduce the NTILE() function to divide our sales into quartile groups

	select
		 NTILE(4) OVER(partition by geo.CountryRegionName ORDER BY sum(cp.[PurchaseTotal]) asc) as Quartile
		,sum(cp.[PurchaseTotal]) as TotalPurchased
		,geo.CountryRegionName
		,geo.StateProvinceName
	from
		[dbo].CustomerPurchasesAllTime cp inner join
		[dbo].[Geography] geo on cp.GeographyKey = geo.GeographyKey and 
								 geo.CountryRegionName='France'
	group by	
		 geo.CountryRegionName
		,geo.StateProvinceName
	order by
   		 geo.CountryRegionName



