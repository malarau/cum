/*
    1•	Desarrollar el modelo en formato SQL (incorporando create y drop table con el orden asociado que deben tener según lógica y prefijos
        de tabla para cada estudiante según sus iniciales para todos los objetos del modelo que se trabajará en los requerimientos del caso).
*/

DROP TABLE Detalle_Venta;
DROP TABLE Venta;
DROP TABLE Productos;
DROP TABLE Cliente;
DROP TABLE Log_Ventas;

CREATE TABLE Log_Ventas(
    cod_log NUMBER,
    instruccion VARCHAR2(50),
    detalle VARCHAR2(200),
    fechayhora DATE,
    CONSTRAINT PK_LOG_VENTAS PRIMARY KEY(cod_log)
);
CREATE TABLE Cliente(
    cod_cliente NUMBER,
    nombre_cliente VARCHAR2(50),
    apellido1_cliente VARCHAR2(50),
    apellido2_cliente VARCHAR2(50),
    email_cliente VARCHAR2(30),
    CONSTRAINT PK_CLIENTE PRIMARY KEY(cod_cliente)
);
CREATE TABLE Venta(
    cod_venta NUMBER,
    fecha_venta DATE,
    total_venta NUMBER,
    cod_cliente NUMBER,
    CONSTRAINT PK_VENTA PRIMARY KEY(cod_venta),
    CONSTRAINT PK_VENTA_CLIENTE
        FOREIGN KEY(cod_cliente)
        REFERENCES Cliente(cod_cliente)
);
CREATE TABLE Productos(
    cod_producto NUMBER,
    nombre_producto VARCHAR2(50),
    precio_compra NUMBER,
    cantidad NUMBER,
    STOCK NUMBER,
    CONSTRAINT PK_PRODUCTOS PRIMARY KEY(cod_producto)
);
CREATE TABLE Detalle_Venta(
    cod_venta NUMBER,
    cod_producto NUMBER,
    cantidad NUMBER,
    valor_total NUMBER,
    CONSTRAINT PK_DETALLE_VENTA PRIMARY KEY(cod_venta, cod_producto),
    CONSTRAINT PK_DETALLE_VENTA_VENTA
        FOREIGN KEY(cod_venta)
        REFERENCES Venta(cod_venta),
    CONSTRAINT PK_DETALLE_VENTA_PRODUCTOS
        FOREIGN KEY(cod_producto)
        REFERENCES Productos(cod_producto)
);

/*
    2•	Crear Triggers que se encarguen de generar la clave primaria, de carácter autoincremental para las tablas Venta y Cliente.
*/

-- Venta
CREATE OR REPLACE TRIGGER tr_insert_venta
    BEFORE INSERT ON Venta FOR EACH ROW
    DECLARE
        tmp_cod_venta NUMBER;
    BEGIN
        SELECT MAX(cod_venta) 
            INTO tmp_cod_venta
            FROM Venta;
        :NEW.cod_venta := NVL(tmp_cod_venta+1, 1); -- If is the first, then SELECT -> null.
    END;

-- Cliente
CREATE OR REPLACE TRIGGER tr_insert_cliente
    BEFORE INSERT ON Cliente FOR EACH ROW
    DECLARE
        tmp_cod_cliente NUMBER;
    BEGIN
        SELECT MAX(cod_cliente) 
            INTO tmp_cod_cliente
            FROM Cliente;
        :NEW.cod_cliente := NVL(tmp_cod_cliente+1, 1); -- If is the first, then SELECT -> null.
    END;

/*
    3•	Crear Triggers que se encarguen de pasar a mayúscula todos los campos alfanuméricos de las tablas Venta y Cliente.
*/

CREATE OR REPLACE TRIGGER tr_uppercase_cliente
    BEFORE INSERT OR UPDATE ON Venta FOR EACH ROW
    BEGIN
        :NEW.nombre_cliente := UPPER(:NEW.nombre_cliente);
        :NEW.apellido1_cliente := UPPER(:NEW.apellido1_cliente);
        :NEW.apellido2_cliente := UPPER(:NEW.apellido2_cliente);
        :NEW.email_cliente := UPPER(:NEW.email_cliente);
    END;

/*
    4•	Crear un Trigger de nombre Sapo, que se encargue de registrar en la tabla log_ventas cada vez que se realice
        la actualización del total de la venta, en la tabla venta, y para ello, se debe llevar a cabo un registro debe
        llenar todos los campos de la tabla definida por el requerimiento.
*/

CREATE OR REPLACE TRIGGER tr_sapo
    AFTER INSERT OR UPDATE OR DELETE ON Venta FOR EACH ROW
    DECLARE
        tmp_cod_log NUMBER;
        tmp_instruccion VARCHAR2(50);
        tmp_detalle VARCHAR2(200);
    BEGIN
        -- cod_log
        SELECT MAX(cod_log) 
            INTO tmp_cod_log
            FROM Log_Ventas;
        tmp_cod_log := NVL(tmp_cod_log+1, 1); -- If is the first, then SELECT -> null.
        -- instruccion, detalle
        IF INSERTING THEN
            tmp_instruccion := 'Insertando';
            tmp_detalle := 'Insertando venta código ' || :NEW.cod_venta || ', con valor ' || :NEW.total_venta;
        ELSIF UPDATING THEN
            tmp_instruccion := 'Actualizando';
            tmp_detalle := 'Actualizando venta código: ' || :NEW.cod_venta || ', con valor: ' || :OLD.total_venta || ' por nuevo valor: ' || :NEW.total_venta;
        ELSIF DELETING THEN
            tmp_instruccion := 'Eliminando';
            tmp_detalle := 'Eliminando venta código: ' || :OLD.cod_venta || ', con valor ' || :OLD.total_venta;
        END IF;

        -- INSERT
        INSERT INTO Log_Ventas
            VALUES (tmp_cod_log, tmp_instruccion, tmp_detalle, TO_DATE(SYSDATE, 'YYYY/MM/DD HH24-MI-SS'));
    END;


