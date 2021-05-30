/*******PRIMERO EJECUTAMOS PROCEDIMIENTO ALMACENADO DE BACKUPS*********/
-- CREATE OR ALTER PROCEDIMIENTO
CREATE PROC BBM_SPBACKUP
	@path VARCHAR(256)
AS
-- DECLARAMOS LAS VARIABLES
DECLARE @name VARCHAR(50), -- database name
-- @path VARCHAR(256), -- path for backup files
@fileName VARCHAR(256), -- filename for backup
@fileDate VARCHAR(20), -- used for file name
@backupCount INT


--CREAMOS UNA TABLA TEMPORAL
CREATE TABLE [dbo].#BBM_TEMPBACKUP 
(intID INT IDENTITY (1, 1), 
name VARCHAR(200))


-- CREAMOS LA CARPETA BBM_BACKUPS EN EL DIRECTORIO RA�Z
SET @path = 'C:\BBM_BACKUPS\'


--- Includes the date in the filename
SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112)

-- Includes the date and time in the filename
--SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ':', '')

INSERT INTO [dbo].#BBM_TEMPBACKUP  (name)
	SELECT name
	FROM master.dbo.sysdatabases
	WHERE name in ( 'BBM_ASPACE')
-- WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')

SELECT TOP 1 @backupCount = intID 
FROM [dbo].#BBM_TEMPBACKUP  
ORDER BY intID DESC

-- Utilidad: Solo Comprobaci�n N� Backups a realizar
print @backupCount

