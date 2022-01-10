---
layout: post
---

En este artículo aprenderemos la instalación y configuración de distintos servidores y clientes de bases de datos.

#### Instalación de un servidor de ORACLE 19c y prueba desde un cliente remoto de SQL*Plus

Vamos a llevar a cabo la instalación de **Oracle** en su versión **19c**. Esta instalación se hará sobre un sistema **Windows 10**, que se ejecutará en una máquina virtual conectada en modo puente a mi red local.

Esta máquina *servidor* posee la IP **192.168.0.55**.

Lo primero que debemos hacer, sería descargarnos el paquete de instalación desde la [web oficial de Oracle](https://www.oracle.com/es/database/technologies/oracle-database-software-downloads.html#19c), para realizar la descarga nos hará falta estar registrados como usuarios de *Oracle*.

Una vez descargado el archivo *.zip*, tenemos que extraerlo y ahora empezaremos el proceso de instalación.

Debemos buscar en el directorio resultante este ejecutable llamado **setup**:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/oracle_setup.png" />

Lo abrimos con permisos de administrador y se nos abrirá esta ventana que quedará cargando:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/oracle_setupcargando.png" />

Una vez haya terminado de cargar el instalador de *Oracle*, se nos abrirá este asistente en el que configuraremos todos los parámetros de los que queremos disponer en nuestro nuevo servidor de base de datos.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/oracle_instalacion1.png" />

Seleccionamos de que tipo de sistema queremos disponer, en mi caso, selecciono la *clase de escritorio* ya que, si seleccionara la *case servidor*, el propio *Oracle* nos realizaría todo el proceso de configuración para el acceso remoto, y esto prefiero mostrar como hacerlo manualmente.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/oracle_instalacion2.png" />

Este paso es bastante importante, pues debemos establecer la contraseña de administrador que poseerá nuestro nuevo *Oracle*:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/oracle_instalacion4.png" />

En este punto, nos redacta un resumen de las preferencias que hemos escogido, y después de esto, ya comenzará el proceso de instalación:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/oracle_instalacion5.png" />

Una vez terminada la instalación, obtendremos esta ventana:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/oracle_instalacion6.png" />

Bien, ya hemos instalado el servidor *Oracle* en nuestro sistema, vamos a acceder a él. Para ello vamos a abrir la aplicación **SQLPlus**. También podemos acceder a través de nuestro **cmd** con el comando:

<pre>
sqlplus
</pre>

Yo accedo mediante esta segunda opción. Como es la primera vez que vamos a acceder, debemos hacerlo mediante el usuario **system** que nos lo crea por defecto y es administrador. Una vez en él, crearé un usuario personal y le asignaré permisos:

<pre>
Microsoft Windows [Versión 10.0.19042.572]
(c) 2020 Microsoft Corporation. Todos los derechos reservados.

C:\Users\javier>sqlplus

SQL*Plus: Release 19.0.0.0.0 - Production on Lun Dic 7 16:43:18 2020
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Introduzca el nombre de usuario: system
Introduzca la contrase±a:
Hora de ┌ltima Conexi¾n Correcta: Sßb Dic 05 2020 18:50:15 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> CREATE USER c##javier IDENTIFIED BY contraseña;

Usuario creado.

SQL> GRANT ALL PRIVILEGES TO c##javier;

Concesi¾n terminada correctamente.

SQL>
</pre>

Con esto, ya tenemos nuestro usuario disponible.

Voy a acceder a él y a crear una serie de tablas de prueba y a insertarle unos pocos registros a partir de este [script](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/scriptoracle.txt).

Hecho esto, es el momento de acceder a este servidor de manera remota.

Para ello, he creado otra máquina virtual con **Windows 10**, que en este caso, actuará como **cliente** que accederá al servidor creado anteriormente. También está conectada en modo puente a mi red doméstica, por lo que tiene totalmente accesible al servidor y viceversa. En esta segunda máquina he instalado *Oracle* de igual manera que en la primera.

Me he dado cuenta de un pequeño detalle, y es que por defecto, el cortafuegos de *Windows 10* (*firewall*), me bloqueaba la entrada de paquetes, es decir, me dejaba enviar paquetes pero no recibir, de manera que las máquinas virtuales no llegaban a establecer una conexión, ya que los paquetes sí salían pero nunca llegaban a su destino, por tanto, he tenido que desactivar los cortafuegos de ambas máquinas. Como estoy trabajando en máquinas virtuales en mi red local, no hay problema, pero obviamente no es nada recomendable desactivar todo el sistemas de cortafuegos del sistema. Para evitar tener que desactivar todo el *firewall*, podemos añadir esta regla al cortafuegos que nos solucionará el problema:

<pre>
netsh advfirewall firewall add rule name="Habilitar respuesta ICMP IPv4" protocol=icmpv4:8,any dir=in action=allow
</pre>

Esta máquina *cliente* posee la IP **192.168.0.56**.

Para habilitar el acceso remoto al servidor, debemos modificar el fichero `listener.ora` en él. Este fichero se encuentra en la ruta `$ORACLE_HOME/network/admin`:

Por defecto, posee este aspecto:

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

Una vez hemos realizado este cambio, podemos iniciar el **listener**. El *listener* se maneja con estos comandos:

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
Fecha de Inicio       17-DIC-2020 14:07:52
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

Vemos que lo ha iniciado correctamente. Ahora, para asegurarnos que realmente está escuchando peticiones desde el puerto **1521** vamos a utilizar el comando `netstat`:

<pre>
C:\Windows\System32>netstat

Conexiones activas

  Proto  Dirección local        Dirección remota       Estado
  TCP    127.0.0.1:1521         DESKTOP-IGG1O7P:50298  ESTABLISHED
  TCP    127.0.0.1:50298        DESKTOP-IGG1O7P:1521   ESTABLISHED
  TCP    192.168.0.55:49694     40.67.254.36:https     ESTABLISHED
  TCP    192.168.0.55:50289     MINI-PC:netbios-ssn    TIME_WAIT
  TCP    192.168.0.55:50299     20.191.46.211:https    ESTABLISHED
  TCP    [fe80::c9ee:eb4d:5f0b:a64f%4]:1521  DESKTOP-IGG1O7P:50297  TIME_WAIT
  TCP    [fe80::c9ee:eb4d:5f0b:a64f%4]:50297  DESKTOP-IGG1O7P:1521   TIME_WAIT
</pre>

Vemos que efectivamente está escuchando en dicho puerto.

Hecho esto, ya habríamos habilitado al servidor para que permita el acceso remoto, por tanto, vamos a intentar acceder a él desde el **cliente**, pero antes vamos a probar si verdaderamente el *cliente* posee conectividad al puerto *1521* del *servidor*. Para esto vamos a utilizar la herramienta `tnsping`, que se encarga de realizar un *ping* a la IP que indiquemos, pero haciendo referencia al puerto *1521*:

<pre>
C:\Users\cliente>tnsping 192.168.0.55

TNS Ping Utility for 64-bit Windows: Version 19.0.0.0.0 - Production on 17-DIC-2020 14:47:58

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Archivos de parßmetros utilizados:
C:\Users\cliente\Desktop\WINDOWS.X64_193000_db_home\network\admin\sqlnet.ora

Adaptador EZCONNECT utilizado para resolver el alias
Intentando contactar con (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=))(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.0.55)(PORT=1521)))
Realizado correctamente (0 mseg)
</pre>

