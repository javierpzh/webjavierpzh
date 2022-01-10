---
layout: post
---

Las interconexiones de servidores de bases de datos son operaciones que pueden ser muy útiles en diferentes contextos. Básicamente, se trata de acceder a datos que no están almacenados en nuestra base de datos, pudiendo combinarlos con los que ya tenemos.

En este artículo veremos varias formas de crear un enlace entre distintos servidores de bases de datos. Los servidores enlazados siempre estarán instalados en máquinas diferentes.

Es muy importante recordar que los enlaces son unidireccionales, es decir, si creamos un enlace en el *servidor1* hacia el *servidor2*, será el *servidor1* el que pueda acceder a los datos del *servidor2*, pero el *servidor2* no podrá acceder a los datos del *servidor1*.

Hay que decir que trabajaré sobre los escenarios creados en el *post* anterior, que trataba sobre [Instalación de Servidores y Clientes de bases de datos](https://javierpzh.github.io/instalacion-de-servidores-y-clientes-de-bases-de-datos.html), por lo que ya dispongo de los servidores instalados y con las configuraciones básicas.

#### Enlace entre dos servidores de bases de datos ORACLE

En este primer caso, vamos a ver que configuraciones son necesarias para enlazar dos servidores **Oracle**. Ambos servidores se encuentran instalados sobre *Windows*, aunque esto no es algo que influya en el proceso.

Nos situamos en la primera de las máquinas, que recordemos que recibe el nombre de **servidor**.

Nos dirigiremos a los ficheros `listener.ora` y `tnsnames.ora`, ambos se encuentran en la ruta `$ORACLE_HOME/network/admin/`, ya que en ellos es donde realizaremos la configuración.

Primeramente, para habilitar el acceso remoto al servidor, debemos modificar el fichero `listener.ora`. Por defecto, posee este aspecto:

<pre>
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = CLRExtProc)
      (ORACLE_HOME = C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home)
      (PROGRAM = extproc)
      (ENVS = "EXTPROC_DLLS=ONLY:C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\bin\oraclr19.dll")
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
</pre>

Si nos fijamos, dentro del bloque **LISTENER**, en la línea que define la regla para el protocolo *TCP*, que es la que nos interesa, podemos ver que en el campo **HOST** está configurado para que solo escuche las peticiones cuyo origen es **localhost**. También está configurado para que el puerto por el que escuche sea el **1521**, que es el que viene configurado por defecto, a mí me vale, por eso lo dejo. Obviamente lo que hay que cambiar es el valor del campo **HOST**, y establecerle como valor la interfaz desde la que queremos escuchar las peticiones. En mi caso, voy a especificar el **nombre de mi máquina** para que así escuche todas las peticiones.

<pre>
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = CLRExtProc)
      (ORACLE_HOME = C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home)
      (PROGRAM = extproc)
      (ENVS = "EXTPROC_DLLS=ONLY:C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\bin\oraclr19.dll")
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = DESKTOP-IGG1O7P)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
</pre>

Una vez hemos realizado este cambio, podemos iniciar el *listener*. El *listener* se maneja con estos comandos:

- **lsnrctl start:** inicia el servicio.
- **lsnrctl stop:** detiene el servicio.
- **lsnrctl status:** muestra información sobre el estado.

Lo iniciamos:

<pre>
C:\Windows\System32>lsnrctl start

LSNRCTL for 64-bit Windows: Version 19.0.0.0.0 - Production on 17-DIC-2020 14:07:48

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Iniciando tnslsnr: espere...

TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
El archivo de parßmetros del sistema es C:\Users\javier\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Mensajes de log escritos en C:\Users\javier\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))

Conectßndose a (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
ESTADO del LISTENER
------------------------
Alias                     LISTENER
Versi¾n                   TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
Fecha de Inicio       28-ENE-2020 14:07:52
Tiempo Actividad   0 dÝas 0 hr. 0 min. 10 seg.
Nivel de Rastreo        off
Seguridad               ON: Local OS Authentication
SNMP                      OFF
Parßmetros del Listener   C:\Users\javier\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Log del Listener          C:\Users\javier\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo Resumen de Puntos Finales...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))
Resumen de Servicios...
El servicio "CLRExtProc" tiene 1 instancia(s).
  La instancia "CLRExtProc", con estado UNKNOWN, tiene 1 manejador(es) para este servicio...
