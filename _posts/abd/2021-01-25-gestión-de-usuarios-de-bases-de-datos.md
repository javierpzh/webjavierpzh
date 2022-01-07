---
layout: post
---

## Oracle

**1. Realiza un procedimiento llamado `MostrarObjetosAccesibles` que reciba un nombre de usuario y muestre todos los objetos a los que tiene acceso. (20)**



**2. Realiza un procedimiento que reciba un nombre de usuario, un privilegio y un objeto y nos muestre el mensaje 'SI, DIRECTO' si el usuario tiene ese privilegio sobre objeto concedido directamente, 'SI, POR ROL' si el usuario lo tiene en alguno de los roles que tiene concedidos y un 'NO' si el usuario no tiene dicho privilegio. (25)**



**3. Escribe una consulta que obtenga un *script* para quitar el privilegio de borrar registros en alguna tabla de *SCOTT* a los usuarios que lo tengan. (6)**



**4. Crea un *tablespace* TS2 con tamaño de extensión de 256K. Realiza una consulta que genere un *script* que asigne ese *tablespace* como *tablespace* por defecto a los usuarios que no tienen privilegios para consultar ninguna tabla de *SCOTT*, excepto a *SYSTEM*. (10)**



**5. La vida de un *DBA* es dura. Tras pedirlo insistentemente, en tu empresa han contratado una persona para ayudarte. Decides que se encargará de las siguientes tareas:**

- **Resetear los archivos de *log* en caso de necesidad.**

- **Crear funciones de complejidad de contraseña y asignárselas a usuarios.**

- **Eliminar la información de *rollback*. (este privilegio podrá pasarlo a quien quiera).**

- **Modificar información existente en la tabla dept del usuario scott. (este privilegio podrá pasarlo a quien quiera).**

- **Realizar pruebas de todos los procedimientos existentes en la base de datos.**

- **Poner un *tablespace* fuera de línea.**

**Crea un usuario llamado `Ayudante` y, sin usar los roles predefinidos de *Oracle*, dale los privilegios mínimos para que pueda resolver dichas tareas. (18)**

Pista: Si no recuerdas el nombre de un privilegio, puedes buscarlo en el diccionario de datos.



**6. Muestra el texto de la última sentencia *SQL* que se ejecuto en el servidor, junto con el número de veces que se ha ejecutado desde que se cargó en el *Shared Pool* y el tiempo de CPU empleado en su ejecución. (10)**

<pre>
select distinct sql_text, executions, CPU_TIME
from v$sqlarea
order by first_load_TIME desc
fetch first 1 rows only;
</pre>

**7. Realiza un procedimiento que genere un *script* que cree un rol conteniendo todos los permisos que tenga el usuario cuyo nombre reciba como parámetro, le hayan sido asignados a aquel directamente o a través de roles. El nuevo rol deberá llamarse `BackupPrivsNombreUsuario`. (25)**




## MySQL

**1. Escribe una consulta que obtenga un *script* para quitar el privilegio de borrar registros en alguna tabla de *SCOTT* a los usuarios que lo tengan. (6)**

Creamos las tablas e insertamos los registros en la base de datos **Scott** mediante el siguiente [script](images/abd_gestion_de_usuarios_de_bases_de_datos/scriptcreacionscottmysql.txt).

Comprobamos que se han creado correctamente:

<pre>
MariaDB [scott]> show tables;
+-----------------+
| Tables_in_scott |
+-----------------+
| DEPT            |
| EMP             |
+-----------------+
2 rows in set (0.001 sec)

MariaDB [scott]> select * from DEPT;
+--------+------------+----------+
| DEPTNO | DNAME      | LOC      |
+--------+------------+----------+
|     10 | ACCOUNTING | NEW YORK |
|     20 | RESEARCH   | DALLAS   |
|     30 | SALES      | CHICAGO  |
|     40 | OPERATIONS | BOSTON   |
+--------+------------+----------+
4 rows in set (0.001 sec)
</pre>

Ahora vamos a crear el **script**, para el que realizamos la consulta de la siguiente manera:

