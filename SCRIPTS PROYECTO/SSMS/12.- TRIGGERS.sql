 
				/*LEVEL TRIGGERS*/
 
 
 /*********************TRIGGER SERVER************************/
 -- FOR E INSTEAD OF NO SE APLICAN SOBRE SERVERS
 USE master
 GO

 DROP TRIGGER IF EXISTS trg_BBM_FORBIDLOGINS --> trg es como sp (stored procedures), significa trigger y es una notación recomendada por Windows


 CREATE OR ALTER TRIGGER trg_BBM_FORBIDLOGINS
 ON ALL SERVER --SERVER LEVEL
 FOR CREATE_LOGIN -- Sentencia a controlar (puede hacer más de una) --> La más típica es la palabra reservada CREATE_LOGIN
 AS --> CUERPO DEL TRIGGER
	PRINT 'Usted no puede crear un LOGIN. Contacte con su manager para tal fin'
	ROLLBACK TRAN --> Provoca que la sentencia no se provoque. Es el antónimo de EXECUTE
GO

/*AQUI LO QUE HACEMOS ES QUE SOBRE LA PALABRA RESERVADA CREATE_LOGIN, LO PROHIBE Y TE ENSEÑA EL BANNER*/


--Intentamos crear un login y nos va a dar error
CREATE LOGIN USERFORBIDTEST WITH PASSWORD ='Abcd1234.'
GO
--No login creations without DBS involvement --> BANNER
--Msg 3609, Level 16, State 2, Line 55
--The transaction ended in the trigger. The batch has been aborted. --> ROLLBACK


/*A EFECTOS DE OBJECT EXPLORER ME LO CREA EN LA CARPETA SERVER OBJECTS>TRIGGERS. AHÍ PODRÍA SACARLO CON CREATE O NEW QUERY EDITOR*/

--Vemos que no nos deja
-- En vez de print podríamos hacer lo mismo con un RAISERROR

DISABLE trigger ALL ON ALL SERVER;
GO

ENABLE Trigger ALL ON ALL SERVER;
GO

-- El trigger está activado. Si queremos borrarlo: DROP
DROP TRIGGER trg_BBM_FORBIDLOGINS
GO 





------------------------------------------PERMISOS A NIVEL BASE DE DATOS-------------------------------------------------------
--En el entorno gráfico este tipo de trigger aparece dentro de 'programmability'

USE BBM_ASPACE
GO

--Uso una de las tablas del schema trial

SELECT * FROM trial.BBM_Comidas

--Creamos el trigger (el FOR AFTER, no es necesario, llega con poner FOR)
IF OBJECT_ID('trg_BBM_NODROP', 'TR') IS NOT NULL
	DROP TRIGGER trg_BBM_NODROP
GO

DROP TRIGGER IF EXISTS trg_BBM_NODROP
GO


CREATE OR ALTER TRIGGER trg_BBM_NODROP
ON DATABASE
FOR DROP_TABLE, ALTER_TABLE

AS
	RAISERROR ('No se puede borrar o modificar tablas por Usuarios o Empleados Consulte al departamento de IT',10,1)
	ROLLBACK TRANSACTION
GO

--Probamos a borrar la tabla BBM_Comidas

DROP TABLE trial.BBM_Comidas;
GO


-- Vemos que no nos deja y nos devuelve el siguiente mensaje
/*No se puede borrar o modificar tablas por Usuarios o Empleados Consulte al departamento de IT
Msg 3609, Level 16, State 2, Line 81
The transaction ended in the trigger. The batch has been aborted.*/


/*EN EL OBJECT EXPLORER ESTÁ EN BASE DE DATOS>PROGRAMMABILITY>DATABSE TRIGGERS*/

DISABLE TRIGGER trg_BBM_NODROP
ON DATABASE;
GO

DROP TABLE trial.BBM_Comidas;
GO



--Ahora lo habilito e intento borrar una CONTRAINT de la tabla trial.BBM_Expediente


ENABLE TRIGGER trg_BBM_NODROP ON DATABASE;
GO

