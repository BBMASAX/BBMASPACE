
-- DYNAMIC DATA MASKING (DDM)

/*PARA ESTE EJEMPLO CREAMOS ROLES E INCLUIMOS DOS USUARIOS:
PADREMIRON AL QUE NO LE VOY A DEJAR VER NADA DE LO QUE ENMASCARE
PSICOLOGO AL QUE AL FINAL LE VOY A DEJAR VER DATOS QUE EL PACIENTE NO*/
USE MASTER

DROP DATABASE IF EXISTS BBM_ASPACE_SECURETEST
GO
CREATE DATABASE BBM_ASPACE_SECURETEST;
GO

USE [BBM_ASPACE_SECURETEST]
GO

-- VOLCAMOS LOS DATOS DE LA TABLA CONTACTO PACIENTE A UNA NUEVA TABLA
CREATE TABLE [dbo].[BBM_Contacto_Paciente_TEST](
	[BBM_Tutor_Tutor_ID] [varchar](10) NOT NULL,
	[BBM_Usuario_Usuario_ID] [varchar](10) NOT NULL,
	[Contacto] [int] NULL,
	[Email] [varchar](255) NULL,
	[Direciion] [varchar](255) NULL,
	[Otros_Detalles] [varchar](255) NULL)
GO

-- INSERTAMOS DATOS PARA LA PRUEBA
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR01','SONUSR01','981222221','correoejemplo01@mail.com','Calle Falsa 121','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR02','SONUSR02','981222222','correoejemplo02@mail.com','Calle Falsa 122','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR03','SONUSR03','981222223','correoejemplo03@mail.com','Calle Falsa 123','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR04','SONUSR04','981222224','correoejemplo04@mail.com','Calle Falsa 124','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR05','SONUSR05','981222225','correoejemplo05@mail.com','Calle Falsa 125','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR06','SONUSR06','981222226','correoejemplo06@mail.com','Calle Falsa 126','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR07','SONUSR07','981222227','correoejemplo07@mail.com','Calle Falsa 127','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR08','SONUSR08','981222228','correoejemplo08@mail.com','Calle Falsa 128','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO
INSERT INTO [dbo].[BBM_Contacto_Paciente_TEST] VALUES ('DADUSR09','SONUSR09','981222229','correoejemplo09@mail.com','Calle Falsa 129','INFORMACIÓN SENSIBLE QUE NO SE PUEDE VER')
GO

--- END POPULATE (CARGAR DATOS EN LA TABLA)

/*VEMOS LOS RESULTADOS*/

SELECT * FROM dbo.BBM_Contacto_Paciente_TEST
GO



-- Create DataUser to have Select access to dbo.BBM_Contacto_Paciente_TEST table

CREATE ROLE BBMDATAMASKINGPROS
GO
CREATE ROLE BBMDATAMASKINGUSERS
GO

GRANT SELECT ON dbo.BBM_Contacto_Paciente_TEST TO BBMDATAMASKINGPROS;
GO
GRANT SELECT ON dbo.BBM_Contacto_Paciente_TEST TO BBMDATAMASKINGUSERS;
GO

CREATE USER PSICOLOGO WITHOUT LOGIN; 
GO
CREATE USER PADREMIRON WITHOUT LOGIN; 
GO

ALTER ROLE  BBMDATAMASKINGPROS  ADD MEMBER PSICOLOGO
GO
ALTER ROLE  BBMDATAMASKINGUSERS  ADD MEMBER PADREMIRON
GO

-- Stored procedure to check dynamic data masking status
CREATE OR ALTER PROC BBM_SHOW_STATUS
AS
BEGIN
		SET NOCOUNT ON 
		SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
		FROM sys.masked_columns AS c  
		JOIN sys.tables AS tbl   
			ON c.[object_id] = tbl.[object_id]  
		WHERE is_masked = 1;
END
GO

EXEC BBM_SHOW_STATUS
GO


/*SE SUPONE QUE AMBOS TIENEN LOS MISMOS PERMISOS, PERO AL FINAL VOY A REVOCAR EL PERMISO DE MASKING AL PSICOLOGO*/



-- Dynamic Data Masking (DDM) Types
-- There are four common types of Dynamic data masking in SQL Server:

--1. Default Data Mask(s) --> Normalmente con correos electrónicos
--2. Partial Data Mask(s)
--3. Random Data Mask(s)
--4. Custom String Data Mask(s) --> Para generar datos falsos

--We are now going to implement all the four common types of dynamic data masking.

--Default dynamic data masking of Email column 
ALTER TABLE dbo.BBM_Contacto_Paciente_TEST
ALTER COLUMN Email varchar(255) MASKED WITH (FUNCTION = 'default()');
GO

EXEC BBM_SHOW_STATUS
GO

--name	table_name	is_masked	masking_function
--Email	dbo.BBM_Contacto_Paciente_TEST		1			default() --> 1 es si, 0 es no

-- Execute SELECT as DataUser
EXECUTE AS USER = 'PADREMIRON';  
GO
-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO

--SaleId	SellingDate			Customer	  Email	Product	Product
--1	2019-05-01 00:00:00.0000000	Asif			xxxx	Dell Laptop	Dell Laptop
--2	2019-05-02 00:00:00.0000000	Mike			xxxx	Dell Laptop	Dell Laptop
--3	2019-05-02 00:00:00.0000000	Adil			xxxx	Lenovo Laptop	Lenovo Laptop
--4	2019-05-03 00:00:00.0000000	Sarah			xxxx	HP Laptop	HP Laptop
--5	2019-05-05 00:00:00.0000000	Asif			xxxx	Dell Desktop	Dell Desktop
--6	2019-05-10 00:00:00.0000000	Sam				xxxx	HP Desktop	HP Desktop
--7	2019-05-12 00:00:00.0000000	Mike			xxxx	iPad	iPad
--8	2019-05-13 00:00:00.0000000	Mike			xxxx	iPad	iPad
--9	2019-05-20 00:00:00.0000000	Peter			xxxx	Dell Laptop	Dell Laptop
--10	2019-05-25 00:00:00.0000000	Peter		xxxx	Asus Laptop	Asus Laptop

-- Revert the User back to what user it was before
REVERT;
GO

PRINT USER
GO
-- DBO

-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO

--SaleId	SellingDate				Customer	Email						Product	Product
--1	2019-05-01 00:00:00.0000000	     Asif	Asif@companytest-0001.com	Dell Laptop	Dell Laptop

-- Partial data masking of Customer names

ALTER TABLE dbo.BBM_Contacto_Paciente_TEST
ALTER COLUMN [Direciion] ADD MASKED WITH (FUNCTION = 'partial(1,"xxxxx",0)')
GO


EXEC BBM_SHOW_STATUS
GO

--name		table_name		is_masked	masking_function
--Customer	dbo.BBM_Contacto_Paciente_TEST			1		partial(1, "XXXXXXX", 0)
--Email		dbo.BBM_Contacto_Paciente_TEST			1		default()

-- Execute SELECT as DataUser
EXECUTE AS USER = 'PSICOLOGO';  

-- View monthly sales as DataUser
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO

--SaleId	SellingDate					Customer	Email	Product	Product
--1		2019-05-01 00:00:00.0000000		AXXXXXXX	xxxx	Dell Laptop	Dell Laptop

-- Revert the User back to what user it was before
REVERT;
GO
PRINT USER
GO
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO

--SaleId		Customer			Email
--1				Asif			Asif@companytest-0001.com


--Random dynamic data masking of TotalPrice column 

ALTER TABLE dbo.BBM_Contacto_Paciente_TEST
ALTER COLUMN [Contacto] integer MASKED WITH (FUNCTION = 'random(1, 5000)')
GO

EXEC BBM_SHOW_STATUS
GO

--name			table_name		is_masked		masking_function
--Customer		dbo.BBM_Contacto_Paciente_TEST		1				partial(1, "XXXXXXX", 0)
--Email			dbo.BBM_Contacto_Paciente_TEST		1				default()
--TotalPrice	dbo.BBM_Contacto_Paciente_TEST		1				random(1.00, 12.00)

-- Execute SELECT as DataUser
EXECUTE AS USER = 'PADREMIRON';  
GO
-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO

--SaleId	Product				TotalPrice
--1			Dell Laptop				8.49

-- Revert the User back to what user it was before
REVERT;
GO
-- DBO
-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO


--Custom string dynamic data masking of Product column 

ALTER TABLE dbo.BBM_Contacto_Paciente_TEST
ALTER COLUMN [Otros_Detalles] ADD MASKED WITH (FUNCTION = 'partial(1,"---",1)')
GO

EXEC BBM_SHOW_STATUS
GO

--name			table_name		is_masked		masking_function
--Customer		dbo.BBM_Contacto_Paciente_TEST		1			partial(1, "XXXXXXX", 0)
--Email			dbo.BBM_Contacto_Paciente_TEST		1			default()
--Product		dbo.BBM_Contacto_Paciente_TEST		1			partial(1, "---", 1)
--TotalPrice	dbo.BBM_Contacto_Paciente_TEST		1			random(1.00, 12.00)

-- Execute SELECT as DataUser
EXECUTE AS USER = 'PSICOLOGO';  
GO
-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO



-- Revert the User back to what user it was before
REVERT;
GO
PRINT USER
GO

-- dbo

-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO

--SaleId	Product
--1			Dell Laptop

-- ¿Cómo puedo hacer que el Usuario vea? --> Con Grant Unmask
GRANT UNMASK TO BBMDATAMASKINGPROS
GO

-- Execute SELECT as DataUser
EXECUTE AS USER = 'PSICOLOGO';  
GO
-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO

--SaleId	SellingDate			Customer	Email						Product			TotalPrice
--1	2019-05-01 00:00:00.0000000		Asif	Asif@companytest-0001.com	Dell Laptop			300.00


-- Revert the User back to what user it was before
REVERT;
GO


/*PROBAMOS CON EL USUARIO*/
EXECUTE AS USER = 'PADREMIRON';  
GO
-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO

REVERT;
GO
-- Dropping a Dynamic Data Mask --> Con esto puedo borrar máscara

ALTER TABLE dbo.BBM_Contacto_Paciente_TEST
ALTER COLUMN Email DROP MASKED;
GO

EXEC BBM_SHOW_STATUS
GO

--name	table_name	is_masked	masking_function
--Customer	dbo.BBM_Contacto_Paciente_TEST	1	partial(1, "XXXXXXX", 0)
--Product	dbo.BBM_Contacto_Paciente_TEST	1	partial(1, "---", 1)
--TotalPrice	dbo.BBM_Contacto_Paciente_TEST	1	random(1.00, 12.00)

-- Execute SELECT as DataUser
EXECUTE AS USER = 'PADREMIRON';  
GO
-- View monthly sales 
SELECT * 
from dbo.BBM_Contacto_Paciente_TEST 
GO
-- 1	2019-05-01 00:00:00.0000000	AXXXXXXX	Asif@companytest-0001.com	D---p	3.91

-- View EMAIL

