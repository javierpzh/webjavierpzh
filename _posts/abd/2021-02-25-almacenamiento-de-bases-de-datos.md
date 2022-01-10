---
layout: post
---

## Oracle

#### Vamos a establecer que los objetos que se creen en el 'TS1' tengan un tamaño inicial de 200K, y que cada extensión sea del doble del tamaño que la anterior. El número máximo de extensiones será de 3.

Para ello, antes de nada, necesitaremos crear el propio *tablespace*. En mi caso, lo crearé con un fichero, de 2 MB, y autoextensible:

<pre>
SQL> create tablespace TS1
  2  datafile 'ts1.dbf'
  3  size 2M
  4  autoextend on;

Tablespace creado.
</pre>

Una vez creado, vamos a establecer dicho *tablespace* *offline* para poder operar con él:

<pre>
SQL> alter tablespace TS1 offline;

Tablespace modificado.
</pre>

Modificamos el *tablespace TS1*:

<pre>
SQL> ALTER TABLESPACE TS1
  2  DEFAULT STORAGE (
  3  INITIAL 200K
  4  NEXT 400K
  5  PCTINCREASE 100
  6  MINEXTENTS 1
  7  MAXEXTENTS 3);
ALTER TABLESPACE TS1
*
ERROR en lÝnea 1:
ORA-25143: la clßusula de almacenamiento por defecto no es compatible con la
polÝtica de asignaci¾n
</pre>

A la hora de realizar la sentencia *ALTER TABLE* nos reporta un error debido a que el *tablespace*, por defecto, está hecho en local, y no por diccionario, por lo que no podemos modificar las cláusulas de almacenamiento.

Podemos observar que el *tablespace system* está guardado en local.

<pre>
SQL> SELECT tablespace_name, extent_management FROM dba_tablespaces where tablespace_name='SYSTEM';

TABLESPACE_NAME                EXTENT_MAN
------------------------------ ----------
SYSTEM                         LOCAL
</pre>

Bien, y ¿podríamos hacer que la gestión de extensiones fuera por diccionario?

Pues desgraciadamente no. La gestión de extensiones se elige en la instalación de *Oracle* y luego no puede modificarse. La gestión local proporciona un mejor rendimiento, pero ignora la cláusula *STORAGE* de los objetos del *tablespace*.


#### Vamos a crear dos tablas en el tablespace recién creado e insertaremos un registro en cada una de ellas. Comprobaremos el espacio libre existente en el tablespace. Borraremos una de las tablas y comprobaremos si ha aumentado el espacio disponible en el tablespace.

Primero vamos a establecer el *tablespace* *online*:

<pre>
SQL> alter tablespace TS1 online;

Tablespace modificado.
</pre>

Antes de nada, vamos a observar el espacio libre que posee ahora mismo dicho *tablespace*, que actualmente se encuentra vacío:

<pre>
SQL> select tablespace_name, bytes from dba_free_space where tablespace_name='TS1';

TABLESPACE_NAME                     BYTES
------------------------------ ----------
TS1                               1048576
</pre>

Bien, ahora vamos a proceder a crear las dos tablas en el *tablespace* **TS1**:

<pre>
SQL> create table Tabla1
  2  (
  3    Campo1 VARCHAR2(20)
  4  )
  5  tablespace TS1;

Tabla creada.

SQL> create table Tabla2
  2  (
  3  Campo2 VARCHAR2(20)
  4  )
  5  tablespace TS1;

Tabla creada.
</pre>

Una vez que las tablas han sido creadas, vamos a insertar un registro en cada una de ellas:

<pre>
SQL> insert into Tabla1 values('Registro1');

1 fila creada.

SQL> insert into Tabla2 values('Registro2');

1 fila creada.
</pre>

Una vez que los registros han sido insertados, vamos a observar de nuevo el tamaño disponible del *tablespace*:

<pre>
SQL> select tablespace_name, bytes from dba_free_space where tablespace_name='TS1';

TABLESPACE_NAME                     BYTES
------------------------------ ----------
TS1                                917504
</pre>

Podemos apreciar como lógicamente el espacio libre ha disminuido.

Por último, vamos a probar a borrar una tabla de las almacenadas en dicho *tablespace* y a observar si se libera espacio.

<pre>
SQL> drop table Tabla2;

Tabla borrada.
</pre>

Ya hemos borrado una de las tablas, de forma que únicamente estaríamos almacenando en el *tablespace TS1*, una tabla. Vamos a repetir la consulta anterior para ver cuanto espacio disponible tenemos:

<pre>
SQL> select tablespace_name, bytes from dba_free_space where tablespace_name='TS1';

