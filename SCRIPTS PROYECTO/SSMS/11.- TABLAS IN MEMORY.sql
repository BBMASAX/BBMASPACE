--https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/in-memory-oltp-in-memory-optimization?view=sql-server-2017
USE master
GO


DROP DATABASE IF EXISTS TRIALBBM
go



CREATE DATABASE [TRIALBBM]
 CONTAINMENT = NONE
 ON PRIMARY
( NAME = N'TRIALBBM', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TRIALBBM.mdf' , 
SIZE = 4288KB , 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 1024KB )
 LOG ON
( NAME = N'TRIALBBM_log', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TRIALBBM_log.ldf' , 
SIZE = 1072KB , 
MAXSIZE = 2048GB , 
FILEGROWTH = 10%)
GO

USE [TRIALBBM]
GO



ALTER DATABASE [TRIALBBM]
	ADD FILEGROUP TRIALBBM_mod 
	CONTAINS MEMORY_OPTIMIZED_DATA
GO

-- You need to add one or more containers to the MEMORY_OPTIMIZED_DATA filegroup

ALTER DATABASE [TRIALBBM]
	ADD FILE (name='TRIALBBM_mod1', 
	filename='c:\data\TRIALBBM_mod1') 
	TO FILEGROUP TRIALBBM_mod
GO

-- Look up DB Properties FILEGROUP

/*OPTIMIZAR LA BASE DE DATOS*/
SELECT d.compatibility_level  
    FROM sys.databases as d  
    WHERE d.name = Db_Name();
go

-- compatibility_level
-- 140

-- Si hubiera que cambiar 

ALTER DATABASE CURRENT  
    SET COMPATIBILITY_LEVEL = 130;
Go


ALTER DATABASE CURRENT  
    SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
GO



-- Template

--======================================================
-- Create Memory Optimized Table Template
-- Use the Specify Values for Template Parameters command (Ctrl-Shift-M) to fill in the parameter values below.
-- This template creates a memory optimized table and indexes on the memory optimized table.
-- The database must have a MEMORY_OPTIMIZED_DATA filegroup before the memory optimized table can be created.
--======================================================

-----------------OTRA MANERA DE CREAR UNA TABLA-----------------------------------
/*USE <database, sysname, AdventureWorks>
GO

--Drop table if it already exists.
IF OBJECT_ID('<schema_name, sysname, dbo>.<table_name,sysname,sample_memoryoptimizedtable>','U') IS NOT NULL
    DROP TABLE <schema_name, sysname, dbo>.<table_name,sysname,sample_memoryoptimizedtable>
GO

CREATE TABLE <schema_name, sysname, dbo>.<table_name,sysname,sample_memoryoptimizedtable>
(
	<column_in_primary_key, sysname, c1> <column1_datatype, , int> <column1_nullability, , NOT NULL>, 
	<column2_name, sysname, c2> <column2_datatype, , float> <column2_nullability, , NOT NULL>,
	<column3_name, sysname, c3> <column3_datatype, , decimal(10,2)> <column3_nullability, , NOT NULL> INDEX <index3_name, sysname, index_sample_memoryoptimizedtable_c3> NONCLUSTERED (<column3_name, sysname, c3>), 

   CONSTRAINT <constraint_name, sysname, PK_sample_memoryoptimizedtable> PRIMARY KEY NONCLUSTERED (<column1_name, sysname, c1>),
   -- See SQL Server Books Online for guidelines on determining appropriate bucket count for the index
   INDEX <index2_name, sysname, hash_index_sample_memoryoptimizedtable_c2> HASH (<column2_name, sysname, c2>) WITH (BUCKET_COUNT = <sample_bucket_count, int, 131072>)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = <durability_type, , SCHEMA_AND_DATA>)
GO*/
--------------------------------

USE TRIALBBM
GO



--Drop table if it already exists.
IF OBJECT_ID('dbo.BBM_Treatment','U') IS NOT NULL
    DROP TABLE dbo.BBM_Treatment