<pre>
Select concat('Revoke Delete on ',table_schema,'.',table_name,' from ',grantee,';') as script
from information_schema.table_privileges
where table_schema='scott'
and privilege_type='DELETE';
</pre>

Da como resultado:

<pre>
+-----------------------------------------------+
| script                                        |
+-----------------------------------------------+
| Revoke Delete on scott.DEPT from 'SCOTT'@'%'; |
| Revoke Delete on scott.EMP from 'SCOTT'@'%';  |
+-----------------------------------------------+
2 rows in set (0.00 sec)
</pre>


## PostgreSQL

**1. Escribe una consulta que obtenga un *script* para quitar el privilegio de borrar registros en alguna tabla de *SCOTT* a los usuarios que lo tengan. (6)**

Creamos las tablas e insertamos los registros en la base de datos **Scott** mediante el siguiente [script](images/abd_gestion_de_usuarios_de_bases_de_datos/scriptcreacionscottpostgres.txt).

Comprobamos que se han creado correctamente:

<pre>
scott=> \d
       List of relations
 Schema | Name | Type  | Owner
--------+------+-------+-------
 scott  | dept | table | scott
 scott  | emp  | table | scott
(2 rows)

scott=> select * from dept;
 deptno |   dname    |   loc    
--------+------------+----------
     10 | ACCOUNTING | NEW YORK
     20 | RESEARCH   | DALLAS
     30 | SALES      | CHICAGO
     40 | OPERATIONS | BOSTON
(4 rows)
</pre>

Ahora vamos a crear el **script**, para el que realizamos la consulta de la siguiente manera:

<pre>
select 'Revoke Delete on '||table_catalog||'.'||table_name||' from '||grantee||';'
from information_schema.role_table_grants
where table_catalog='scott'
and privilege_type='DELETE'
and table_schema='scott';
</pre>

Da como resultado:

<pre>
?column?                  
-------------------------------------------
Revoke Delete on scott.dept from scott;
Revoke Delete on scott.emp from scott;
</pre>

## MongoDB

**1. Averigua si existe la posibilidad en *MongoDB* de limitar el acceso de un usuario a los datos de una colección determinada. (6)**