Tenemos conectividad con el puerto *1521* del *servidor*.

Si queremos acceder remotamente con **sqlplus** hay que utilizar un comando como este:

<pre>
C:\Users\cliente>sqlplus usuario/contraseña@X.X.X.X/nombrebasededatos
</pre>

Accedo a mi servidor de base de datos desde la máquina *cliente*:

<pre>
C:\Users\cliente>sqlplus c##javier/contraseña@192.168.0.55/orcl

SQL*Plus: Release 19.0.0.0.0 - Production on Jue Dic 17 14:14:05 2020
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Hora de ┌ltima Conexi¾n Correcta: Jue Dic 17 2020 14:12:14 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> select * from cat;

TABLE_NAME
--------------------------------------------------------------------------------
TABLE_TYPE
-----------
EMPLEADOS
TABLE

TIENDAS
TABLE

PRODUCTOS
TABLE


SQL> select * from productos;

CODIGO NOMBRE               TIPO
------ -------------------- ---------------
DESCRIPCION                                                      PRECIO COD_TI
------------------------------------------------------------ ---------- ------
AAAAAA Correa de paseo      Paseo
Correa de perro para dar paseos                                      10 000001

BBBBBB Chandal Espanya      Futbol
Chandal oficial de la seleccion española de futbol                   90 000002

CCCCCC Pollo asado          Carne
Pollo asado a fuego lento                                             8 000003


CODIGO NOMBRE               TIPO
------ -------------------- ---------------
DESCRIPCION                                                      PRECIO COD_TI
------------------------------------------------------------ ---------- ------
DDDDDD Laptop Study         Portatil
Ordenador portatil marca Javi s                                     750 000004

EEEEEE Sudadera Rosa        Sudadera
Sudadera rosa de niña                                                30 000005


SQL>
</pre>

Como hemos visto, hemos accedido correctamente, y hemos comprobado que tenemos acceso a todos los datos, por lo que habríamos terminado este ejercicio.


#### Instalación de un servidor de ORACLE 19c en CentOS y prueba desde un cliente remoto de SQL*Plus

Ahora vamos a realizar el mismo proceso, pero esta vez instalaremos tanto el servidor como el cliente, en máquinas **Linux**.

En mi caso voy a llevar a cabo la instalación de **Oracle** sobre sistemas **CentOS 8**, que se ejecutarán en máquinas virtuales conectadas en modo puente a mi red local.

- La máquina *servidor* posee la IP **192.168.0.47**.
- La máquina *cliente* posee la IP **192.168.0.48**.

