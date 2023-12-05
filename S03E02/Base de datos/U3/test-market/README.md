## Requisitos

* Python 3.8+
* Flask
* Oracle Database 21c Express Edition [Microsoft Windows x64 (64-bit) [Link]](https://www.oracle.com/cl/database/technologies/xe-downloads.html)
    - New Windows user:
        - user: demodb
        - pass: demodb
    - Oracle db name:
        - user: orcl
        - pass: Oracle1234
    - Oracle user connection
        - user: SYS
        - pass: demodb
* SQL Developer 23.1 [Windows 64-bit with JDK 11 included [Link]](https://www.oracle.com/database/sqldeveloper/technologies/download/)

## Setup (Windows)

#### Entorno virtual
```
python -m venv venv
.\venv\Scripts\activate
python -m pip install --upgrade pip
```

#### Instalar el controlador Oracle para Python y dependencias
https://oracle.github.io/python-oracledb/

```
python -m pip install -r requirements.txt
```

#### (Opcional) Crear usuario (CMD)
```
SQLPLUS / AS SYSDBA
alter session set "_ORACLE_SCRIPT"=true;
CREATE USER testuser IDENTIFIED BY testpassword;
GRANT CREATE SESSION TO testuser;
(Otros)
```

## Ejecución
Correr:
```
run.py
```
Revisar en:
```
http://127.0.0.1:5000
```

## Ejemplo:

- En *views/views.py* se encuentran todas las rutas.
- Allí por ejemplo se define:
```
@app.route('/productos', methods=['GET', 'POST'])
```
- Se encarga de listar productos (GET), agregar, modificar y eliminar (POST).
- Para ello renderiza *productos.html*
- Los datos resultantes de los formularios para por ejemplo agregar, se enlazan con la clase creada en forms.py