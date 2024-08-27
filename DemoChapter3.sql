---Inner join example--
SELECT 
ProductName,
ListPrice,
UnitCost,
DateKey
FROM PRODUCT prod
INNER JOIN [dbo].[ProductInventory] inv
on prod.ProductKey = inv.ProductKey


--Create a JOIN on the tables Product and ProductSubcategory, select the ProductName,Color and ProductSubcategoryName where the subcategory is 'Jerseys'
SELECT
ProductName,
Color,
ProductSubcategoryName
FROM Product prod
INNER JOIN [dbo].[ProductSubcategory] prodsub
ON prod.ProductSubcategoryKey = prodsub.ProductSubcategoryKey
where prodsub.ProductSubcategoryName = 'Jerseys'----the short-sleeve classic Jersey is yellow

---------Left join example--
SELECT
LastName,
Gender,
geo.City
FROM Customer cust
LEFT JOIN[dbo].[Geography] geo
ON cust.GeographyKey = geo.GeographyKey
---where LastName = 'Martin'

----Create a LEFT JOIN on tables Currency and CurrencyHistory , select the CurrencyName and EndOfDayRate where the CurrencyName is 'Argentine Peso'
SELECT
CurrencyName,
EndOfDayRate,
Date
FROM Currency curr
LEFT JOIN CurrencyHistory currhist
ON curr.CurrencyKey = currhist.CurrencyKey
where CurrencyName = 'Argentine Peso'
AND Date = '2011-04-20';

------Right outer join/Right join--

SELECT
LastName,
YearlyIncome,
City
FROM Customer cust
RIGHT JOIN [dbo].[Geography] geo
ON cust.GeographyKey = geo.GeographyKey

----Create a RIGHT JOIN on tables Product and ProductSupplier , select the ProductName and SupplierKey where the product name is 'Mountain-300 Black, 48'

SELECT
[ProductName],
[SupplierKey]
FROM Product prod
RIGHT JOIN [dbo].[ProductSupplier] sup
ON prod.ProductKey = sup.ProductKey
where [ProductName] = 'Mountain-300 Black, 48';----How many suppliers of the product 'Mountain-300 Black, 48' are there ? 2

----FULL OUTER JOIN--FULL JOIN same
SELECT
[LastName],
[TotalChildren],
[City],
[CountryRegionName]
FROM Customer cust
FULL OUTER JOIN [dbo].[Geography] geo
on cust.GeographyKey = geo.GeographyKey
order by city;--Full outer joins are handy when doing profiling, when trying to see if data is missing or not

---Create a FULL JOIN on tables Supplier and ProductSupplier selecting Supplier and the average lead time for the product supplier
SELECT
ps.[SupplierKey],
[AverageLeadTime],
[Name]
FROM ProductSupplier ps
FULL JOIN [dbo].[Supplier] s
ON  ps.SupplierKey = s.SupplierKey
where Name = 'Crowley Sport'

------CROSS JOIN---
SELECT
LastName,
Gender,
City
FROM Customer cust
CROSS JOIN [dbo].[Geography] geo;

---Create a CROSS JOIN on tables Product and Product inventory selecting Product and Unit balance for the 30 April 2013
SELECT
[ProductName],
[UnitsBalance]
FROM Product
CROSS JOIN [dbo].[ProductInventory]
WHERE MovementDate = '2013-04-30'

----SELF JOIN---
--Are we buying the same product from different suppliers??

--1st Self join which will return the product key and manager key---same products supplied by different suppliers--just reveals keys

SELECT distinct
ps1.Productkey,
'' AS ProductName,
0 as ListPrice,
ps1.Supplierkey,
'' AS Name
FROM ProductSupplier ps1 
INNER JOIN ProductSupplier ps2 ON ps1.ProductKey = ps2.ProductKey and
                                  ps1.SupplierKey <> ps2.SupplierKey---eg same product with 3 different suppliers
								  where ps1.ProductKey = 405
----phase 2, same product supplied by different suppliers, show supplier name
UNION

SELECT distinct
ps1.Productkey,
'' as ProductName,
0 as ListPrice,
ps1.Supplierkey,
sup.Name
FROM ProductSupplier ps1 
INNER JOIN ProductSupplier ps2 ON ps1.ProductKey = ps2.ProductKey and
                                   ps1.SupplierKey <> ps2.SupplierKey inner join
[dbo].[Supplier] sup on ps1.SupplierKey = sup.SupplierKey
where ps1.ProductKey = 405

----phase 2, same product supplied by different suppliers, show supplier name and prduct name
UNION

SELECT distinct
ps1.Productkey,
prd.ProductName,
prd.ListPrice,
ps1.Supplierkey,
sup.Name
FROM ProductSupplier ps1 
INNER JOIN ProductSupplier ps2 ON ps1.ProductKey = ps2.ProductKey and
                                   ps1.SupplierKey <> ps2.SupplierKey inner join
[dbo].[Supplier] sup on ps1.SupplierKey = sup.SupplierKey inner join
[dbo].[Product] prd on ps1.ProductKey = prd.ProductKey
where ps1.ProductKey = 405

--I added the wehere ps1.ProductKey = 405 in all 3 statements above to answer the below exercise
--Exercise:Create a SELF JOIN on tables ProductSupplier where 1 product has more than one supplier reduce the list to product 405--
--How many suppliers does product 405 have = 3

