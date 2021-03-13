/*CREAR TABLAS PARA TEST*/


DROP TABLE IF EXISTS trial.BBM_Expediente
GO

CREATE TABLE [trial].[BBM_Expediente](
	[ID_Expediente] [varchar](10) NOT NULL,
	[BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad] [varchar](50) NOT NULL,
	[BBM_Usuario_Usuario_ID] [varchar](10) NOT NULL,
	[BBM_Sesion_Sesion_ID] [char](14) NOT NULL,
	[BBM_Tratamientos_BBM_Tratamientos_ID] [char] (8) NOT NULL,
 CONSTRAINT [BBM_Expediente_PK] PRIMARY KEY CLUSTERED 
(
	[ID_Expediente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



DROP TABLE IF EXISTS trial.BBM_Sesion
GO

CREATE TABLE [trial].[BBM_Sesion](
	[Sesion_ID] [char](14) NOT NULL,
	[Fecha_y_Hora_de_inicio] [datetime] NULL,
	[Fecha_y_Hora_de_fin] [datetime] NULL,
	[BBM_Horario_ID_Horario] [char](8) NOT NULL,
	[BBM_Espacio_ID_Espacio] [char](10) NOT NULL,
	[BBM_Equipamiento_ID_Equipamiento] [char](10) NOT NULL,
	[BBM_Empleado_BBM_Empleado_ID] [int] NOT NULL,
	[BBM_Actividades_BBM_Actividades_ID] [int] NOT NULL,
 CONSTRAINT [BBM_Sesion_PK] PRIMARY KEY CLUSTERED 
(
	[Sesion_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



DROP TABLE IF EXISTS trial.BBM_Medicacion
GO


CREATE TABLE [trial].[BBM_Medicacion](
	[ID_Medicacion] [char](12) NOT NULL,
	[Nombre_Medicamento] [varchar](25) NOT NULL,
	[Codigo_EAN] [int] NOT NULL,
	[Fabricante] [varchar](50) NULL,
	[Posologia] [varchar](255) NULL,
	[Descripcion] [varchar](255) NULL,
	[Observaciones] [varchar](255) NULL,
 CONSTRAINT [BBM_Medicacion_PK] PRIMARY KEY CLUSTERED 
(
	[ID_Medicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS trial.BBM_Comidas
GO

CREATE TABLE [trial].[BBM_Comidas](
	[ID_Menu] [char](9) NOT NULL,
	[Plato_1] [varchar](255) NULL,
	[Plato_2] [varchar](255) NULL,
	[Plato_3] [varchar](255) NULL,
	[BBM_Otros_Departamentos_OD_ID] [char](5) NOT NULL,
 CONSTRAINT [BBM_Comidas_PK] PRIMARY KEY CLUSTERED 
(
	[ID_Menu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



DROP TABLE IF EXISTS trial.BBM_Enfermedad_Diagnosticada
GO

CREATE TABLE [trial].[BBM_Enfermedad_Diagnosticada](
	[Nombre_Enfermedad] [varchar](50) NOT NULL,
	[Nombre_Comun_Enfermedad] [varchar](50) NOT NULL,
	[Descripcion] [varchar](255) NULL,
	[Sintomas] [varchar](255) NULL,
 CONSTRAINT [BBM_Enfermedad_Diagnosticada_PK] PRIMARY KEY CLUSTERED 
(
	[Nombre_Enfermedad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS trial.BBM_Tratamientos
GO

CREATE TABLE [trial].[BBM_Tratamientos](
	[BBM_Tratamientos_ID] [char] (8) NOT NULL,
	[Tratamiento_ID] [char](4) NOT NULL,
	[BBM_Auxiliar_BBM_Empleado_BBM_Empleado_ID] [int] NULL,
	[BBM_Especialista_BBM_Empleado_BBM_Empleado_ID] [int] NULL,
 CONSTRAINT [BBM_Tratamientos_PK] PRIMARY KEY CLUSTERED 
(
	[BBM_Tratamientos_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




DROP TABLE IF EXISTS trial.BBM_Usuario
GO


CREATE TABLE [trial].[BBM_Usuario](
	[Usuario_ID] [varchar](10) NOT NULL,
	[Nombre_1] [varchar](20) NULL,
	[Nombre_2] [varchar](20) NULL,
	[Apellido_1] [varchar](20) NULL,
	[Apellido_2] [varchar](20) NULL,
	[DNI] [varchar](9) NOT NULL,
	[Otros_Detalles] [varchar](255) NULL,
 CONSTRAINT [BBM_Usuario_PK] PRIMARY KEY CLUSTERED 
(
	[Usuario_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS trial.BBM_Especialista
GO

CREATE TABLE trial.BBM_Especialista 
    (
     Especialista_ID VARCHAR (5) NOT NULL ,
    )
GO

ALTER TABLE trial.BBM_Especialista ADD CONSTRAINT Especialista_ID_PK PRIMARY KEY CLUSTERED (Especialista_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO


--- INSERTAMOS LOS VALORES EN LAS TABLAS (VER SCRIPT INSERT VALUES)



--TRATAMIENTOS
INSERT INTO [trial].[BBM_Tratamientos]
           ([BBM_Tratamientos_ID],[Tratamiento_ID],[BBM_Auxiliar_BBM_Empleado_BBM_Empleado_ID],[BBM_Especialista_BBM_Empleado_BBM_Empleado_ID])
     VALUES
           ('FISI','FISI','123','')
GO
INSERT INTO [trial].[BBM_Tratamientos]
           ([BBM_Tratamientos_ID],[Tratamiento_ID],[BBM_Auxiliar_BBM_Empleado_BBM_Empleado_ID],[BBM_Especialista_BBM_Empleado_BBM_Empleado_ID])
     VALUES
           ('TERO','141','','')
GO
INSERT INTO [trial].[BBM_Tratamientos]
           ([BBM_Tratamientos_ID],[Tratamiento_ID],[BBM_Auxiliar_BBM_Empleado_BBM_Empleado_ID],[BBM_Especialista_BBM_Empleado_BBM_Empleado_ID])
     VALUES
           ('PSIC','235','','')
GO

-------------------------------------------------------------------------------------------------------------------------
---USUARIO

INSERT INTO [trial].[BBM_Usuario]
           ([Usuario_ID],[Nombre_1],[Nombre_2],[Apellido_1],[Apellido_2],[DNI],[Otros_Detalles])
     VALUES
           ('USERGPP012','PACO','','GONZALEZ','PEREZ','11111012S','')
GO
INSERT INTO [trial].[BBM_Usuario]
           ([Usuario_ID],[Nombre_1],[Nombre_2],[Apellido_1],[Apellido_2],[DNI],[Otros_Detalles])
     VALUES
           ('USERVNA013','ANA','MARIA','VAZQUEZ','NUNEZ','11111013N','')
GO
INSERT INTO [trial].[BBM_Usuario]
           ([Usuario_ID],[Nombre_1],[Nombre_2],[Apellido_1],[Apellido_2],[DNI],[Otros_Detalles])
     VALUES
           ('USERVRI013','ISABEL','','VILLAR','RODRIGUEZ','11111013D','Violento')
GO

---------------------------------------------------------------------------
--ENFERMEDAD DIAGNOSTICADA
INSERT INTO [trial].[BBM_Enfermedad_Diagnosticada]
           ([Nombre_Enfermedad],[Nombre_Comun_Enfermedad],[Descripcion],[Sintomas])
     VALUES
           ('APRAXIA IDEOMOTORA','APRAXIA','Incapacidad para realizar tareas que requieren recordar patrones o secuencias de movimientos.','no pueden recordar ni hacer la secuencia de movimientos necesaria para completar habilidades sencillas o tareas complejas, a pesar de que tienen la capacidad física para realizar la tarea y de que pueden hacer los movimientos simples de la tarea.')
GO

INSERT INTO [trial].[BBM_Enfermedad_Diagnosticada]
           ([Nombre_Enfermedad],[Nombre_Comun_Enfermedad],[Descripcion],[Sintomas])
     VALUES
           ('PARALISIS CEREBRAL','PA','Lesión en el cerebro que afecta a la movilidad y la postura de la persona, limitando su actividad.','VARIOS')
GO




----------------------------------------------------------------------------------
--COMIDAS
INSERT INTO [trial].[BBM_Comidas]
           ([ID_Menu],[Plato_1],[Plato_2],[Plato_3],[BBM_Otros_Departamentos_OD_ID])
     VALUES
           ('DESAYUNO','PORRIDGE DE AVENA','','','')
GO
INSERT INTO [trial].[BBM_Comidas]
           ([ID_Menu],[Plato_1],[Plato_2],[Plato_3],[BBM_Otros_Departamentos_OD_ID])
     VALUES
           ('COMIDA','SOPA','FILETE DE TERNERA A LA PLANCHA CON BROCOLI AL VAPOR','MANZANA','')
GO
------------------------------------------------------------------------
--MEDICACION
INSERT INTO [trial].[BBM_Medicacion]
           ([ID_Medicacion],[Nombre_Medicamento],[Codigo_EAN],[Fabricante],[Posologia],[Descripcion],[Observaciones])
     VALUES
           ('NEUNUFOR','NEURO-NUTRITION FORMULA', '','superSMART','Tomar de 1 a 3 cápsulas vegetales al día con las comidas.','','Contiene derivados de la soja')
GO
--------------------------------------------------------------------------------
-- SESION

INSERT INTO [trial].[BBM_Sesion]
           ([Sesion_ID],[Fecha_y_Hora_de_inicio],[Fecha_y_Hora_de_fin],[BBM_Horario_ID_Horario],[BBM_Espacio_ID_Espacio],[BBM_Equipamiento_ID_Equipamiento],[BBM_Empleado_BBM_Empleado_ID],[BBM_Actividades_BBM_Actividades_ID])
     VALUES
           ('LU25012021','01/25/2021 10:00','01/25/2021 11:00','','','INDIBA','','')
GO
INSERT INTO [trial].[BBM_Sesion]
           ([Sesion_ID],[Fecha_y_Hora_de_inicio],[Fecha_y_Hora_de_fin],[BBM_Horario_ID_Horario],[BBM_Espacio_ID_Espacio],[BBM_Equipamiento_ID_Equipamiento],[BBM_Empleado_BBM_Empleado_ID],[BBM_Actividades_BBM_Actividades_ID])
     VALUES
           ('DO24012021','01/24/2021 10:00','01/24/2021 12:00','','','ELECTRO','','')
GO

--------------------------
---EXPEDIENTE
INSERT INTO [trial].[BBM_Expediente]
           ([ID_Expediente],[BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad],[BBM_Usuario_Usuario_ID],[BBM_Sesion_Sesion_ID],[BBM_Tratamientos_BBM_Tratamientos_ID])
     VALUES
           ('GPPTUT012','APRAXIA IDEOMOTORA','USERGPP012','LU25012021','PSIC')
GO

--ESPECIALISTA
INSERT INTO [trial].[BBM_Especialista]
    ([Especialista_ID])
     VALUES
           ('FISIO')
GO

-- PARA UNA PRUEBA MÁS REAL, AÑADIMOS PRIMARY KEYS


ALTER TABLE [trial].[BBM_Expediente]
   ADD CONSTRAINT BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad_FK FOREIGN KEY (BBM_Enfermedad_Diagnosticada_Nombre_Enfermedad)
      REFERENCES trial.BBM_Enfermedad_Diagnosticada (Nombre_Enfermedad)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;



ALTER TABLE [trial].[BBM_Expediente]
   ADD CONSTRAINT BBM_Usuario_Usuario_ID_FK FOREIGN KEY (BBM_Usuario_Usuario_ID)
      REFERENCES trial.BBM_Usuario (Usuario_ID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;


ALTER TABLE [trial].[BBM_Expediente]
   ADD CONSTRAINT BBM_Sesion_Sesion_ID_FK FOREIGN KEY (BBM_Sesion_Sesion_ID)
      REFERENCES trial.BBM_Sesion(Sesion_ID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;



ALTER TABLE [trial].[BBM_Expediente]
   ADD CONSTRAINT BBM_Tratamientos_BBM_Tratamientos_ID_FK FOREIGN KEY (BBM_Tratamientos_BBM_Tratamientos_ID)
      REFERENCES trial.BBM_Tratamientos (BBM_Tratamientos_ID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;



ALTER TABLE [trial].[BBM_Expediente]
	ADD  Especialista_ID VARCHAR (5) NULL;
GO

ALTER TABLE [trial].[BBM_Expediente]
   ADD CONSTRAINT Especialista_ID_FK FOREIGN KEY (Especialista_ID)
      REFERENCES trial.BBM_Especialista (Especialista_ID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;


