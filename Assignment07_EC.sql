--*************************************************************************--
-- Title: Assignment 07
-- Desc: This file demonstrates how to use Functions
-- Change Log: When, Who, What
-- 2017-01-01, RRoot, Created File
-- 2026-11-19, EC, Completed File
--**************************************************************************--
BEGIN TRY
	USE Master;
	IF EXISTS (SELECT	Name
				FROM		SysDatabases
				WHERE	Name = 'Assignment07DB_EC')
		BEGIN
			ALTER DATABASE [Assignment07DB_EC]
				SET SINGLE_USER 
				WITH ROLLBACK IMMEDIATE;
			DROP DATABASE Assignment07DB_EC;
		END
	CREATE DATABASE Assignment07DB_EC;
END TRY
BEGIN CATCH
	PRINT Error_Number();
END CATCH


GO
USE Assignment07DB_EC;

-- Create Tables (Module 01)-- 
CREATE TABLE Categories (
	[CategoryID]	INT				IDENTITY (1, 1) NOT NULL,
	[CategoryName]	NVARCHAR (100)	NOT NULL
);


GO
CREATE TABLE Products (
	[ProductID]		INT				IDENTITY (1, 1) NOT NULL,
	[ProductName]	NVARCHAR (100)	NOT NULL,
	[CategoryID]	INT				NULL,
	[UnitPrice]		MONEY			NOT NULL
);


GO
CREATE TABLE Employees ( -- New Table
	[EmployeeID]		INT				IDENTITY (1, 1) NOT NULL,
	[EmployeeFirstName]	NVARCHAR (100)	NOT NULL,
	[EmployeeLastName]	NVARCHAR (100)	NOT NULL,
	[ManagerID]			INT				NULL
);


GO
CREATE TABLE Inventories (
	[InventoryID]	INT		IDENTITY (1, 1) NOT NULL,
	[InventoryDate]	DATE	NOT NULL,
	[EmployeeID]	INT		NOT NULL,
	[ProductID]		INT		NOT NULL,
	[ReorderLevel]	INT		NOT NULL, -- New Column 
	[Count]			INT		NOT NULL
);


GO
-- Add Constraints (Module 02) -- 
BEGIN
	-- Categories
	ALTER TABLE Categories
		ADD CONSTRAINT pkCategories PRIMARY KEY (CategoryId);
	ALTER TABLE Categories
		ADD CONSTRAINT ukCategories UNIQUE (CategoryName);
END


GO
BEGIN
	-- Products
	ALTER TABLE Products
		ADD CONSTRAINT pkProducts PRIMARY KEY (ProductId);
	ALTER TABLE Products
		ADD CONSTRAINT ukProducts UNIQUE (ProductName);
	ALTER TABLE Products
		ADD CONSTRAINT fkProductsToCategories FOREIGN KEY (CategoryId) REFERENCES Categories (CategoryId);
	ALTER TABLE Products
		ADD CONSTRAINT ckProductUnitPriceZeroOrHigher CHECK (UnitPrice >= 0);
END


GO
BEGIN
	-- Employees
	ALTER TABLE Employees
		ADD CONSTRAINT pkEmployees PRIMARY KEY (EmployeeId);
	ALTER TABLE Employees
		ADD CONSTRAINT fkEmployeesToEmployeesManager FOREIGN KEY (ManagerId) REFERENCES Employees (EmployeeId);
END


GO
BEGIN
	-- Inventories
	ALTER TABLE Inventories
		ADD CONSTRAINT pkInventories PRIMARY KEY (InventoryId);
	ALTER TABLE Inventories
		ADD CONSTRAINT dfInventoryDate DEFAULT GetDate() FOR InventoryDate;
	ALTER TABLE Inventories
		ADD CONSTRAINT fkInventoriesToProducts FOREIGN KEY (ProductId) REFERENCES Products (ProductId);
	ALTER TABLE Inventories
		ADD CONSTRAINT ckInventoryCountZeroOrHigher CHECK ([Count] >= 0);
	ALTER TABLE Inventories
		ADD CONSTRAINT fkInventoriesToEmployees FOREIGN KEY (EmployeeId) REFERENCES Employees (EmployeeId);
END


GO
-- Adding Data (Module 04) -- 
INSERT	INTO Categories (
	CategoryName
)
SELECT		CategoryName
FROM		Northwind.dbo.Categories
ORDER BY	CategoryID;


GO
INSERT	INTO Products (
	ProductName,
	CategoryID,
	UnitPrice
)
SELECT		ProductName,
			CategoryID,
			UnitPrice
FROM		Northwind.dbo.Products
ORDER BY	ProductID;


GO
INSERT	INTO Employees (
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
)
SELECT		E.FirstName,
			E.LastName,
			IsNull(E.ReportsTo, E.EmployeeID)
FROM		Northwind.dbo.Employees AS E
ORDER BY	E.EmployeeID;


