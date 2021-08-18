--*************************************************************************--
-- Title: Assignment06
-- Author: Lulu Patel
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-08-18, LPatel,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_LuluPatel')
	 Begin 
	  Alter Database [Assignment06DB_LuluPatel] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_LuluPatel;
	 End
	Create Database Assignment06DB_LuluPatel;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_LuluPatel;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Create basic view for Categories

Create View vCategories
With SCHEMABINDING
 As
   Select TOP 10000000000
   CategoryID, CategoryName
From dbo.Categories
Order by CategoryID
go

Select CategoryID, CategoryName From vCategories Order by CategoryID;

--Check for accuracy

Select * From Categories;
Select * From vCategories;

--Verified breaking table is not allowed
Alter table Categories Drop Column CategoryName;
GO

--Create basic view for Products

Create View vProducts
With SCHEMABINDING
 As
   Select TOP 10000000000
   ProductID, ProductName, CategoryID, UnitPrice
From dbo.Products
Order by ProductID
go

Select ProductID, ProductName, CategoryID, UnitPrice From vProducts Order by ProductID;

--Check for accuracy

Select * From Products;
Select * From vProducts;

-- Create base view for Employees

Create View vEmployees
With SCHEMABINDING
 As
   Select TOP 10000000000
   EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees
Order by EmployeeID
go

Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From vEmployees Order by EmployeeID;

--Check for accuracy

Select * From Employees;
Select * From vEmployees;

--Create basic view for Inventories

Create View vInventories
With SCHEMABINDING
 As
   Select TOP 10000000000
   InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
From dbo.Inventories
Order by InventoryID
go

Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] From vInventories Order by InventoryID;

--Check for accuracy

Select * From Inventories;
Select * From vInventories;

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select on Categories to PUBLIC
Grant Select on vCategories to PUBLIC

Deny Select on Products to PUBLIC
Grant Select on vProducts to PUBLIC

Deny Select on Employees to PUBLIC
Grant Select on vEmployees to PUBLIC

Deny Select on Inventories to PUBLIC
Grant Select on vInventories to PUBLIC

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View vCategoryProductNamesPrice
with SCHEMABINDING
As
Select TOP 10000000000
CategoryName, ProductName, UnitPrice
    From dbo.Categories Join dbo.Products
        On Categories.CategoryID = Products.CategoryID      -- Need to join categories and products tables together and link category id in order to get unit price
    Order BY CategoryName, ProductName
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View vProductNameInvCount
with SCHEMABINDING
As
Select TOP 10000000000
ProductName, InventoryDate, sum(count) as Count
    From dbo.Products Join dbo.Inventories
        On Products.ProductID = Inventories.ProductID       -- need to join products and inventories tables together and link on product id in order to get the inventory date
    Group BY ProductName, InventoryDate
    Order BY ProductName, InventoryDate, Count 
GO

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create View vInventoryDateEmployee
with SCHEMABINDING
As
Select TOP 10000000000
InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
    From dbo.Inventories Join dbo.Employees
        On Inventories.EmployeeID = Employees.EmployeeID            -- need to join inventories and employees tables and link on employee id 
    Group by InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName 
    Order BY InventoryDate 
GO

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View vCategoriesProductsInvDateCount
with SCHEMABINDING
As
Select TOP 10000000000
CategoryName, ProductName, InventoryDate, sum(Count) as Count
    From dbo.Categories 
    Join dbo.Products
        On Categories.CategoryID = Products.CategoryID 
   Join dbo.Inventories
        On Products.ProductID = Inventories.ProductID -- I needed to join categories, products, and inventories tables together in order to also get the date and count for the products.
    Group by CategoryName, ProductName, InventoryDate
    Order BY CategoryName, ProductName, InventoryDate, Count 
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vCategoriesProductsInvDateCountEmployee
with SCHEMABINDING
As
Select TOP 10000000000
CategoryName, ProductName, InventoryDate, sum(Count) as Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
    From dbo.Categories 
    Join dbo.Products
        On Categories.CategoryID = Products.CategoryID
   Join dbo.Inventories
        On Products.ProductID = Inventories.ProductID
    JOIN dbo.Employees
        On Inventories.EmployeeID = Employees.EmployeeID           --I copied the code from #6 but also added the join for employees to give me the employee who took the count.
    Group by CategoryName, ProductName, InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName
    Order BY InventoryDate, CategoryName, ProductName, EmployeeName
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vCategoriesProductsChaiChang
with SCHEMABINDING
As
Select TOP 10000000000
CategoryName, ProductName, InventoryDate, sum(Count) as Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
    From dbo.Categories 
    Join dbo.Products
        On Categories.CategoryID = Products.CategoryID
   Join dbo.Inventories
        On Products.ProductID = Inventories.ProductID
    JOIN dbo.Employees
        On Inventories.EmployeeID = Employees.EmployeeID
    WHERE Products.ProductID in (Select ProductID FROM dbo.Products Where ProductName in ('Chai', 'Chang')) -- I copied the code from #7 and also needed to create a subquery that filtered on Chai and Chang
    Group by CategoryName, ProductName, InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName
    Order BY InventoryDate, CategoryName, ProductName
GO


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View vEmployeesByManager
with SCHEMABINDING
As
Select TOP 10000000000
A.EmployeeFirstName + ' ' + A.EmployeeLastName as Manager, B.EmployeeFirstName + ' ' + B.EmployeeLastName as Employee
    From dbo.Employees A, dbo.Employees B
    WHERE A.EmployeeID = B.ManagerID        -- I needed to do a self join to connect the employee with its manager. I was able to do this by creating a Table A and Table B. 
    Order BY Manager, Employee
GO


-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?				

Create view vInventoriesByProductsByCategoriesByEmployees 
with SCHEMABINDING
As
Select TOP 10000000000
Categories.CategoryID, CategoryName, Products.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, sum(Count) as Count, Emp.EmployeeID, Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName as Employee, Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName as Manager
    From dbo.Categories 
    Join dbo.Products
        On Categories.CategoryID = Products.CategoryID
   Join dbo.Inventories
        On Products.ProductID = Inventories.ProductID
    JOIN dbo.Employees Emp
        On Inventories.EmployeeID = Emp.EmployeeID
   Join dbo.Employees Mgr
   		On Mgr.EmployeeID = Emp.ManagerID       -- Join all tables and group all columns
    Group by Categories.CategoryID, CategoryName, Products.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Emp.EmployeeID, Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName, Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName
    Order BY CategoryName, ProductName;
GO 

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From vCategoryProductNamesPrice;
Select * From vProductNameInvCount;
Select * From vInventoryDateEmployee;
Select * From vCategoriesProductsInvDateCount;
Select * From vCategoriesProductsInvDateCountEmployee;
Select * From vCategoriesProductsChaiChang;
Select * From vEmployeesByManager;
Select * From vInventoriesByProductsByCategoriesByEmployees;
/***************************************************************************************/