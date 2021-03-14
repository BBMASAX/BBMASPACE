# PROYECTO ASAX ![Logo Wirtz](https://user-images.githubusercontent.com/73242009/111064260-4a919780-84b3-11eb-9353-cef7b924da0c.png)
###### Manuel Beade Boán (BBM)
---


## SINOPSIS

Proyecto correspondiente a la asigantura **ASAX** del instituto **I.E.S. Fernando Wirtz** del Ciclo Superior de **Administración de Sistemas Informáticos en Red** (*ASIR*)


## HERRAMIENTAS PARA EL PROYECTO ![Herramientas de trabajo](https://user-images.githubusercontent.com/73242009/111064547-e96ac380-84b4-11eb-9662-d269f984244d.png)
###### Máquinas Virtuales
* Servidor máster del dominio: Windows Server 16
* Cliente SQL Server: Windows 10
* Cliente Linux
###### Programas
* SQL Server
* SQL Server Management Studio
* Dia
* SQL Developer
* SQL  Developer Data Modeler
* SQL*Plus
* Sqlcmd
* Notepad ++
* Azure Data Studio
* Git Bash
* GIT Tortoise
* VMWare 15.0

## ARCHIVOS QUE COMPONEN EL PROYECTO ![Files](https://user-images.githubusercontent.com/73242009/111064750-1bc8f080-84b6-11eb-83d1-e06d0a76d26e.png)
* Base de datos
    * Archivos que componen la base de datos (.mdf, .ndf, .ldf)
    * Archivo de Backup de la base principal .BAK
* Fotos de personas que no existen para incluir en el apartado **Filestream** y **Filetable**
* Proyecto de Modelado en *SQL Developer Data Modeler*
* Scripts
    * Archivo Sqlcmd
	* Archivo Desbloquear Usuario HR en SQL*Plus
	* Demostración de pasar tablas del Usuario HR a SQL Server
	* Proyecto en Archivo .ddl
	* Script GIT
	* Scripts de SQL Server
	* Sqlcmd en Ubuntu
* Gitignore
* Readme
* Indice del Proyecto


## DESARROLLO DEL PROYECTO    ![Paste](https://user-images.githubusercontent.com/73242009/111062006-9db11d80-84a6-11eb-9ce5-163e69f1d68a.png)

Consta de **tres** partes:

#### PREPARACIÓN PARA EL TRABAJO    ![Users](https://user-images.githubusercontent.com/73242009/111062555-ddc5cf80-84a9-11eb-8eeb-5e64075dfb05.png)
~~~
WINDOWS
	Creación de Maquinas Virtuales e instalación de Sistemas Operativos 
		Creación de Máquina Virtual con Windows 10 [cliente]
			Instalación de SQL Server 2017 en Windows 10 [cliente]
		Creación de Máquina Virtual con Windows Server 2016 [controlador de dominio]
			Creación de Máquina Virtual con Windows Server 2016
			Instalación de SQL Server 2017 en Windows Server 2016
	Configurar Firewall de Windows para permitir el acceso a SQL Server 
		Configuración del Firewall en Windows 10
			Creación de regla Inbound para permitir el puerto 1433
			Creación de regla Inbound/Outbound para permitir el puerto 1434
			Creación de regla Inbound/Outbound para permitir la red
		Configuración del Firewall en Windows Server 2016
			Creación de regla Inbound/Outbound para permitir el puerto 1433 y 1434
			Creación de regla Inbound/Outbound para permitir la red
	Instalación de SSMS (GUI)
	Configuración de la red en VMWare
		Configuración del adaptador de red en Windows Server 2016			
		Configuración del adaptador de red en Windows 10
		Configuración del Dominio 
			Agregar la característica “Servicios de Dominio de Active Directory”
			Unir la máquina con Windows 10 al Dominio 
			Acceder desde SQL Server a otras instancias de otros equipos del dominio
	Explicar Instalación Desatendida
LINUX
	Creación de MV e instalación de Ubuntu 18.04
		Configuración del firewall de Ubuntu
		Configuración de la red de Ubuntu
		Unir Ubuntu al dominio
	Instalar SQL Server 2017 / 2019
	Instalar GUI: Azure Data Studio
	Instalación y uso de Sqlcmd
~~~~
### MODELADO BASE DE DATOS    ![Database](https://user-images.githubusercontent.com/73242009/111062509-917a8f80-84a9-11eb-8c91-790cfe026099.png)
~~~~
	Modelado con SQL Data Modeler 
		Instalación de Oracle
		SQL Developer - Oracle Express
		Conexiones
			Desde CMD
			Desde GUI
		Desbloquear Usuario HR
		Bases de Datos Ejemplo
		Modelado Lógico - Relacional - Fisico Proyecto
			Subvistas
			Modelo Lógico
			Modelo Relacional
			Generar archivo DDL
		SQL Data Modeler a SQL Server
			Convertir el modelo Lógico-Relacional a SQL Server
	INSTALAR BASES DE DATOS DE EJEMPLO en SSMS 
		Pubs desde script 
		Northwind con ATTACH
		Adventureworks2017 desde BACKUP
		WideWorldImporters con BACPAC
	PRUEBAS PREVIAS
	FILEGROUP 
	FILESTREAM / FILETABLE
	BASES DE DATOS CONTENIDAS 
	PARTICIONES (SPLIT, MERGE, SWITCH, TRUNCATE) 
	TABLAS TEMPORALES (VERSION SISTEMA) 
	TRIGGERS
	TABLAS IN MEMORY
	BACKUP DE TODOS LOS CURSORES
	STORED PROCEDURE BACKUP
~~~~
### SISTEMA DE CONTROL DE VERSIONES    ![GIT](https://user-images.githubusercontent.com/73242009/111062657-79efd680-84aa-11eb-8742-84f85ebb90cc.png)
~~~~
	GIT como sistema de control de versiones distribuido
	Sentencias GIT
		Sentencias GIT REPOSITORY
		Sentencias INDEX / STAGING AREA
	Instalando GIT
		Instalación del "cmd" de GIT
		Entornos gráficos
	Primeros pasos con GIT
		Crear un repositorio en GitHub
		Uso del Command Prompt de GIT
			Inicio con GIT Bash
			Creación del archivo README.md
			Ignorar archivos con .gitignore
			Reset vs Revert
				GIT RESET
				GIT REVERT
			Git Branch
	Entorno Gráfico en Windows: GitTortoise
~~~~

## Enlaces

[Repositorio Github](https://github.com/BBMASAX/BBMASPACE.git)
[Crear personas irreales] (https://generated.photos/)