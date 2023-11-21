## Control RRHH.

La empresa de abarrotes necesita llevar un control de sus trabajadores, ya
que actualmente todo el control lo realizan de forma manual, y necesitan de
una aplicaci´on que les ayude a agilizar procesos como buscar de forma r´apida
a un trabajador, crear un trabajador, aumentar sueldo, buscar por sueldos,
buscar por departamento, despedir a un trabajador, cambiar el salario, cambiar
el salario a todo un departamento, son las funciones que debe tener el sistema
(Ver Fig. 1).

![Fig 1](img/figura1.png)

### Requerimientos (3 puntos c/u)

1. En la clase empresa, en su constructor, se deber´a crear dos listas que
almacenen los trabajadores, una lista con 5 trabajadores despedidos y una
lista con 5 trabajadores activos,a su vez se debe crear 2 departamentos,
uno llamado Producci´on y otro llamado Administraci´on para ser asignado
a cada trabajador
2. Se debe buscar a un trabajador, para ello, se debe recorrer la lista de
activos, retornando todos los datos del trabajador o un mensaje en caso
de que el trabajador no exista.
3. Se debe agregar un nuevo trabajador a la lista, validando que el RUT no
se repita, adem´as debe validar que el departamento sea uno de los dos
especificados. Debe retornar un String indicando la situaci´on de ingreso
correcto o si hubo un problema al ingresar. Otro punto importante es que
no se puede agregar un trabajador que ya fue despedido.
4. Se debe aumentar el salario de un trabajador activo, para ello se debe
buscar al trabajador y aumentar su salario, considerando que lo m´aximo
que se puede aumentar corresponde a la mitad de sueldo. Debe retornar
un String indicando la situaci´on.
5. Se debe filtrar por sueldo, para ello, se debe recorrer la lista de todos los
trabajadores activos, e imprimir todos los trabajadores que se encuentren
en el rango establecido por los par´ametros del m´etodo. Debe validar que el
rango de inicio sea menor al rango de fin para poder realizar la b´usqueda.
6. Se debe buscar trabajadores activos por departamento, para ello, debe 
recorrer la lista de todos los trabajadores e imprimir todos los trabajadores que pertenezcan al departamento. Debe validar que el nombre del
departamento exista.
7. Se debe despedir a un trabajador, para ello, debe buscar en la lista de
trabajadores el RUT del trabajador a despedir, si lo encuentra, debe agregar al trabajador a la lista de despedidos. El m´etodo retorna un String
indicando la situaci´on.
8. Se debe cambiar el salario, para ello, debe buscar a un trabajador en
la lista de trabajadores activos, si lo encuentra debe cambiar el salario,
siempre y cuando el nuevo salario se encuentre en el rango de 350.000 y
500.000.
9. Se debe cambiar el salario por departamento, para ello, debe recorrer la
lista de trabajadores activos buscando aquellos trabajadores que pertenecen al departamento especificado como par´ametro, siempre y cuando el
nuevo salario se encuentre en el rango de 350.000 y 500.000.
10. Se debe ver a los trabajadores despedidos, para ello, debe retornar la lista
de despedidos.
11. Se debe ver a los trabajadores contratados, para ello, debe retornar la lista
de trabajadores.
2
12. Se debe crear un menú con todas las funciones operativas.
- 1.) CREAR TRABAJADOR
- 2.) BUSCAR TRABAJADOR
- 3.) AUMENTAR SUELDO TRABAJADOR
- 4.) FILTRAR POR SUELDO
- 5.) FILTRAR POR DEPARTAMENTO
- 6.) DESPEDIR TRABAJADOR
- 7.) CAMBIAR SUELDO TRABAJADOR
- 8.) CAMBIAR SUELDO DEPARTAMENTO
- 9.) VER TRABAJADORES
- 10.) VER DESPEDIDOS
- 11.) VER CONTRATADOS
- 12.) SALIR
