USE [BBM_ASPACE];
GO

-- Basic example
DECLARE @BBM_HASHING NVARCHAR(MAX) = 'Project Hash inclusion'
SELECT HASHBYTES ('SHA2_512', @BBM_HASHING) AS [Hash value];
GO

-- All the hashing algorithms
DECLARE @BBM_HASHING NVARCHAR(MAX) = 'Project Hash inclusion'
SELECT HASHBYTES ('MD2', @BBM_HASHING) AS [Hash value], DATALENGTH(HASHBYTES ('MD2', @BBM_HASHING)) AS [Data lenght];
SELECT HASHBYTES ('MD4', @BBM_HASHING) AS [Hash value], DATALENGTH(HASHBYTES ('MD4', @BBM_HASHING)) AS [Data lenght];
SELECT HASHBYTES ('MD5', @BBM_HASHING) AS [Hash value], DATALENGTH(HASHBYTES ('MD5', @BBM_HASHING)) AS [Data lenght];
SELECT HASHBYTES ('SHA', @BBM_HASHING) AS [Hash value], DATALENGTH(HASHBYTES ('SHA', @BBM_HASHING)) AS [Data lenght];
SELECT HASHBYTES ('SHA1', @BBM_HASHING) AS [Hash value], DATALENGTH(HASHBYTES ('SHA1', @BBM_HASHING)) AS [Data lenght];
SELECT HASHBYTES ('SHA2_256', @BBM_HASHING) AS [Hash value], DATALENGTH(HASHBYTES ('SHA2_256', @BBM_HASHING)) AS [Data lenght];
SELECT HASHBYTES ('SHA2_512', @BBM_HASHING) AS [Hash value], DATALENGTH(HASHBYTES ('SHA2_512', @BBM_HASHING)) AS [Data lenght];
GO

-- No salt
DECLARE @BBM_HASHING NVARCHAR(MAX) = 'Project Hash inclusion'
SELECT HASHBYTES ('SHA2_512', @BBM_HASHING) AS [Hash value 1];
SELECT HASHBYTES ('SHA2_512', @BBM_HASHING) AS [Hash value 2];

-- Different data types
SELECT HASHBYTES ('SHA2_512', N'Gin tonic') AS [Hash value 1];
SELECT HASHBYTES ('SHA2_512', 'Gin tonic') AS [Hash value 2];

-- Get hashes for customer invoices
USE [BBM_ASPACE];
GO
SELECT 
	trial.BBM_Tratamientos.Tratamiento_ID
	, HASHBYTES ('SHA2_512', (
SELECT        trial.BBM_Usuario.Usuario_ID, trial.BBM_Tratamientos.Tratamiento_ID, trial.BBM_STANSARDPRICE.Precio
FROM            trial.BBM_Usuario CROSS JOIN
                         trial.BBM_Tratamientos CROSS JOIN
                         trial.BBM_STANSARDPRICE
		WHERE 
			Precio = '10'
		FOR XML AUTO)
		) AS [Invoices hash]
FROM 
	trial.BBM_Tratamientos