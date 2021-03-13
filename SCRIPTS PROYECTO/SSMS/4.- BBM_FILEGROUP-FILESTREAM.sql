-- https://dba-presents.com/index.php/databases/sql-server/59-introduction-to-filestream

-- A BLOB, or Binary Large Object, is an SQL object data type, meaning  --> MUY IMPORTANTE
-- it is a reference or pointer to an object. 
-- Typically a BLOB is a file, image, video, or other large object. 
-- In database systems, such as Oracle and SQL Server, a BLOB can hold 
-- as much as 4 gigabytes. 

-- https://docs.microsoft.com/en-us/sql/relational-databases/blob/binary-large-object-blob-data-sql-server?view=sql-server-ver15

-- Options for Storing Blobs

-- FILESTREAM (SQL Server)
-- FILESTREAM enables SQL Server-based applications to store unstructured data, 
	--such as documents and TRIALBBM, on the file system. Applications can leverage the rich streaming APIs and performance of the file system and at the same time maintain transactional consistency between the unstructured data and corresponding structured data.

--FileTables (SQL Server)
--The FileTable feature brings support for the Windows file namespace and compatibility with Windows applications to the file data stored in SQL Server. FileTable lets an application integrate its storage and data management components, and provides integrated SQL Server services - including full-text search and semantic search - over unstructured data and metadata.

--In other words, you can store files and documents in special tables in SQL Server called FileTables, but access them from Windows applications as if they were stored in the file system, without making any changes to your client applications.

--Remote Blob Store (RBS) (SQL Server)
--Remote BLOB store (RBS) for SQL Server lets database administrators store binary large objects (BLOBs) in commodity storage solutions instead of directly on the server. This saves a significant amount of space and avoids wasting expensive server hardware resources. RBS provides a set of API libraries that define a standardized model for applications to access BLOB data. RBS also includes maintenance tools, such as garbage collection, to help manage remote BLOB data.

--RBS is included on the SQL Server installation media, but is not installed by the SQL Server Setup program.


-- https://www.sqlshack.com/viewing-sql-server-filestream-data-with-ssrs/

-- https://blog.sqlauthority.com/2019/03/01/sql-server-sql-server-configuration-manager-missing-from-start-menu/

-- IF CONFIGURATION MANAGER  --> Se utilizaa par alos protocolos de servicio y de red
-- SQL Server 2017	SQLServerManager14.msc --> ESTO LO TENEMOS QUE HACER PORQUE NO HEMOS HABILITADO ESTA OPCIÓN EN LA INSTALACIÓN. POR ELLO VAMOS A LANZAR EL CONFIGURATION MANAGER. 

--¿CÓMO LO LANZAMOS? EJERCUTAMOS EN WINDOWS + R esto: SQLServerManager14.msc 

-- ENABLE FILESTREAM

-- RESTART MSSQLSERVER SERVICE

-------------------------------------------------
-- Before FILESTREAM can be used, it has to be enabled on the instance. 
-- To do this, go to Configuration Manager, select SQL Server Services and double click the instance you would like to have FILESTREAM enabled.

--	A nivel de BD mediante sp_configure @enablelevel, dónde @enablelevel indica:

--0 = Deshabilitado. Este es el valor por defecto.
--1 = Habilitado solo para acceso T-SQL.
--2 = Habilitado solo para T-SQL y acceso local al sistema de ficheros.
--3 = Habilitado para T-SQL, acceso local y remoto al sistema de ficheros.


EXEC sp_configure filestream_access_level, 2
RECONFIGURE
GO

--Configuration option 'filestream access level' changed from 0 to 2. Run the RECONFIGURE statement to install.
--FILESTREAM feature could not be initialized. The operating system Administrator must enable FILESTREAM on the instance using Configuration Manager.

--> COMO NO QUIERO HACERLO SOBRE LA BASE DE DATOS ORIGINAL, CREO UNA BASE NUEVA Y VUELCO DATOS PARA HACER PRUEBAS

-- PRIMERO COMPRUEBO LA EXISTENCIA DE LA BASE DATOS