Lo primero que debemos hacer, al igual que antes, sería descargarnos el paquete de instalación desde la [web oficial de Oracle](https://www.oracle.com/es/database/technologies/oracle-database-software-downloads.html#19c), para realizar la descarga nos hará falta estar registrados como usuarios de *Oracle*.

Una vez descargado, en mi caso ya que utilizo *CentOS*, el archivo *.rpm*, tenemos que extraerlo y ahora empezaremos el proceso de instalación.

Antes de empezar con la propia instalación, vamos a instalar un paquete que nos proporciona *Oracle*, que básicamente lo que hace, es preparar nuestro sistema para la posterior instalación de nuestro servidor de base de datos. Para ello, ejecutamos el siguiente comando:

<pre>
dnf install https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el8.x86_64.rpm -y
</pre>

Una vez instalado y terminado el proceso, es el momento de instalar nuestro servidor de base de datos, por lo que vamos a ello:

<pre>
[root@servidororacle ~]# rpm -Uhv oracle-database-ee-19c-1.0-1.x86_64.rpm
advertencia:oracle-database-ee-19c-1.0-1.x86_64.rpm: EncabezadoV3 RSA/SHA256 Signature, ID de clave ec551f03: NOKEY
Verifying...                          ################################# [100%]
Preparando...                         ################################# [100%]
Actualizando / instalando...
   1:oracle-database-ee-19c-1.0-1     ################################# [100%]
[INFO] Executing post installation scripts...
[INFO] Oracle home installed successfully and ready to be configured.
To configure a sample Oracle Database you can execute the following service configuration script as root: /etc/init.d/oracledb_ORCLCDB-19c configure
</pre>

Indicamos los siguientes parámetros:

- **U:** elimina cualquier versión anterior del paquete en caso de existir.
- **h:** muestra la barra de progreso de la instalación.
- **v:** muestra más información respectiva a la instalación.

Terminada la instalación, vamos a ejecutar el *script* al que nos hace referencia al final del proceso de instalación. Este *script* se encargará de crear una base de datos de ejemplo.

<pre>
[root@servidororacle ~]# /etc/init.d/oracledb_ORCLCDB-19c configure
Configuring Oracle Database ORCLCDB.
Preparar para funcionamiento de base de datos
8% finalizado
Copiando archivos de base de datos
31% finalizado
Creando e iniciando instancia Oracle
32% finalizado
36% finalizado
40% finalizado
43% finalizado
46% finalizado
Terminando creación de base de datos
51% finalizado
54% finalizado
Creando Bases de Datos de Conexión
58% finalizado
77% finalizado
Ejecutando acciones posteriores a la configuración
100% finalizado
Creación de la base de datos terminada. Consulte los archivos log de /opt/oracle/cfgtoollogs/dbca/ORCLCDB
 para obtener más información.
Información de Base de Datos:
Nombre de la Base de Datos Global:ORCLCDB
Identificador del Sistema (SID):ORCLCDB
Para obtener información detallada, consulte el archivo log "/opt/oracle/cfgtoollogs/dbca/ORCLCDB/ORCLCDB.log".

Database configuration completed successfully. The passwords were auto generated, you must change them by connecting to the database using 'sqlplus / as sysdba' as the oracle user.
</pre>

Una vez ha terminado el proceso y generada esta base de datos, habremos terminado completamente la instalación de *Oracle 19c* en *CentOS*.

Es el momento de pasar con las configuraciones. En primer lugar, vamos a definir las variables de entorno necesarias en el usuario **oracle**, ¿y esto para qué? Pues esto nos facilitará mucho el trabajo con *Oracle*, ya que nos ahorrará indicar la ruta completa de cada binario ejecutable, cada vez que vayamos a hacer uso de ellos.

Para esto, vamos a modificar el fichero `.bash_profile` del usuario **oracle**, que por defecto posee esta configuración:

<pre>
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi
</pre>

En este archivo, definimos las siguientes variables de entorno:

<pre>
umask 022
export ORACLE_SID=ORCLCDB
export ORACLE_BASE=/opt/oracle/oradata
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin
</pre>

Una vez modificado el fichero, debemos emplear el siguiente comando para volver a cargar las variables de entorno:

<pre>
source ~/.bash_profile
</pre>

Hecho esto, vamos a probar a acceder por primera vez a nuestro nuevo gestor de base de datos. Para ello, hacemos uso del comando `sqlplus` y accederemos con el usuario administrador llamado **sysdba**:

<pre>
[oracle@servidororacle ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Mon Feb 15 11:10:07 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Connected to an idle instance.

SQL>
</pre>

Efectivamente podemos acceder correctamente al cliente *sqlplus*. Ahora debemos montar la base de datos, para así poder hacer uso de la misma. Para ello utilizamos el comando `STARTUP`.

<pre>
SQL> STARTUP                
ORACLE instance started.

Total System Global Area  763360520 bytes
Fixed Size		    9139464 bytes
Variable Size		  486539264 bytes
Database Buffers	  264241152 bytes
Redo Buffers		    3440640 bytes
Base de datos montada.
Base de datos abierta.

SQL>
</pre>

En este punto, crearemos un usuario personal y le asignaremos permisos:

<pre>
SQL> CREATE USER c##javier IDENTIFIED BY contraseña;

Usuario creado.

SQL> GRANT ALL PRIVILEGES TO c##javier;

Concesion terminada correctamente.

SQL>
</pre>

En este punto, nos faltaría configurar el acceso remoto. El proceso es muy parecido al que hemos seguido en *Windows*, por lo que no supone nada nuevo.

Volvemos al usuario **root**, y en primer lugar, debemos configurar el fichero `/etc/hosts` para establecer una resolución estática de nombres en la máquina.

Tendremos que añadir una nueva línea en la que indicaremos, la IP de nuestra máquina, con su respectivo *hostname* y su respectivo *alias*. La línea que en mi caso añado es la siguiente:

<pre>
192.168.0.47   servidororacle     servidororacle
</pre>

Tras ello, debemos reiniciar nuestro sistema para aplicar los cambios.

Hecho esto, ya nos tocaría tocar los archivos de configuración propios para habilitar el acceso remoto al servidor. Como hemos visto antes, debemos modificar el fichero `listener.ora`. Este fichero se encuentra en la ruta `/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora`:

Por defecto, posee este aspecto:

<pre>
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
</pre>

Si nos fijamos, dentro del bloque **LISTENER**, en la línea que define la regla para el protocolo *TCP*, que es la que nos interesa, podemos ver que en el campo **HOST** está configurado para que solo escuche las peticiones cuyo origen es **localhost**. También está configurado para que el puerto por el que escuche sea el **1521**, que es el que viene configurado por defecto, a mí me vale, por eso lo dejo. Obviamente lo que hay que cambiar es el valor del campo **HOST**, y establecerle como valor la interfaz desde la que queremos escuchar las peticiones. En mi caso, voy a especificar el **nombre de mi máquina** para que así escuche todas las peticiones.

En mi caso, añado el siguiente bloque:

<pre>
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = servidororacle)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
</pre>

Una vez hemos realizado este cambio, podemos iniciar el **listener**. El *listener* se maneja con estos comandos:

- **lsnrctl start:** inicia el servicio.
- **lsnrctl stop:** detiene el servicio.
- **lsnrctl status:** muestra información sobre el estado.

Lo iniciamos:

<pre>
[oracle@servidororacle ~]$ lsnrctl start

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 15-FEB-2021 11:36:53

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
Start Date                15-FEB-2021 11:36:55
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/servidororacle/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=servidororacle)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
The listener supports no services
The command completed successfully
</pre>

