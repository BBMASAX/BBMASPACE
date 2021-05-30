/*PRIMERO HACEMOS UN BACKUP DE LA BASE DE DATOS ORIGINAL Y UN CLONADO DE LA BASE DE DATOS*/
DBCC CLONEDATABASE ('BBM_ASPACE', 'BBM_ASPACEClone')




-- create a new database for this example

USE MASTER;
GO
-- create master key and certificate in database master
-- CREAMOS LA MASTER KEY. 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
GO

-- HINT : IF EXISTS --> ESTO ES UNA PRUEBA DE LANZAR DOS VECES EL COMANDO
-- Msg 15578, Level 16, State 1, Line 54
--There is already a master key in the database. Please drop it before performing this statement.
-- NO PROBLEM

DROP CERTIFICATE SQL_encriptar_BBMDBCert
GO
CREATE CERTIFICATE SQL_encriptar_BBMDBCert --> SON CERTIFICADOS SELF-SIGN. Es posible hacerlo en producción
    WITH SUBJECT = 'SQL_encriptar_BBMDB Backup Certificate';
GO

-- export the backup certificate to a file --> Es una recomendación. Porque cuando pierdes un certificado del backup, sería irrecuperable

/****CREAMOS LA CARPETA BBMBACKCERT****/
BACKUP CERTIFICATE SQL_encriptar_BBMDBCert 
TO FILE = 'c:\BBMBACKCERT\SQL_encriptar_BBMDBCert.cert'
WITH PRIVATE KEY (
			FILE = 'c:\BBMBACKCERT\SQL_encriptar_BBMDBCert.key', --> nuestra master key creada anteriormente
			ENCRYPTION BY PASSWORD = 'Abcd1234.')
GO



--MI OBJETIVO ES GUARDAR LOS backup the database with encryption. LA IDEA ES PROTEGERLA ENCRIPTANDO EL BACKUP
BACKUP DATABASE BBM_ASPACE
TO DISK = 'c:\BBMBACKCERT\BBM_ASPACE.bak'
WITH ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = SQL_encriptar_BBMDBCert) --> CON ESTO ME HACE EL CERTIFICADO
GO

/*Processed 384 pages for database 'SQL_encriptar_BBM', file 'SQL_encriptar_BBM' on file 1.
Processed 6 pages for database 'SQL_encriptar_BBM', file 'SQL_encriptar_BBM_log' on file 1.
BACKUP DATABASE successfully processed 390 pages in 0.195 seconds (15.622 MB/sec).*/


/*UNA PRUEBA SERÍA CARGARSE LA BASE DE DATOS Y HACER EL RESTORE CON EL CERTIFICADO. AQUÍ SERÍA EL FINAL*/


/*VAMOS A INTENTAR CARGARNOS EL .MDF DE LA BASE DE DATOS SITUADA EN C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA*/


-- OUR EXAMPLE WITHOUT USING SECOND SERVER

-- TAKE DATABASE BBM_ASPACE offline
 
ALTER DATABASE BBM_ASPACE SET OFFLINE WITH  ROLLBACK IMMEDIATE --> PONGO LA BASE DE DATOS OFFLINE ECHANDO A QUIEN ESTÉ CONECTADO
go

-- Failed to restart the current database. The current database is switched to master.

-- SI HACEMOS REFRESH, VEMOS QUE NUESTRA BASE TIENE COMO UNA X Y PONE OFFLINE. SI HAGO CLIC DERECHO EN LA BASE DE DATOS>TASK NO ME DEJA HACER TAKE OFFLINE. ESO TAMBIÉN ES UN INDICATIVO

-- delete .mdf data file from the hard drive
-- C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\SQL_encriptar_BBM.MDF
-- DATABASE OFFLINE ALLOWS DELETE
 

 -- DATABASE ONLINE AGAIN
 -- mejor desde GUI

ALTER DATABASE BBM_ASPACE SET ONLINE WITH  ROLLBACK IMMEDIATE --> DA UN ERROR, PERO SI LE DAMOS A REFRESH, SE PONE EN ESTADO RECOVERY PENDING. SI MIRAMOS CON BOTÓN DERECHO EN TASK, ME DEJA TAKE OFFLINE, CON LO QUE ESTÁ ONLINE
go

--Msg 5120, Level 16, State 101, Line 113
--Unable to open the physical file "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\SQL_encriptar_BBM.mdf". Operating system error 2: "2(The system cannot find the file specified.)".
--Msg 5181, Level 16, State 5, Line 113
--Could not restart database "SQL_encriptar_BBM". Reverting to the previous status.
--Msg 5069, Level 16, State 1, Line 113
--ALTER DATABASE statement failed.

--GUI BBM_ASPACE RECOVERY PENDING

-- BUT LOOKING TO GUI IS ONLINE