GO
INSERT	INTO Inventories (
	InventoryDate,
	EmployeeID,
	ProductID,
	[Count],
	[ReorderLevel]
)
-- New column added this week
SELECT		'20170101' AS InventoryDate,
			5 AS EmployeeID,
			ProductID,
			UnitsInStock,
			ReorderLevel
FROM		Northwind.dbo.Products
UNION
SELECT		'20170201' AS InventoryDate,
			7 AS EmployeeID,
			ProductID,
			UnitsInStock + 10,
			ReorderLevel -- Using this is to create a made up value
FROM		Northwind.dbo.Products
UNION
SELECT		'20170301' AS InventoryDate,
			9 AS EmployeeID,
			ProductID,
			abs(UnitsInStock - 10),
			ReorderLevel -- Using this is to create a made up value
FROM		Northwind.dbo.Products
ORDER BY	1, 2;


GO
-- Adding Views (Module 06) -- 
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
SELECT	CategoryID,
		CategoryName
FROM	dbo.Categories;


GO
CREATE VIEW vProducts
WITH SCHEMABINDING
AS
SELECT	ProductID,
		ProductName,
		CategoryID,
		UnitPrice
FROM	dbo.Products;


GO
CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT	EmployeeID,
		EmployeeFirstName,
		EmployeeLastName,
		ManagerID
FROM	dbo.Employees;


GO
CREATE VIEW vInventories
WITH SCHEMABINDING
AS
SELECT	InventoryID,
		InventoryDate,
		EmployeeID,
		ProductID,
		ReorderLevel,
		[Count]
FROM	dbo.Inventories;


GO
-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT	*
FROM	vCategories;


GO
SELECT	*
FROM	vProducts;


GO
SELECT	*
FROM	vEmployees;


GO
SELECT	*
FROM	vInventories;


GO
/********************************* Questions and Answers *********************************/
PRINT 'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------';

-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.
-- -- Start with a simple Select statement
-- Select Distinct
-- ProductName  
-- From vProducts;
-- go
-- -- Then add simple functions and test results
-- Select Distinct
--  Format (UnitPrice, 'C', 'en-US') As 'UnitPrice'
-- From vProducts;
-- go
-- Next add column and order
SELECT		DISTINCT ProductName,
					Format(UnitPrice, 'C', 'en-US') AS 'UnitPrice'
FROM		vProducts
ORDER BY	ProductName;


GO
-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- -- Start with a simple Select statement
-- Select Distinct
-- ProductName  
-- From vProducts;
-- go
-- Select Distinct
-- CategoryName  
-- From vCategories;
-- go
-- -- Then add simple functions and test results
-- Select Distinct
--  Format (UnitPrice, 'C', 'en-US') As 'UnitPrice'
-- From vProducts;
-- go
-- Next add column 
-- Select Distinct
-- ProductName,  
-- Format (UnitPrice, 'C', 'en-US') As 'UnitPrice'
-- From vProducts;
-- go
-- Next add column, Join and order
SELECT		DISTINCT CategoryName,
					ProductName,
					Format(UnitPrice, 'C', 'en-US') AS 'UnitPrice'
FROM		vProducts AS P
			INNER JOIN
			vCategories AS C
			ON P.CategoryID = C.CategoryID
ORDER BY	CategoryName, ProductName;


GO
-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
-- -- Start with a simple Select statement
-- Select
-- ProductName  
-- From vProducts;
-- go
-- Select
-- InventoryDate, Count
-- From vInventories;
-- go
-- -- Then add simple functions and test results 
-- SELECT
-- DATENAME(MM,InventoryDate) + ', ' +
-- DATENAME(YY,InventoryDate) as InventoryDate,
-- Count as InventoryCount
-- FROM
-- vInventories;
-- GO
-- Next add column, Join and order
SELECT		ProductName,
			DATENAME(MM, InventoryDate) + ', ' + DATENAME(YY, InventoryDate) AS InventoryDate,
			Count AS InventoryCount
FROM		vInventories AS I
			INNER JOIN
			vProducts AS P
			ON I.ProductID = P.ProductID
ORDER BY	ProductName, Month(InventoryDate);


GO
-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
-- -- Look at all the data
-- Select * From vProducts;
-- go
-- Select * From vInventories;
-- go
-- --Look at just the data we want
-- Select ProductName From vProducts;
-- go
-- Select Count, InventoryDate From vInventories;
-- go
-- -- Then add simple functions and test results 
-- SELECT
-- DATENAME(MM,InventoryDate) + ', ' +
-- DATENAME(YY,InventoryDate) as InventoryDate,
-- Count as InventoryCount
-- FROM
-- vInventories;
-- GO
-- Create View
CREATE OR ALTER VIEW vProductInventories
AS
SELECT		TOP 1000000 ProductName,
						DATENAME(MM, InventoryDate) + ', ' + DATENAME(YY, InventoryDate) AS InventoryDate,
						Count AS InventoryCount