ALTER TABLE [trial].[BBM_Expediente] DROP CONSTRAINT [BBM_Sesion_Sesion_ID_FK]
GO
 /*No se puede borrar o modificar tablas por Usuarios o Empleados Consulte al departamento de IT
Msg 3609, Level 16, State 2, Line 108
The transaction ended in the trigger. The batch has been aborted.*/

--Para Borrar
DROP TRIGGER trg_BBM_NODROP
GO

-- Si no funciona borrar, lo hacemos en el GUI






/*****************A NIVEL DE TABLA/VISTA******************/

-- NO SE CONTROLAN TRIGGERS DE VARIAS TABLAS EN UNA MISMA INSTRUCCIÓN

--Después de una inserción o un update en la tabla trial.BBM_Comidas

use BBM_ASPACE
Go

	
DROP TABLE IF EXISTS trial.BBM_Comidas
GO


SELECT *
		into trial.BBM_Comidas
		from dbo.BBM_Comidas
GO

SELECT * FROM trial.BBM_Comidas


--Controlo el trigger


DROP TRIGGER IF EXISTS trg_BBM_UPDATES
GO


-- Creamos un trigger que nos ejecute un raiserror y un procedimiento almacenado
-- Después de una inserción o un update en la tabla trial.BBM_Comidas
CREATE OR ALTER TRIGGER trg_BBM_UPDATES
ON trial.BBM_Comidas
AFTER INSERT, UPDATE --SI ponermos FOR es un 'After' --> hacen la misma función
AS
	RAISERROR (50009,16,10)
	EXEC sp_helpdb BBM_ASPACE
GO
/*EL TRIGER CONTROLA OPERACIONES DE ACTUALIZACIÓN, LO QUE HACE ES EJECUTAR UNA OPERACIÓN DE ACTUALIZCIÓN, TE DA EL RAISERROR Y A MAYORES EXJECUTA*/	


--Comprobamos

Select * from trial.BBM_Comidas;
GO


--Lo probamos
UPDATE trial.BBM_Comidas
	SET ID_Menu = 'Desayuno'
	Where Plato_1= 'Manzana';
GO
--Msg 18054, Level 16, State 1, Procedure trg_BBM_UPDATES, Line 5 [Batch Start Line 211]
--Error 50009, severity 16, state 10 was raised, but no message with that error number was found in sys.messages. If error is larger than 50000, make sure the user-defined message is added using sp_addmessage.
 

 Select * from trial.BBM_Comidas;
GO

DISABLE TRIGGER trg_BBM_UPDATES ON trial.BBM_Comidas
GO

ENABLE TRIGGER trg_BBM_UPDATES ON trial.BBM_Comidas
GO


DROP TRIGGER trg_BBM_UPDATES
GO






/*PRUEBA DE TRIGGER CON BORRADO DE TABLA*/

CREATE OR ALTER TRIGGER trg_BBM_DROPTABLE
On trial.BBM_Medicacion
FOR DELETE, UPDATE
AS
	RAISERROR ('%d row modified in trial.BBM_Medicacion', 16,1,@@rowcount) --> es una especie de formato %d
GO


--INSERTO VALORES EN GUI

SELECT*
FROM trial.BBM_Medicacion
Where Codigo_EAN = '0'
GO

--Try out
DELETE trial.BBM_Medicacion
Where Codigo_EAN= '0';
GO

