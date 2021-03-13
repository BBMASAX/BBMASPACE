EXEC sp_configure filestream_access_level, 2
RECONFIGURE --> PROVOCA LA EJECUCIÓN
GO

--FileTable

USE [master]
GO
DROP DATABASE IF EXISTS TRIALBBM
GO


CREATE DATABASE TRIALBBM
ON PRIMARY
(
    NAME = TRIALBBM_data,
    FILENAME = 'C:\Data\TRIALBBM.mdf'--> MASTER DATA FILE
),
FILEGROUP FileStreamFG CONTAINS FILESTREAM --> NOS LO GUARDA COMO NDF
(
    NAME = TRIALBBM,
    FILENAME = 'C:\Data\TRIALBBM_Container' 
)
LOG ON
(
    NAME = TRIALBBM_Log,
    FILENAME = 'C:\Data\TRIALBBM_Log.ldf'
)
WITH FILESTREAM
(
    NON_TRANSACTED_ACCESS = FULL,
    DIRECTORY_NAME = 'TRIALBBMContainer'
);
GO
------------------------- SI VAMOS A LA BASE>TABLES>FILETABLES VEMOS QUE NOS LO CREA
-- METADATA

-- Check the Filestream Options
SELECT DB_NAME(database_id),
non_transacted_access,
non_transacted_access_desc
FROM sys.database_filestream_options;
GO
----------------
-- Another version
SELECT DB_NAME(database_id) as DatabaseName, non_transacted_access, non_transacted_access_desc 
FROM sys.database_filestream_options
where DB_NAME(database_id)='TRIALBBM';
GO

--We can have the following options for non-transacted access.

--OFF: Non-transactional access to FileTables is not allowed
--Read Only– Non-transactional access to FileTables is allowed for the read-only purpose
--Full– Non-transactional access to FileTables is allowed for both reading and writing
--Specify a directory for the SQL Server FILETABLE. We need to specify directory without directory path. This directory acts as a root path in FILETABLE hierarchy. We will explore more in a further section of this article


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

-- Createe FileTable Table
USE TRIALBBM --> HABILITO FILETABLE
GO
DROP TABLE IF EXISTS BBM_FILETABLE_TRIAL 
GO
CREATE TABLE BBM_FILETABLE_TRIAL --> CREO UNA TABLA ESPECÍFICA PARA FILETABLE
AS FILETABLE
WITH 
(
    FileTable_Directory = 'TRIALBBMContainer',
    FileTable_Collate_Filename = database_default
);
GO
-- See FileTableTb in OBJECT EXPLORER

-- Now you can select data using a regular select table.






SELECT *
FROM BBM_FILETABLE_TRIAL
GO


-- Arrastro 3 objetos


SELECT TOP (1000) [stream_id]
      ,[name]
  FROM [TRIALBBM].[dbo].[BBM_FILETABLE_TRIAL]

-- SUMMING UP



--  stream_id									           name
--B4608232-B146-EA11-9BCD-000C29A5C7F8					hiremenow.png
--B5608232-B146-EA11-9BCD-000C29A5C7F8					names.xls
--B7608232-B146-EA11-9BCD-000C29A5C7F8					Seguridad Encerado.jpeg

SELECT * FROM sys.tables WHERE is_filetable = 1;  
GO  