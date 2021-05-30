-- TRANSPARENT DATA ENCRYPTION (TDE)

-- AT REST
-- mdf, ndf, ldf

--Configuring a SQL Server database for TDE is a straight-forward process. It consists of:

--Creating the database master key in the master database.
--Creating a certificate encrypted by that key.
--Backing up the certificate and the certificate's private key. While this isn't required to encrypt the database, you want to do this immediately.
--Creating a database encryption key in the database that's encrypted by the certificate.
--Altering the database to turn encryption on.

USE [master];
GO

drop master key
go

-- Create the database master key
-- to encrypt the certificate
CREATE MASTER KEY
  ENCRYPTION BY PASSWORD = 'Abcd1234.';
GO 

-- Create the certificate we're going to use for TDE
CREATE CERTIFICATE TDEBBMASPACE
  WITH SUBJECT = 'TDE Cert for Project';
GO 
-- VER EN SSMS EL CERTIFICADO    -BD MASTER -SECURITY -CERTIFICATES


-- CERTIFICATES T-SQL

SELECT TOP 1 * 
FROM sys.certificates 
ORDER BY name DESC
GO

--name	certificate_id	principal_id	pvt_key_encryption_type	pvt_key_encryption_type_desc	is_active_for_begin_dialog	issuer_name	cert_serial_number	sid	string_sid	subject	expiry_date	start_date	thumbprint	attested_by	pvt_key_last_backup_date	key_length
--TDEBBMASPACE	261	1	MK	ENCRYPTED_BY_MASTER_KEY	1	TDE Cert for Test	1a 06 45 8f ec 08 34 8e 43 9a b7 63 d5 6f a1 50	0x0106000000000009010000009786C19F76D4A77DF3E6BE100E7F9A7517943E31	S-1-9-1-2680260247-2108150902-280946419-1973059342-826184727	TDE Cert for Test	2022-04-22 20:07:33.000	2021-04-22 20:07:33.000	0x9786C19F76D4A77DF3E6BE100E7F9A7517943E31	NULL	NULL	2048

-- Back up the certificate and its private key
-- Remember the password!
BACKUP CERTIFICATE TDEBBMASPACE
  TO FILE = 'C:\BBMTDE\TDEBBMASPACE.cer'
  WITH PRIVATE KEY ( 
    FILE = 'C:\BBMTDE\TDEBBMASPACE_key.pvk',
 ENCRYPTION BY PASSWORD = 'Abcd1234.'
  );
GO
-- Look at Folder C:\BBMTDE



-- Create the DEK (DATABASE ENCRYPTION KEY)so we can turn on encryption
USE BBM_ASPACE;
GO 

CREATE DATABASE ENCRYPTION KEY
  WITH ALGORITHM = AES_256
  ENCRYPTION BY SERVER CERTIFICATE TDEBBMASPACE;
GO 

-- INFORMATION

SELECT  * 
FROM sys.dm_database_encryption_keys
GO

-- database_id	encryption_state	create_date					regenerate_date				modify_date					set_date					opened_date					key_algorithm	key_length	encryptor_thumbprint						encryptor_type		percent_complete
-- 2			3					2021-04-22 20:05:23.110		2021-04-22 20:05:23.110		2021-04-22 20:05:23.110		1900-01-01 00:00:00.000		2021-04-22 20:05:23.110		AES				256			0x											ASYMMETRIC KEY		0
-- 18			1					2021-04-22 20:08:22.357		2021-04-22 20:08:22.357		2021-04-22 20:08:22.357		1900-01-01 00:00:00.000		2021-04-22 20:08:22.357		AES				256			0x9786C19F76D4A77DF3E6BE100E7F9A7517943E31	CERTIFICATE			0

-- Exit out of the database. If we have an active 
-- connection, encryption won't complete.
USE [master];
GO 

-- Turn on TDE
-- T-SQL OR SSMS

ALTER DATABASE [BBM_ASPACE]  SET ENCRYPTION ON;
GO 

--This starts the encryption process on the database. 
--Note the password I specified for the database master key. 
--As is implied, when we go to do the restore on the second server, 
-- I'm going to use a different password. 
-- Having the same password is not required, but having the same certificate is. 
-- We'll get to that as we look at the "gotchas" in the restore process.

--Even on databases that are basically empty, it does take a few seconds to encrypt the database.
--  You can check the status of the encryption with the following query:

-- We're looking for encryption_state = 3
-- Query periodically until you see that state
-- It shouldn't take long
SELECT DB_Name(database_id) AS 'Database', encryption_state 
FROM sys.dm_database_encryption_keys;
GO

--Database	encryption_state
--tempdb			3
--RecoveryWithTDE	3


-- hint

-- https://docs.microsoft.com/es-es/sql/relational-databases/system-dynamic-management-views/sys-dm-database-encryption-keys-transact-sql?view=sql-server-ver15

--encryption_state	int	Indicates whether the database is encrypted or not encrypted.

--0 = No database encryption key present, no encryption

--1 = Unencrypted

--2 = Encryption in progress

--3 = Encrypted

--4 = Key change in progress

--5 = Decryption in progress

--6 = Protection change in progress (The certificate or asymmetric key that is encrypting the database encryption key is being changed.)

-- As the comments indicate, we're looking for our database to show a state of 3, meaning the encryption is finished. 

-- When the encryption_state shows as 3, you should take a backup of the database, because we'll need it for the restore to the second server (your path may vary):

-- Now backup the database so we can restore it
-- Onto a second server

BACKUP DATABASE [BBM_ASPACE]
TO DISK = 'C:\BBMTDE\BACKBBMASPACE_Full.bak';
GO 

--Processed 352 pages for database 'RecoveryWithTDEBBM', file 'RecoveryWithTDEBBM' on file 1.
--Processed 2 pages for database 'RecoveryWithTDEBBM', file 'RecoveryWithTDEBBM_log' on file 1.
--BACKUP DATABASE successfully processed 354 pages in 0.055 seconds (50.168 MB/sec).

BACKUP LOG [BBM_ASPACE]
TO DISK = 'C:\BBMTDE\BACKBBMASPACE_log.bak'
With NORECOVERY
GO

--Processed 3 pages for database 'RecoveryWithTDEBBM', file 'RecoveryWithTDEBBM_log' on file 1.
--BACKUP LOG successfully processed 3 pages in 0.019 seconds (1.130 MB/sec).
