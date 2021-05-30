--HAY BBM_AUDIT DE SERVIDOR Y BBM_AUDIT DE BASES DE DATOS

-- ORDEN PARA REALIZAR BBM_AUDITS

-- SECURITY						(TANTO PARA SERVIDOR COMO PARA BD)
--			AUDIT
--				SERVER AUDIT SPECIFICATIONS


--PODRÍA HACER CLIC EN BOTÓN DERECHO> NUEVA BBM_AUDIT Y AHÍ PODRÍA GENERARLA. eN AUDIT FRDTINATION, IRIA AHÍ 

-- Creacion de las BBM_AUDITs (a nivel de servidor)

--	Application.log (La captura va al visor de sucesos Aplications)
--	Security.log	(La captura va a  al visor de sucesos Security)
--	File			(La captura va a un fichero)

--Creación de application log

use master
go
create server audit [srv_app_log_bbmaudit]
	to application_log
with
( queue_delay = 1000,
  on_failure = fail_operation --> sI DA UN ERRROR, INTERRUMPE LA BBM_AUDIT
)
go

-- VER RESULTADO EN GUI SECURITY -> AUDIT

-- Enable GUI or SCRIPT

-- Creación de security log
-- podemos tambien crearla desde el entorno grafico.
-- por ejemplo, en lugar de ejecutar el siguiente script, lo haremos desde el entorno grafico

use master
go
create server audit [srv_sec_log_bbmaudit]
	to security_log
with
( queue_delay = 1000,
  on_failure = continue --> SI FALLA, CONTINUA EJECUTANDO
)
go

-- Enable GUI

-- Creación de FILE
-- HINT : FOLDER  c:\BBM_AUDIT\




-- DONDE SE GUARDA EL OUTPUT



--INTERESA CREAR FILELOG_AUDITS
-- CREAMOS UN LOG EN UN ARCHIVO Y CONTROLO LO QUE AUDITO

use master
go
create server audit [srv_file_log_bbmaudit]
to file 
(   filepath = 'c:\BBM_AUDIT\'
	,maxsize = 0 mb
	,max_rollover_files = 2147483647
	,reserve_disk_space = off
)
with
( queue_delay = 1000,
  on_failure = continue
)
go

-- VER GUI
--		AUDITS
--			3 TIPOS

-- HABILITAR ENABLE ON

ALTER SERVER AUDIT srv_file_log_bbmaudit WITH (STATE = ON) 
GO

-- Or Enable from GUI

-- Creación de especificación de auditoría de SERVIDOR para: Filelog_Audits
-- GUI SERVER AUDIT SPECIFICATIONS

use master
go
create server audit specification [srv_instance_log_bbmaudit]
for server audit [srv_file_log_bbmaudit]
	add (server_state_change_group),
	add(backup_restore_group),
	add (dbcc_group)
with (state = on)
go
-- GUI -> server audit specification -> [InstanceAuditsFile] -> PROPERTIES -> AUDIT ACTION TYPE

-- Comprobamos que esten habilitadas las BBM_AUDITs y las Especificaciones
-- Provocamos uno de los eventos indicados en la especificación de auditoría del servidor.


-- Try It Out

-- Por ejemplo el del Backup de la base de datos: BBM_ASPACE (AUDIT ACTION TYPE)

use master
go
backup database BBM_ASPACE
	to disk = 'c:\BBM_AUDIT\BBM_ASPACE.bak'
	with init;
go

-- Check the current database (AUDIT ACTION TYPE)    
DBCC CHECKDB;    
GO    
-- Check the BBM_ASPACE database without nonclustered indexes (AUDIT ACTION TYPE)    
DBCC CHECKDB (BBM_ASPACE, NOINDEX);    
GO    

--Para ver los registros de una auditoría con salida a un archivo: DONDE MIRO LA BBM_AUDIT
SELECT *
	FROM sys.fn_get_audit_file ('C:\BBM_AUDIT\*',default,default);
GO

-- Por ejemplo el del Backup de mi base de datos: BBM_ASPACE
use master
go
backup database BBM_ASPACE
	to disk = 'c:\BBM_AUDIT\BBM_ASPACE.bak'
	with init;
go


--Para ver los registros de una auditoría con salida a un archivo:
SELECT *
	FROM sys.fn_get_audit_file ('C:\BBM_AUDIT\*',default,default);
GO

-- EN GUI VER Audit [Filelog_audits] ...............View Audit Logs


------------------------------------------------------------------------------
-- Creacion de especificacion a nivel de bases de datos

USE BBM_ASPACE
GO

SELECT * FROM trial.BBM_Equipamiento
GO


-- EN GUI

-- [BBM_ASPACE] -> SECURITY -> DATABASE AUDIT SPECIFICATIONS

-- Database Audit Spacifications

CREATE DATABASE AUDIT SPECIFICATION [BBM_ASPACE_EQUIPMENT_AUDIT]
FOR SERVER AUDIT [srv_file_log_bbmaudit]
ADD (SELECT ON OBJECT::[trial].[BBM_Equipamiento] BY [dbo]),
ADD (INSERT ON OBJECT::[trial].[BBM_Equipamiento] BY [dbo]),
ADD (UPDATE ON OBJECT::[trial].[BBM_Equipamiento] BY [dbo]),
ADD (DELETE ON OBJECT::[trial].[BBM_Equipamiento] BY [dbo])
GO

ALTER DATABASE AUDIT SPECIFICATION [BBM_ASPACE_EQUIPMENT_AUDIT]
WITH (STATE = ON) 
GO
--  GUI
-- [BBM_AUDIT Department de BBM_ASPACE]-> PROPERTIES

-- PROBANDO :
-- Realizamos una consulta

USE BBM_ASPACE
GO


SELECT * FROM trial.BBM_Equipamiento
GO


-- Realizamos un borrado

INSERT INTO [trial].[BBM_Equipamiento]
values ('TEST','2021-05-24 22:12:52.114','2021-05-25 22:12:52.114')
GO
--(1 row affected)

--Para ver los registros de una auditoría con salida a un archivo:

SELECT *
	FROM sys.fn_get_audit_file ('C:\BBM_AUDIT\*.sqlaudit',default,default);
GO

-- ver acciones desde GUI
-- SECURITY -> AUDITS -> FILELOG_AUDITS

ALTER DATABASE AUDIT SPECIFICATION [BBM_ASPACE_EQUIPMENT_AUDIT]
WITH (STATE = OFF) 
GO

DROP DATABASE AUDIT SPECIFICATION [BBM_ASPACE_EQUIPMENT_AUDIT]
GO