GO

CREATE TABLE dbo.BBM_Treatment
(
	Treatment_ID int NOT NULL, 
	Name varchar(200) NOT NULL,
	Description varchar(200) NOT NULL INDEX index_sample_memoryoptimizedtable_c3 NONCLUSTERED (Description), 

   CONSTRAINT PK_sample_memoryoptimizedtable PRIMARY KEY NONCLUSTERED (Treatment_ID),
   -- See SQL Server Books Online for guidelines on determining appropriate bucket count for the index
   INDEX hash_index_sample_memoryoptimizedtable_c2 HASH (Name) WITH (BUCKET_COUNT = 131072)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO


--https://mostafaelmasry.com/2015/03/25/durable-vs-non-durable-tables-in-memory-oltp/


USE TRIALBBM
GO

DROP TABLE IF EXISTS BBM_User
GO
Create Table BBM_User
(
User_ID INT NOT NULL Primary key nonclustered Hash WITH (bucket_Count = 1000000),
	FirstName_1 Nvarchar(20) NOT NULL,
	FirstName_2 Nvarchar(20) NOT NULL,
	Lastname_1 Nvarchar(20)NOT NULL,
	Lastname_2 Nvarchar(20)NOT NULL,
	DNI Nvarchar(9) NOT NULL,
	Other_Details Nvarchar(20) NOT NULL,
)
With(Memory_optimized=on,Durability=SCHEMA_And_DATA)
GO


/*
DROP TABLE IF EXISTS BBM_Equipment
GO
Create Table BBM_Treatment
(
	Treatment_ID INT NOT NULL Primary key nonclustered Hash WITH (bucket_Count = 1000000),
	Description Nvarchar(200) NOT NULL,
)
With(Memory_optimized=on,Durability=SCHEMA_ONLY)
GO
*/

-- BBM_User
SET nocount ON
GO
DECLARE @counter INT
SET @counter = 1
WHILE @counter <= 100000
 BEGIN
 INSERT INTO dbo.BBM_User
 VALUES (@counter, 'Paco','Diego','Maradona','León','12345678C','DETALLES 1'),
 (@counter+1, 'Teresa','Carmen','Galilei','Einstein','12345679K','DETALLES 2'),
 (@counter+2, 'Pepe','El','Gran','Viyuela','12345678T','DETALLES 3')

SET @counter = @counter + 3
 END
GO


SELECT * FROM BBM_User
GO
-- BBM_Treatment
set nocount on
go
DECLARE @counter INT
SET @counter = 1
WHILE @counter <= 100000
 BEGIN
 INSERT INTO dbo.BBM_Treatment
 VALUES (@counter, 'Esquizofrenia', 'ESTO ES LA DESCRIPCIÓN DEL TRATAMIENTO UNO'),
 (@counter+1, 'TDAH', 'ESTO ES LA DESCRIPCIÓN DEL TRATAMIENTO DOS'),
 (@counter+2, 'TOC', 'ESTO ES LA DESCRIPCIÓN DEL TRATAMIENTO TRES')

SET @counter = @counter + 3
 END
GO

--The statement has been terminated.
--Msg 701, Level 17, State 109, Line 183
--There is insufficient system memory in resource pool 'default' to run this query.


--FASTER

SELECT * FROM BBM_Treatment
GO

Use Master
go
ALTER DATABASE TRIALBBM SET OFFLINE WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE TRIALBBM SET ONLINE
GO

-- Check now the Count of data in both tables you will found No Data in Non-Durable in memory table

USE [TRIALBBM]
GO
SELECT * FROM BBM_User
GO
SELECT * FROM BBM_Treatment
GO
Select Count(1) AS CONTADORNODURABLE from BBM_Treatment
GO
Select Count(1) AS CONTADORDURABLE from BBM_User
GO
--So at the End take care from Durable table and non-Durable table in memory Optimized table you should know when you need to use this or this if you don’t care about the data loss you can use non-Durable table in memory
--table.