Vemos que lo ha iniciado correctamente. Ahora, para asegurarnos que realmente está escuchando peticiones desde el puerto **1521** vamos a utilizar el comando `netstat`:

<pre>
[oracle@servidororacle ~]$ netstat -tln
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp6       0      0 :::111                  :::*                    LISTEN     
tcp6       0      0 :::1521                 :::*                    LISTEN     
tcp6       0      0 :::22                   :::*                    LISTEN
</pre>

Vemos que efectivamente está escuchando en dicho puerto, pero ojo, aún no podríamos conectar con nuestro servidor *Oracle*, ya que, por defecto, *CentOS* incorpora su característico *firewall*, que bloquea las peticiones en el puerto *1521*. Por tanto, añadiremos la siguiente regla para cambiar este comportamiento:

<pre>
[root@servidororacle ~]# firewall-cmd --permanent --add-port=1521/tcp
success

[root@servidororacle ~]# firewall-cmd --reload
success
</pre>

Hecho esto, ya habríamos habilitado al servidor para que permita el acceso remoto, por tanto, vamos a intentar acceder a él desde el **cliente**, pero antes vamos a probar si verdaderamente el *cliente* posee conectividad al puerto *1521* del *servidor*. Para esto vamos a utilizar la herramienta `tnsping`, que se encarga de realizar un *ping* a la IP que indiquemos, pero haciendo referencia al puerto *1521*:

<pre>
[oracle@clienteoracle ~]$ tnsping 192.168.0.47

TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 15-FEB-2021 11:43:08

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora

Used HOSTNAME adapter to resolve the alias
Attempting to contact (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=))(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.0.47)(PORT=1521)))
OK (10 msec)
</pre>

Vemos como tenemos conectividad con el puerto *1521* del *servidor*.

Si queremos acceder remotamente con **sqlplus** hay que utilizar un comando como este:

<pre>
sqlplus usuario/contraseña@X.X.X.X/nombrebasededatos
</pre>

Accedo a mi servidor de base de datos desde la máquina *cliente*:

<pre>
[oracle@clienteoracle ~]$ sqlplus c##javier/contraseña@192.168.0.47/orclcdb

SQL*Plus: Release 19.0.0.0.0 - Production on Wed Feb 17 15:04:51 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Hora de Ultima Conexion Correcta: Lun Feb 15 2021 11:16:17 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL>
</pre>

Ya podríamos acceder correctamente, y tendríamos acceso a los datos, por lo que habríamos terminado este ejercicio.


#### Instalación de un servidor MySQL y configuración para permitir el acceso remoto desde la red local

Para realizar este ejercicio he decidido crear dos máquinas virtuales conectadas en modo puente a mi red local, las dos poseen un sistema **Debian 10**, y una actuará como servidor y la otra como cliente. Las he creado con **Vagrant**, con el siguiente fichero *Vagrantfile*:

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :servidor do |servidor|
        servidor.vm.box="debian/buster64"
        servidor.vm.hostname="servidor"
	      servidor.vm.network :public_network, :bridge=>"wlo1"
  end

  config.vm.define :cliente do |cliente|
        cliente.vm.box="debian/buster64"
        cliente.vm.hostname="cliente"
	      cliente.vm.network :public_network, :bridge=>"wlo1"
  end

end
</pre>

Las direcciones IP de ambas máquinas son:

- **Servidor:** 192.168.0.32

- **Cliente:** 192.168.0.33

Primeramente nos dirigimos a la máquina *servidor*, e instalamos el servidor **MySQL**:

<pre>
apt install mariadb-server -y
</pre>