/*
    5•	Crear una función, que se encargue de calcular el total de la venta,considerando
    los valores totales de los productos asociados a cada venta, de acuerdo a su código.
*/

-- Cursor explícito
CREATE OR REPLACE FUNCTION fun_total_venta(
    cod_venta_f NUMBER
)
RETURN NUMBER
IS
    CURSOR cursor_ventas IS
        SELECT valor_total
        FROM Detalle_Venta
        WHERE (cod_venta = cod_venta_f);
    tmp_total_detalle_venta Detalle_Venta.valor_total%TYPE DEFAULT 0;
    tmp_total NUMBER DEFAULT 0;
BEGIN
    OPEN cursor_ventas;

    LOOP
        FETCH cursor_ventas INTO tmp_total_detalle_venta;
        EXIT WHEN cursor_ventas%NOTFOUND;

        tmp_total := tmp_total + NVL(tmp_total_detalle_venta, 0);
    END LOOP;
    RETURN tmp_total;
END;

-- Cursor implícito
CREATE OR REPLACE FUNCTION fun_total_venta_imp(
    cod_venta_f NUMBER
)
RETURN NUMBER
IS
    total_venta NUMBER DEFAULT 0;
BEGIN
    FOR fila_detalle_venta IN 
        (SELECT valor_total 
            FROM Detalle_Venta
            WHERE (cod_venta = cod_venta_f)) 
        LOOP
            total_venta := total_venta + fila_detalle_venta.valor_total;
    END LOOP;

    RETURN total_venta;
END;

/*
    6•	Crear un procedimiento almacenado integral para la tabla Venta, que incorpore las opciones:
        R para insert
        U para update
        D para delete

    o	Restricciones 
        	En el caso de insertar datos, se deben insertar todos.
        	En el caso de la actualización será el total de acuerdo a un código.
        	En el caso del borrado, se realizará a través del código
*/

CREATE OR REPLACE PROCEDURE proc_rud_venta(
    opcion VARCHAR2,
    cod_venta_f NUMBER,
    fecha_venta_f DATE DEFAULT NULL,
    total_venta_f NUMBER DEFAULT NULL,
    cod_cliente_f NUMBER DEFAULT NULL
)
IS
BEGIN
    LOCK TABLE Venta IN ROW EXCLUSIVE MODE;
    CASE opcion
        WHEN 'R' THEN
            IF fecha_venta_f IS NULL OR cod_cliente_f IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('No se ha podido ingresar la información, se deben incluir todos los campos.');
            ELSE
                INSERT INTO Venta 
                    VALUES(0, fecha_venta_f, total_venta_f, cod_cliente_f); --> tr_insert_venta para el cod_venta
            END IF;
        WHEN 'U' THEN
            UPDATE Venta SET total_venta = total_venta_f WHERE (cod_venta = cod_venta_f);
        WHEN 'D' THEN
            DELETE FROM Venta WHERE (cod_venta = cod_venta_f);
	END CASE;
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ha ocurrido un error intentando realizar el procedimiento.');
        ROLLBACK;
END;


/*
    7• Crear un procedimiento almacenado de inserción para tabla Cliente,
        que considere todos los campos de la tabla.
*/
CREATE OR REPLACE PROCEDURE proc_insert_cliente(
    nombre_cliente_f VARCHAR2,
    apellido1_cliente_f VARCHAR2,
    apellido2_cliente_f VARCHAR2,
    email_cliente_f VARCHAR2
)
IS
BEGIN
    LOCK TABLE Cliente IN ROW EXCLUSIVE MODE;
    
    IF COALESCE(nombre_cliente_f, apellido1_cliente_f, apellido2_cliente_f, email_cliente_f) IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Alguno de los parámetros contiene valores nulos.');
    ELSE
        --tr_insert_cliente para el código
        INSERT INTO Cliente 
            VALUES(0, nombre_cliente_f, apellido1_cliente_f, apellido2_cliente_f, email_cliente_f);
    END IF;

    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ha ocurrido un error intentando realizar el procedimiento.');
        ROLLBACK;
END;

/*
    8•	Generar una secuencia que se encargue de gestionar la clave primaria para la productos.
*/

-- Eventualmente se deberá analizar el uso de:
--  CYCLE, si se desea que se reinicie al llegar a ese tope
--  MINVALUE, qué valor tomar al reiniciar
--  CACHE, almacenar/reservar cierta cantidad de números consecutivos para usar

-- De momento 1000 productos, dado que comienza con la tienda (por lo poco) y teniendo en cuenta que un mismo producto podría tener
-- diferentes códigos según talla, tamaño, cantidad, color, etc. (por lo mucho), se establece ese tope.
CREATE SEQUENCE sec_primarykey_productos
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 1000
    ORDER;
    



-- TMP
INSERT INTO Cliente (cod_cliente, nombre_cliente, apellido1_cliente, apellido2_cliente, email_cliente)
	VALUES (0, 'Carlos', 'Martínez', 'Díaz', 'carlos.martinez@email.com');

INSERT INTO Venta(cod_venta, fecha_venta, total_venta, cod_cliente)
    VALUES (0, TO_DATE('2023-11-18', 'YYYY-MM-DD'), 50, 101);

UPDATE Venta SET total_venta = 50 WHERE (cod_venta = 3);
DELETE FROM Venta WHERE (cod_venta = 4);

SELECT * FROM Venta;
SELECT * FROM Cliente;
SELECT * FROM Log_Ventas;

