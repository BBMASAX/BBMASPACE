USE BBM_ASPACE
GO


/*CREO ESQUEMA PARA HACER PRUEBAS*/
DROP SCHEMA IF EXISTS trial
GO

CREATE SCHEMA trial
GO

--------------------------------
--VER 3.- CREATE TABLES & INSERT VALUES FOR TESTING
--------------------------------





/*CREAMOS UNA VISTA PARA EL USUARIO*/

SELECT *
FROM trial.BBM_Expediente
GO
--ID_Expediente	BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad	BBM_Usuario_Usuario_ID
--GPPTUT012		APRAXIA IDEOMOTORA								USERGPP012
/*QUIERO QUE SOLO VEA LOS CAMPOS DE ARRIBA*/


/*CREO LA VISTA*/
DROP VIEW IF EXISTS trial.bbmlookexpediente
GO

CREATE VIEW trial.bbmlookexpediente
AS
SELECT
	ID_Expediente, BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad, BBM_Usuario_Usuario_ID
FROM trial.BBM_Expediente
GO

/*CREO UN ROL*/
DROP ROLE IF EXISTS BBMConsultasUsuarios
GO

CREATE ROLE BBMConsultasUsuarios
GO

/*DOY PERMISOS DE SELECT AL ROL*/
GRANT SELECT ON trial.bbmlookexpediente TO BBMConsultasUsuarios;
GO 



/*CREAMOS UN USUARIO PARA ASIGNARLE EL ROL*/


DROP USER IF EXISTS USERGPP012
GO
CREATE USER USERGPP012 WITHOUT LOGIN;
GO 

-- METEMOS AL USUARIO EN EL ROL
ALTER ROLE BBMConsultasUsuarios
ADD MEMBER USERGPP012;
GO 

/*NOS IMPERSONAMOS COMO EL USUARIO USERGPP012 PARA QUE SE VEA QUE PUEDE HACER CONSULTAS SOBRE LA VISTA PERMITIDA EN EL ROL*/

EXECUTE AS USER = 'USERGPP012';
GO 

PRINT USER
GO

SELECT * FROM trial.bbmlookexpediente;
GO 

REVERT

PRINT USER
GO



/*MISMO SCRIPT CON PROCEDIMIENTO ALAMACENADO*/

CREATE OR ALTER PROC trial.BBMProcedure
	--PARAMETROS
	@ID_Expediente varchar(10) NULL,
	@BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad varchar(50) NULL,
	@BBM_Usuario_Usuario_ID varchar(10)  NULL,
	@BBM_Sesion_Sesion_ID char(14)  NULL,
	@BBM_Tratamientos_BBM_Tratamientos_ID char(8)  NULL,
	@Especialista_ID varchar(5) NULL
AS
	BEGIN
		INSERT INTO trial.BBM_Expediente
			(ID_Expediente, BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad, BBM_Usuario_Usuario_ID, BBM_Sesion_Sesion_ID, BBM_Tratamientos_BBM_Tratamientos_ID, Especialista_ID)
		VALUES
			(@ID_Expediente, @BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad, @BBM_Usuario_Usuario_ID, 	@BBM_Sesion_Sesion_ID,	@BBM_Tratamientos_BBM_Tratamientos_ID, @Especialista_ID);
END;
GO


--El sistema compila info y la almacena. Siempre queda a la espera. Luego tú lo llamas a ejecución desde donde quieras

/***********DEMOSTRACIÓN****************/

DROP ROLE IF EXISTS BBMFisioGestion
GO

CREATE ROLE BBMFisioGestion
GO


GRANT EXECUTE ON SCHEMA::[trial] TO BBMFisioGestion; --> DOY LOS PERMISOS DE SCHEMA AL ROL
GO

CREATE USER FISIOESPECIALISTA WITHOUT LOGIN;
GO

ALTER ROLE BBMFisioGestion --> AÑADO EL MIEMBRO AL ROL
ADD MEMBER FISIOESPECIALISTA
GO

--> HACEMOS QUE EL FISIOESPECIALISTA INTENTE HACER UNA INSERCIÓN. NO DE MANERA MANUAL, PUES NO TIENE PERMISOS, SINO A TRAVÉS DEL PROCEDIMIENTO ALMACENADO QUE ACABAMOS DE CREAR


EXECUTE AS USER = 'FISIOESPECIALISTA'
GO

PRINT USER
GO


EXEC trial.BBMProcedure
	--PARAMETROS
	@ID_Expediente = 'TESTEO001',
	@BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad = 'APRAXIA IDEOMOTORA',
	@BBM_Usuario_Usuario_ID = 'USERGPP012',
	@BBM_Sesion_Sesion_ID = 'DO24012021',
	@BBM_Tratamientos_BBM_Tratamientos_ID = 'FISI    ',
	@Especialista_ID = 'FISIO';
GO

REVERT

PRINT USER
GO

SELECT * 
FROM trial.BBM_Expediente
GO