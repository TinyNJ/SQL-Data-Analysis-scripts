---Repractice chapter 2 sales--
Select 142+156/2;--220

Select (142 + 156) /2;--149

Select * from Product;--606 rows

--Quiz3

Select occupation 
from [dbo].[Customer]
where Gender = 'M';


---How many customers have an income less than 60000?

--Foundation query
Select * from [dbo].[Customer];

Select distinct(HouseOwnerFlag)
from[dbo].[Customer];

Select count(*)
from [dbo].[Customer]
where [YearlyIncome] < 60000;

Select count(*)
from[dbo].[Customer]
where [HouseOwnerFlag] = 1
and [YearlyIncome] > 100000
and [MaritalStatus] = 'M';

Select count(*)
from [dbo].[Customer]
where[YearlyIncome] between 75000 and 75500;

Select count(*)
from[dbo].[Customer]
where[EmailAddress] LIKE '%cedric%'
and[NumberChildrenAtHome] between 2 and 4;

Select avg([NumberChildrenAtHome]) as NumberOfChildrenStayedAtHome, MaritalStatus
from[dbo].[Customer]
group by MaritalStatus
HAVING MaritalStatus ='M' or MaritalStatus = 'S';

select

avg([NumberChildrenAtHome]) as [NumberChildrenAtHome],

[MaritalStatus]

from

[dbo].[Customer]

where

[MaritalStatus] = 'M' or

[MaritalStatus] = 'S'

group by

[MaritalStatus]


Select
AVG([YearlyIncome])
,[Gender]
,[EducationLevel]
FROM[dbo].[Customer]
GROUP BY 
[Gender]
,[EducationLevel]
HAVING [Gender] = 'F'
and [EducationLevel] ='Graduate Degree';

--Cal Avg over the group (across genders)
Select
AVG([NumberCarsOwned]) as AvgCarsOwned
,[Gender]
,[EducationLevel]
from customer
Group by rollup
([Gender]
,[EducationLevel])
HAVING [EducationLevel] = 'Partial High School';


---
Select
AVG([TotalChildren]) as AVGTotachidlren
, [MaritalStatus]
FROM [dbo].[Customer]
group by ([MaritalStatus])
having [MaritalStatus] = 'S';

-- Calc AVG over the group

select
	 avg([YearlyIncome]) as [YearlyIncome]
	,[EducationLevel]
	,[Gender]
from
	[dbo].[Customer]
group by rollup ([EducationLevel],[Gender])	