Una vez lo hemos instalado, vamos a configurar una serie de opciones con el comando `mysql_secure_installation`. Vamos a especificarle una **contraseña de root**, vamos a **eliminar los usuarios anónimos**, vamos a especificar que queremos **desactivar el acceso remoto** a la base de datos, en resumen, vamos a restablecer la base de datos, con nuestras preferencias. Esta es una manera de asegurar el servicio. Aquí muestro el proceso:

<pre>
root@servidor:/home/vagrant# mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

You already have a root password set, so you can safely answer 'n'.

Change the root password? [Y/n] y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... skipping.

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
</pre>

Es el turno de crear un usuario propio, asignarle privilegios y especificarle que sea accesible solo desde mi red local, es decir, desde cualquier dirección IP dentro de **192.168.0.XXX**. Para hacer esto debemos conectarnos como *root*:

<pre>
root@servidor:~# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 39
Server version: 10.3.27-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'javier'@'192.168.0.*' IDENTIFIED BY 'contraseña';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'javier'@'192.168.0.*';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> exit
Bye
</pre>

Una vez tenemos el usuario al que accederemos remotamente, nos quedaría configurar el acceso remoto a nuestro servidor *MySQL*, para ello, debemos modificar el fichero de configuración `/etc/mysql/mariadb.conf.d/50-server.cnf` y buscar la línea `bind-address = 127.0.0.1` y sustituirla por la siguiente:

<pre>
bind-address = 0.0.0.0
</pre>

Esto hará que el servidor escuche las peticiones que provienen de todas las interfaces, a diferencia del punto anterior, que estaba configurado para que solo escuchara en *localhost*.

Hecho esto podemos dirigirnos al **cliente**, donde vamos a instalar el cliente *MySQL*:

<pre>
apt install mariadb-client -y
</pre>

Una vez instalado, vamos a intentar acceder al usuario **javier** que hemos creado en el servidor. Recordemos que la dirección IP del servidor es la **192.168.0.32**, por tanto, para conectarnos, vamos a emplear este comando:

<pre>
mysql -h 192.168.0.32 -u javier -p
</pre>

El parámetro **-h** indica la dirección del servidor, y los parámetros **-u** y **-p**, como ya sabemos, indican el usuario y la autenticación mediante contraseña.

Obtenemos este resultado:

<pre>
vagrant@cliente:~$ mysql -h 192.168.0.32 -u javier -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 40
Server version: 10.3.27-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
</pre>

Hemos accedido a nuestro servidor con el nuevo usuario, ahora vamos a crear una base de datos de prueba llamada *empresa*:

<pre>
MariaDB [(none)]> create database empresa;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> use empresa;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [empresa]>
</pre>

En esta base de datos voy a crear una serie de tablas y a introducirle unos registros de prueba a través de este [script](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/scriptmysql.txt).

Vemos las tablas y algunos de los registros creados:

<pre>
MariaDB [empresa]> show tables;
+-------------------+
| Tables_in_empresa |
+-------------------+
| Empleados         |
| Productos         |
| Tiendas           |
+-------------------+
3 rows in set (0.002 sec)

MariaDB [empresa]> select * from Tiendas;
+--------+-------------------+--------------+--------------+
| Codigo | Nombre            | Especialidad | Localizacion |
+--------+-------------------+--------------+--------------+
| 000001 | Javi s Pet        | Animales     | Sevilla      |
| 000002 | Javi s Sport      | Deportes     | Cordoba      |
| 000003 | Javi s Food       | Comida       | Granada      |
| 000004 | Javi s Technology | Tecnologia   | Cadiz        |
| 000005 | Javi s Clothes    | Ropa         | Huelva       |
+--------+-------------------+--------------+--------------+
5 rows in set (0.001 sec)

MariaDB [empresa]>
</pre>

El resultado es el esperado, y por tanto, ya hemos terminado este ejercicio donde hemos configurado el acceso desde un cliente a un servidor remoto *MySQL*.


#### Realización de una aplicación web en cualquier lenguaje que conecte con un servidor PostgreSQL tras autenticarse y muestre alguna información almacenada en el mismo

Primeramente voy a instalar un servidor **PostgreSQL** en una instancia del *cloud*, para luego acceder de manera remota desde una máquina virtual donde haré la aplicación web.

Instalo en la instancia el servidor:

<pre>
apt install postgresql-11 -y
</pre>

Para verificar si la base de datos *PostgreSQL* está inicializada y verificar el estado de conexión del servidor utilizamos este comando:

<pre>
root@servidor-postgresql:~# pg_isready
/var/run/postgresql:5432 - accepting connections
</pre>

Una vez instalado se crea un nuevo usuario llamado *postgres* que tiene rol de superusuario. Vamos a asignarle una contraseña por cuestión de seguridad:

<pre>
postgres@servidor-postgresql:/root$ psql postgres
psql (11.9 (Debian 11.9-0+deb10u1))
Type "help" for help.

postgres=# ALTER ROLE postgres PASSWORD 'contraseña';
ALTER ROLE

postgres=#
</pre>

Vamos a crear un nuevo rol, y debemos hacerlo a través de este usuario.

Utilizamos el argumento *--interactive* para que nos pregunte si el nuevo rol será de administrador o no:

<pre>
debian@servidor-postgresql:~$ sudo -u postgres createuser --interactive
Enter name of role to add: debian
Shall the new role be a superuser? (y/n) y
</pre>

