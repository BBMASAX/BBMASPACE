--PARTICIONES --> SE USAN PARA TABLAS DE GRAN TAMAÑO. SE PARTICIONAN EN HORIZONTAL (FILAS). NUNCA POR COLUMNAS (VERTICALES). EN MONGODB SE LLAMAN SHARDS.
-- https://docs.microsoft.com/en-us/sql/relational-databases/partitions/partitioned-tables-and-indexes?view=sql-server-ver15

-- PARTITIONS
--Crear un grupo o grupos de archivos y los archivos correspondientes que contendrán las particiones especificadas por el esquema de partición.
--Crear una función de partición que asigna las filas de una tabla o un índice a particiones según los valores de una columna especificada.
--Crear un esquema de partición que asigna las particiones de una tabla o índice con particiones a los nuevos grupos de archivos.
--Crear o modificar una tabla o un índice y especificar el esquema de partición como ubicación de almacenamiento.


-- OPERATIONS
-- Operations SPLIT-MERGE-SWITCH-TRUNCATE PARTITION
-->  DIVIDIR-FUSIONAR-CAMBIAR-BORRAR


--Create a database with multiple files and filegroups
--Create a Partition Function and a Partition Scheme based on date
--Create a Table on the Partition
--Insert Data into the Table
--Investigate how the data is stored according to partition

-- ONLY HORIZONTAL
-- http://datablog.roman-halliday.com/index.php/2019/02/02/partitions-in-sql-server-creating-a-partitioned-table/


--What makes a partitioned table in SQL Server?
--In SQL Server, to partition a table you first need to define a function, and then a scheme.

--Partition Function: The definition of how data is to be split. 
-- It includes the data type and the value ranges to use in each partition.

--Partition Scheme: The definition of how a function is to be applied to data files. 
-- This allows DBAs to split data across logical storage locations if required, 
-- however in most modern environments with large SANs most SQL Server implementations and their DBAs
--  will just use ‘primary’.

--A partition function can be used in one or more schemes, 
-- and a scheme in one or more tables. 
-- There can be organisational advantages to sharing a scheme/function across tables 
--(update one, and you update everything in kind). However, in my experience most cases DBAs prefer to have one function and scheme combination for each table.


-- AL DIVIDIRLO POR FECHAS, PUEDO DIVIDIRLO POR RANGOS

USE master 
go
DROP DATABASE IF EXISTS TRIALBBM 
GO
CREATE DATABASE [TRIALBBM] 
	ON PRIMARY ( NAME = 'TRIALBBM', 
		FILENAME = 'C:\Data\TRIALBBM_Fijo.mdf' , 
		SIZE = 15360KB , MAXSIZE = UNLIMITED, FILEGROWTH = 0) 
	LOG ON ( NAME = 'TRIALBBM_log', 
		FILENAME = 'C:\Data\TRIALBBM_log.ldf' , 
		SIZE = 10176KB , MAXSIZE = 2048GB , FILEGROWTH = 10%) 
GO

-- SSMS DB Properties

USE TRIALBBM
GO

ALTER DATABASE [TRIALBBM] ADD FILEGROUP [BBMFILEGROUP_Archivo] 
GO 
ALTER DATABASE [TRIALBBM] ADD FILEGROUP [BBMFILEGROUP_2016] 
GO 
ALTER DATABASE [TRIALBBM] ADD FILEGROUP [BBMFILEGROUP_2017] 
GO 
ALTER DATABASE [TRIALBBM] ADD FILEGROUP [BBMFILEGROUP_2018]
GO

select * from sys.filegroups
GO