El comando ha terminado correctamente
</pre>

Vemos que lo ha iniciado correctamente. Ahora, para asegurarnos que realmente está escuchando peticiones desde el puerto *1521* vamos a utilizar el comando `netstat`:

<pre>
C:\Users\servidor>netstat

Conexiones activas

  Proto  Dirección local        Dirección remota       Estado
  TCP    127.0.0.1:1521         DESKTOP-IGG1O7P:49692  ESTABLISHED
  TCP    127.0.0.1:49692        DESKTOP-IGG1O7P:1521   ESTABLISHED
  TCP    [fe80::c9ee:eb4d:5f0b:a64f%4]:49703  DESKTOP-IGG1O7P:1521   TIME_WAIT
</pre>

Vemos que efectivamente está escuchando en dicho puerto.

Hecho esto, ya habríamos habilitado al servidor para que permita el acceso remoto, por tanto, vamos a dirigirnos al segundo y último fichero de configuración, el llamado `tnsnames.ora`, que por defecto posee esta configuración:

<pre>
LISTENER_ORCL =
  (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))


ORACLR_CONNECTION_DATA =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
    (CONNECT_DATA =
      (SID = CLRExtProc)
      (PRESENTATION = RO)
    )
  )

ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )
</pre>

Editaremos el último bloque que definirá la conexión con el segundo servidor *Oracle*, quedando de esta manera:

<pre>
ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.56)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )
</pre>

Una vez modificado este fichero, debemos parar el proceso **listener** y volverlo a iniciar para que así se apliquen los nuevos cambios.

<pre>
C:\Windows\system32>lsnrctl stop

LSNRCTL for 64-bit Windows: Version 19.0.0.0.0 - Production on 03-FEB-2021 17:53:36

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Conectßndose a (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
El comando ha terminado correctamente

C:\Windows\system32>lsnrctl start

LSNRCTL for 64-bit Windows: Version 19.0.0.0.0 - Production on 03-FEB-2021 17:53:58

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Iniciando tnslsnr: espere...

TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
El archivo de parßmetros del sistema es C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Mensajes de log escritos en C:\Users\servidor\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))

Conectßndose a (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
ESTADO del LISTENER
------------------------
Alias                     LISTENER
Versi¾n                   TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
Fecha de Inicio       03-FEB-2021 17:54:02
Tiempo Actividad   0 dÝas 0 hr. 0 min. 10 seg.
Nivel de Rastreo        off
Seguridad               ON: Local OS Authentication
SNMP                      OFF
Parßmetros del Listener   C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Log del Listener          C:\Users\servidor\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo Resumen de Puntos Finales...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))
Resumen de Servicios...
El servicio "CLRExtProc" tiene 1 instancia(s).
  La instancia "CLRExtProc", con estado UNKNOWN, tiene 1 manejador(es) para este servicio...
El comando ha terminado correctamente

C:\Windows\system32>
</pre>

Bien, ahora debemos dirigirnos al **segundo servidor**, que es al que vamos a realizarle la consulta, y en su fichero `listener.ora`, habilitar el acceso remoto como hicimos anteriormente:

<pre>
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = CLRExtProc)
      (ORACLE_HOME = C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home)
      (PROGRAM = extproc)
      (ENVS = "EXTPROC_DLLS=ONLY:C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\bin\oraclr19.dll")
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = DESKTOP-IGG1O7P)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
</pre>

Cuando hayamos realizado la modificación, iniciaremos de nuevo el **listener** y aplicaremos los cambios:

<pre>
C:\Windows\system32>lsnrctl start

LSNRCTL for 64-bit Windows: Version 19.0.0.0.0 - Production on 03-FEB-2021 18:02:49

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Iniciando tnslsnr: espere...

TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
El archivo de parßmetros del sistema es C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Mensajes de log escritos en C:\Users\servidor\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))

Conectßndose a (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
ESTADO del LISTENER
------------------------
Alias                     LISTENER
Versi¾n                   TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
Fecha de Inicio       03-FEB-2021 18:02:55
Tiempo Actividad   0 dÝas 0 hr. 0 min. 12 seg.
Nivel de Rastreo        off
Seguridad               ON: Local OS Authentication
SNMP                      OFF
Parßmetros del Listener   C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Log del Listener          C:\Users\servidor\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo Resumen de Puntos Finales...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))
Resumen de Servicios...
El servicio "CLRExtProc" tiene 1 instancia(s).
  La instancia "CLRExtProc", con estado UNKNOWN, tiene 1 manejador(es) para este servicio...
