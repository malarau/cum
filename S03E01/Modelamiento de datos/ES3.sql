--
-- 1
--
/*
	DDL. Pasar el modelo de la ilustración 1 a código SQL para esto debe seguir la siguiente
pauta
*/

-- Drop tables
--	Se realiza borrado desde quienes son requeridos a quienes requieren.

DROP TABLE MALU_DETALLE_DE_ORDEN;
DROP TABLE MALU_REPUESTO;
DROP TABLE MALU_TAREAS;
DROP TABLE MALU_ORDEN_DE_TRABAJO;
DROP TABLE MALU_DIAGNOSTICO;
DROP TABLE MALU_VEHICULO;
DROP TABLE MALU_USUARIO;
DROP TABLE MALU_TIPO_DE_USUARIOS;

-- Create tables
--	Se realiza creacion en orden inverso al borrado.

CREATE TABLE MALU_TIPO_DE_USUARIOS(
	cod_tipo NUMBER,
	nombre_tipo VARCHAR2(25),
	CONSTRAINT PK_MALU_TIPO_DE_USUARIOS PRIMARY KEY(cod_tipo)
);

-- Requiere:
--	MALU_TUPO_DE_USUARIOS	
CREATE TABLE MALU_USUARIO(
	rut NUMBER,
	nombre VARCHAR2(50),
	apellido_paterno VARCHAR2(50),
	apellido_materno VARCHAR2(50),
	tipo_de_usuario NUMBER,
	nombre_de_usuario VARCHAR2(32),
	contrasena VARCHAR2(35),
	CONSTRAINT PK_MALU_USUARIO PRIMARY KEY(rut),
	CONSTRAINT FK_MALU_USUARIO_MALU_TIPO_DE_USUARIOS
		FOREIGN KEY(tipo_de_usuario)
		REFERENCES MALU_TIPO_DE_USUARIOS(cod_tipo)
);


-- Requiere:
--	MALU_USUARIO
CREATE TABLE MALU_VEHICULO(
	patente VARCHAR2(6),
	marca VARCHAR2(35),
	modelo VARCHAR2(35),
	dueno NUMBER,
	CONSTRAINT PK_MALU_VEHICULO PRIMARY KEY(patente),
	CONSTRAINT FK_MALU_VEHICULO_MALU_USUARIO
		FOREIGN KEY(dueno)
		REFERENCES MALU_USUARIO(rut)
);

-- Requiere
--	MALU_VEHICULO
CREATE TABLE MALU_DIAGNOSTICO(
	cod_diagnostico NUMBER,
	patente VARCHAR2(6),
	diagnostico VARCHAR2(500),
	CONSTRAINT PK_MALU_DIAGNOSTICO PRIMARY KEY(cod_diagnostico),
	CONSTRAINT FK_MALU_DIAGNOSTICO_MALU_VEHICULO
		FOREIGN KEY(patente)
		REFERENCES MALU_VEHICULO(patente)
);

-- Requiere
--	MALU_DIAGNOSTICO
CREATE TABLE MALU_ORDEN_DE_TRABAJO(
	cod_orden NUMBER,
	cod_diagnostico NUMBER,
	precio_total NUMBER,
	CONSTRAINT PK_MALU_ORDEN_DE_TRABAJO PRIMARY KEY(cod_orden),
	CONSTRAINT FK_MALU_ORDEN_DE_TRABAJO_MALU_DIAGNOSTICO
		FOREIGN KEY(cod_diagnostico)
		REFERENCES MALU_DIAGNOSTICO(cod_diagnostico)
);

CREATE TABLE MALU_TAREAS(
	cod_tareas NUMBER,
	nombre_tarea VARCHAR2(75),
	precio_mano_obra NUMBER,
	CONSTRAINT PK_MALU_TAREAS PRIMARY KEY(cod_tareas)
);

CREATE TABLE MALU_REPUESTO(
	cod_repuesto NUMBER,
	nombre_repuesto VARCHAR2(75),
	precio_unitario NUMBER,
	CONSTRAINT PK_MALU_REPUESTO PRIMARY KEY(cod_repuesto)
);

