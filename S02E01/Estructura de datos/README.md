## ESTRUCTURA DE DATOS
### Selección aleatoria de turnos

#### Entrada de datos
Residente en el archivo de texto "guardias.in": En cada línea aparecerán tres números
(N, k y m, los tres mayores que 0 y menores que 1000) separados por un único espacio
en blanco y sin blancos ni al comienzo ni al final de la línea. La última línea del archivo
contendrá siempre tres ceros.

#### Salida requerida
A guardar en el archivo de texto "guardias.out": Para cada línea de datos del archivo de
entrada (excepto la última que contiene tres ceros), se generará una línea de números
que especifique el orden en que serían seleccionados los guardias para esos valores de
N, k y m. Cada selección se separa de la anterior por una coma y los números
seleccionados deben estar separados por un espacio en blanco. Cuando los dos guardias
son seleccionados simultáneamente, en el archivo aparecerá primero el elegido por el
encargado que cuenta en sentido horario, no debe ponerse una coma después del
último grupo.
#### Ejemplo de entrada
```
10 4 3
5 2 8
13 2 2
0 0 0
```
#### Ejemplo de salida
```
 4 8,9 5,3 1,2 6,10,7
 2 3,5,4 1
 2 12,4 10,6 8,9 5,13 1,7,3 11
```