FROM		vProducts AS P
			INNER JOIN
			vInventories AS I
			ON P.ProductID = I.ProductID
ORDER BY	ProductName, Month(InventoryDate);


GO
-- Check that it works: 
SELECT	*
FROM	vProductInventories;


GO
-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
-- -- Look at all the data
-- Select * From vCategories;
-- go
-- Select * From vProducts;
-- go
-- Select * From vInventories;
-- go
-- --Look at just the data we want
-- Select CategoryName From vCategories;
-- go
-- Select Count, InventoryDate From vInventories;
-- go
-- -- Then add simple functions and test results 
-- SELECT
-- DATENAME(MM,InventoryDate) + ', ' +
-- DATENAME(YY,InventoryDate) as InventoryDate,
-- Count as InventoryCount
-- FROM
-- vInventories;
-- GO
-- Create View
CREATE OR ALTER VIEW vCategoryInventories
AS
SELECT		TOP 1000000 CategoryName,
						DATENAME(MM, InventoryDate) + ', ' + DATENAME(YY, InventoryDate) AS InventoryDate,
						SUM(Count) AS InventoryCountByCategory
FROM		vCategories AS C
			INNER JOIN
			vProducts AS P
			ON C.CategoryID = P.CategoryID
			INNER JOIN
			vInventories AS I
			ON P.ProductID = I.ProductID
GROUP BY	CategoryName, InventoryDate
ORDER BY	CategoryName, Month(InventoryDate);


GO
-- Check that it works: 
SELECT	*
FROM	vCategoryInventories;


GO
-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviousMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.
-- -- Look at all the data
-- Select * From vProductInventories;
-- go
-- --Look at just the data we want
-- Select ProductName, InventoryDate, InventoryCount From vProductInventories;
-- go
-- -- Create View and add functions
-- CREATE OR ALTER VIEW vProductInventoriesWithPreviousMonthCounts
-- AS
-- SELECT		TOP 1000000 ProductName,
-- DATENAME(MM,InventoryDate) + ', ' +
-- DATENAME(YY,InventoryDate) as InventoryDate,
-- InventoryCount,
-- Lag (InventoryCount) Over (Order by ProductName, Month(InventoryDate)) as PreviousMonthCount
-- FROM		vProductInventories;
-- go
-- -- Add null=0 and January=0
CREATE OR ALTER VIEW vProductInventoriesWithPreviousMonthCounts
AS
SELECT	TOP 1000000 ProductName,
					InventoryDate,
					InventoryCount,
					IIF (InventoryDate LIKE ('January%'), 0, IsNull(Lag(InventoryCount) OVER (ORDER BY	ProductName, Year(InventoryDate)), 0)) AS [PreviousMonthCount]
FROM	vProductInventories;


GO
-- Check that it works: 
SELECT	*
FROM	vProductInventoriesWithPreviousMonthCounts;


GO
-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
-- -- Look at all the data
-- Select * From vProductInventoriesWithPreviousMonthCounts;
-- go
-- --Look at just the data we want
-- Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount 
-- From vProductInventoriesWithPreviousMonthCounts;
-- go
-- -- Create View and add functions
CREATE OR ALTER VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
SELECT		TOP 1000000 ProductName,
						InventoryDate,
						InventoryCount,
						PreviousMonthCount,
						CASE WHEN InventoryCount > PreviousMonthCount THEN 1 WHEN InventoryCount = PreviousMonthCount THEN 0 WHEN InventoryCount < PreviousMonthCount THEN -1 END AS [CountVsPreviousCountKPI]
FROM		vProductInventoriesWithPreviousMonthCounts
ORDER BY	ProductName, Month(InventoryDate);


GO
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 
SELECT	*
FROM	vProductInventoriesWithPreviousMonthCountsWithKPIs;


GO
-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.
-- -- Look at all the data
-- Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
-- go
-- --Look at just the data we want
-- Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI 
-- From vProductInventoriesWithPreviousMonthCountsWithKPIs;
-- go
-- Create UDF
CREATE OR ALTER FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs
(@CountVsPreviousCountKPI INT)
RETURNS TABLE 
AS
RETURN 
	(SELECT	ProductName,
			InventoryDate,
			InventoryCount,
			PreviousMonthCount,
			CountVsPreviousCountKPI
		FROM	vProductInventoriesWithPreviousMonthCountsWithKPIs
		WHERE	CountVsPreviousCountKPI = @CountVsPreviousCountKPI)



GO
SELECT	*
FROM	fProductInventoriesWithPreviousMonthCountsWithKPIs(1);

SELECT	*
FROM	fProductInventoriesWithPreviousMonthCountsWithKPIs(0);

SELECT	*
FROM	fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);


GO
PRINT 'Note: You will get an error until the views and functions are created!';


/* Check that it works:
Select * From vProductInventories;
Select * From vCategoryInventories;
Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
/***************************************************************************************/