El comando ha terminado correctamente
</pre>

Cuando ya poseamos todas las configuraciones listas, vamos a proceder a crear la conexión entre los servidores.

Pero antes de esto, voy a crear un usuario y alguna tabla que poder consultar, ya que este servidor, es totalmente virgen, por decirlo de alguna forma:

<pre>
C:\Windows\system32>sqlplus

SQL*Plus: Release 19.0.0.0.0 - Production on MiÚ Feb 3 18:06:19 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Introduzca el nombre de usuario: system
Introduzca la contrase±a:
Hora de ┌ltima Conexi¾n Correcta: Jue Ene 28 2021 18:56:11 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> CREATE USER c##javierserv2 IDENTIFIED BY contraseña;

Usuario creado.

SQL> GRANT ALL PRIVILEGES TO c##javierserv2;

Concesi¾n terminada correctamente.
</pre>

Vamos a crear la tabla **Empleados**, que será la que consultaremos luego a partir de este [script](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_interconexiones_de_servidores_de_bases_de_datos/scriptoracle.txt).

Ahora sí, vamos a crear el propio enlace.

Para ello nos dirigimos al **primer servidor** y con el usuario **sys**, crearemos el enlace hacia el segundo servidor.

La sintaxis para crear un enlace es la siguiente:

<pre>
create database link linkserv2
connect to c##javierserv2
identified by contraseña
using 'orcl';
</pre>

Vemos el resultado de la creación del enlace:

<pre>
C:\Windows\system32>sqlplus

SQL*Plus: Release 19.0.0.0.0 - Production on MiÚ Feb 3 18:07:21 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Introduzca el nombre de usuario: system
Introduzca la contrase±a:
Hora de ┌ltima Conexi¾n Correcta: Mar Ene 19 2021 19:32:59 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> create database link linkserv2
  2  connect to c##javierserv2
  3  identified by contraseña
  4  using 'orcl';

Enlace con la base de datos creado.
</pre>

Vamos a probar a hacer una consulta desde el primer servidor a la tabla **Empleados** que acabamos de crear y se encuentra en el segundo servidor:

<pre>
SQL> select * from empleados@linkserv2;

NIF
---------
NOMBRE
--------------------------------------------------------------------------------
ANYONACIMIENTO COD_TI
-------------- ------
12345678A
Rodrigo Fernandez
          1974 000001

12345678B
Cristina Perez
          1976 000002

NIF
---------
NOMBRE
--------------------------------------------------------------------------------
ANYONACIMIENTO COD_TI
-------------- ------

12345678C
Ramon Fuentes
          1983 000003

12345678D
Maria Diaz

NIF
---------
NOMBRE
--------------------------------------------------------------------------------
ANYONACIMIENTO COD_TI
-------------- ------
          1969 000004

12345678E
Alejandro Cortes
          1978 000005
</pre>

¡Bien! Ya tenemos el enlace creado y utilizable, y por último vamos a realizar una consulta combinada que una la tabla **Tiendas** (tabla almacenada en el primer servidor) y la tabla **Empleados** (tabla almacenada en el segundo servidor):

<pre>
SQL> SELECT Tiendas.Codigo AS Codigo, Tiendas.Nombre AS NombreTienda, Tiendas.Especialidad AS Especialidad, Tiendas.Localizacion AS Localizacion, Empleados.NIF AS NIF, Empleados.Nombre AS NombreEmpleado, Empleados.AnyoNacimiento AS AnyoNacimiento, Empleados.Cod_Tienda AS Cod_Tienda
  2  FROM Tiendas, Empleados@linkserv2 Empleados
  3  WHERE Tiendas.Codigo = Empleados.Cod_Tienda;

CODIGO NOMBRETIENDA         ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
---------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO COD_TI
-------------- ------
000001 Javi s Pet           Animales   Sevilla
12345678A
Rodrigo Fernandez
          1974 000001


CODIGO NOMBRETIENDA         ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
---------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO COD_TI
-------------- ------
000002 Javi s Sport         Deportes   Cordoba
12345678B
Cristina Perez
          1976 000002


