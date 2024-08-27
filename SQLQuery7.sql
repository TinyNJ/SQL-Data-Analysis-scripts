SELECT distinct
ps1.ProductKey
,ps1.SupplierKey
,s.Name
from[dbo].productSupplier ps1
inner join [dbo].productSupplier ps2
on ps1.ProductKey = ps2.ProductKey
and ps1.SupplierKey <> ps2.SupplierKey
inner join [dbo].[Supplier]s
on ps1.SupplierKey = s.SupplierKey;--expecting data from our left hand table, first table