Ahora creamos una base de datos con el mismo nombre que el rol que hemos creado y nos conectamos:

<pre>
debian@servidor-postgresql:~$ psql
psql (11.9 (Debian 11.9-0+deb10u1))
Type "help" for help.

debian=# ALTER ROLE debian PASSWORD 'contraseña';

debian=# CREATE DATABASE empresa;
CREATE DATABASE

debian=# GRANT ALL PRIVILEGES ON DATABASE empresa TO debian;
GRANT

debian=# \c empresa
You are now connected to database "empresa" as user "debian".

empresa=#
</pre>

Vamos a crear unas tablas y unos registros, para ello, utilizamos el siguiente [script](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/scriptpostgresql.txt).

Si comprobamos las tablas:

<pre>
empresa=# \d
          List of relations
 Schema |   Name    | Type  | Owner  
--------+-----------+-------+--------
 public | empleados | table | debian
 public | productos | table | debian
 public | tiendas   | table | debian
(3 rows)
</pre>

Ahora vamos a permitir el acceso remoto al servidor. Para ello debemos dirigirnos al fichero `/etc/postgresql/11/main/postgresql.conf` y descomentamos la línea *listen_addresses = 'localhost'* y sustituimos el valor *localhost* por la dirección que queremos que se conecte remotamente o si queremos habilitar conexiones desde todas las direcciones, establecemos el valor *****. En mi caso, la línea quedaría así:

<pre>
listen_addresses = '*'
</pre>

Nos quedaría modificar un fichero de configuración para terminar de habilitar el acceso remoto. Tenemos que editar el fichero `/etc/postgresql/11/main/pg_hba.conf` y en la línea que hace referencia a las direcciones *IPv4*, modificar el valor **127.0.0.1/32** por **all**, de manera que quedaría así:

<pre>
# IPv4 local connections:
host    all             all             all            md5
</pre>

Ya hemos configurado todo lo necesario para poder acceder remotamente a nuestro servidor *PostgreSQL*. Vamos a dirigirnos a la máquina virtual y vamos a instalar el cliente y a intentar acceder remotamente a la base de datos *empresa*:

<pre>
apt install postgresql-client -y
</pre>

Intentamos acceder de manera remota. Utilizamos los parámetros **-h** para indicar la dirección IP del servidor, **-U** para indicar el usuario y **-d** para indicar la base de datos:

<pre>
root@buster:/etc/apache2/conf-available# psql -h 172.22.201.25 -U debian -d empresa
Password for user debian:
psql (11.9 (Debian 11.9-0+deb10u1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

empresa=# \d
          List of relations
 Schema |   Name    | Type  | Owner  
--------+-----------+-------+--------
 public | empleados | table | debian
 public | productos | table | debian
 public | tiendas   | table | debian
(3 rows)

empresa=# select * from tiendas;
 codigo |      nombre       | especialidad | localizacion
--------+-------------------+--------------+--------------
 000001 | Javi s Pet        | Animales     | Sevilla
 000002 | Javi s Sport      | Deportes     | Cordoba
 000003 | Javi s Food       | Comida       | Granada
 000004 | Javi s Technology | Tecnologia   | Cadiz
 000005 | Javi s Clothes    | Ropa         | Huelva
(5 rows)
</pre>

Vemos como tenemos acceso remoto y tenemos acceso a los datos almacenados.

En este punto, solo nos quedaría configurar la aplicación web.

Para servir una página web lógicamente necesitamos un servidor web. Yo he decidido utilizar *Apache*:

<pre>
apt install apache2 apache2-utils -y
</pre>

Instalamos los paquetes necesarios para poder acceder desde una aplicación web:

<pre>
apt install php libapache2-mod-php php-cli php-pgsql phppgadmin -y
</pre>

En este punto solo nos quedaría hacer unas pequeñas modificaciones en algunos ficheros de configuración.

El primer cambio debemos hacerlo en el fichero `/etc/apache2/conf-available/phppgadmin.conf` y comentar la línea **Require local**.

Después de hacer esto, en el fichero `/etc/phppgadmin/config.inc.php` debemos buscar la siguiente línea:

<pre>
$conf['extra_login_security'] = true;
</pre>

Tenemos que asegurarnos que su valor sea igual a **true**, y añadir estas líneas que indican la dirección del servidor y el puerto de la máquina remota:

<pre>
$conf['servers'][1]['host'] = '172.22.201.25';
$conf['servers'][1]['port'] = 5432;
</pre>

Si accedemos a la dirección `.../phppgadmin` en nuestro navegador e iniciamos sesión con las credenciales de nuestro usuario de la base de datos, obtendremos un resultado como éste:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/postgresqlaplicacionweb.png" />

Podemos ver como nuestra aplicación nos muestra las bases de datos existentes en el servidor, y podemos eliminarlas, modificarlas y establecer privilegios, entre otras cosas, ya que también podemos realizar consultas, ...


#### Instalación de una herramienta de administración para MongoDB y prueba desde un cliente remoto

Lo primero que voy a hacer, sería crear las dos máquinas virtuales con las que vamos a trabajar en este ejercicio. Como siempre, una actuará como servidor y la otra como cliente. Las dos *mv* están creadas con un sistema **Debian 10**, y conectadas a la misma red local. La máquina **cliente** tendrá **entorno gráfico** para así poder utilizar la herramienta de administración.

Las direcciones IP de ambas máquinas son:

- **Servidor:** 192.168.0.39

- **Cliente:** 192.168.0.40

Una vez tenemos operativas ambas máquinas, nos dirigimos a la que va a tener el rol de **servidor**, y procedemos con la instalación de **MongoDB**. Antes de nada, hay que instalar el siguiente paquete:

<pre>
apt install gnupg -y
</pre>

Ahora vamos a añadir un nuevo repositorio a nuestro sistema:

<pre>
wget https://www.mongodb.org/static/pgp/server-4.4.asc -qO- | sudo apt-key add -
</pre>

En el fichero `/etc/apt/sources.list.d/mongodb-org.list` añadimos la siguiente línea:

<pre>
deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main
</pre>

Ya hemos añadido a nuestra lista de repositorios el que contiene los paquetes de *MongoDB*, por tanto podemos proceder a instalarlo:

<pre>
apt update && apt install mongodb-org -y
</pre>

Una vez descargado el paquete, vamos a iniciar el proceso:

<pre>
systemctl enable --now mongod
</pre>

Con esto, habríamos terminado la instalación, que vemos que es muy sencilla.

Vamos a proceder a acceder por primera vez a nuestro servidor:

<pre>
root@servidor:~# mongo
MongoDB shell version v4.4.2
connecting to: mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("a09dc1ed-067a-4dc0-a7f4-6064715a3a95") }
MongoDB server version: 4.4.2
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
	https://docs.mongodb.com/
Questions? Try the MongoDB Developer Community Forums
	https://community.mongodb.com
---
The server generated these startup warnings when booting:
        2020-12-09T16:01:32.945+00:00: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine. See http://dochub.mongodb.org/core/prodnotes-filesystem
        2020-12-09T16:01:33.334+00:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
---
---
        Enable MongoDB's free cloud-based monitoring service, which will then receive and display
        metrics about your deployment (disk utilization, CPU, operation statistics, etc).

        The monitoring data will be available on a MongoDB website with a unique URL accessible to you
        and anyone you share the URL with. MongoDB may use this information to make product
        improvements and to suggest MongoDB products and deployment options to you.

        To enable free monitoring, run the following command: db.enableFreeMonitoring()
        To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
---
/>
</pre>

Una vez hemos accedido al servidor, lo primero que debemos hacer es crear un usuario administrador con contraseña. Para hacer esto, nos conectamos a la base de datos **admin**:

<pre>
/> use admin
switched to db admin
/>
</pre>

Y una vez aquí, creamos el usuario con la siguiente línea:

<pre>
/> db.createUser({user: "javier", pwd: "contraseña", roles: [{role: "root", db: "admin"}]})
Successfully added user: {
	"user" : "javier",
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	]
}
/>
</pre>

