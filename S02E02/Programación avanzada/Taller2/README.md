## Cooperativa Rau Ltda

La Cooperativa Rau Ltda. tiene como visión: “Ser una Cooperativa modelo a nivel
Nacional, prestando servicios de Agua Potable, Alcantarillado y Saneamiento en
forma eficiente y de calidad, respetando el Medio Ambiente, no dejando de lado el compromiso y responsabilidad Social con nuestros Cooperados, Usuarios y la
Comunidad de Colbún en General”.

Con el transcurso de los años, la Cooperativa ha ido creciendo dentro de la comuna de Colbún, llegando a diversas zonas con sus servicios. En consecuencia, a este crecimiento, la Cooperativa ha solicitado la creación de un sistema de escritorio con los siguientes módulos:
* Gestión de usuarios.
* Gestión de lecturas.
* Módulo de pagos.
* Módulo de convenios.

Sin embargo, por temas de tiempo, han solicitado como primer entregable solo el módulo de Gestión de usuarios. Este módulo tendrá que contar con los siguientes datos del cliente:
* Rut.
* Nombre.
* Apellido.
* Sector.
* Estado.

Además, el módulo permitirá las siguientes operaciones (Paneles o Ventanas):
* Añadir Cliente: Permite agregar a un nuevo cliente.
* Modificar Cliente: Permite modificar datos de un cliente, excepto su rut.
* Ver Clientes Activos: Mostrar todos los datos tabulados en una tabla.
* Ver Clientes Inactivos: Mostrar todos los datos tabulados en una tabla.
* Ver Filtro por Sector: Mostrar todos los datos tabulados y filtrados en una tabla.

Cabe señalar que cada operación se tendrá que realizar en un panel o ventana
diferente. 

El panel o ventana de Añadir Cliente tendrá tres JtextField para ingresar el Rut, Nombre y Apellido, el campo de sector se deberá manipular mediante un JComboBox que contendrá los siguientes ítems:
o C*lbún
* Panimávida.
* Maule Sur.
* La Guardia.
* San Nic*las.
* Quinamavida.
* Rari.
* Capilla Palacio.

El campo estado se deberá manipular mediante un JComboBox que contendrá dos estados:
* Activo
* Inactivo

La operación de añadir se efectuará al presionar un JButton.

En el panel o ventana de Modificar Cliente, usted tendrá que ingresar el Rut del cliente a modificar en un JTextField, y este buscará a la persona en el listado de activos, desplegando todos sus datos en sus respectivos JTextField, desde ahí usted podrá editar el campo y mediante un JButton activará el evento de modificación.

Los paneles o ventanas de Ver clientes Activos y Ver clientes Inactivo, contendrán un JTable que se tabularán sus datos al momento de instanciar (Constructor) a esta operación.

Las columnas a visualizar son: Rut, Nombre, Apellido y Sector.

El panel o ventana de Filtrar por sector, debe contener un JComboBox, JButton y un JTable. El JComboBox contendrá todos los sectores mencionados con anterioridad, en donde se podrá seleccionar un sector y mediante el JButton se aplicará el filtrado, mostrando solo los clientes del sector seleccionado en el JTable, las columnas a visualizar son: Rut, Nombre, Apellido y Sector.

#### ¿QUÉ LE FALTA AL CASO?
No aplica

#### INFORMACIÓN ADICIONAL

Preguntas orientadoras:
- 1. ¿Qué clase debo desarrollar primero?
- 2. ¿Qué tipo de contenedores será más apropiado?
- 3. ¿Qué tipo de evento es el más apropiado utilizar en lo Menú Bar?

#### Base de datos:

La base de datos deberá contener una tabla Cliente, con los siguientes campos:
o Rut: Varchar(12).
* Nombre: Varchar(12).
* Apellido: Varchar(12).
* Sector: Varchar(20).
* Estado: Varchar(12).

En donde el Rut será la clave primaria de la tabla Cliente.