-- Requiere:
--	MALU_ORDEN_DE_TRABAJO
--	MALU_TAREAS
--	MALU_REPUESTO
CREATE TABLE MALU_DETALLE_DE_ORDEN(
	cod_orden NUMBER,
	cod_detalle_orden NUMBER,
	tarea NUMBER,
	precio NUMBER,
	repuesto NUMBER,
	CONSTRAINT PK_MALU_DETALLE_DE_ORDEN PRIMARY KEY(cod_orden, cod_detalle_orden),
	CONSTRAINT FK_MALU_DETALLE_DE_ORDEN_MALU_ORDEN_DE_TRABAJO
		FOREIGN KEY(cod_orden)
		REFERENCES MALU_ORDEN_DE_TRABAJO(cod_orden),
	CONSTRAINT FK_MALU_DETALLE_DE_ORDEN_MALU_TAREAS
		FOREIGN KEY(tarea)
		REFERENCES MALU_TAREAS(cod_tareas),
	CONSTRAINT FK_MALU_DETALLE_DE_ORDEN_MALU_REPUESTO
		FOREIGN KEY(repuesto)
		REFERENCES MALU_REPUESTO(cod_repuesto)
);

--
-- 2
-- 
/*
	A través de instrucciones DML debe hacer lo siguiente:
*/

-- A
/*
	Se solicita ingresar 3 Mecánicos, 1 Dueño y 6 Clientes
	Por lo que en primera instacia se deben crear los 3 tipos de usuario:
	-	Mecánico
	-	Dueño
	-	Cliente
*/
INSERT INTO MALU_TIPO_DE_USUARIOS VALUES(1, 'Dueño');
INSERT INTO MALU_TIPO_DE_USUARIOS VALUES(2, 'Mecánico');
INSERT INTO MALU_TIPO_DE_USUARIOS VALUES(3, 'Cliente');

-- Luego se procede con la creación de lo requerido usando información genérica.
-- Mecánicos
INSERT INTO MALU_USUARIO 
	VALUES(10000001, 'Nombre 1', 'apellido_paterno', 'apellido_materno', 2, 'username', 'password');
	INSERT INTO MALU_USUARIO 
	VALUES(10000002, 'Nombre 2', 'apellido_paterno', 'apellido_materno', 2, 'username', 'password');
	INSERT INTO MALU_USUARIO 
	VALUES(10000003, 'Nombre 3', 'apellido_paterno', 'apellido_materno', 2, 'username', 'password');
-- Dueño
INSERT INTO MALU_USUARIO 
	VALUES(10000004, 'Nombre 4', 'apellido_paterno', 'apellido_materno', 1, 'username', 'password');
-- Clientes
INSERT INTO MALU_USUARIO 
	VALUES(10000005, 'Nombre 5', 'apellido_paterno', 'apellido_materno', 3, 'username', 'password');
INSERT INTO MALU_USUARIO 
	VALUES(10000006, 'Nombre 6', 'apellido_paterno', 'apellido_materno', 3, 'username', 'password');
INSERT INTO MALU_USUARIO 
	VALUES(10000007, 'Nombre 7', 'apellido_paterno', 'apellido_materno', 3, 'username', 'password');
INSERT INTO MALU_USUARIO 
	VALUES(10000008, 'Nombre 8', 'apellido_paterno', 'apellido_materno', 3, 'username', 'password');
INSERT INTO MALU_USUARIO 
	VALUES(10000009, 'Nombre 9', 'apellido_paterno', 'apellido_materno', 3, 'username', 'password');
INSERT INTO MALU_USUARIO 
	VALUES(10000010, 'Nombre10', 'apellido_paterno', 'apellido_materno', 3, 'username', 'password');

-- B
/*
	Ingresar 10 Vehículos (debe considerar 2 clientes tienen 1 vehículo y los otros
	tienen 2 cada uno).
*/

INSERT INTO MALU_VEHICULO VALUES('A00001', 'Marca', 'Modelo', 10000005);
INSERT INTO MALU_VEHICULO VALUES('A00002', 'Marca', 'Modelo', 10000006);
INSERT INTO MALU_VEHICULO VALUES('A00003', 'Marca', 'Modelo', 10000007);
INSERT INTO MALU_VEHICULO VALUES('A00004', 'Marca', 'Modelo', 10000007);
INSERT INTO MALU_VEHICULO VALUES('A00005', 'Marca', 'Modelo', 10000008);
INSERT INTO MALU_VEHICULO VALUES('A00006', 'Marca', 'Modelo', 10000008);
INSERT INTO MALU_VEHICULO VALUES('A00007', 'Marca', 'Modelo', 10000009);
INSERT INTO MALU_VEHICULO VALUES('A00008', 'Marca', 'Modelo', 10000009);
INSERT INTO MALU_VEHICULO VALUES('A00009', 'Marca', 'Modelo', 10000010);
INSERT INTO MALU_VEHICULO VALUES('A00010', 'Marca', 'Modelo', 10000010);

