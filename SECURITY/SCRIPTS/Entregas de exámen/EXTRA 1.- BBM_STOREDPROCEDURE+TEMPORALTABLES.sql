SELECT object_name(object_id) AS TableName,
		Name as ColumnName
FROM sys.columns
WHERE name LIKE '%nombre%'

USE BBM_ASPACE /*O EN BASE DE DATOS A USAR*/
GO

DROP PROCEDURE IF EXISTS sp_BBM_SEARCHENCRYPT
GO

CREATE OR ALTER PROCEDURE sp_BBM_SEARCHENCRYPT
AS
		BEGIN
		DECLARE @DatabaseName nvarchar(100)
		, @Word nvarchar(50)
		, @SQL nvarchar(max)

-- Borra la tabla #Words si existe
IF OBJECT_ID('tempdb.dbo.#Words', 'U') IS NOT NULL
DROP TABLE #Words;

-- Borra la tabla #DiscoverGDPR si existe
IF OBJECT_ID('tempdb.dbo.#DiscoverGDPR', 'U') IS NOT NULL
DROP TABLE #DiscoverGDPR;

-- Creación de tabla #Words
CREATE TABLE #Words (word nvarchar(50))

-- Creación de tabla #DiscoverGDPR
CREATE TABLE #DiscoverGDPR (DatabaseName nvarchar(100), SchemaName nvarchar(100), TableName nvarchar(100), ColumnName nvarchar(100))

-- Insertamos palabras a buscar en la tabla #Words
INSERT INTO #Words VALUES
-- Spanish
('Nombre')
,('Apellido')
,('Tel') -- Aquí cogería valores como Telefono y abreviaturas
,('Tfno')
,('Direccion')
,('Poblacion')
,('Ciudad')
,('Pais')
,('Postal') -- Aquí cogería valores como CodigoPostal, DireccionPostal, DestinoPostal
,('CP')
,('Nac') -- Aquí cogería valores como Nacionalidad, FechaNacimiento, LugarNacimiento
,('DNI')
,('CIF')
,('NIE')
,('Pasaporte')
,('Identifi')
,('Mail') -- Aquí cogería valores como Mail, Email, Correo Mail
,('Correo') -- Aquí cogería valores como Correo, CorreoElectronico
,('Foto') -- Aquí cogería valores como Foto, Fotografia
,('Banco')
,('Tarjeta')
,('Cuenta')
,('Numero') -- Aquí cogería valores como NumeroCuenta, NumeroTelefono
,('IP')

-- English (Algunos términos de Spanish también son válidos, como Postal o Identifi)
,('Name')
,('Surname')
,('Phone') -- Aquí cogería valores como Phone, PhoneNumber, Cellphone
,('Mobile')
,('Cell')
,('Celular')
,('Address')
,('City')
,('Country')
,('ZIP')
,('Code')
,('Birthday')
,('Passport')
,('Photo')
,('Bank')
,('Card')
,('Account')
,('Number')
,('IP')

-- Creamos un cursor con las Bases de Datos en las que queremos buscar la información
DECLARE db_cursor CURSOR
FOR 

	SELECT	name 
	FROM	master.sys.databases
	WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb', 'distribution');

-- Iniciamos cursor db_cursor	
OPEN db_cursor

-- Avanzamos cursor db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName;

-- Loop db_cursor
WHILE @@FETCH_STATUS = 0
BEGIN

-- Creamos un cursor que recorra la tabla #Words
DECLARE Word_Cursor CURSOR FOR 
SELECT * FROM #Words

-- Iniciamos cursor Word_Cursor
OPEN Word_Cursor 

-- Avanzamos cursor Word_Cursor
FETCH NEXT FROM Word_Cursor INTO @Word

-- Loop Word_Cursor
WHILE @@FETCH_STATUS = 0
BEGIN 

	-- Creamos la sentencia
	SET @SQL =	'USE ' + @DatabaseName + ';' +

				'INSERT INTO #DiscoverGDPR ' +
				'SELECT	''' + @DatabaseName + ''' AS [database], ' +
				'		SCHEMA_NAME(schema_id) AS [schema],  ' +
				'		t.name AS table_name, c.name AS column_name ' + 
				'FROM	sys.tables AS t ' + 
				'INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID ' + 
				'WHERE	c.name LIKE ''%'+ @Word +'%'' COLLATE SQL_Latin1_General_CP1_CI_AI' 
	
	-- Ejecutamos sentencia
	EXEC sp_executesql @SQL

-- Avanzamos cursor Word_Cursor
FETCH NEXT FROM Word_Cursor INTO @Word

END

-- Cerramos y borramos cursor Word_Cursor
CLOSE Word_Cursor 
DEALLOCATE Word_Cursor 

-- Avanzamos cursor db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName;

END

-- Cerramos y borramos cursor db_cursor
CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Mostramos los datos
SELECT *
FROM #DiscoverGDPR
ORDER BY DatabaseName, SchemaName, TableName, ColumnName
END
GO

EXEC sp_BBM_SEARCHENCRYPT 


