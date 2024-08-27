
Create database DrillActivtiesList;

	Use DrillActivitiesList;
	go

Create Schema Megalist;
go

Create Table Megalist.DrillHolesList
(
drillholeid INT Identity (1,1) primary key,
drillholetype nvarchar (50),
maxdepth nvarchar (50)
)

Create Table Megalist.DimDrillDate
(
DateKey int 



)