TABLESPACE_NAME                     BYTES
------------------------------ ----------
TS1                                917504
TS1                                 65536
</pre>

Como podemos observar, nos aparece una nueva línea que indica 65536 bytes.

Esto se debe a que en *Oracle*, los *tablespaces* se dividen en segmentos, y cada segmento es un objeto del *tablespace*, por lo que esos *bytes* son los que se han liberado tras eliminar la tabla *Tabla2*.


#### Vamos a convertir 'TS1' en un tablespace de sólo lectura. Intentaremos insertar registros en la tabla existente. ¿Qué ocurre? Intentaremos borrar la tabla. ¿Qué ocurre? ¿Por qué pasa eso?

Vamos a convertir el *tablespace TS1* en un *tablespace* de sólo lectura. Para ello ejecutamos el siguiente comando:

<pre>
SQL> alter tablespace TS1 read only;

Tablespace modificado.
</pre>

Hecho esto, vamos a probar a insertar un registro en la *Tabla1* almacenada en dicho *tablespace*:

<pre>
SQL> insert into Tabla1 values('Registro2');
insert into Tabla1 values('Registro2')
            *
ERROR en lÝnea 1:
ORA-00372: el archivo 13 no se puede modificar en este momento
ORA-01110: archivo de datos 13:
'C:\USERS\SERVIDOR\DESKTOP\WINDOWS.X64_193000_DB_HOME\DATABASE\TS1.DBF'
</pre>

Obviamente, al establecer el *tablespace TS1* como sólo lectura, no podemos hacer una inserción de datos en él, ya que esto supondría una escritura sobre lo que ya se encuentra almacenado en dicho *tablespace*.

Para seguir comprobando este razonamiento, vamos a intentar borrar la tabla que se encuentra almacenada en él:

<pre>
SQL> drop table Tabla1;

Tabla borrada.
</pre>

¡Vaya! El razonamiento anterior parece que no es del todo cierto, pues la tabla sí ha sido borrada.

¿Pero por qué pasa esto?

Bien, esto se debe a que la orden ejecutada, envía la información al diccionario de datos, donde dicho *tablespace* que lo gestiona, sí tiene permisos de escritura, por lo cual sí permite el borrado de la tabla.


#### Vamos a crear un espacio de tablas 'TS2' con dos ficheros en rutas diferentes de 1M cada uno y no autoextensibles. Crearemos en el tablespace citado una tabla con una cláusula de almacenamiento. Insertaremos registros hasta que se llene el tablespace. ¿Qué ocurrirá?

Vamos a crear el *tablespace* con los dos ficheros y no autoextensibles:

<pre>
SQL> create tablespace TS2
  2  datafile 'ts2.dbf'
  3  size 1M,
  4  'ts2(2).dbf'
  5  size 1M
  6  autoextend off;

Tablespace creado.
</pre>

Una vez creado, vamos a crear una tabla en él con una cláusula de almacenamiento, en mi caso he elegido una *Initial*.

<pre>
SQL> create table Tabla3
  2  (
  3  Campo1 VARCHAR2(100),
  4  Campo2 VARCHAR2(100),
  5  Campo3 VARCHAR2(100),
  6  Campo4 VARCHAR2(100)
  7  )
  8  storage
  9  (
 10  Initial 20K
 11  )
 12  tablespace TS2;

Tabla creada.
</pre>

En este punto, voy a insertar registros hasta que el espacio del *tablespace* se agote.

<pre>
SQL> insert into Tabla3 (Campo1,Campo2,Campo3,Campo4) values('Registro de prueba 1','Registro de prueba 2','Registro de prueba 3','Registro de prueba 4');

1 fila creada.

SQL> insert into Tabla3 (Campo1,Campo2,Campo3,Campo4) values('Registro de prueba 1','Registro de prueba 2','Registro de prueba 3','Registro de prueba 4');
insert into Tabla3 (Campo1,Campo2,Campo3,Campo4) values('Registro de prueba 1','Registro de prueba 2','Registro de prueba 3','Registro de prueba 4')
*
ERROR en lÝnea 1:
ORA-01653: no se ha podido ampliar la tabla SYSTEM.TABLA3 con 128 en el tablespace TS2
</pre>

Tras insertar una serie de registros, podemos ver como me ha devuelto un error. Este error se debe a que el espacio del *tablespace* se ha agotado, y como al crear *TS2* especificamos que no fuera autoextensible, no nos permitirá insertar más datos en dicho *tablespace*.