/*HAGO UN BACKUP DEL LOG PARA TEST*/

USE master;
GO
-- attempt to take TailLogDB online
BACKUP LOG BBM_ASPACE
TO DISK = 'c:\BBMBACKCERT\BBM_ASPACETailLogDB.log'
WITH CONTINUE_AFTER_ERROR,ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = SQL_encriptar_BBMDBCert)
go


--Processed 14 pages for database 'SQL_encriptar_BBM', file 'SQL_encriptar_BBM_log' on file 1.
--BACKUP LOG successfully processed 14 pages in 0.047 seconds (2.316 MB/sec).



--Check for the backup
 
/*PROBAMOS A CARGARNOS LA BASE DE DATOS*/
 
DROP DATABASE BBM_ASPACE; --> REFRESCO DESPUÉS DE EJECUTAR
GO

-- Commands completed successfully.
-- REFRESH. NO DATABASE

/***PARA DARLE EMOCIÓN, ME CARGO TODO***/
USE master
GO
 -- RECREATE master key and certificate

DROP CERTIFICATE SQL_encriptar_BBMDBCert
GO
DROP SYMMETRIC KEY SQL_encriptar_BBMDBCert --> a VECES FALLA
GO
DROP MASTER KEY
GO

/*CREO LA MASTER KEY*/

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
GO


-- restore the certificate --> rESTAURAMOS EL CERTOFICADO
CREATE CERTIFICATE SQL_encriptar_BBMDBCert
FROM FILE = 'C:\BBMBACKCERT\SQL_encriptar_BBMDBCert.cert'
WITH PRIVATE KEY (FILE = 'C:\BBMBACKCERT\SQL_encriptar_BBMDBCert.key',
DECRYPTION BY PASSWORD = 'Abcd1234.');
GO

-- EN ALGUNOS CASOS
--Msg 15232, Level 16, State 1, Line 209
--A certificate with name 'SQL_encriptar_BBMDBCert' already exists or this certificate already has been added to the database.
-- LO BORRO
-- <Commands completed successfully.

--Use RESTORE WITH MOVE to move and/or rename database files to a new path.

/*ESTO ES EL MOMENTO CUMBRE*/
 
RESTORE DATABASE BBM_ASPACE
FROM DISK = 'c:\BBMBACKCERT\BBM_ASPACE.bak'
WITH NORECOVERY,
MOVE 'BBM_ASPACE_PRINCIPAL' TO 'c:\BBMBACKCERT\BBM_ASPACE_Data.mdf', 
MOVE 'BBM_ASPACE_SECONDARY' TO 'c:\BBMBACKCERT\BBM_ASPACE_Data.ndf',
MOVE 'BBM_ASPACE_log' TO 'c:\BBMBACKCERT\BBM_ASPACE_Log.ldf', 
REPLACE, STATS = 10;
GO
/*A VECES DICE QUE NO TIENES PERMISO. VAMOS A LA CARPETA Y LE DAMOS CONTROL TOTAL SOBRE ELLA*/

/*10 percent processed.
20 percent processed.
30 percent processed.
41 percent processed.
51 percent processed.
61 percent processed.
71 percent processed.
80 percent processed.
90 percent processed.
100 percent processed.
Processed 384 pages for database 'SQL_encriptar_BBM', file 'SQL_encriptar_BBM' on file 1.
Processed 6 pages for database 'SQL_encriptar_BBM', file 'SQL_encriptar_BBM_log' on file 1.
RESTORE DATABASE successfully processed 390 pages in 0.090 seconds (33.848 MB/sec).*/

-- HINT SQL_encriptar_BBM RESTORING
-- GUI SQL_encriptar_BBM (RESTORING)

/*ANTES DE LANZAR EL LOG LE DAMOS A REFRESH PARA QUE SE VEA QUE ESTÁ ESPERANDO POR EL ARCHIVO*/

/*LANZAMOS EL RESTORE DEL LOG*/
-- attempt the restore log 
RESTORE LOG BBM_ASPACE
FROM DISK = 'c:\BBMBACKCERT\BBM_ASPACETailLogDB.log';
GO


/*Processed 0 pages for database 'SQL_encriptar_BBM', file 'SQL_encriptar_BBM' on file 1.
Processed 14 pages for database 'SQL_encriptar_BBM', file 'SQL_encriptar_BBM_log' on file 1.
RESTORE LOG successfully processed 14 pages in 0.009 seconds (12.098 MB/sec).*/

-- HINT SQL_encriptar_BBM RESTORING
-- GUI SQL_encriptar_BBM ON LINE


/*VEMOS QUE ESTA FETÉN LO QUE HEMOS BORRADO*/

--Data validation 
USE BBM_ASPACE 
GO
SELECT * FROM trial.BBM_Usuario;
GO



