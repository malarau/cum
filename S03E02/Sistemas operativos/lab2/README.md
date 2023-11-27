### app.py

Contiene la clase `PagingSystem()` y se encarga de ejecutar el algoritmo por medio de la función `run_algorithm()`.
Opcionalmente puede recibir un parámetro, que hace referencia a un porcentaje necesario de fragmentación de memoria para ejecuutar la compactación, un valor entre 0 y 1.

Por defecto el nivel de log es `INFO`. 

```
logging.basicConfig(level=logging.INFO)
```


Pero para ver todo el detalle, se puede establecer en `DEBUG`.

### data_handling.py

Desde allí se puede generar un nuevo archivo de texto `generate_txt(n)`, donde `n` es el número de procesos a crear. Además permite otros ajuste.
También se puede leer el mismo archivo de texto en `read_txt()`.

### experimennt_runner.py

Es la clase que se encarga de generar las pruebas de forma automatizada.
De momento solo imprime valores, ideal sería poder pasar todo a un DataFrame para ser exportado.

