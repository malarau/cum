import oracledb

class OracleDBConnector:
    _instance = None

    def __new__(cls, username, password, connect_string, mode=oracledb.SYSDBA):
        print(F'username, password, connect_string: {(username, password, connect_string)}')
        if not cls._instance:
            cls._instance = super(OracleDBConnector, cls).__new__(cls)
            cls._instance._username = username
            cls._instance._password = password
            cls._instance._connect_string = connect_string
            cls._instance._mode = mode
            cls._instance._pool = oracledb.create_pool(
                user=username,
                password=password,
                dsn=connect_string,
                min=1,
                max=2,
                increment=1,
                mode=oracledb.SYSDBA
            )
        return cls._instance

    # EJECUTA UNA QUERY PARA TRAER COSAS
    def execute_query(self, query, *args):
        try:
            with self._pool.acquire() as connection:
                with connection.cursor() as cursor:
                    cursor.execute(query, args)
                    result = cursor.fetchall()                    
                    return result
        except Exception as e:
            print(f"Error executing query: {e}")
            return None
        
    # EJECUTA UNA QUERY PARA INSERTAR COSAS, IMAGINO QUE FUNCIONA PARA UPDATE
    # TODO: NO USAR ESTO, CREAR PROCEDIMIENTOS ESPECIALES
    def execute_insert(self, query, *args):
        try:
            with self._pool.acquire() as connection:
                with connection.cursor() as cursor:
                    cursor.execute(query, args)
                    connection.commit()  # MUCHO MUY IMPORTANTE
        except Exception as e:
            print(f"Error executing insert: {e}")

    ########

    def get_user_by_id(self, id):
        query = "SELECT * FROM USUARIO WHERE username = :1"
        print("query: ", query)
        return self.execute_query(query, id)

    def get_user_by_username(self, username):
        query = "SELECT * FROM USUARIO WHERE username = :1"
        print("query: ", query)
        return self.execute_query(query, username)
    
    # USO DE PROCEDIMIENTO
    def crear_usuario(self, username, email, password):
        try:
            with self._pool.acquire() as connection:
                with connection.cursor() as cursor:

                    out_val = cursor.var(int)
                    
                    cursor.callproc('proc_crear_usuario', [username, email, password, out_val])

                    result = out_val.getvalue()              
                    return result
        except Exception as e:
            print(f"Error executing query: {e}")
            return None

    # Productos
    def get_all_products(self):
        query = "SELECT * FROM PRODUCTOS"
        return self.execute_query(query)
    
    # MALO MALO, VALIDAR ANTES
    def agregar_producto(self, nombre_producto, cantidad, marca):
        query = "INSERT INTO PRODUCTOS VALUES(:1, :2, :3)"
        return self.execute_insert(query, nombre_producto, cantidad, marca)
    
    def get_product_by_name(self, nombre):
        query = "SELECT * FROM PRODUCTOS WHERE NOMBRE = :1"
        return self.execute_query(query, nombre)
    
    # MAL, USAR PROCEDIMIENTO
    def update_product(self, nombre, nuevo_nombre, nueva_cantidad, nueva_marca):
        query = "UPDATE PRODUCTOS SET nombre = :2, cantidad = :3, marca = :4 WHERE nombre = :1"
        return self.execute_insert(query, nombre, nuevo_nombre, nueva_cantidad, nueva_marca)



