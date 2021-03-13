--ACTIVAMOS LA BASE DE DATOS
1> use trialbbm
2> go

--VEMOS LAS COLUMNAS QUE TIENE DENTRO
1> select name from sysobjects where type='U'
2> go


-- CREAMOS UNA BASE DE DATOS
1> DROP DATABASE IF EXISTS BBM_SQLCMDUBUNTU
2> GO
1> CREATE DATABASE BBM_SQLCMDUBUNTU
2> GO
1> USE BBM_SQLCMDUBUNTU
2> GO
Changed database context to 'BBM_SQLCMDUBUNTU'.


--CREAMOS UNA TABLA
1> DROP TABLE IF EXISTS BBM
2> GO
1> CREATE TABLE BBM (ID INT,NAME VARCHAR(20))
2> GO
1> 


-- VEMOS LA TABLA CREADA EN LA BASE
1> Select name from sysobjects where type='U'
2> GO
name                                                                                                                            
--------------------------------------------------------------------------------------------------------------------------------
BBM 

-- VEMOS EL CONTENIDO DE LA TABLA
1> SELECT * FROM BBM
2> GO
ID          NAME                
----------- --------------------

(0 rows affected)
1> 


-- BORRAMOS LA BASE DE DATOS
1> USE master
2> GO
Changed database context to 'master'.
1> DROP DATABASE IF EXISTS BBM_SQLCMDUBUNTU
2> GO