-- C
/*
	Existe Diagnóstico para 3 Vehículos
*/
INSERT INTO MALU_DIAGNOSTICO VALUES(1, 'A00001', 'Diagnostico blablabla');
INSERT INTO MALU_DIAGNOSTICO VALUES(2, 'A00002', 'Diagnostico blablabla');
INSERT INTO MALU_DIAGNOSTICO VALUES(3, 'A00003', 'Diagnostico blablabla');

-- D
/*
	Existe Orden de trabajo para sólo 2 diagnósticos
*/
INSERT INTO MALU_ORDEN_DE_TRABAJO VALUES(1, 1, 120000);
INSERT INTO MALU_ORDEN_DE_TRABAJO VALUES(2, 2, 90000);

-- E y F
/*
	Una Orden de trabajo tiene 3 detalles y la otra 6.
	Para ello se requiere:
	--	MALU_TAREAS
	--	MALU_REPUESTO

	Eso es F:
	Tareas y repuestos existen dependiendo de los detalles las órdenes de trabajo.
	Por lo que los valores concuerdan con el precio final.
*/
-- Crear tareas y un repuestos
INSERT INTO MALU_TAREAS VALUES(1, 'Tarea1', 5000);
INSERT INTO MALU_REPUESTO VALUES(1, 'Repuesto1', 15000);

INSERT INTO MALU_TAREAS VALUES(2, 'Tarea2', 10000);
INSERT INTO MALU_REPUESTO VALUES(2, 'Repuesto2', 20000);

-- 6 detalles
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(1, 1, 1, 20000, 1);
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(1, 2, 1, 20000, 1);
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(1, 3, 1, 20000, 1);
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(1, 4, 1, 20000, 1);
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(1, 5, 1, 20000, 1);
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(1, 6, 1, 20000, 1);

-- 3 detalles
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(2, 7, 2, 30000, 2);
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(2, 8, 2, 30000, 2);
INSERT INTO MALU_DETALLE_DE_ORDEN VALUES(2, 9, 2, 30000, 2);

--
-- 3
--
/*
	Actualizar
*/

-- A
--	Un diagnóstico
UPDATE MALU_DIAGNOSTICO SET diagnostico = 'Me equivoqué, en realidad no era eso jeje'
	WHERE(cod_diagnostico = 1);

-- B
--	Un diagnóstico
UPDATE MALU_USUARIO SET nombre_de_usuario = 'nenitobienrankeao'
	WHERE(rut = 10000005);

-- C
--	Un vehículo
UPDATE MALU_VEHICULO SET marca = 'Marca china'
	WHERE(patente = 'A00001');

-- 4
/*
	Borrar
*/

-- A
--	2 detalles de orden de trabajo
DELETE 

DELETE FROM MALU_DETALLE_DE_ORDEN
	WHERE(cod_detalle_orden = 5);
DELETE FROM MALU_DETALLE_DE_ORDEN
	WHERE(cod_detalle_orden = 6);

--
-- 5
--
/*
	Consultas
*/

-- A
/*
	Quiero saber cuál es el precio (mostrado de la siguiente forma: $1.000), de qué
	vehículo (patente), su dueño (rut), y su orden de trabajo asociada al pago
	correspondiente (código).
*/

-- Utilizando cod_orden = 1
-- Precio
SELECT precio_total FROM MALU_ORDEN_DE_TRABAJO WHERE(cod_orden = 1);
-- Patente
SELECT DISTINCT patente FROM MALU_DIAGNOSTICO WHERE cod_diagnostico IN (
	SELECT cod_diagnostico FROM MALU_ORDEN_DE_TRABAJO WHERE(cod_orden = 1)
);


-- B
/*
	Quiero saber de las distintas órdendes de trabajo, cuántos detalles tiene cada
	una.
*/
SELECT COUNT(*) FROM MALU_DETALLE_DE_ORDEN WHERE(cod_orden = 1);
SELECT COUNT(*) FROM MALU_DETALLE_DE_ORDEN WHERE(cod_orden = 2);

-- C
/*
	Quiero saber cuántos diagnósticos están asociados a una orden de trabajo y
	cuántos aún no se comienzan a trabajar, detallado de la siguiente forma:
	diagnóstico | orden (ejemplo: 1 | 1; 1 |null).
*/



