USE [master]
GO
DROP DATABASE IF EXISTS TRIALBBM
GO
CREATE DATABASE TRIALBBM  
ON   
( NAME = TRIALBBM_dat,  
    FILENAME = 'C:\Data\trialbbmdat.mdf',  
    SIZE = 10,  
    MAXSIZE = 50,  
    FILEGROWTH = 5 )  
LOG ON  
( NAME = TRIALBBM_log,  
    FILENAME = 'C:\Data\trialbbmlog.ldf',  
    SIZE = 5MB,  
    MAXSIZE = 25MB,  
    FILEGROWTH = 5MB ) ;  
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


-- AHORA A ESTA BASE LE CREO UN FILEGROUP PARA PODER METER TODO
USE TRIALBBM
GO

ALTER DATABASE TRIALBBM 
	ADD FILEGROUP [PRIMARY_FILESTREAMBBM] --> ORGANIZACIONES LÓGICAS DE ARCHIVOS FÍSICOS
	CONTAINS FILESTREAM 
GO

ALTER DATABASE TRIALBBM
       ADD FILE (
             NAME = 'BBM_FILESTREAM',
             FILENAME = 'C:\Data\bbmfilestream'
       )
       TO FILEGROUP [PRIMARY_FILESTREAMBBM]
GO


-- COMO SE ME HA OLVIDADO METER LA TABLA QUE CONTIENE LAS IMÁGENES
USE TRIALBBM
GO

DROP TABLE IF EXISTS BBM_Imágenes_Usuarios
GO

CREATE TABLE BBM_Imágenes_Usuarios(
       id UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
       imagenesarchivo VARBINARY(MAX) FILESTREAM
);
GO
-- FOLDER C:\Fotos_BBMUSERS\

INSERT INTO BBM_Imágenes_Usuarios(id, imagenesarchivo)
		SELECT NEWID(), BulkColumn
		FROM OPENROWSET(BULK 'C:\Fotos_BBMUSERS\USERGPP012.png', SINGLE_BLOB) as f;
GO
INSERT INTO BBM_Imágenes_Usuarios(id, imagenesarchivo)
	SELECT NEWID(), BulkColumn
	FROM OPENROWSET(BULK 'C:\Fotos_BBMUSERS\USERVNA013.png', SINGLE_BLOB) as f;
GO
INSERT INTO BBM_Imágenes_Usuarios(id, imagenesarchivo)
	SELECT NEWID(), BulkColumn
	FROM OPENROWSET(BULK 'C:\Fotos_BBMUSERS\USERVRI013.png', SINGLE_BLOB) as f;
GO

SELECT *
FROM BBM_Imágenes_Usuarios;
GO
--C:\Data\bbmfilestream
-- Open with PAINT 

-- Filestream columns
SELECT SCHEMA_NAME(t.schema_id) AS [schema], 
    t.[name] AS [table],
    c.[name] AS [column],
    TYPE_NAME(c.user_type_id) AS [column_type]
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
WHERE t.filestream_data_space_id IS NOT NULL
    AND c.is_filestream = 1
ORDER BY 1, 2, 3;
-- Filestream files and filegroups
SELECT f.[name] AS [file_name],
    f.physical_name AS [file_path],
    fg.[name] AS [filegroup_name]
FROM sys.database_files f 
JOIN sys.filegroups fg ON f.data_space_id = fg.data_space_id
WHERE f.[type] = 2
ORDER BY 1;
GO

ALTER TABLE [dbo].BBM_Imágenes_Usuarios DROP COLUMN [imagenesarchivo]
GO
ALTER TABLE BBM_Imágenes_Usuarios SET (FILESTREAM_ON="NULL")
GO

ALTER DATABASE [TRIALBBM] REMOVE FILE BBM_FILESTREAM;
GO

--Msg 5042, Level 16, State 13, Line 134
--The file 'BBM_FILESTREAM' cannot be removed because it is not empty.

USE master
GO


-- The filegroup 'PRIMARY_FILESTREAM' has been removed.

DROP DATABASE [TRIALBBM]
GO