IF ((@backupCount IS NOT NULL) AND (@backupCount > 0))
BEGIN
	DECLARE @currentBackup INT
	SET @currentBackup = 1
	WHILE (@currentBackup <= @backupCount)
		BEGIN
			SELECT
				@name = name,
				@fileName = @path + name + '_' + @fileDate + '.BAK' -- Unique FileName
				--@fileName = @path + @name + '.BAK' -- Non-Unique Filename
				FROM [dbo].#BBM_TEMPBACKUP 
				WHERE intID = @currentBackup

			-- Utilidad: Solo Comprobaci�n Nombre Backup
			print @fileName

			-- does not overwrite the existing file
				BACKUP DATABASE @name TO DISK = @fileName
			-- overwrites the existing file (Note: remove @fileDate from the fileName so they are no longer unique
			--BACKUP DATABASE @name TO DISK = @fileName WITH INIT

				SET @currentBackup = @currentBackup + 1
		END
END
GO


-- Ejecutar Procedimiento
-- Input Parameter 'C:\Backup\'
EXEC BBM_SPBACKUP 'C:\BBM_BACKUPS\'
GO
/*****************************************************************************/


--LOGINS NIVEL SERVIDOR SIEMPRE
--USUARIOS NIVEL BASE DE DATOS

-- SE ALAMACENAN EN SECURITY Y AH� EST�N LOS DOS LOGINS

-- Encryption Clinic Data

-- One such scenario I talk to customers who have requirements of security is 
-- around column level encryption. 
-- It is one of the most simplest implementation and yet difficult to visualize.
--  The scenario is simple where-in most of the HRMS (Hospital Management Systems) 
-- come with a simple requirement that data of one person must be masked to other.

USE master
GO

--   Creamos login con el procedimiento almacenado sp_addlogin a nivel server

sp_addlogin 'BBMfisio1', 'Abcd1234.'
sp_addlogin 'BBMfisio2', 'Abcd1234.'



USE BBM_ASPACE
go

-- Options:
-- Map with Login 
-- WITHOUT login

DROP USER IF EXISTS BBMFIS01
GO

DROP USER IF EXISTS BBMFIS02
GO

CREATE USER BBMFIS01 FOR LOGIN BBMfisio1 --A NIVEL BASE DE DATOS 
go
CREATE USER BBMFIS02 /*USUARIO BASE DE DATOS*/ FOR LOGIN BBMfisio2 /*LOGIN DE SERVER*/
go
/*SE VEN EN DATABASE --> SECURITY>USERS*/
--VAMOS A USAR LA TABLA BBM_USUARIO
-- For our example we have two doctors, we want to build a mechanism where BBMFIS01 patients details
--  must not be visible to BBMFIS02. Let us create our simple table to keep values.


-- Vamos a encriptar uid y symptom

SELECT * FROM trial.BBM_Usuario
GO

-- Grant access to the table to both doctors. CONCEDEMOS EL HECHO DE QUE CONSULTEN E INSERTEN

GRANT SELECT, INSERT ON trial.BBM_Usuario TO BBMFIS01;
GRANT SELECT, INSERT ON trial.BBM_Usuario TO BBMFIS02;
Go

-- Basic Encryption steps

-- Next step is to create our keys. To start with, we need to create our Master Key first. 
-- Then we will create the Certificates we will use. 
-- In this example, I am using a Symmetric key which will be encrypted by the certificates as part of logic.

-- Create the Master Key

DROP MASTER KEY
GO


CREATE master KEY encryption BY password = 'Abcd1234.' --> CREAMOS UNA CLAVE MAESTRA PROTEGIDA POR ESA PALABRA. HAY QUE TENER CUIDADO, PORQUE YA HAY UNA MASTER KEY EN MASTER. LO QUE SIGNIFICA QUE TENEMOS QUE ESTAR EN LA TABLA
GO
/*SI VOY A BASE DE DATOS>SECURITY>SYMMETRIC KEYS. COMO EN EL GUI NO SE VE, SIEMPRE TENEMOS LA DUDA, ESTE COMANDO ME LO RESUELVE. POR LO TANTO, SIEMPRE TENGO UNA MASTER KEY
EN LA BASE DE DATOS, Y UNA COPIA EN MASTER */
SELECT name KeyName,
  symmetric_key_id KeyID,
  key_length KeyLength,
  algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
GO

--KeyName					KeyID	KeyLength	KeyAlgorithm
--##MS_DatabaseMasterKey##	101			256			AES_256

-- Create a self-signed certificate. SE CREAN 2 CERTIFICADOS (UTILIZA PARA PROTEGERSE LA MASTER KEY) UNA PARA CADA USER. DEBEN HACERSE CON FECHA DE CADUCIDAD, PARA OBLIGAR A RENOVAR


CREATE CERTIFICATE BBMFIS01cert AUTHORIZATION BBMFIS01 
WITH subject = 'Abcd1234.', start_date = '01/01/2021' 
GO
CREATE CERTIFICATE BBMFIS02cert AUTHORIZATION BBMFIS02 
WITH subject = 'Abcd1234.', start_date = '01/01/2021'
GO

/*SE VEN EN TABLA>SECURITY>CERTIFICATES*/



SELECT name CertName, -- ESTA SE USA PARA VER LOS CERTIFICADOS QUE TENEMOS
  certificate_id CertID,
  pvt_key_encryption_type_desc EncryptType,
  issuer_name Issuer
FROM sys.certificates;
GO


--CertName	CertID	EncryptType	             Issuer
--BBMFIS01cert	 256	ENCRYPTED_BY_MASTER_KEY	 Abcd1234.
--BBMFIS02cert	 257	ENCRYPTED_BY_MASTER_KEY	 Abcd1234.

--PARA SEGUIR PROTEGIENDO LA ENCRIPTACI�N, CREO DOS CLAVES SIM�TRICAS


CREATE SYMMETRIC KEY BBMFIS01key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE BBMFIS01cert 
GO

CREATE SYMMETRIC KEY BBMFIS02key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE BBMFIS02cert 
GO
/*CURIOSAMENTE, EN BASE>SECURITY>SYMMETRIC KEYS, ESTAS SI SE VEN*/

----
-- Let us next look at the Keys we just created using the DMVs.

SELECT *
FROM   sys.symmetric_keys 
GO 


--name	principal_id	symmetric_key_id	key_length	key_algorithm	algorithm_desc	create_date	modify_date	key_guid	key_thumbprint	provider_type	cryptographic_provider_guid	cryptographic_provider_algid
--##MS_DatabaseMasterKey##	1	101	256	A3	AES_256	2018-01-30 18:47:17.020	2018-01-30 18:47:17.020	02505A00-A89D-4C1A-97B7-A7ED6EF388D0	NULL	NULL	NULL	NULL
--BBMFIS01key	1	256	256	A3	AES_256	2018-01-30 18:51:43.670	2018-01-30 18:51:43.670	BDF48900-C7CD-403E-B83D-686C59572DB0	NULL	NULL	NULL	NULL
--BBMFIS02key	1	257	256	A3	AES_256	2018-01-30 18:52:01.397	2018-01-30 18:52:01.397	DBD5B600-FA58-4082-97E7-9954B5A20B08	NULL	NULL	NULL	NULL





-- Adding Data into table

-- Next is to simulate as two different users and enter some data into our tables.
-- Let us first impersonate as BBMFIS01 and enter values, 
-- next we will do it for BBMFIS02.


------------------------------EMPEZAMOS A ENCRIPTAR LA INFO-------------------------------------------




--IMPERSONO

EXECUTE AS User = 'BBMFIS01'


PRINT USER
GO

--ABRO LA CLAVE PARA PODER INSERTAR
OPEN SYMMETRIC KEY BBMFIS01key
    DECRYPTION BY CERTIFICATE BBMFIS01cert
GO

--- Insert into our table. HACEMOS LAS INSERCIONES PERO CON LA PALABRE ENCRYPTBYKEY.
-- METEMOS 3 PACIENTES

INSERT INTO [trial].[BBM_Usuario]
     VALUES
           ('KEYFIS0', 'USUARIO', 'INSERTADO', 'POR', 'BBMFISIO1',
		   Encryptbykey(Key_guid('BBMFIS01Key'), '12345678A'),
		   Encryptbykey(Key_guid('BBMFIS01Key'), 'TEST'))
GO


REVERT


/* BORRAMOS TABLA. PARA PODER ENCRIPTAR TIENE QUE SER VARBINARY SIEMPRE*/

DROP TABLE IF EXISTS trial.BBM_Usuario
GO
/*Msg 3726, Level 16, State 1, Line 254
Could not drop object 'trial.BBM_Usuario' because it is referenced by a FOREIGN KEY constraint.*/

ALTER TABLE trial.BBM_Expediente DROP CONSTRAINT BBM_Usuario_Usuario_ID_FK

DROP TABLE IF EXISTS trial.BBM_Usuario
GO


/*CREAMOS TABLA CON VALORES BUENOS*/
CREATE TABLE [trial].[BBM_Usuario]
(
	[Usuario_ID] [INTEGER],
	[Nombre_1] [varchar](20),
	[Nombre_2] [varchar](20),
	[Apellido_1] [varchar](20),
	[Apellido_2] [varchar](20),
	[DNI] [Varbinary](1000),
	[Otros_Detalles] [varbinary](4000),
)
GO

/*INSERTAMOS VALORES IMPERSONANDO*/

EXECUTE AS User = 'BBMFIS01'


PRINT USER
GO

--ABRO LA CLAVE PARA PODER INSERTAR
OPEN SYMMETRIC KEY BBMFIS01key
    DECRYPTION BY CERTIFICATE BBMFIS01cert
GO

SELECT *
FROM   sys.openkeys
GO


INSERT INTO [trial].[BBM_Usuario]
     VALUES
           (1,'USUARIO','INSERTADO','POR','FISIO01',
Encryptbykey(Key_guid('BBMFIS01Key'), '123456789'),
Encryptbykey(Key_guid('BBMFIS01Key'), 'TEXTO OCULTO'))
GO

INSERT INTO [trial].[BBM_Usuario]
     VALUES
           (2,'USUARIO','INSERTADO','POR','FISIO01',
Encryptbykey(Key_guid('BBMFIS01Key'), '1234567891'),
Encryptbykey(Key_guid('BBMFIS01Key'), 'TEXTO OCULTO'))
GO

INSERT INTO [trial].[BBM_Usuario]
     VALUES
           (3,'USUARIO','INSERTADO','POR','FISIO01',
Encryptbykey(Key_guid('BBMFIS01Key'), '12345674'),
Encryptbykey(Key_guid('BBMFIS01Key'), 'TEXTO OCULTO'))
GO




-- SACO EL LISTADO ENCRIPTANDO EL CODIGO DEL PACIENTE Y LA ENFERMEDAD QUE SUFRE. VEMOS QUE EST� TODO ENCRIPTADO --> M�S ADELANTE, CON BBMFIS01 USAMOS EL CERTIFICADO PARA VERLO
SELECT * FROM trial.BBM_Usuario
GO

--id	name	doctorname	uid																symptom
--1		Jack	BBMFIS01		0x005A7BD512B53E43A3D85027BEADAEA201000000D33772B7CFEA49C4EB854E184DF7803D2D02B6A4C2C5949FAD1A2903E8E0558115ED9FF942D9A0630E9B2555B5DC70D0	0x005A7BD512B53E43A3D85027BEADAEA2010000000C52F94AFF6CE976419E67EAA1E074050DAD406813DE5347A48C94CCEA0A3182
--2		Jill	BBMFIS01		0x005A7BD512B53E43A3D85027BEADAEA2010000000CEE8DAEDA92EAF6EB097563213EAFD7B3E054F448F5A1BCA1D0EB5F5D0D0757496D838505604DE19D7918FEB7EFB8FE	0x005A7BD512B53E43A3D85027BEADAEA2010000001EF36F1A4FA4661428653E125FA0A514F9C48A4FD8CC84AABBF58A85C0A7A7F8
--3		Jim	    BBMFIS01		0x005A7BD512B53E43A3D85027BEADAEA20100000022ED2CE3A2A5AF6DA666B64ED03A9B5B98B48ADE46BDD2BB9BC4641912DF1C9786FAAFA9A60E61E354CEB1A0D17EE90D	0x005A7BD512B53E43A3D85027BEADAEA201000000B340D3D95AD7776F26F2DD36B0BA90996A5ADED4041DD0005757E5242304C7535478D4CF8AC12C277205420BC9A8C25E


-- In this example the Doc1 has 3 records for him.
 
--Next is to revert back to BBMFIS02 and do the same set of operations.

--  Close all opened keys Y VUELVO A DBO. SI DEJO ABIERTO TODO CON LAS SESIONES, COMO NO HAY AUTORIZACI�N, NO PASAR�A NADA
CLOSE ALL symmetric keys
GO

REVERT 
GO

PRINT USER

-- BBMFIS02
EXECUTE AS user = 'BBMFIS02'
GO

PRINT USER
-- ABRO LAS CLAVES
OPEN symmetric KEY BBMFIS02key decryption BY certificate BBMFIS02cert
GO
-- view the list of open keys in the session
SELECT *
FROM   sys.openkeys
GO

--database_id	database_name	key_id	key_name	key_guid	opened_date	status
--12	hospitaldb	257	BBMFIS02key	B2DD2A00-343C-489C-8568-1DF5D80CB901	2018-01-30 19:19:53.203	1

-- INSERTO LO DEL DOCTOR 2, QUE ES EL QUE TIENE PERMISOS
INSERT INTO [trial].[BBM_Usuario]
     VALUES
           (1,'USUARIO','INSERTADO','POR','FISIO02',
Encryptbykey(Key_guid('BBMFIS02Key'), '123456789'),
Encryptbykey(Key_guid('BBMFIS02Key'), 'TEXTO OCULTO'))
GO

INSERT INTO [trial].[BBM_Usuario]
     VALUES
           (2,'USUARIO','INSERTADO','POR','FISIO02',
Encryptbykey(Key_guid('BBMFIS02Key'), '1234567891'),
Encryptbykey(Key_guid('BBMFIS02Key'), 'TEXTO OCULTO'))
GO

INSERT INTO [trial].[BBM_Usuario]
     VALUES
           (3,'USUARIO','INSERTADO','POR','FISIO02',
Encryptbykey(Key_guid('BBMFIS02Key'), '12345674'),
Encryptbykey(Key_guid('BBMFIS02Key'), 'TEXTO OCULTO'))
GO


 SELECT * FROM trial.BBM_Usuario
WHERE Apellido_2 = 'FISIO02'


/*name	uid																																			symptom
Jack	0x00FA104EC23C9745A25568985DFAF4B1020000007938F2C19D9BC06EE3C165B8970D56F72E9E01982902EDA1A8251A47E51736FF8EB359E475F1756657BDC32ADC2D31EB	0x00FA104EC23C9745A25568985DFAF4B102000000AA214E5B344D2EC5C9B6175E27FD439EF9B6ECB8DC7597FDE4DC7F9F0A31A745
Jill	0x00FA104EC23C9745A25568985DFAF4B1020000006FBB6DA34B5E638F8B162EBC4DCF7120C6E4CED5D0F14EEF7DDEAC2C1AE07C1D8F3F839D4622AC4B79EA00FCD609D7AB	0x00FA104EC23C9745A25568985DFAF4B102000000A99F7A005BAA5732E75CE3902D0A77847E0C82AA5CA5FB2DDB62C899E569B719
Jim		0x00FA104EC23C9745A25568985DFAF4B102000000D8FF319F611109311C24CF71DD4718F9D7E4170429E6B92D77EA7817FFF4ADF7FF6A35B5D9FFE02ECDE0FDC217019761	0x00FA104EC23C9745A25568985DFAF4B1020000001B84645FF8F7353B25297EB346BCE31CC9FF9846CCCC12F3CF86899B73AD4354E542413D163BB7359FF7BB9CB5573A30
Rick	0x002F9344D2DC5E4E947414BCD890997A0200000079AE0714C93E12EF35F9414AF74F7A43EF7907059DB4A9849B6997958CA09802DFA759082D598B05EE6AD3FE494BD977	0x002F9344D2DC5E4E947414BCD890997A020000005D6B966509175A6AD1962F9334E9B9A3AE8735760881ED2673E3086F726BAC5B
Joe		0x002F9344D2DC5E4E947414BCD890997A0200000009FB5AB7547F77E15A26674E08B293294D0975D0F5EA9E2C3E7E941BFD7784AD54FB98003D96BAF14FBF210B9B911637	0x002F9344D2DC5E4E947414BCD890997A020000007266380919A953540045528D627A85A36C2BACC39C4F49227BF273081C8A9530
Pro		0x002F9344D2DC5E4E947414BCD890997A020000006913A3263FB02B78118A3AAED142ECAA0214F06C557BC0971ECD0CC477BD4E27FE8FD162441993CB0B8B1C86AEECFDC0	0x002F9344D2DC5E4E947414BCD890997A020000005745AEAFF06E9666B4E028010099252324BB6589D309BD101043553C1C4EBB0D*/


--PARA FINALIZAR CIERRO.
CLOSE ALL symmetric keys
GO

SELECT * FROM trial.BBM_Usuario
GO

--name	doctorname	symptom
--Jack	BBMFIS01	0x005A7BD512B53E43A3D85027BEADAEA2010000000C52F94AFF6CE976419E67EAA1E074050DAD406813DE5347A48C94CCEA0A3182
--Jill	BBMFIS01	0x005A7BD512B53E43A3D85027BEADAEA2010000001EF36F1A4FA4661428653E125FA0A514F9C48A4FD8CC84AABBF58A85C0A7A7F8
--Jim	BBMFIS01	0x005A7BD512B53E43A3D85027BEADAEA201000000B340D3D95AD7776F26F2DD36B0BA90996A5ADED4041DD0005757E5242304C7535478D4CF8AC12C277205420BC9A8C25E
--Rick	BBMFIS02	0x002ADDB23C349C4885681DF5D80CB901010000002ADB2CFF507A9DD38ED3FBCDFF007372EAE973EB00147C25D708A6E93AF3BAD7
--Joe	BBMFIS02	0x002ADDB23C349C4885681DF5D80CB901010000002B1BBF2C2F92D2144552AE4691C17E342496FD604AD5E144EA2A083A1524A28F
--Pro	BBMFIS02	0x002ADDB23C349C4885681DF5D80CB90101000000E37BECCB15AFB987D089FD5CC60977B633CF3B264F0B9E4048C555F3A288BD39





-- AHORA DESENCRIPTO PARA VER LAS ENCRIPTACIONES DE LAS TABLAS
-- As you can see the values are not visible as-is but has some garbage.

-- Impersonate as Doctor and show Values

-- The next step is to show that BBMFIS01 can see his data 
--and BBMFIS02 can see his data alone. The steps are simple:
REVERT
GO
print user


-- ME IMPERSONO
EXECUTE AS user = 'BBMFIS01'
GO
OPEN SYMMETRIC KEY BBMFIS01key decryption  BY CERTIFICATE BBMFIS01cert -- SIEMPRE Y CUANDO DISPONGA EL CERTIFICADO SE VER�A
GO


SELECT Usuario_ID, --> COMPROBAMOS LO QUE VE EL DOCTOR 1. LO QUE EST� ENCRIPTADO POR 2 SE VE COMO NULO
Nombre_1,
Apellido_2,
CONVERT(VARCHAR, Decryptbykey(DNI))      AS DNI,
CONVERT (VARCHAR, Decryptbykey(Otros_Detalles)) AS Detalles
FROM   trial.BBM_Usuario
GO

--id	name		doctorname	UID			Symptom
--1		Jack		BBMFIS01		1111111111	Cut
--2		Jill		BBMFIS01		2222222222	Bruise
--3		Jim			BBMFIS01		3333333333	Head ache
--4		Rick		BBMFIS02		NULL		NULL 
--5		Joe			BBMFIS02		NULL		NULL
--6		Pro			BBMFIS02		NULL		NULL

CLOSE ALL SYMMETRIC keys
GO


-- HACEMOS EL DOCTOR 2
REVERT
GO

PRINT USER

EXECUTE AS USER ='BBMFIS02'
GO


OPEN SYMMETRIC KEY BBMFIS02key decryption BY CERTIFICATE BBMFIS02cert
GO



SELECT Usuario_ID, 
Nombre_1,
Apellido_2,
CONVERT(VARCHAR, Decryptbykey(DNI))      AS DNI,
CONVERT (VARCHAR, Decryptbykey(Otros_Detalles)) AS Detalles
FROM   trial.BBM_Usuario
GO

--id	name	doctorname	UID			Symptom
--1		Jack	BBMFIS01		NULL		NULL
--2		Jill	BBMFIS01		NULL		NULL
--3		Jim		BBMFIS01		NULL		NULL
--4		Rick	BBMFIS02		4444444444	Cough
--5		Joe		BBMFIS02		5555555555	Asthma
--6		Pro		BBMFIS02		6666666666	Cold


-- Null id Patient 1 2 3 
CLOSE ALL SYMMETRIC keys
GO


REVERT
GO 

PRINT USER


--PARA CERRAR EL EJERCICIO, ME CARGO EL CERTIFICADO Y COMPRUEBO

-- Conclusion

-- As you can see this is a very simple implementation of column level encryption 
-- inside SQL Server and can be quite effective to mask data from each others in a multi-tenant 
-- environment. There are a number of reasons one can go for this solution. I thought this will 
-- be worth a shout even though the implementation has been in industry for close to a decade now.



DROP SYMMETRIC KEY [BBMFIS02key] -- como est�n anidados, primero tengo que borrar la clave sim�trica
GO

DROP CERTIFICATE [BBMFIS02cert]
GO


EXECUTE AS USER ='BBMFIS02'
GO


OPEN SYMMETRIC KEY BBMFIS02key decryption BY CERTIFICATE BBMFIS02cert
GO

/*Msg 15151, Level 16, State 1, Line 415
Cannot find the symmetric key 'BBMFIS02key', because it does not exist or you do not have permission.
*/

SELECT Usuario_ID, 
Nombre_1,
Apellido_2,
CONVERT(VARCHAR, Decryptbykey(DNI))      AS DNI,
CONVERT (VARCHAR, Decryptbykey(Otros_Detalles)) AS Detalles
FROM   trial.BBM_Usuario
GO
/*
id	name	doctorname	UID	Symptom
1	Jack	BBMFIS01		NULL	NULL
2	Jill	BBMFIS01		NULL	NULL
3	Jim		BBMFIS01		NULL	NULL
4	Rick	BBMFIS02		NULL	NULL
5	Joe		BBMFIS02		NULL	NULL
6	Pro		BBMFIS02		NULL	NULL
*/

REVERT


PRINT USER

