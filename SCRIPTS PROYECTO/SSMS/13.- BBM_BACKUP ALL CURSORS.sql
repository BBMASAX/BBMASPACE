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
CREATE OR ALTER PROC BBM_CURSORBACKUP
AS
	BEGIN
		DECLARE @name VARCHAR(50) -- database name  
		DECLARE @path VARCHAR(256) -- path for backup files  
		DECLARE @fileName VARCHAR(256) -- filename for backup  
		DECLARE @fileDate VARCHAR(20) -- used for file name
 
		-- specify database backup directory
		SET @path = 'C:\BBM_BACKUPS\'  
	    SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')
		DECLARE db_cursor CURSOR READ_ONLY FOR  
		SELECT name 
		FROM master.dbo.sysdatabases 
		WHERE name IN ('BBMASPACE_CLONE')

 
		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @name   
 
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
		   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
		   BACKUP DATABASE @name TO DISK = @fileName  
 
		   FETCH NEXT FROM db_cursor INTO @name   
		END   
		CLOSE db_cursor   
		DEALLOCATE db_cursor
	END
GO



EXECUTE BBM_CURSORBACKUP
GO


ALTER DATABASE BBMASPACE_CLONE SET READ_ONLY
GO

DROP DATABASE BBMASPACE_CLONE
GO