Antes de empezar, me gustaría aclarar el escenario sobre el que estoy trabajando, y se trata del que fue creado en el *post* acerca de la [Instalación de Servidores y Clientes de bases de datos](https://javierpzh.github.io/instalacion-de-servidores-y-clientes-de-bases-de-datos.html), en el apartado de **MongoDB**.

En primer lugar, vamos a crear un usuario llamado **javier_trabajador** que tenga acceso sobre la base de datos **empresa_mongodb**. Para ello, le asignaré un rol `readWrite`.

<pre>
\> db.createUser({user: "javier_trabajador", pwd: "contraseña", roles: ["readWrite"]})
Successfully added user: { "user" : "javier_trabajador", "roles" : [ "readWrite" ] }

\> db.getUser("javier_trabajador")
{
	"_id" : "empresa_mongodb.javier_trabajador",
	"userId" : UUID("71963567-1b0d-469c-9278-a73e2ddc9dd2"),
	"user" : "javier_trabajador",
	"db" : "empresa_mongodb",
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "empresa_mongodb"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}

\>
</pre>

Podemos ver como he creado el nuevo usuario y que efectivamente se le ha asignado el rol que pretendíamos.

Ahora, vamos a comprobar como el usuario **javier_trabajador**, posee acceso a los datos de la base de datos **empresa_mongodb**, en concreto, de la colección **Productos**.

<pre>
vagrant@cliente:~$ mongo --host 192.168.0.39 --authenticationDatabase "empresa_mongodb" -u javier_trabajador -p
MongoDB shell version v4.4.2
Enter password:
connecting to: mongodb://192.168.0.39:27017/?authSource=empresa_mongodb&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("b5895a01-a384-4a58-8003-6530fa3ac687") }
MongoDB server version: 4.4.2

\> use empresa_mongodb
switched to db empresa_mongodb

\> show collections
Empleados
Estudios
Productos

\> db.Productos.find().pretty()
{
	"_id" : ObjectId("5fd10b94364af274079c314b"),
	"Nombre" : "Javi s Phone 1",
	"Tipo" : "Telefono",
	"Descripcion" : "4,7 Pulgadas, Procesador 4 nucleos, 2 GB RAM",
	"Precio" : 175
}
{
	"_id" : ObjectId("5fd10b95364af274079c314c"),
	"Nombre" : "Javi s Phone 2",
	"Tipo" : "Telefono",
	"Descripcion" : "5,8 Pulgadas, Procesador 6 nucleos, 4 GB RAM",
	"Precio" : 390
}
{
	"_id" : ObjectId("5fd10b95364af274079c314d"),
	"Nombre" : "Javi s Phone 3",
	"Tipo" : "Telefono",
	"Descripcion" : "6,1 Pulgadas, Procesador 8 nucleos, 6 GB RAM",
	"Precio" : 600
}
{
	"_id" : ObjectId("5fd10b95364af274079c314e"),
	"Nombre" : "Javi s PC 1",
	"Tipo" : "Ordenador",
	"Descripcion" : "15,7 Pulgadas, Procesador 6 nucleos 12 hilos, 16 GB RAM",
	"Precio" : 950
}
{
	"_id" : ObjectId("5fd10b95364af274079c314f"),
	"Nombre" : "Javi s PC 2",
	"Tipo" : "Ordenador",
	"Descripcion" : "13,7 Pulgadas, Procesador 4 nucleos 8 hilos, 8 GB RAM",
	"Precio" : 450
}

\>
</pre>

Como esperábamos, así es.

Podemos apreciar como esta base de datos incluye tres colecciones (*Empleados*, *Estudios* y *Productos*), pero, ¿qué pasa si deseamos que este usuario pueda acceder a los datos de la colección *Productos*, pero que no tenga acceso a las colecciones *Empleados* y *Estudios*?

En este caso, deberíamos revocarle al usuario, el rol de leer y escribir en esta base de datos, es decir, el rol `readWrite`, ya que éste se asigna a todas las colecciones de la propia base de datos.

<pre>
\> use empresa_mongodb

\> db.revokeRolesFromUser(
   "javier_trabajador",
   [ { "role" : "readWrite", db : "empresa_mongodb" } ]
)

\> db.getUser("javier_trabajador")
{
	"_id" : "empresa_mongodb.javier_trabajador",
	"userId" : UUID("71963567-1b0d-469c-9278-a73e2ddc9dd2"),
	"user" : "javier_trabajador",
	"db" : "empresa_mongodb",
	"roles" : [ ],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}

\>
</pre>

Si ahora intentáramos acceder a los datos de **empresa_mongodb**:

<pre>
vagrant@cliente:~$ mongo --host 192.168.0.39 --authenticationDatabase "empresa_mongodb" -u javier_trabajador -p
MongoDB shell version v4.4.2
Enter password:
connecting to: mongodb://192.168.0.39:27017/?authSource=empresa_mongodb&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("ec7905cb-bf1d-49d3-b13f-9169ee5b59db") }
MongoDB server version: 4.4.2

\> use empresa_mongodb
switched to db empresa_mongodb

\> show collections
Warning: unable to run listCollections, attempting to approximate collection names by parsing connectionStatus

\> db.Productos.find().pretty()
Error: error: {
	"ok" : 0,
	"errmsg" : "not authorized on empresa_mongodb to execute command { find: \"Productos\", filter: {}, lsid: { id: UUID(\"ec7905cb-bf1d-49d3-b13f-9169ee5b59db\") }, $db: \"empresa_mongodb\" }",
	"code" : 13,
	"codeName" : "Unauthorized"
}

\>
</pre>

Lógicamente no tenemos acceso a ninguna de las colecciones.

Para asignarle **privilegios sobre una determinada colección**, podemos crear un **rol definido por el usuario**, es decir, por nosotros mismos.

Esto es lo que vamos a hacer. Como podemos ver a continuación, he creado el rol llamado **rol_acceso_coleccion**, que otorga privilegios de lectura y escritura sobre la colección **Productos** de la base de datos **empresa_mongodb**.

Posteriormente se lo asignamos al usuario **javier_trabajador**.

<pre>
\> db.createRole({role:"rol_acceso_coleccion", privileges:[{resource:{db:"empresa_mongodb", collection: "Productos"}, actions: ["find","remove","insert","update"]}], roles: []})
{
	"role" : "rol_acceso_coleccion",
	"privileges" : [
		{
			"resource" : {
				"db" : "empresa_mongodb",
				"collection" : "Productos"
			},
			"actions" : [
				"find",
				"remove",
				"insert",
				"update"
			]
		}
	],
	"roles" : [ ]
}

\> db.grantRolesToUser(
   "javier_trabajador",
   [ { role : "rol_acceso_coleccion", db : "empresa_mongodb" } ]
)

\> db.getUser("javier_trabajador")
{
	"_id" : "empresa_mongodb.javier_trabajador",
	"userId" : UUID("71963567-1b0d-469c-9278-a73e2ddc9dd2"),
	"user" : "javier_trabajador",
	"db" : "empresa_mongodb",
	"roles" : [
		{
			"role" : "rol_acceso_coleccion",
			"db" : "empresa_mongodb"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}

\>
</pre>

Hecho esto, supuestamente, tendríamos acceso a los datos de la colección *Productos*. Vamos a comprobarlo:

<pre>
vagrant@cliente:~$ mongo --host 192.168.0.39 --authenticationDatabase "empresa_mongodb" -u javier_trabajador -p
MongoDB shell version v4.4.2
Enter password:
connecting to: mongodb://192.168.0.39:27017/?authSource=empresa_mongodb&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("3507c66f-5b8e-47a2-b9c1-47af2739b991") }
MongoDB server version: 4.4.2

\> use empresa_mongodb
switched to db empresa_mongodb

\> show collections
Productos

\> db.Productos.find().pretty()
{
	"_id" : ObjectId("5fd10b94364af274079c314b"),
	"Nombre" : "Javi s Phone 1",
	"Tipo" : "Telefono",
	"Descripcion" : "4,7 Pulgadas, Procesador 4 nucleos, 2 GB RAM",
	"Precio" : 175
}
{
	"_id" : ObjectId("5fd10b95364af274079c314c"),
	"Nombre" : "Javi s Phone 2",
	"Tipo" : "Telefono",
	"Descripcion" : "5,8 Pulgadas, Procesador 6 nucleos, 4 GB RAM",
	"Precio" : 390
}
{
	"_id" : ObjectId("5fd10b95364af274079c314d"),
	"Nombre" : "Javi s Phone 3",
	"Tipo" : "Telefono",
	"Descripcion" : "6,1 Pulgadas, Procesador 8 nucleos, 6 GB RAM",
	"Precio" : 600
}
{
	"_id" : ObjectId("5fd10b95364af274079c314e"),
	"Nombre" : "Javi s PC 1",
	"Tipo" : "Ordenador",
	"Descripcion" : "15,7 Pulgadas, Procesador 6 nucleos 12 hilos, 16 GB RAM",
	"Precio" : 950
}
{
	"_id" : ObjectId("5fd10b95364af274079c314f"),
	"Nombre" : "Javi s PC 2",
	"Tipo" : "Ordenador",
	"Descripcion" : "13,7 Pulgadas, Procesador 4 nucleos 8 hilos, 8 GB RAM",
	"Precio" : 450
}

\> db.Estudios.find().pretty()
Error: error: {
	"ok" : 0,
	"errmsg" : "not authorized on empresa_mongodb to execute command { find: \"Estudios\", filter: {}, lsid: { id: UUID(\"3507c66f-5b8e-47a2-b9c1-47af2739b991\") }, $db: \"empresa_mongodb\" }",
	"code" : 13,
	"codeName" : "Unauthorized"
}

\>
</pre>

Genial, podemos ver como únicamente nos muestra la colección sobre la que poseemos privilegios, por tanto, ya habríamos terminado este apartado.

**2. Averigua si en *MongoDB* existe el concepto de privilegio del sistema y muestra las diferencias más importantes con *Oracle*. (6)**

En **Oracle** existen dos tipos de privilegios de usuario:

- *System*

- *Object*

**System**

Permite al usuario hacer ciertas tareas sobre la base de datos, como por ejemplo crear un *tablespace*. Estos permisos son otorgados por el administrador o por alguien que haya recibido el permiso para administrar ese tipo de privilegio. Existen como 100 tipos distintos de privilegios de este tipo.

En general los permisos de sistema, permiten ejecutar comandos del tipo **DDL**, como *CREATE*, *ALTER* y *DROP* o del tipo **DML**.

Los privilegios de sistema más importantes son: **SYSDBA** y **SYSOPER**, que son dados a usuarios que serán administradores de base de datos.

**Object**

Permite al usuario realizar ciertas acciones en objetos de la base de datos, como una tabla, una vista, un procedimiento, una función, ... Si a un usuario no se le dan estos permisos sólo puede acceder a sus propios objetos.

Este tipo de permisos los da el dueño del objeto, el administrador o alguien que haya recibido este permiso explícitamente.

Por el contrario, en **MongoDB**, no existe el concepto de privilegio como tal, sino que nos encontramos con los determinados **roles**.

¿Y qué son los *roles*?

Un *rol* se define como un conjunto de privilegios. Cuando a un usuario se le asigna un rol, los privilegios de ese rol son accesibles por el usuario.

Un privilegio define una acción o acciones que se pueden efectuar sobre un recurso. Los recursos pueden ser de varios tipos:

- Una base de datos
- Una colección
- Un conjunto de colecciones
- A nivel de *cluster*: representa operaciones sobre el conjunto de réplicas o el *cluster* de *shards*

Un rol puede además heredar privilegios de uno o varios roles.

*MongoDB* dispone de dos tipos de roles:

- **Roles predefinidos en el sistema:** son los que ya se encuentran creados de manera predeterminada y listos para utilizarse.

- **Roles definidos por el usuario:** son los creados por el administrador del sistema.

Una vez explicado como funcionan los privilegios en un gestor y otro, creo que se pueden ver las diferencias más importantes con bastante facilidad, pero por si acaso, voy a poner un ejemplo práctico.

Supongamos que quisiéramos que un usuario pudiera acceder a una tabla, o una colección, de la cuál no es dueño. Por un lado, en *Oracle* nos bastaría con ejecutar una sentencia (*GRANT*) que le permitiera al usuario acceder a ese recurso, y por otro lado, en *MongoDB*, al usuario deberíamos asignarle el rol que poseiera el privilegio adecuado que le permitiera realizar dicha acción en el recurso.

**3. Explica los roles por defecto que incorpora *MongoDB* y como se asignan a los usuarios. (6)**

Como ya sabemos lo qué es un **rol** gracias al apartado anterior, vamos a pasar, en este caso, con los que nos interesan, los **roles predefinidos**.

Dentro de éstos, podemos clasificar los distintos roles en varias categorías.

- Roles de usuarios de bases de datos

- Roles de administradores de base de datos

- Roles de administradores de *cluster*

- Roles de copias de seguridad/restauración

- Roles de superusuarios

Ahora sí, vamos a ver cada uno de los roles que existen en *MongoDB*.

##### Roles de usuarios de bases de datos

- Roles que actúan a nivel de base de datos

    - `read`: permite leer datos de todas las colecciones.

    - `readWrite`: permite leer y escribir datos de todas las colecciones.


##### Roles de administradores de bases de datos

- Roles que actúan a nivel de base de datos

    - `dbAdmin`: permite realizar tareas administrativas.

    - `userAdmin`: permite crear y modificar usuarios y roles en la base de datos actual

    - `dbOwner`: puede efectuar cualquier operación administrativa en la base de datos. Por lo tanto, junta los privilegios de `readWrite`, `dbAdmin` y `userAdmin`.


##### Roles de administradores de *cluster*

- Roles que actúan a nivel de todo el sistema

    - `clusterMonitor`: permite acceso de solo lectura a las herramientas de supervisión.

    - `clusterManager`: permite realizar acciones de administración y monitorización en el *cluster*.

    - `hostManager`: permite monitorizar y administrar servidores.

    - `clusterAdmin`: combina los tres roles anteriores, añadiendo además el rol `dropDatabase`.


##### Roles de copias de seguridad/restauración

- Roles que actúan a nivel de base de datos

    - `backup`: permite realizar copias de seguridad de los datos.

    - `restore`: permite restaurar los datos de las copias de seguridad.


##### Roles de todas las bases de datos

- Roles que actúan a nivel de todas las bases de datos

    - `readAnyDatabase`: es el mismo rol que `read` pero se aplica a todas las bases de datos.

    - `readWriteAnyDatabase`: es el mismo rol que `readWrite` pero se aplica a todas las bases de datos.

    - `userAdminAnyDatabase`: es el mismo rol que `userAdmin` pero se aplica a todas las bases de datos.

    - `dbAdminAnyDatabase`: es el mismo rol que `dbAdmin` pero se aplica a todas las bases de datos.


##### Roles de superusuarios

- No son roles de superusuario directamente, pero pueden asignar a cualquier usuario cualquier privilegio en cualquier base de datos, también ellos mismos.

    - `userAdmin`

    - `dbOwner`

    - `userAdminAnyDatabase`

- Roles que actúan a nivel de todo el sistema

    - `root`: asigna privilegios completos sobre todos los recursos del sistema.


Una vez explicados todos los roles que vienen definidos por defecto en *MongoDB*, vamos a ver como se asignan sobre los usuarios.

Hay que decir que podemos **asignar un rol**, tanto a la hora de crear el usuario, como, con el usuario ya creado con anterioridad.

- **En el momento de crear el usuario**

<pre>
\> use nombrebd

\> db.createUser(
{
   user: "nombreusuario",
   pwd: "contraseña",
   roles: [ { role: "nombredelrol", db: "nombrebd" } ]
})
</pre>

- **Después de haber creado el usuario**

<pre>
\> use nombrebd

\> db.grantRolesToUser(
   "nombreusuario",
   [ { role : "nombredelrol", db : "nombrebd" }, "nombredelrol", … ]
)
</pre>

Bien, ¿y qué pasa si queremos **remover un rol** de un usuario?

Pues para ello, debemos emplear el siguiente comando:

<pre>
\> use nombrebd

\> db.revokeRolesFromUser(
   "nombreusuario",
   [ { role : "nombredelrol", db : "nombrebd" } | "nombredelrol" ]
)
</pre>

Listo.

**4. Explica como puede consultarse el diccionario de datos de *MongoDB* para saber que roles han sido concedidos a un usuario y qué privilegios incluyen. (6)**

Si queremos saber que roles posee un usuario en concreto, podemos hacer uso del siguiente comando:

<pre>
db.getUser("nombreusuario")
</pre>

Por ejemplo, vamos a comprobar que roles se le han concedido al usuario **javier** de mi sistema:

<pre>
\> use admin
switched to db admin

\> db.getUser("javier")
{
	"_id" : "admin.javier",
	"userId" : UUID("3da264ea-1f70-4fdc-8231-82bdc6d70cce"),
	"user" : "javier",
	"db" : "admin",
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}

\>
</pre>

Podemos ver como nos muestra que el usuario **javier**, posee el rol de `root` para la base de datos **admin**.

Bien, ¿y si queremos saber qué privilegios incluye un determinado rol?

Para ello, podemos utilizar el comando:

<pre>
db.system.roles.find("nombredelrol").pretty()
</pre>

Por ejemplo, vamos a comprobar que privilegios incluye el rol **rol_acceso_coleccion** de mi sistema:

<pre>
\> use admin
switched to db admin

\> db.system.roles.find().pretty("rol_acceso_coleccion")
{
	"_id" : "empresa_mongodb.rol_acceso_coleccion",
	"role" : "rol_acceso_coleccion",
	"db" : "empresa_mongodb",
	"privileges" : [
		{
			"resource" : {
				"db" : "empresa_mongodb",
				"collection" : "Productos"
			},
			"actions" : [
				"find",
				"insert",
				"remove",
				"update"
			]
		}
	],
	"roles" : [ ]
}

\>
</pre>

Vemos que incluye privilegios sobre las acciones `find`, `insert`, `remove` y `update`.
