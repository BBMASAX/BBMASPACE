USE BBM_ASPACE
GO

/*CLONO BASE PARA HACER LAS PRUEBAS*/
DBCC CLONEDATABASE (BBM_ASPACE, BBMASPACE_CLONE);    
GO 



USE BBMASPACE_CLONE
GO


-- POR DEFECTO EL CLONADO LO CREA EN READ ONLY, ASÍ QUE YO LO PONGO EN READ/WRITE
ALTER DATABASE BBMASPACE_CLONE SET READ_WRITE
GO

USE master
GO
DROP PROCEDURE IF EXISTS BBM_SPBACKUP
GO

-- SQL Server 2017
-- CREATE OR ALTER 
CREATE PROC BBM_SPBACKUP
	@path VARCHAR(256)
AS
-- Declarando variables
DECLARE @name VARCHAR(50), -- database name
-- @path VARCHAR(256), -- path for backup files
@fileName VARCHAR(256), -- filename for backup
@fileDate VARCHAR(20), -- used for file name
@backupCount INT

CREATE TABLE [dbo].#BBM_TEMPBACKUP 
(intID INT IDENTITY (1, 1), 
name VARCHAR(200))

-- Crear la Carpeta Backup
-- SET @path = 'C:\BBM_BACKUPS\'

-- Includes the date in the filename
SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112)

-- Includes the date and time in the filename
--SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ':', '')

INSERT INTO [dbo].#BBM_TEMPBACKUP  (name)
	SELECT name
	FROM master.dbo.sysdatabases
	WHERE name in ( 'BBMASPACE_CLONE')
-- WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')

SELECT TOP 1 @backupCount = intID 
FROM [dbo].#BBM_TEMPBACKUP  
ORDER BY intID DESC

-- Utilidad: Solo Comprobación Nº Backups a realizar
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

			-- Utilidad: Solo Comprobación Nombre Backup
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




ALTER DATABASE BBMASPACE_CLONE SET READ_ONLY
GO

DROP DATABASE BBMASPACE_CLONE
GO