Vemos como hemos creado correctamente el usuario administrador. Antes de acceder con este usuario, vamos a modificar el fichero de configuración de *MongoDB*, que se encuentra en `/etc/mongod.conf`. Para aumentar la seguridad, debemos descomentar la línea `security:` y añadirle la siguiente directiva, esto hará que al intentar acceder a cualquier base de datos, nos pida una autenticación *usuario/contraseña*. La línea debe quedar así:

<pre>
security:
  authorization: enabled
</pre>

Después de esto, hay que reiniciar el servicio:

<pre>
systemctl restart mongod
</pre>

Ahora sí, probamos a acceder con este nuevo usuario:

<pre>
root@servidor:~# mongo -u javier
MongoDB shell version v4.4.2
Enter password:
connecting to: mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("66ad3221-76d2-4e5f-b88b-1a3759309f58") }
MongoDB server version: 4.4.2
...
/>
</pre>

Accedemos exitosamente a nuestro nuevo usuario. Si nos fijamos, hemos vuelto a hacer uso del parámetro **-u** para indicar el usuario.

Una vez tenemos nuestro nuevo usuario vamos a crear una base de datos de prueba y vamos crear algunas tablas que rellenaremos con una serie de registros.

¿Recordáis que antes para acceder a la base de datos **admin**, hicimos uso del comando `use`? Bien, pues para crear una nueva base de datos, actuamos de igual manera, de forma que `use` buscará entre las bases de datos existentes la que hemos introducido, y en el caso de que no exista ninguna, la creará automáticamente.

Sabiendo esto, vamos a listar las bases de datos que ya existen en nuestro servidor:

<pre>
/> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
</pre>

Ahora vamos a crear la nueva base de datos que recibirá el nombre de **empresa_mongodb**:

<pre>
/> use empresa_mongodb
switched to db empresa_mongodb
</pre>

Vemos como nos indican mediante un mensaje, que hemos cambiado a trabajar con esta nueva base de datos, que supuestamente debería haber creado.

Para asegurarnos que la ha creado, vamos a volver a listar las bases de datos existentes:

<pre>
/> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
</pre>

Vaya, no aparece **empresa_mongodb**. Aquí viene un apunte importante. *MongoDB* detecta las bases de datos que contienen algún registro en ellas, de manera que si una base de datos se encuentra vacía, no la muestra.

