-- Category performance over time (Time series) 

/*	-- Scenario --- 

	-- We are an online retailer, our CEO of wants a performance analysis of DAILY sales by
	-- product grouped by product category for the year 2013 , the CEO wants to see when the 
	-- product was first sold																				

	-- Our CEO has requested when was the product first stocked to be added to the summary as well			
	-- do CSQ on [dbo].[ProductInventory] 


*/

-- Initial build up

	select
		 [OrderDate]
		,[ProductName]
		,sum([SalesAmount]) as TotalSales
	from
		[dbo].[OnlineSales] os inner join
		[dbo].[Product] prod on os.ProductKey = prod.ProductKey
	group by	 
		 [OrderDate]
		,[ProductName]
	order by
		 [OrderDate]
		,[ProductName]	

-- Add product categories 

	select
		 convert(date,[OrderDate]) as [Purchase date]
		,pc.ProductCategoryName
		,[ProductName]
		,sum([SalesAmount]) as TotalSales
	from
		[dbo].[OnlineSales] os inner join
		[dbo].[Product] prod on os.ProductKey = prod.ProductKey and
								year([OrderDate]) = 2013		inner join
		[dbo].[ProductSubcategory] psc on prod.ProductSubcategoryKey = psc.ProductSubcategoryKey inner join
		[dbo].[ProductCategory] pc on psc.ProductCategoryKey = pc.ProductCategoryKey
	group by	 
		 [OrderDate]
		,pc.ProductCategoryName
		,[ProductName]
	order by
		 [OrderDate]
		,pc.ProductCategoryName
		,[ProductName]	
	
-- Add product first sold using correlated sub query


	select
		 convert(date,[OrderDate]) as [Purchase date]
		,pc.ProductCategoryName
		,[ProductName]
		,(select min(cast(os1.[OrderDate] as date)) from [dbo].[OnlineSales] os1 where os1.ProductKey = os.ProductKey ) as [First sold date]
		,sum([SalesAmount]) as TotalSales
	from
		[dbo].[OnlineSales] os inner join
		[dbo].[Product] prod on os.ProductKey = prod.ProductKey and
								year([OrderDate]) = 2013		inner join
		[dbo].[ProductSubcategory] psc on prod.ProductSubcategoryKey = psc.ProductSubcategoryKey inner join
		[dbo].[ProductCategory] pc on psc.ProductCategoryKey = pc.ProductCategoryKey
	group by	 
		 [OrderDate]
		,pc.ProductCategoryName
		,[ProductName]
		,os.ProductKey
	order by
		 [OrderDate]
		,pc.ProductCategoryName
		,[ProductName]	

-- Our CEO has requested when was the product first stocked to be added to the summary as well			
	-- do CSQ on [dbo].[ProductInventory] 

Select * from [dbo].[ProductInventory];

select
		 convert(date,[OrderDate]) as [Purchase date]
		,pc.ProductCategoryName
		,[ProductName]
		,(select min(cast(os1.[OrderDate] as date)) from [dbo].[OnlineSales] os1 where os1.ProductKey = os.ProductKey ) as [First sold date]
		,(select min([MovementDate]) as date) from 
		,sum([SalesAmount]) as TotalSales
	from
		[dbo].[OnlineSales] os inner join
		[dbo].[Product] prod on os.ProductKey = prod.ProductKey and
								year([OrderDate]) = 2013		inner join
		[dbo].[ProductSubcategory] psc on prod.ProductSubcategoryKey = psc.ProductSubcategoryKey inner join
		[dbo].[ProductCategory] pc on psc.ProductCategoryKey = pc.ProductCategoryKey inner join
        [dbo].[ProductInventory] pinv on os.ProductKey = pinv.ProductKey
	group by	 
		 [OrderDate]
		,pc.ProductCategoryName
		,[ProductName]
		,os.ProductKey
	order by
		 [OrderDate]
		,pc.ProductCategoryName
		,[ProductName]	-----revisit this

		--min(movemementDate

---duplicate check example

		Select
		[ProductKey]
		,[ProductName]
		,[SafetyStockLevel]
		,count (*)
		from [dbo].[Product]
		GROUP BY
		[ProductKey]
		,[ProductName]
		,[SafetyStockLevel]
		HAVING count (*) >1;

	---NULL VALUE Check
	Select
		[ProductKey]
		,[ProductName]
		,[SafetyStockLevel]
	FROM [dbo].[Product]
	WHERE [ProductName] IS NULL;

	--DATA TYPE check---using CASE and IS OF--

	SELECT 
	[StandardCost]
	,[SizeUnitMeasureCode]
	,[Weight]
	CASE
	 WHEN [StandardCost] IS OF money then 'money'
	 WHEN [SizeUnitMeasureCode] IS OF char then 'char'
	 WHEN [Weight] IS OF float then 'float'
	 else 'Other'
	END AS DataType
	FROM [dbo].[Product];

	SELECT 
    [StandardCost],
    [SizeUnitMeasureCode],
    [Weight],
    CASE
        WHEN SQL_VARIANT_PROPERTY([StandardCost], 'BaseType') = 'money' THEN 'money'
        WHEN SQL_VARIANT_PROPERTY([SizeUnitMeasureCode], 'BaseType') = 'char' THEN 'char'
        WHEN SQL_VARIANT_PROPERTY([Weight], 'BaseType') = 'float' THEN 'float'
        ELSE 'Other'
    END AS DataType
FROM 
    [dbo].[Product];