#### Vamos a realizar una consulta al diccionario de datos que muestre qué índices existen para objetos pertenecientes al esquema de SCOTT y sobre qué columnas están definidos. ¿En qué fichero o ficheros de datos se encuentran las extensiones de sus segmentos correspondientes?

Realizamos la siguiente consulta:

<pre>
SQL> SELECT columns.TABLE_NAME, columns.INDEX_NAME, columns.COLUMN_NAME, files.FILE_NAME
  2  FROM DBA_IND_COLUMNS columns, DBA_EXTENTS extents, DBA_DATA_FILES files
  3  WHERE columns.TABLE_NAME = extents.SEGMENT_NAME
  4  AND extents.FILE_ID = files.FILE_ID
  5  AND columns.TABLE_OWNER='SCOTT';

TABLE_NAME                     INDEX_NAME
------------------------------ ------------------------------
COLUMN_NAME
--------------------------------------------------------------------------------
FILE_NAME
--------------------------------------------------------------------------------
DEPT                           PK_DEPT
DEPTNO
C:\APP\JAVIER\ORADATA\ORCL\USERS01.DBF

EMP                            PK_EMP
EMPNO
C:\APP\JAVIER\ORADATA\ORCL\USERS01.DBF

TABLE_NAME                     INDEX_NAME
------------------------------ ------------------------------
COLUMN_NAME
--------------------------------------------------------------------------------
FILE_NAME
--------------------------------------------------------------------------------

TABLA_ARTICULOS                SYS_C0011484
CODIGO
C:\APP\JAVIER\ORADATA\ORCL\USERS01.DBF

</pre>

Podemos ver los resultados.

## PostgreSQL

#### ¿Existen los conceptos de segmento y de extensión en PostgreSQL, en qué consisten?
#### ¿Cuáles son las diferencias con los conceptos correspondientes de Oracle?

En **Oracle**, la organización del almacenamiento dentro de un *tablespace*, se organiza en **segmentos**, que a su vez, contienen una o varias **extensiones**.

Un *segmento* es un grupo de *extensiones* que forman un objeto de la base de datos, como por ejemplo una tabla o un índice.

Cuando se crea un *segmento* en un *tablespace*, *Oracle* asigna una o varias *extensiones* en alguno de los archivos de datos del *tablespace*. Cuando el espacio inicialmente asignado se agota, *Oracle* asigna una nueva *extensión* al *segmento*, y así sucesivamente.

Las *extensiones* asignadas a un *segmento* están en el *tablespace* de creación del *segmento*, aunque no tienen porque estar juntas, ni en el mismo archivo de datos (si el *tablespace* tuviera varios archivos de datos).

Cuando se elimina un *segmento*, las *extensiones* que ocupa se liberan y vuelven a quedar disponibles.

Este gráfico resume lo explicado:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_almacenamiento_de_bases_de_datos/grafico.ej.postgresql.png" />

Entendido lo que son los *segmentos* y las *extensiones* en *Oracle*, vamos a ver su comportamiento en **PostgreSQL**.

En *PostgreSQL* estos conceptos no existen como en *Oracle*, sino que se comportan de la siguiente manera.

Cada *tablespace* creado se asigna a un subdirectorio del directorio que hayamos definido como directorio de datos (*data_directory*) en la instalación de *PostgreSQL*. (Para consultar cuál es nuestro directorio de datos podemos emplear el siguiente comando: `SHOW data_directory;`).

En dicho directorio del *tablespace* se crearán archivos distintos para cada uno de los *segmentos*. Es decir, cuando se crea un *segmento*, se crea un archivo de datos dentro del directorio asignado al *tablespace*. A este archivo no se le puede indicar el tamaño ni el nombre, y no es compartido por otras tablas.

Respecto a las *extensiones*, no existe tal concepto en *PostgreSQL* como lo conocemos en *Oracle*. Pero sí existe este concepto como librerías o módulos que agregan funcionalidades específicas (se deben instalar con `create extension`).

La única referencia al sistema de almacenamiento, es que la unidad mínima de almacenamiento se denomina *página* o *bloque*. Un *bloque* en *PostgreSQL* ocupa por defecto 8 *kilobytes*.


## MySQL

#### ¿Existe el concepto de espacio de tablas en MySQL?
#### ¿Qué diferencias presentan con los tablespaces de Oracle?

La principal diferencia que presenta *MySQL* en comparación con *Oracle*, es que éste, sólo posee un tipo de motor de almacenamiento, y está pensado para una sola base de datos, al contrario que *MySQL*.

En *MySQL* también disponemos de *tablespaces*, aunque su comportamiento puede variar según el motor de base de datos que escojamos.