Me gustaría hacer un apunte un poco fuera del guión, y es que, en realidad, en *MongoDB* al no ser una base de datos relacional, las tablas de las bases de datos no reciben este nombre como tal, sino que se llaman **Colecciones** y sus registros, **Documentos**. Nos parecerá un poco extraño, ya que seguramente estemos más habituados a las bases de datos relacionales, que son las que hemos visto en los ejercicios anteriores.

Una vez dentro de esta nueva base de datos, primeramente vamos a crear un nuevo usuario, para así no tener que trabajar con el administrador.

<pre>
/> db.createUser({user: "javier_empresario", pwd: "contraseña", roles: ["dbOwner"]})
Successfully added user: { "user" : "javier_empresario", "roles" : [ "dbOwner" ] }
</pre>

Salimos y entramos con el usuario **javier_empresario**. En este caso, como este usuario ha sido creado en la base de datos **empresa_mongodb**, tendremos que hacer uso del parámetro **--authenticationDatabase** e indicar donde se encuentra el nuevo usuario. Acto después seleccionamos usar **empresa_mongodb**:

<pre>
root@servidor:~# mongo --authenticationDatabase "empresa_mongodb" -u javier_empresario -p
MongoDB shell version v4.4.2
Enter password:
connecting to: mongodb://127.0.0.1:27017/?authSource=empresa_mongodb&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("40c042b7-2ca1-4089-a234-b708db8e888b") }
MongoDB server version: 4.4.2

/> use empresa_mongodb
switched to db empresa_mongodb
</pre>

Es el momento de crear algunas *colecciones* e insertarle algunos *documentos*. Lo llevaré a cabo a través de este [script](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/scriptmongodb.txt).

En este punto, vamos a configurar el acceso remoto para intentar acceder a estos datos desde la máquina **cliente**.

Para hacer esto, debemos modificar el fichero `/etc/mongod.conf` y buscar el bloque llamado **Network interfaces** y sustituirle el valor del campo *bindIP*, que por defecto tendrá el valor *127.0.0.1*, es decir *localhost*. Si queremos permitir el acceso remoto, debe quedar así:

<pre>
# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0
</pre>

Después de esto, hay que reiniciar el servicio:

<pre>
systemctl restart mongod
</pre>

Hecho esto, habríamos terminado de configurar el acceso remoto a nuestro servidor, por lo que ya podríamos acceder desde el cliente.

Desde la máquina **cliente** vamos a acceder al servidor en el que hemos estado trabajado anteriormente.

Utilizamos los parámetros **-host** para especificar la dirección del servidor al que nos vamos a conectar, y todos los demás los conocemos ya:

<pre>
root@cliente:~# mongo --host 192.168.0.39 --authenticationDatabase "empresa_mongodb" -u javier_empresario -p
MongoDB shell version v4.4.2
Enter password:
connecting to: mongodb://192.168.0.39:27017/?authSource=empresa_mongodb&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("4b97badb-bc4c-4479-b843-e6da44c97f51") }
MongoDB server version: 4.4.2
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
	https://docs.mongodb.com/
Questions? Try the MongoDB Developer Community Forums
	https://community.mongodb.com

/> show dbs
empresa_mongodb  0.000GB

/> use empresa_mongodb
switched to db empresa_mongodb

/> show collections
Empleados
Estudios
Productos

/> db.Productos.find().pretty()
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
/>
</pre>

Acabamos de comprobar como podemos efectivamente podemos acceder al servidor y tenemos acceso a la base de datos y a sus colecciones y documentos.

Por tanto, solo nos faltaría instalar la herramienta para administrar nuestro servidor de *MongoDB*.

Este proceso lo haremos desde el *cliente*.

He decidido instalar la propia herramienta de administración de *MongoDB*, llamada **Compass**. Es una aplicación bastante sencilla de utilizar y que nos facilita muchísimo el trabajo.

Para descargar esta aplicación de escritorio nos dirigimos a la [página oficial de descargas de MongoDB](https://www.mongodb.com/try/download/compass) y elegimos el sistema operativo con el que trabajamos y descargamos el archivo `.exe`, `.deb`, `.rpm`, ... En mi caso estoy trabajando con *Debian*, por lo que descargo el `.deb`, y lo instalo con el siguiente comando:

<pre>
sudo dpkg -i mongodb-compass_1.24.1_amd64.deb
</pre>

Una vez instalado, ya podemos abrir la aplicación.

Una vez en ella, nos aparecerá una ventana como esta:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/compass.png" />

Vemos que nos aparece un recuadro, aquí es donde debemos introducir el comando para conectarnos a nuestro servidor remoto. Para ello, utilizamos este comando:

<pre>
mongodb://usuario:contraseña@X.X.X.X:27017/?authSource=admin&readPreference=primary&appname=MongoDB%20Compass&ssl=false
</pre>

Obviamente, tendremos que sustituir el valor *usuario* y *contraseña* por el que cada uno tenga, y la *IP* también.

En mi caso, utilizo el siguiente comando:

<pre>
mongodb://javier:********@192.168.0.39:27017/?authSource=admin&readPreference=primary&appname=MongoDB%20Compass&ssl=false
</pre>

Hecho esto, ya tendremos configurado el acceso remoto a nuestro servidor. Como podemos ver, tenemos acceso a todos los datos:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/abd_instalacion_de_servidores_y_clientes_de_bases_de_datos/compassdatos.png" />

Hemos finalizado el ejercicio.