--Msg 50000, Level 16, State 1, Procedure trg?borra, Line 5 `Batch Start Line 246+
--1 filas modificadas en la tabla Autores

SELECT*
FROM trial.BBM_Medicacion
Where Codigo_EAN = '0'
GO

--cerramos el circulo deshabilitando habilitando y borrando

DISABLE TRIGGER trg_BBM_DROPTABLE ON trial.BBM_Medicacion
GO

ENABLE TRIGGER trg_BBM_DROPTABLE ON trial.BBM_Medicacion
GO

DROP TRIGGER trg_BBM_DROPTABLE
GO


--------------------------------------------------------------------------------------------
--TRIGER SOBRE LA VISTA DE TIPO INSTEAD OF
--------------------------------------------------------------------------------------------
USE BBM_ASPACE
Go


-- Creamos la vista
CREATE OR ALTER VIEW trial.BBM_testrgview
AS
    SELECT *
    FROM trial.BBM_Usuario
GO

-- Creamos un trigger para la vista (de tipo INSTEAD OF)


CREATE OR ALTER TRIGGER trg_BBM_DROPtestrgview
ON trial.BBM_testrgview
    INSTEAD OF DELETE
AS
    PRINT 'Esto es un test de prueba sobre borrados de vista'
GO

SELECT * FROM trial.BBM_testrgview
GO

DELETE FROM trial.BBM_testrgview;
GO

select * from trial.BBM_testrgview;
GO

DROP TRIGGER trg_BorrarVista
GO

Select * from trg_BBM_DROPtestrgview



--------------------------------------------------------------------------------------------
--TRIGER SOBRE LA TABLA DE TIPO AFTER
--------------------------------------------------------------------------------------------
--Controlo el trigger
IF OBJECT_ID ('Trg_DarAutor', 'TR') IS NOT NULL
	DROP TRIGGER trg_BBM_AFTERINSERTUPDATE;
GO

DROP TRIGGER IF EXISTS trg_BBM_AFTERINSERTUPDAT
GO


-- Creamos un trigger que nos ejecute un raiserror y un procedimiento almacenado
-- Después de una inserción o un update en la tabla autores
CREATE OR ALTER TRIGGER trg_BBM_AFTERINSERTUPDAT
ON trial.BBM_Expediente
AFTER INSERT, UPDATE --SI ponermos FOR es un 'After' --> hacen la misma función
AS
	RAISERROR (50009,16,10)
	EXEC sp_helpdb BBM_ASPACE
GO
/*EL TRIGER CONTROLA OPERACIONES DE ACTUALIZACIÓN, LO QUE HACE ES EJECUTAR UNA OPERACIÓN DE ACTUALIZCIÓN, TE DA EL RAISERROR Y A MAYORES EXJECUTA*/	


--Comprobamos

Select * from trial.BBM_Expediente;
GO


--Lo probamos
UPDATE trial.BBM_Expediente
	SET ID_Expediente = 'INSRTT3ST'
	Where BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad = 'TESTEO';
GO
/*Msg 18054, Level 16, State 1, Procedure trg_BBM_AFTERINSERTUPDAT, Line 5 [Batch Start Line 311]
Error 50009, severity 16, state 10 was raised, but no message with that error number was found in sys.messages. 
If error is larger than 50000, make sure the user-defined message is added using sp_addmessage.
 (0 rows affected)
*/

 Select * from trial.BBM_Expediente;
GO

DISABLE TRIGGER trg_BBM_AFTERINSERTUPDAT ON trial.BBM_Expediente
GO

ENABLE TRIGGER trg_BBM_AFTERINSERTUPDAT ON trial.BBM_Expediente
GO


DROP TRIGGER trg_BBM_AFTERINSERTUPDAT
GO


--------------------------------------------------------------------------------------------
--TRIGER SOBRE LA TABLA DE TIPO FOR INTENTANDO DELETE Y UPDATE
--------------------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_BBM_DELETEUPDATE
On trial.BBM_Tratamientos
FOR DELETE, UPDATE
AS
	RAISERROR ('%d filas modificadas en la tabla Autores', 16,1,@@rowcount) --> es una especie de formato %d
GO

SELECT*
FROM trial.BBM_Tratamientos
Where Tratamiento_ID = '141'
GO

--Try out
DELETE trial.BBM_Tratamientos
Where Tratamiento_ID= '141';
GO

/*Msg 50000, Level 16, State 1, Procedure trg_BBM_DELETEUPDATE, Line 5 [Batch Start Line 353]
1 filas modificadas en la tabla Autores

(1 row affected)*/


SELECT*
FROM trial.BBM_Tratamientos
Where Tratamiento_ID = '141'
GO

--cerramos el circulo deshabilitando habilitando y borrando

DISABLE TRIGGER trg_BBM_DELETEUPDATE ON trial.BBM_Tratamientos
GO

ENABLE TRIGGER trg_BBM_DELETEUPDATE  ON trial.BBM_Tratamientos
GO

DROP TRIGGER trg_BBM_DELETEUPDATE
GO





--------------------------------------------------------------------------------------------
--TRIGER SOBRE LA TABLA DE TIPO FOR INTENTANDO DELETE Y UPDATE
--------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_BBM_AFTERUPDATE
GO

CREATE OR ALTER TRIGGER trg_BBM_AFTERUPDATE
ON trial.BBM_Sesion
AFTER UPDATE
AS
    PRINT 'Tabla inserted'
    select * from inserted
    PRINT 'Tabla inserted'
    select * from deleted
Go

select * from trial.BBM_Sesion
GO

UPDATE trial.BBM_Sesion
SET BBM_Horario_ID_Horario = '10001200'
WHERE Sesion_ID = 'DO24012021';
GO



SELECT * FROM trial.BBM_Sesion
GO


UPDATE trial.BBM_Sesion
SET BBM_Horario_ID_Horario = '10001200'
WHERE Sesion_ID = 'DO24012021';
GO


--------------------------------------------------------------------------------------------
--TRIGER SOBRE LA TABLA DE TIPO FOR INTENTANDO INSTEAD OF
--------------------------------------------------------------------------------------------

USE BBM_ASPACE
GO

-- Creamos la vista
CREATE OR ALTER VIEW vista_TESTTRIGGER
AS
    SELECT *
    FROM trial.BBM_Tratamientos
GO

-- Creamos un trigger para la vista (de tipo INSTEAD OF)


CREATE OR ALTER TRIGGER vista_INSTEADOFDROP
ON vista_TESTTRIGGER
    INSTEAD OF DELETE
AS
    PRINT 'La vista no puede ser borrada. Consulte con el departamento correspondiente'
GO

SELECT * FROM vista_TESTTRIGGER
GO

DELETE FROM vista_TESTTRIGGER;
GO

select * from vista_TESTTRIGGER;
GO

DROP TRIGGER vista_INSTEADOFDROP
GO



------------------------------------------------
-- TRIGGER PARA CLASE EN SECUENCIA
------------------------------------------------

USE BBM_ASPACE
GO

DROP TABLE IF EXISTS trial.BBM_Equipamiento
GO

CREATE TABLE trial.BBM_Equipamiento (
	ID_Equipamiento int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Nombre_Equipo nvarchar(1000) NOT NULL,
	CreateDate datetime DEFAULT CURRENT_TIMESTAMP,
	ModifiedDate datetime DEFAULT CURRENT_TIMESTAMP
);
GO

CREATE OR ALTER TRIGGER trg_BBM_Secuence
ON trial.BBM_Equipamiento
AFTER UPDATE
AS
	UPDATE trial.BBM_Equipamiento
	SET ModifiedDate = CURRENT_TIMESTAMP
	WHERE ID_Equipamiento IN (SELECT DISTINCT ID_Equipamiento FROM inserted);
GO

INSERT INTO trial.BBM_Equipamiento(Nombre_Equipo) 
VALUES ('Electro');
GO

SELECT * FROM trial.BBM_Equipamiento;
GO

/*ID_Equipamiento	Nombre_Equipo	CreateDate	ModifiedDate
1	Electro	2021-03-12 22:11:21.113	2021-03-12 22:11:21.113*/

UPDATE trial.BBM_Equipamiento 
SET Nombre_Equipo = 'Electro'
WHERE ID_Equipamiento = 1;
GO

SELECT * FROM trial.BBM_Equipamiento;
GO

/*ID_Equipamiento	Nombre_Equipo	CreateDate	ModifiedDate
1	Electro	2021-03-12 22:11:21.113	2021-03-12 22:12:46.747*/

DROP TRIGGER trg_BBM_Secuence
GO


---------------------------------------
--TRIGGER CON ESTRUCTURA CONDICIONAL SOBRE UN CAMPO
---------------------------------------
USE BBM_ASPACE
GO


SELECT * FROM trial.BBM_Enfermedad_Diagnosticada

--Usamos condicional para borrar el trigger
IF OBJECT_ID ('trg_BBM_CONDITIONTRIGGER', 'TR') IS NOT NULL
   DROP TRIGGER trg_BBM_CONDITIONTRIGGER;
GO



CREATE OR ALTER TRIGGER trg_BBM_CONDITIONTRIGGER
ON trial.BBM_Enfermedad_Diagnosticada
FOR UPDATE
AS
	IF UPDATE (Nombre_Comun_Enfermedad)
			BEGIN 
					RAISERROR('No puedes cambiar la tabla', 15,1)
					ROLLBACK TRAN
			END
	ELSE
			PRINT 'Operación Fallida'
GO


SELECT * FROM trial.BBM_Enfermedad_Diagnosticada
GO

-- No cambia Nombre_Comun_Enfermedad
UPDATE trial.BBM_Enfermedad_Diagnosticada
SET Descripcion= 0
WHERE Nombre_Comun_Enfermedad='Oakland' ;
GO

UPDATE trial.BBM_Enfermedad_Diagnosticada
SET au_lname = 'BLANCO'
WHERE au_fname='Johnson' ;
GO

SELECT * 
FROM trial.BBM_Enfermedad_Diagnosticada
WHERE Nombre_Comun_Enfermedad='APRAXIA'
GO


-- Cambia Nombre_Comun_Enfermedad

update trial.BBM_Enfermedad_Diagnosticada
set Nombre_Comun_Enfermedad='TEST' 
where Nombre_Enfermedad='APRAXIA IDEOMOTORA'
GO	

SELECT * FROM trial.BBM_Enfermedad_Diagnosticada
go
------

-----------------------------------------------------------------------------------------------
				--TRIGGER QUE NOS IMPIDE ACTUALIZAR UN CAMPO DETERMINADO UPDATE
-----------------------------------------------------------------------------------------------

USE BBM_ASPACE
GO


SELECT * FROM trial.BBM_Usuario
GO

create OR ALTER trigger trg_BBM_IFNODELFIELD
on trial.BBM_Usuario
after update --after y for se pueden emplear indistintamente
as
	if UPDATE(Otros_Detalles)
		BEGIN
			PRINT 'Este tipo de actualizaciones requieren la supervisión de un Empleado Especialista';
			ROLLBACK TRAN;
		END
GO
	
--Intentamos actualizar Los Detalles sobre un usuario
UPDATE trial.BBM_Usuario
SET Otros_Detalles='Miedo a la Oscuridad'
WHERE Usuario_ID='USERVNA013';


/*Este tipo de actualizaciones requieren la supervisión de un Empleado Especialista
Msg 3609, Level 16, State 1, Line 20
The transaction ended in the trigger. The batch has been aborted.*/




--Vemos que no ha actualizado nada
select * from trial.BBM_Usuario WHERE Usuario_ID='USERVNA013';



DISABLE TRIGGER trg_BBM_IFNODELFIELD ON trial.BBM_Usuario

DROP TRIGGER trg_BBM_IFNODELFIELD

-------------------------------------------------------------------------------------
--CREAR UN TRIGGER QUE NO PERMITA BORRAR MÁS DE UN REGISTRO CON UNA SENTENCIA DELETE
-------------------------------------------------------------------------------------


	/*********FORMATO CONDICIONAL CON FOR CON ROWCOUNT********************/
--PROHIBIDO BORRAR MÁS DE UN REGISTRO
USE BBM_ASPACE
GO

SELECT * FROM trial.BBM_Usuario ORDER BY Apellido_1
GO


-- 1 Solucion


DROP TRIGGER IF EXISTS trg_BBM_ROWDELETE1REG
GO
CREATE OR ALTER TRIGGER trg_BBM_ROWDELETE1REG
ON trial.BBM_Usuario
FOR DELETE
AS
	IF (@@ROWCOUNT>1) -- Si es más de uno en el recuento 
		BEGIN
			RAISERROR('Los registros SOLO se BORRAN de 1 EN 1',15,1)
			ROLLBACK TRAN
		END
	ELSE -- De lo contrario
		PRINT 'Operación Realizada'
GO

DELETE trial.BBM_Usuario
GO

/*Msg 50000, Level 15, State 1, Procedure trg_BBM_ROWDELETE1REG, Line 7 [Batch Start Line 28]
Los registros SOLO se BORRAN de 1 EN 1
Msg 3609, Level 16, State 1, Line 29
The transaction ended in the trigger. The batch has been aborted.*/

DELETE trial.BBM_Usuario
WHERE Apellido_1='VILLAR'
GO
--Operación Realizada

--(1 row affected)
------------------------
SELECT * FROM trial.BBM_Usuario ORDER BY Apellido_1
GO
------------------------

	/**********************FORMATO CONDICIONAL CON FOR SIN ROWCOUNT*******************/
	
/*NO PONER EN TRABAJO, SÍ EN SCRIPT
-- 2 Solucion
IF OBJECT_ID ('trg_BBM_ROWFAILDELETE1REG', 'TR') IS NOT NULL
   DROP TRIGGER trg_delete_individual;
GO

CREATE OR ALTER TRIGGER trg_BBM_ROWFAILDELETE1REG
ON trial.BBM_Usuario
FOR DELETE
AS
	IF (SELECT COUNT(*) FROM deleted) > 1
			BEGIN 
				RAISERROR('Borra TAN sólo UN REGISTRO',16,3);
				ROLLBACK
				RETURN
			END
	ELSE
			PRINT 'Registro Borrado'
GO

delete trial.BBM_Usuario
where Apellido_1 >'VILLAR';
go	
--Devuelve:
------------Msg 50000, Level 16, State 3, Procedure trg_delete_individual, Line 7
------------Borra sólo un empleado
------------Msg 3609, Level 16, State 1, Line 1
------------The transaction ended in the trigger. The batch has been aborted.

-- Borra 'VILLAR' , Trigger no lo impide
delete trial.BBM_Usuario 
where Apellido_1 ='VILLAR';
go

--Registro Borrado
--(1 row(s) affected)
-- 
SELECT * FROM  trial.BBM_Usuario
where Apellido_1 ='VILLAR';
go


--drop table trial.BBM_Usuario;
--drop trigger trg_BBM_ROWFAILDELETE1REG;
*/

-------------------------
/**********************FORMATO CONDICIONAL INSTEAD OF ROWCOUNT - TRANCOUNT******************************/
-- 3 Solución 

-- TRIGGER INSTEAD OF DELETE 

-- USO DE FUNCIONES @@ROWCOUNT -  @@TRANCOUNT

-- @@ROWCOUNT

--Returns the number of rows affected by the last statement. 
--If the number of rows is more than 2 billion, use ROWCOUNT_BIG.

-- @@TRANCOUNT

-- @@TRANCOUNT returns the count of open transactions in the current session. 
-- It increments the count value whenever we open a transaction and decrements 
-- the count whenever we commit the transaction.
-- Rollback sets the trancount to zero and transaction with save point does to affect the trancount value.


USE BBM_ASPACE




SELECT * from trial.BBM_Especialista
go

INSERT INTO trial.BBM_Especialista
	VALUES ('TEST1'),('TEST2'),('TEST3')
GO
--(3 rows affected)
SELECT * from trial.BBM_Especialista
go


CREATE  OR ALTER TRIGGER trg_BBMROWTRANNODELETE
ON trial.BBM_Especialista
INSTEAD OF DELETE 
 AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    BEGIN
        RAISERROR
            ('ESTA TABLA SOLO PUEDE SER ALTERADA POR DBA', -- Message
            10, -- Severity.
            1); -- State.

        -- Rollback any active or uncommittable transactions
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END;
END;
GO


-- PRUEBA

DELETE trial.BBM_Especialista
GO


/*ESTA TABLA SOLO PUEDE SER ALTERADA POR DBA
Msg 3609, Level 16, State 1, Line 47
The transaction ended in the trigger. The batch has been aborted.
*/


DELETE trial.BBM_Especialista
	WHERE Especialista_ID = 'TEST1'-- EXISTE
GO

/*ESTA TABLA SOLO PUEDE SER ALTERADA POR DBA
Msg 3609, Level 16, State 1, Line 57
The transaction ended in the trigger. The batch has been aborted.
*/

DELETE trial.BBM_Especialista
	WHERE Especialista_ID = 'TEST700' -- NO EXISTE
GO

--(0 rows affected)


------------------------------------------------------------------------

-- USO DE LA FUNCIÓN DE CADENA REPLACE RIGHT

----------------------------------------------------------------------------
--Replaces all ocurrences of a specified string value with another string value.


--SYNTAX


USE BBM_ASPACE
GO

SELECT * FROM trial.BBM_Usuario
GO


-- AHORA CONTROLO LA EXISTENCIA DEL TRIGGER

IF OBJECT_ID('trg_BBM_REPLACERIGHT','TR') is not NULL
	DROP TABLE trg_BBM_REPLACERIGHT
GO

CREATE OR ALTER TRIGGER trg_BBM_REPLACERIGHT
ON trial.BBM_Usuario -- Nombre de la tabla o vista
INSTEAD OF INSERT -- Recordar que si le pongo after no evita la operacion a no ser que se le ponga un Rollback
AS
BEGIN --PRINCIPIO DEL CODIGO
	IF EXISTS -- SI EXISTE
		(
		SELECT Nombre_1 -- SIEMPRE VIENE DETRÁS DE UNA SELECT
		FROM Inserted
		WHERE RIGHT (Nombre_1,3) = 'EST' -- SI TOMO LOS TRES PRIMEROS VALORES POR LA DERECHA
		) -- SI DEVUELVE FILAS, SE EJECUTA EL INSERT
		INSERT INTO trial.BBM_Usuario
			(Nombre_1, Nombre_2, Apellido_1, Apellido_2, DNI, Otros_Detalles, Usuario_ID)
			SELECT REPLACE(Nombre_1, 'EST', 'NOMBRETEST'), Nombre_2, Apellido_1, Apellido_2, DNI, Otros_Detalles, Usuario_ID--> ANTES DE INSERTAR, REEMPLAZAME AVE POR AVENUE
			FROM Inserted;
	ELSE -- EN CASO DE QUE NO DEVUELVA FILAS, DEVUELVE ESA PARTE --> UN INSERT SELECT
		INSERT INTO trial.BBM_Usuario
			(Nombre_1, Nombre_2, Apellido_1, Apellido_2, DNI, Otros_Detalles, Usuario_ID)
			SELECT Nombre_1, Nombre_2, Apellido_1, Apellido_2, DNI, Otros_Detalles, Usuario_ID --> ¿DE DONDE SACO EL CONTENIDO?
			FROM inserted; --> DE LA TABLA INSERTED
END -- FIN DEL CODIGO
GO


/*AHORA VAMOS A INSERTAR UN CONTENIDO QUE PROVOQUE EL REEMPLAZO Y OTRO QUE NO*/


--COMO SE CUMPLE LA CONDICION IF, ME INSERTA EL NOMBRETEST

INSERT INTO trial.BBM_Usuario (Nombre_1, Nombre_2, Apellido_1, Apellido_2, DNI, Otros_Detalles, Usuario_ID)
							VALUES ('EST','NOMBRE2','APELLIDO1','APELLIDO2','123456789','LOREM','USERTEST') -- Como se cumple la condición, va a hacer el la primera parte del IF exists
GO
--(1 row affected)




SELECT * 
	FROM trial.BBM_Usuario
	WHERE Nombre_1 = 'NOMBRETEST';
GO

/*Usuario_ID	Nombre_1	Nombre_2	Apellido_1	Apellido_2	DNI	Otros_Detalles
USERTEST	NOMBRETEST	NOMBRE2	APELLIDO1	APELLIDO2	123456789	LOREM*/



INSERT INTO trial.BBM_Usuario (Nombre_1, Nombre_2, Apellido_1, Apellido_2, DNI, Otros_Detalles, Usuario_ID)
							VALUES ('RICHI','NOMBRE2','APELLIDO1','APELLIDO2','123456789','LOREM','NO CUMPLE'); -- Como no se cumple la condición, lo que coge es rez de Juan Florez, entonces hace el Else
GO


--(1 row affected)

--(1 row affected)




SELECT *
	FROM trial.BBM_Usuario
	WHERE Usuario_ID = 'NO CUMPLE';
GO

--> Se cumple que lo hace con la tabla Inserted porque no reconoce AVE

/*Usuario_ID	Nombre_1	Nombre_2	Apellido_1	Apellido_2	DNI	Otros_Detalles
NO CUMPLE	RICHI	NOMBRE2	APELLIDO1	APELLIDO2	123456789	LOREM*/