Los espacios de tabla (*tablespaces*) son unidades de almacenamiento lógicas de motores de base de datos relacionales como **InnoDB**, que contienen todos los datos del sistema de base de datos. Cada uno de los espacios de tabla contiene como mínimo, un fichero de datos físico del sistema operativo, en el que se almacenan tanto tablas de bases de datos, como índices.

Dentro de los motores de base de datos, me centraré en el más conocido, que es el llamado **InnoDB**. Este motor nos permite controlar la lógica del almacenamiento físico y acceso a los datos. Sus principales ventajas son las siguientes:

- Soporte de transacciones
- Bloqueo de registros
- *Rollback*
- Nos permite tener las características *ACID*, garantizando la integridad de nuestras tablas
- Requiere bastante espacio de disco y bastante RAM
- Aumento de rendimiento a la hora de un uso elevado de sentencias *INSERT* y *UPDATE*

La sintaxis para crear un *tablespace* con *InnoDB* es la siguiente:

<pre>
create tablespace {Nombre tablespace}
	add datafile '{Nombre de archivo}'
	use logfile group logfile_group
	[extent_size [=] extent_size]
	[initial_size [=] initial_size]
	[autoextend_size [=] autoextend_size]
	[max_size [=] max_size]
	[nodegroup [=] nodegroup_id]
	[wait]
	[comment [=] comment_text]
	[engine [=] engine_name]
</pre>

Aunque me haya centrado principalmente en *InnoDB*, en *MySQL*, disponemos de muchos otros motores de almacenamiento, como por ejemplo **MyISAM**. Este motor de base de datos se utiliza para tablas que no requieran muchos espacio en disco ni mucha RAM. Sus principales ventajas son las siguientes:

- Gran velocidad a la hora de recuperar datos
- Recomendable para aplicaciones en las que dominan las sentencias *SELECT* ante los *INSERT/UPDATE*
- Al no tener que hacer comprobaciones de la integridad referencial, ni bloquear las tablas para realizar las operaciones, nos proporciona una mayor velocidad


## MongoDB

#### ¿Existe la posibilidad en MongoDB de decidir en qué archivo se almacena una colección?

En primer lugar, vamos a ver donde guarda *MongoDB* los archivos de la base de datos. Por defecto, se guardan en la ruta que viene establecida en su archivo de configuración llamado `mongod.conf`. En mi caso, al tener instalado *MongoDB* sobre un sistema *Debian*, dicho archivo se encuentra en la ruta `/etc/mongod.conf`. Si nos dirigimos a él, al principio nos encontraremos un bloque como el siguiente:

<pre>
# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb
...
</pre>

Podemos apreciar como nos indica donde se están guardando los datos de nuestra base de datos, en mi caso, la ruta por defecto es `/var/lib/mongodb`. A continuación voy a mostrar una salida del contenido de dicha ruta para comprobar que mis documentos se estén almacenando en tal lugar:

<pre>
root@servidor:~# ls /var/lib/mongodb
collection-0-3377914449258320463.wt   index-1-3763332829671594932.wt   journal
collection-0-3763332829671594932.wt   index-1--575804202552084677.wt   _mdb_catalog.wt
collection-0--575804202552084677.wt   index-1--6595949044337281648.wt  mongod.lock
collection-0--6595949044337281648.wt  index-2--6595949044337281648.wt  sizeStorer.wt
collection-2-3763332829671594932.wt   index-3-3763332829671594932.wt   storage.bson
collection-4-3377914449258320463.wt   index-5-3377914449258320463.wt   WiredTiger
collection-4-3763332829671594932.wt   index-5-3763332829671594932.wt   WiredTigerHS.wt
collection-7-3763332829671594932.wt   index-6-3763332829671594932.wt   WiredTiger.lock
diagnostic.data			      index-8-3763332829671594932.wt   WiredTiger.turtle
index-1-3377914449258320463.wt	      index-9-3763332829671594932.wt   WiredTiger.wt
</pre>

Efectivamente aquí podemos encontrar los distintos documentos.

Bien, ya sabríamos como localizar la ruta donde se están almacenando los datos de nuestra base de datos, pero, ¿y si quisiéramos indicar una nueva ruta para que *MongoDB* almacene una determinada colección?

Esto también es posible en dicho gestor no relacional, y podríamos hacerlo utilizando la herramienta `mongod` mediante el siguiente comando:

<pre>
mongod --dbpath {/ruta_a_almacenar} --fork --logpath {/ruta_a_almacenar/log}
</pre>

Es importante que dicha ruta exista previamente y posea los permisos adecuados para que `mongod` pueda leer y escribir en ella.