CODIGO NOMBRETIENDA         ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
---------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO COD_TI
-------------- ------
000003 Javi s Food          Comida     Granada
12345678C
Ramon Fuentes
          1983 000003


CODIGO NOMBRETIENDA         ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
---------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO COD_TI
-------------- ------
000004 Javi s Technology    Tecnologia Cadiz
12345678D
Maria Diaz
          1969 000004


CODIGO NOMBRETIENDA         ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
---------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO COD_TI
-------------- ------
000005 Javi s Clothes       Ropa       Huelva
12345678E
Alejandro Cortes
          1978 000005
</pre>

(El resultado de la consulta no tiene mucho sentido, pero lo importante es mostrar el funcionamiento).

Como hemos visto, hemos podido realizar la consulta correctamente, por lo que habríamos terminado este ejercicio.


#### Enlace entre dos servidores de bases de datos PostgreSQL

En este apartado vamos a realizar un enlace entre dos servidores **PostgreSQL**. Ambos servidores se encuentran instalados sobre *Debian*, aunque esto no es algo que influya en el proceso.

*PostgreSQL* hace uso de la extensión `dblink` para realizar o aceptar consultas desde enlaces, por lo que debemos instalar esta herramienta que se encuentra en el paquete llamado `postgresql-contrib`

<pre>
apt install postgresql-contrib -y
</pre>

Hecho esto, procederemos a editar el fichero de configuración de ambos servidores `/etc/postgresql/XXX/main/postgresql.conf`, y en él descomentaremos la línea llamada `listen_addresses`. Como valor le estableceremos la IP que nos interese que escuche nuestro servidor, en mi caso introduzco el valor ***** para que así escuche cualquier petición. De manera que la línea resultante sería la siguiente:

<pre>
listen_addresses = '*'
</pre>

Como segunda modificación, que también debe realizarse en ambos servidores, tenemos que dirigirnos al fichero `/etc/postgresql/XXX/main/pg_hba.conf` y buscar la siguiente línea:

<pre>
host    all             all             127.0.0.1/32            md5
</pre>

Esta línea actualmente define que no se permita la conexión remota, ya que por defecto solo escucha peticiones de *localhost*. Por tanto cambiamos este valor, en mi caso especifico que escuche peticiones desde cualquier interfaz, y la línea queda de esta manera:

<pre>
host    all             all             0.0.0.0/0            md5
</pre>

Realizados los cambios, vamos a reiniciar los servicios de los dos servidores para así aplicar los nuevos cambios:

<pre>
systemctl restart postgresql
</pre>

Ya tenemos ambos servidores configurados correctamente y tan solo nos faltaría crear el enlace desde el primer servidor al segundo, y al revés.

Para ello, antes, voy a crear en ambos servidores un usuario llamado **javierservX**, y una base de datos de prueba llamada **empresaX**, en la que introduciré algunos registros de prueba.

<pre>
root@servidor:~# su - postgres

postgres@servidor:~$ psql postgres
psql (11.9 (Debian 11.9-0+deb10u1))
Type "help" for help.

postgres=# CREATE USER javierserv1 WITH PASSWORD 'contraseña';
CREATE ROLE

postgres=# CREATE DATABASE empresa1;
CREATE DATABASE

postgres=# GRANT ALL PRIVILEGES ON DATABASE empresa1 TO javierserv1;
GRANT

postgres=# exit

--------------------------------------------------------------------------------

root@cliente:~# su - postgres

postgres@cliente:~$ psql postgres
psql (11.9 (Debian 11.9-0+deb10u1))
Type "help" for help.

postgres=# CREATE USER javierserv2 WITH PASSWORD 'contraseña';
CREATE ROLE

postgres=# CREATE DATABASE empresa2;
CREATE DATABASE

postgres=# GRANT ALL PRIVILEGES ON DATABASE empresa2 TO javierserv2;
GRANT

postgres=# exit
</pre>

Una vez creados ambos usuarios y ambas bases de datos, inserto una serie de tablas con sus respectivos registros. Puedes encontrar la información [aquí](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_interconexiones_de_servidores_de_bases_de_datos/scriptpostgresql.txt).