ALTER DATABASE [TRIALBBM] ADD FILE ( NAME = 'Nuevas_Altas_BBM', FILENAME = 'c:\Data\Nuevas_Altas_BBM.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [BBMFILEGROUP_Archivo] 
GO
ALTER DATABASE [TRIALBBM] ADD FILE ( NAME = 'ARCHIVO_2016', FILENAME = 'c:\Data\ARCHIVO_2016.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [BBMFILEGROUP_2016] 
GO
ALTER DATABASE [TRIALBBM] ADD FILE ( NAME = 'ARCHIVO_2017', FILENAME = 'c:\Data\ARCHIVO_2017.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [BBMFILEGROUP_2017] 
GO
ALTER DATABASE [TRIALBBM] ADD FILE ( NAME = 'ARCHIVO_2018', FILENAME = 'c:\Data\ARCHIVO_2018.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [BBMFILEGROUP_2018] 
GO


select * from sys.filegroups
GO

select * from sys.database_files
GO



-- ME COLOCO EN LA BASE DE DATOS Y CREO UN ESQUEMA
USE TRIALBBM
GO
DROP SCHEMA IF EXISTS trial
GO
CREATE SCHEMA trial
GO

--CON LO CREADO ANTERIORMENTE, VUELCO LOS DATOS DE LAS TABLAS DE PRUEBAS EN ESTA NUEVA TABLA PARA PODER TRABAJAR EN ELLA
Select * into TRIALBBM.trial.BBM_Expediente 				from BBM_ASPACE.trial.BBM_Expediente 
Select * into TRIALBBM.trial.BBM_Sesion 					from BBM_ASPACE.trial.BBM_Sesion
Select * into TRIALBBM.trial.BBM_Comidas 					from BBM_ASPACE.trial.BBM_Comidas 
Select * into TRIALBBM.trial.BBM_Enfermedad_Diagnosticada	from BBM_ASPACE.trial.BBM_Enfermedad_Diagnosticada
Select * into TRIALBBM.trial.BBM_Tratamientos 				from BBM_ASPACE.trial.BBM_Tratamientos 
Select * into TRIALBBM.trial.BBM_Usuario 					from BBM_ASPACE.trial.BBM_Usuario 
Select * into TRIALBBM.trial.BBM_Especialista  				from BBM_ASPACE.trial.BBM_Especialista  


-- PARTITION FUNCTION

CREATE PARTITION FUNCTION PART_FUNCTION_BBM (datetime) 
AS RANGE RIGHT 
	FOR VALUES ('2016-01-01','2017-01-01')
GO

-- PARTITION SCHEME


CREATE PARTITION SCHEME PART_SCHEMA_BBM 
AS PARTITION PART_FUNCTION_BBM 
	TO (BBMFILEGROUP_Archivo,BBMFILEGROUP_2016,BBMFILEGROUP_2017,BBMFILEGROUP_2018) 
GO


-- Partition scheme 'PART_SCHEMA_BBM' has been created successfully. 'BBMFILEGROUP_2018' is marked as the next used filegroup in partition scheme 'PART_SCHEMA_BBM'.

--Partitioned Table
--Lastly a table needs to be defined (as normal), with two additional requirements:

--The storage location is given as the partition scheme (with the name of the column to be used 
--for partitioning).
--The table must have a clustered index (usually the primary key) which includes the column to be used 
-- for partitioning.


ALTER TABLE trial.BBM_Usuario
	ADD fecha_alta datetime
	ON PART_SCHEMA_BBM -- partition scheme
		(fecha_alta) -- the column to apply the function within the scheme
GO



DROP TABLE IF EXISTS trial.BBM_Usuario
GO
CREATE TABLE [trial].[BBM_Usuario](
	Usuario_ID INT NOT NULL IDENTITY,
	Nombre_1 varchar(20) NULL,
	Apellido_1 varchar(20) NULL,
	DNI varchar(9) NOT NULL,
	fecha_alta datetime) 
	ON PART_SCHEMA_BBM -- partition scheme
		(fecha_alta) -- the column to apply the function within the scheme
GO


-- SSMS TABLE PROPERTIES PARTITIONS

INSERT INTO trial.BBM_Usuario (Nombre_1, Apellido_1, DNI, fecha_alta) 
	Values ('Carlos','Ariza','12345678A','2015-01-01'), ('Victorino','Navas','12345678B','2013-05-05'), ('Debora','Moran','12345678C','2014-08-11')
GO

SELECT * FROM trial.BBM_Usuario 
GO
----------------

SELECT *,$Partition.PART_FUNCTION_BBM(fecha_alta) AS Partition
FROM trial.BBM_Usuario
GO

-- partition function
select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'PART_FUNCTION_BBM'
gO

--name	create_date	value
--PART_FUNCTION_BBM	2020-02-03 10:32:30.537	2016-01-01 00:00:00.000
--PART_FUNCTION_BBM	2020-02-03 10:32:30.537	2017-01-01 00:00:00.000



--partition_number	rows
--1	3
--2	0
--3	0

DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	3		9			less than	2016-01-01 00:00:00.000	3:8
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2016		0		0			less than	2017-01-01 00:00:00.000	0:0
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2017		0		0			less than	NULL	0:0
-------------------
INSERT INTO trial.BBM_Usuario 
	VALUES ('Cesar','Medrano','12345678D','2016-06-23'), ('Julia','Cañete','12345678E','2016-02-03'), ('Noa','Ferrando','12345678F','2016-04-06')
GO

SELECT *,$Partition.PART_FUNCTION_BBM(fecha_alta) 
FROM trial.BBM_Usuario
GO

select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'PART_FUNCTION_BBM'
gO


select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'trial.BBM_Usuario' 
GO

DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object	p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2016	3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2017	0	0	less than	NULL	0:0

--------------------
INSERT INTO trial.BBM_Usuario 
	VALUES ('Kevin','Pascual','12345678H','2017-05-21'), ('Evangelina','Lamas','12345678I','2017-07-09'), ('Cesar','Lopez','12345678J','2017-09-12')
GO

SELECT *,$Partition.PART_FUNCTION_BBM(fecha_alta) 
FROM trial.BBM_Usuario
GO

select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'PART_FUNCTION_BBM'
gO


select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'trial.BBM_Usuario' 
GO

DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object	p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2016	3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2017	3	9	less than	NULL	5:8

------------------


INSERT INTO trial.BBM_Usuario 
	VALUES ('Davinia','Cantero','12345678K','2018-02-12'), ('Josu','Cordoba','12345678L','2018-01-23'), ('Pelayo','Florez','12345678M','2018-02-23')
GO



SELECT *,$Partition.PART_FUNCTION_BBM(fecha_alta) as PARTITION
FROM trial.BBM_Usuario
GO

select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'PART_FUNCTION_BBM'
gO


select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'trial.BBM_Usuario' 
GO

DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO


--object	p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2016		3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2017		6	9	less than	NULL	5:8


-- SPLIT

ALTER PARTITION FUNCTION PART_FUNCTION_BBM() 
	SPLIT RANGE ('2018-01-01'); 
GO

SELECT *,$Partition.PART_FUNCTION_BBM(fecha_alta) as PARTITION
FROM trial.BBM_Usuario
GO

DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2016		3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.trial.BBM_Usuario	4	BBMFILEGROUP_2018		3	9	less than	NULL	6:8

-- MERGE

ALTER PARTITION FUNCTION PART_FUNCTION_BBM ()
 MERGE RANGE ('2016-01-01'); 
 GO

SELECT *,$Partition.PART_FUNCTION_BBM(fecha_alta) 
FROM trial.BBM_Usuario
GO
DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	6	9	less than	2017-01-01 00:00:00.000	3:8
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2018		3	9	less than	NULL	6:8

-- Example SWITCH

USE master
GO
ALTER DATABASE [TRIALBBM] REMOVE FILE ARCHIVO_2016
go

ALTER DATABASE [TRIALBBM] REMOVE FILEGROUP BBMFILEGROUP_2016 
GO


--The file 'ARCHIVO_2016' has been removed.
--The filegroup 'BBMFILEGROUP_2016' has been removed.

select * from sys.filegroups
GO

select * from sys.database_files
GO


-- SWITCH

USE TRIALBBM
go

SELECT *,$Partition.PART_FUNCTION_BBM(fecha_alta) 
FROM trial.BBM_Usuario
GO
DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	6	9	less than	2017-01-01 00:00:00.000	3:8
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2018		3	9	less than	NULL	6:8



CREATE TABLE SWITCH_BBM 
	(Usuario_ID INT NOT NULL IDENTITY,
	Nombre_1 varchar(20) NULL,
	Apellido_1 varchar(20) NULL,
	DNI varchar(9) NOT NULL,
	fecha_alta datetime) 
ON BBMFILEGROUP_Archivo
go


ALTER TABLE trial.BBM_Usuario 
	SWITCH Partition 1 to SWITCH_BBM
go


select * from trial.BBM_Usuario 
go


--id_alta	nombre	apellido	fecha_alta
--7	Ismael	Cabana	2017-05-21 00:00:00.000
--8	Alejandra	Martinez	2017-07-09 00:00:00.000
--9	Alfonso	Verdes	2017-09-12 00:00:00.000
--10	Amanda	Smith	2018-02-12 00:00:00.000
--11	Adolfo	Muñiz	2018-01-23 00:00:00.000
--12	Rosario	Fuertes	2018-02-23 00:00:00.000


select * from SWITCH_BBM 
go

--id_alta	nombre	apellido	fecha_alta
--1	Antonio	Ruiz	2015-01-01 00:00:00.000
--2	Lucas	García	2015-05-05 00:00:00.000
--3	Manuel	Sanchez	2015-08-11 00:00:00.000
--4	Laura	Muñoz	2016-06-23 00:00:00.000
--5	Rosa Maria	Leandro	2016-02-03 00:00:00.000
--6	Federico	Ramos	2016-04-06 00:00:00.000



DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows
, au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	0	0	less than	2017-01-01 00:00:00.000	0:0
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2018		3	9	less than	NULL	6:8

-- TRUNCATE

TRUNCATE TABLE trial.BBM_Usuario 
	WITH (PARTITIONS (3));
go

select * from trial.BBM_Usuario
GO

--id_alta	nombre	apellido	fecha_alta
--7	Ismael	Cabana	2017-05-21 00:00:00.000
--8	Alejandra	Martinez	2017-07-09 00:00:00.000
--9	Alfonso	Verdes	2017-09-12 00:00:00.000


DECLARE @TableName NVARCHAR(200) = N'trial.BBM_Usuario' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , BBMFILEGROUP.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups BBMFILEGROUP ON dds.data_space_id = BBMFILEGROUP.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.trial.BBM_Usuario	1	BBMFILEGROUP_Archivo	0	0	less than	2017-01-01 00:00:00.000	0:0
--dbo.trial.BBM_Usuario	2	BBMFILEGROUP_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.trial.BBM_Usuario	3	BBMFILEGROUP_2018		0	0	less than	NULL	0:0