---CROSS JOIN--Scenario- the marketing department requires a set of data that identifies all the product sales for a specific month for example Jan 2014
--They want to see not only the sales of the products across their sales terittory but also, but they also want to include any products that do not have a sale
--I need those product sale for Jan 2014

SELECT 
[SalesTerritoryKey],
[ProductKey],
--[OrderDate],
SUM([SalesAmount]) AS TotalSales
FROM [dbo].[OnlineSales]
where [OrderDate] between '2014-01-01' and '2014-01-31'
group by [SalesTerritoryKey],[ProductKey]--,[OrderDate];

--the query above is showing a bit of what we asked for, it's not showing us the 0(zero) values as well--salest with no sales

SELECT
st.SalesTerritoryKey,
PRD.[ProductKey]
FROM [dbo].[SalesTerritory] st
CROSS JOIN[dbo].[Product] PRD

---Final answer showing all the sales terrorities that have sold and not sold any products in Jan 2014--Final solution incorparting the above queries

SELECT
st.SalesTerritoryKey,
PRD.[ProductKey],
PRD.ProductName,
isnull(TerritorySales.TotalSales,0)
FROM [dbo].[SalesTerritory] st
CROSS JOIN[dbo].[Product] PRD
LEFT JOIN 
	(
		SELECT 
		[SalesTerritoryKey],
		[ProductKey],
		SUM([SalesAmount]) AS TotalSales
		FROM [dbo].[OnlineSales]
		where [OrderDate] between '2014-01-01' and '2014-01-31'
		group by [SalesTerritoryKey],[ProductKey]
	) as TerritorySales --this is a temp table in a way
	ON TerritorySales.SalesTerritoryKey = st.SalesTerritoryKey and
							TerritorySales.ProductKey = PRD.ProductKey
order by TerritorySales.TotalSales desc;-----nfo/data from this query can be used by marketing team in qlikview or Qliksense or PowerBI for the insights they want

----SELECT CROSS OUTER APPLY--
--Scenario: The Promotions manager wants to know if customers purchased products again during a specific promo month and if so, does it correlate to the promo
--Did we get the customers back again during the promotion period?. I need to know if the promo worked!
--Repeat Purchases

SELECT
distinct cust.[CustomerKey]
,[LastName]
,[OrderQuantity]---below we will add the correlated query
,(select min([OrderDate]) from [dbo].[OnlineSales] os1 where cust.CustomerKey = os.CustomerKey and [OrderDate] between '2014-01-01' and '2014-01-31') as FirstOrdered
,(select max([OrderDate]) from [dbo].[OnlineSales] os1 where cust.CustomerKey = os.CustomerKey and [OrderDate] between '2014-01-01' and '2014-01-31') as MostRecentOrdered--might need advise from the dba when it comes to performance for this subquery
FROM [dbo].[Customer] cust
LEFT JOIN [dbo].[OnlineSales] os on cust.CustomerKey = os.CustomerKey and
								os.OrderDate between '2014-01-01' and '2014-01-31';

---Using Outer Apply is like a left join (as above but nicer to code and easy to add more columns as needed)
SELECT
distinct cust.[CustomerKey]
,cust.[LastName]
,CA.[OrderQuantity]
,CA.FirstOrdered
,CA.MostRecentOrdered
FROM 
[dbo].[Customer] cust
OUTER APPLY
		(
			select
				min(OrderDate) as FirstOrdered
				,max(OrderDate) as MostRecentOrdered
				,os.OrderQuantity
				from
		        [dbo].[OnlineSales] os
				where os.CustomerKey = cust.CustomerKey and os.OrderDate between '2014-01-01' and '2014-01-31'
				group by os.OrderQuantity
		)as CA
order by ca.MostRecentOrdered desc;

---Inner Join and correlated subquery--
SELECT
distinct cust.[CustomerKey]
,[LastName]
,[OrderQuantity]---below we will add the correlated query
,(select min([OrderDate]) from [dbo].[OnlineSales] os1 where cust.CustomerKey = os.CustomerKey and [OrderDate] between '2014-01-01' and '2014-01-31') as FirstOrdered
,(select max([OrderDate]) from [dbo].[OnlineSales] os1 where cust.CustomerKey = os.CustomerKey and [OrderDate] between '2014-01-01' and '2014-01-31') as MostRecentOrdered--might need advise from the dba when it comes to performance for this subquery
FROM [dbo].[Customer] cust
inner JOIN [dbo].[OnlineSales] os on cust.CustomerKey = os.CustomerKey and
								os.OrderDate between '2014-01-01' and '2014-01-31';

SELECT
distinct cust.[CustomerKey]
,cust.[LastName]
,CA.[OrderQuantity]
,CA.FirstOrdered
,CA.MostRecentOrdered
,ca.MinFreight
,ca.MaxFreight
FROM 
[dbo].[Customer] cust
CROSS APPLY
		(
			select
				min(OrderDate) as FirstOrdered
				,max(OrderDate) as MostRecentOrdered
				,MIN(os.Freight) as MinFreight
				,max(os.Freight) as MaxFreight
				,os.OrderQuantity
				from
		        [dbo].[OnlineSales] os
				where os.CustomerKey = cust.CustomerKey and os.OrderDate between '2014-01-01' and '2014-01-31'
				group by os.OrderQuantity
		)as CA
order by ca.MostRecentOrdered desc;