Hecho esto, llegó el momento de crear los enlaces entre ambos servidores. Los enlaces deben crearse con el usuario administrador **postgres** ya que es el usuario que posee los permisos para ello, y deben crearse en las bases de datos **empresaX**, ya que los usuarios **javierservX**, solo poseen permisos sobre ellas.

Explicado esto, en primer lugar, crearemos el enlace desde el primer servidor hacia el segundo:

<pre>
postgres@servidor:~$ psql postgres
psql (11.9 (Debian 11.9-0+deb10u1))
Type "help" for help.

postgres=# \c empresa1
You are now connected to database "empresa1" as user "postgres".

empresa1=# CREATE EXTENSION dblink;
CREATE EXTENSION

empresa1=# exit
</pre>

Y ahora al revés, desde el segundo hacia el primero:

<pre>
postgres@cliente:~$ psql postgres
psql (11.9 (Debian 11.9-0+deb10u1))
Type "help" for help.

postgres=# \c empresa2
You are now connected to database "empresa2" as user "postgres".

empresa2=# CREATE EXTENSION dblink;
CREATE EXTENSION

empresa2=# exit
</pre>

En principio ya estaría todo listo, así que vamos a probarlo. Empezaremos haciendo una consulta desde el *servidor1* hacia el *servidor2*:

<pre>
postgres@servidor:~$ psql -h 127.0.0.1 -U javierserv1 -d empresa1
Password for user javierserv1:
psql (11.9 (Debian 11.9-0+deb10u1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

empresa1=> select * from dblink('dbname=empresa2 host=192.168.0.44 user=javierserv2 password=contraseña', 'select * from Empleados') AS Empleados (NIF VARCHAR, Nombre VARCHAR, AnyoNacimiento NUMERIC, Cod_Tienda VARCHAR);
    nif    |      nombre       | anyonacimiento | cod_tienda
-----------+-------------------+----------------+------------
 12345678A | Rodrigo Fernandez |           1974 | 000001
 12345678B | Cristina Perez    |           1976 | 000002
 12345678C | Ramon Fuentes     |           1983 | 000003
 12345678D | Maria Diaz        |           1969 | 000004
 12345678E | Alejandro Cortes  |           1978 | 000005
(5 rows)
</pre>

Vemos que nos muestra la información correctamente. Pero, ¿y si quisiéramos unir una consulta de la tabla del primer servidor y de la tabla del segundo servidor? Pues vamos a ver si podríamos hacerlo:

<pre>
postgres@servidor:~$ psql -h 127.0.0.1 -U javierserv1 -d empresa1
Password for user javierserv1:
psql (11.9 (Debian 11.9-0+deb10u1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

empresa1=> select Tiendas.Codigo AS Codigo, Tiendas.Nombre AS NombreTienda, Tiendas.Especialidad AS Especialidad, Tiendas.Localizacion AS Localizacion, Empleados.NIF AS NIF, Empleados.Nombre AS NombreEmpleado, Empleados.AnyoNacimiento AS AnyoNacimiento, Empleados.Cod_Tienda AS Cod_Tienda

empresa1-> from Tiendas, dblink('dbname=empresa2 host=192.168.0.44 user=javierserv2 password=contraseña', 'select * from Empleados') AS Empleados (NIF VARCHAR, Nombre VARCHAR, AnyoNacimiento NUMERIC, Cod_Tienda VARCHAR)

empresa1-> where Tiendas.Codigo=Empleados.Cod_Tienda;

 codigo |   nombretienda    | especialidad | localizacion |    nif    |  nombreempleado   | anyonacimiento | cod_tienda
--------+-------------------+--------------+--------------+-----------+-------------------+----------------+------------
 000001 | Javi s Pet        | Animales     | Sevilla      | 12345678A | Rodrigo Fernandez |           1974 | 000001
 000002 | Javi s Sport      | Deportes     | Cordoba      | 12345678B | Cristina Perez    |           1976 | 000002
 000003 | Javi s Food       | Comida       | Granada      | 12345678C | Ramon Fuentes     |           1983 | 000003
 000004 | Javi s Technology | Tecnologia   | Cadiz        | 12345678D | Maria Diaz        |           1969 | 000004
 000005 | Javi s Clothes    | Ropa         | Huelva       | 12345678E | Alejandro Cortes  |           1978 | 000005
(5 rows)

</pre>

Efectivamente podemos unir ambas consultas, ¡esto es maravilloso!

(El resultado de la consulta no tiene mucho sentido, pero lo importante es mostrar el funcionamiento).

Para terminar con este apartado, haremos la misma consulta pero esta vez desde el segundo servidor, y de esta manera asegurarnos que ambos enlaces funcionan.

<pre>
postgres@cliente:~$ psql -h 127.0.0.1 -U javierserv2 -d empresa2
Password for user javierserv2:
psql (11.9 (Debian 11.9-0+deb10u1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

empresa2=> select Tiendas.Codigo AS Codigo, Tiendas.Nombre AS NombreTienda, Tiendas.Especialidad AS Especialidad, Tiendas.Localizacion AS Localizacion, Empleados.NIF AS NIF, Empleados.Nombre AS NombreEmpleado, Empleados.AnyoNacimiento AS AnyoNacimiento, Empleados.Cod_Tienda AS Cod_Tienda

empresa2-> from Empleados, dblink('dbname=empresa1 host=192.168.0.43 user=javierserv1 password=contraseña', 'select * from Tiendas') AS Tiendas (Codigo VARCHAR, Nombre VARCHAR, Especialidad VARCHAR, Localizacion VARCHAR)

empresa2-> where Empleados.Cod_Tienda=Tiendas.Codigo;

codigo |   nombretienda    | especialidad | localizacion |    nif    |  nombreempleado   | anyonacimiento | cod_tienda
--------+-------------------+--------------+--------------+-----------+-------------------+----------------+------------
000001 | Javi s Pet        | Animales     | Sevilla      | 12345678A | Rodrigo Fernandez |           1974 | 000001
000002 | Javi s Sport      | Deportes     | Cordoba      | 12345678B | Cristina Perez    |           1976 | 000002
000003 | Javi s Food       | Comida       | Granada      | 12345678C | Ramon Fuentes     |           1983 | 000003
000004 | Javi s Technology | Tecnologia   | Cadiz        | 12345678D | Maria Diaz        |           1969 | 000004
000005 | Javi s Clothes    | Ropa         | Huelva       | 12345678E | Alejandro Cortes  |           1978 | 000005
(5 rows)
</pre>

Lógicamente funciona igualmente, por lo que este apartado habría terminado.


#### Enlace entre un servidor ORACLE y un servidor PostgreSQL empleando Heterogeneus Services

En este último caso, vamos a enlazar un servidor **Oracle** y otro **PostgreSQL**. El servidor *Oracle* se encuentra instalado sobre un sistema *CentOS* y el servidor *PostgreSQL*, sobre *Debian* (es el que he utilizado en el apartado anterior), aunque esto no es algo que influya en el proceso.

Algo importante es que, ambos servidores ya están configurados previamente y permiten conexiones remotas.

##### ORACLE a PostgreSQL

Nos situamos en la máquina que contiene el servidor **Oracle**.

El primer paso que debemos realizar consiste en instalar el paquete `unixODBC`, que contiene el *software* necesario para crear dicho enlace, y junto a él, el *driver* específico llamado `postgresql-odbc`:

<pre>
[root@servidororacle ~]# dnf install unixODBC postgresql-odbc -y
</pre>

Una vez instalados, procederemos a visualizar el fichero de configuración `/etc/odbcinst.ini`. En él podremos apreciar todos los *drivers* existentes, pero en nuestra caso nos interesa el que hace referencia a *PostgreSQL*.

El próximo paso consiste en la creación del fichero `/etc/odbc.ini`, ya que dicho fichero será el utilizado para determinar la manera de conectarse al servidor *PostgreSQL*. En él introduciremos el siguiente contenido:

<pre>
[PSQLU]
Debug = 0
CommLog = 0
ReadOnly = 0
Driver = PostgreSQL
Servername = 192.168.0.43
Username = javierserv1
Password = contraseña
Port = 5432
Database = empresa1
Trace = 0
TraceFile = /tmp/sql.log
</pre>

Las informaciones como pueden ser **Servername**, **Username**, **Password**, **Port** y **Database**, hacen referencia al servidor al que nos vamos a conectar, por lo que debemos introducir nuestros datos de *PostgreSQL*.

Creado este fichero, habríamos terminado la configuración del *driver* de *ODBC*. Para comprobar que el funcionamiento es el correcto, podemos hacer uso del comando `isql`, como vemos a continuación:

<pre>
[root@servidororacle ~]# isql PSQLU
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
SQL>
</pre>

Vemos como se nos abre una especie de cliente en el que podemos ejecutar órdenes *SQL*:

<pre>
SQL> select * from empleados;
+----------+-------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+-----------+
| nif      | nombre                                                                                                                                                | anyonacimiento| cod_tienda|
+----------+-------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+-----------+
| 12345678A| Rodrigo Fernandez                                                                                                                                     | 1974          | 000001    |
| 12345678B| Cristina Perez                                                                                                                                        | 1976          | 000002    |
| 12345678C| Ramon Fuentes                                                                                                                                         | 1983          | 000003    |
| 12345678D| Maria Diaz                                                                                                                                            | 1969          | 000004    |
| 12345678E| Alejandro Cortes                                                                                                                                      | 1978          | 000005    |
+----------+-------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+-----------+
SQLRowCount returns 5
5 rows fetched
</pre>

Parece que la conexión hacia el servidor *PostgreSQL* es correcta, así que ahora sería el turno de configurar *Oracle* para utilizar este *driver*.

Para ello debemos crear el fichero `initPSQLU.ora`, en el que tendremos que especificar los parámetros que veremos a continuación. Este fichero debemos crearlo en la ruta `/opt/oracle/product/19c/dbhome_1/hs/admin/initPSQLU.ora` y su contenido sería el siguiente:

<pre>
HS_FDS_CONNECT_INFO = PSQLU
HS_FDS_TRACE_LEVEL = DEBUG
HS_FDS_SHAREABLE_NAME = /usr/lib64/psqlodbcw.so
HS_LANGUAGE = AMERICAN_AMERICA.WE8ISO8859P1
set ODBCINI=/etc/odbc.ini
</pre>

Podemos apreciar que hemos definido varios parámetros que hacen referencia al *driver* configurado anteriormente, al fichero que define la conexión con *PostgreSQL*, ...

Tras ello, ya estaría todo listo para dirigirnos a los ficheros `listener.ora` y `tnsnames.ora`, ambos se encuentran en la ruta `/opt/oracle/product/19c/dbhome_1/network/admin/`, y en ellos es donde realizaremos las siguientes configuraciones.

Primeramente, debemos modificar el fichero `listener.ora` y añadir la siguiente entrada:

<pre>
SID_LIST_LISTENER=
 (SID_LIST=
   (SID_DESC=
     (SID_NAME=PSQLU)
     (ORACLE_HOME=/opt/oracle/product/19c/dbhome_1)
     (PROGRAM=dg4odbc)
   )
 )
</pre>

Hecho esto, vamos a dirigirnos al segundo y último fichero de configuración, el llamado `tnsnames.ora`, que por defecto posee esta configuración:

<pre>
ORCLCDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = servidororacle)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )

LISTENER_ORCLCDB =
  (ADDRESS = (PROTOCOL = TCP)(HOST = servidororacle)(PORT = 1521))
</pre>

Añadiremos este último bloque:

<pre>
PSQLU =
  (DESCRIPTION=
     (ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521))
     (CONNECT_DATA=(SID=PSQLU))
     (HS=OK)
  )
</pre>

Una vez hemos realizado todos los cambios, podemos iniciar el *listener*. El *listener* se maneja con estos comandos:

- **lsnrctl start:** inicia el servicio.
- **lsnrctl stop:** detiene el servicio.
- **lsnrctl status:** muestra información sobre el estado.

Lo iniciamos:

<pre>
[oracle@servidororacle ~]$ lsnrctl start

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 18-FEB-2021 20:35:40

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Starting /opt/oracle/product/19c/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/servidororacle/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=servidororacle)(PORT=1521)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=servidororacle)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                18-FEB-2021 20:35:40
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/servidororacle/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=servidororacle)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
Services Summary...
Service "PSQLU" has 1 instance(s).
  Instance "PSQLU", status UNKNOWN, has 1 handler(s) for this service...
The command completed successfully
</pre>

Vemos que lo ha iniciado correctamente.

Cuando ya poseemos todas las configuraciones listas, procederemos a crear la conexión entre los servidores.

Pero antes de esto, voy a crear un usuario:

<pre>
[oracle@servidororacle ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Thu Feb 18 19:39:08 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> CREATE USER c##javier1 IDENTIFIED BY contraseña;

Usuario creado.

SQL> GRANT ALL PRIVILEGES TO c##javier1;

Concesion terminada correctamente.
</pre>

Ahora sí, vamos a crear el propio enlace.

Para ello accederemos con el nuevo usuario **c##javier1** y crearemos el enlace hacia el servidor *PostgreSQL*.

La sintaxis para crear un enlace es la siguiente:

<pre>
create database link linkservpostgresql
connect to "javierserv1"
identified by "contraseña"
using 'PSQLU';
</pre>

**NOTA:** Es importante utilizar comillas dobles para el nombre de usuario y la contraseña, y comillas simples para el nombre del alias.

El usuario y la contraseña hacen referencia a las credenciales de la base de datos remota.

Vemos el resultado de la creación del enlace:

<pre>
[oracle@servidororacle ~]$ sqlplus c##javier1

SQL*Plus: Release 19.0.0.0.0 - Production on Thu Feb 18 20:42:15 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Enter password:
Hora de Ultima Conexion Correcta: Jue Feb 18 2021 20:38:21 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> create database link linkservpostgresql
  2  connect to "javierserv1"
  3  identified by "contraseña"
  4  using 'PSQLU';

Enlace con la base de datos creado.
</pre>

Con esto, habríamos terminado la creación del enlace.

Vamos a probarlo haciendo una consulta sencilla:

<pre>
SQL> select "nombre" from "empleados"@linkservpostgresql;

nombre
--------------------------------------------------------------------------------
Rodrigo Fernandez
Cristina Perez
Ramon Fuentes
Maria Diaz
Alejandro Cortes
</pre>

Obviamente, gracias a este enlace también podremos realizar consultas combinadas, es decir, que incluyan informaciones de ambos servidores, vamos a verlo haciendo una consulta a la tabla **Tiendas**(tabla almacenada en el primer servidor) y la tabla **Empleados** (tabla almacenada en el segundo servidor):

<pre>
SQL> SELECT Tiendas.Codigo AS Codigo, Tiendas.Nombre AS NombreTienda, Tiendas.Especialidad AS Especialidad, Tiendas.Localizacion AS Localizacion, Empleados."nif" AS NIF, Empleados."nombre" AS NombreEmpleado, Empleados."anyonacimiento" AS AnyoNacimiento, Empleados."cod_tienda" AS Cod_Tienda
  2  FROM Tiendas, "empleados"@linkservpostgresql Empleados
  3  WHERE Tiendas.Codigo = Empleados."cod_tienda";

CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
000001 Javi s Pet	    Animales   Sevilla
12345678A
Rodrigo Fernandez

CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
	  1974
000001


CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
000002 Javi s Sport	    Deportes   Cordoba
12345678B
Cristina Perez

CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
	  1976
000002


CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
000003 Javi s Food	    Comida     Granada
12345678C
Ramon Fuentes

CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
	  1983
000003


CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
000004 Javi s Technology    Tecnologia Cadiz
12345678D
Maria Diaz

CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
	  1969
000004


CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
000005 Javi s Clothes	    Ropa       Huelva
12345678E
Alejandro Cortes

CODIGO NOMBRETIENDA	    ESPECIALID LOCALIZACION
------ -------------------- ---------- ----------------------------------------
NIF
--------------------------------------------------------------------------------
NOMBREEMPLEADO
--------------------------------------------------------------------------------
ANYONACIMIENTO
--------------
COD_TIENDA
------------------------------------------------------------------------
	  1978
000005
</pre>

(El resultado de la consulta no tiene mucho sentido, pero lo importante es mostrar el funcionamiento).

Podemos apreciar como efectivamente podemos realizar la consulta correctamente.

##### PostgreSQL a ORACLE

Nos situamos en la máquina que contiene el servidor **PostgreSQL**.

El primer paso que debemos realizar consiste en la instalación de un ***Data Wrappers***, pero, ¿qué son estos *Data Wrappers*? Pues son una especie de extensiones que permiten conectar servidores *PostgreSQL* con otros gestores de bases de datos, como pueden ser *Oracle*, *MySQL* o *MongoDB*. En el caso de *Oracle*, que es el que nos interesa, podemos recurrir al paquete `oracle_fdw`.


















































.
