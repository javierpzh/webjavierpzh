---
layout: post
---

**Vamos a instalar un servidor *LDAP* en *Sancho* que va a actuar como servidor secundario o de respaldo del servidor *LDAP* instalado en *Freston*, para ello habrá que seleccionar un modo de funcionamiento y configurar la sincronización entre ambos directorios, para que los cambios que se realicen en uno de ellos se reflejen en el otro.**

Si quieres saber como instalar un servidor **LDAP**, puedes consultar [este post](https://javierpzh.github.io/instalacion-y-configuracion-inicial-de-openldap.html).

Si quieres saber como configurar un servidor **LDAPs**, puedes consultar [este post](https://javierpzh.github.io/ldaps.html).

Vamos a configurar **Sancho** como servidor **LDAP** secundario de **Freston**, pero antes de realizar la configuración, voy a explicar brevemente los tipos de métodos que podemos elegir para configurar un servidor *LDAP* de respaldo, y por qué el que he seleccionado es el más adecuado para este caso.

Bien, primeramente, si ya tenemos instalado un servidor *LDAP* que nos ofrece servicio, ¿para qué instalar otro? Pues es muy sencillo, esto nos hará tener una segunda máquina que nos siga ofreciendo el servicio de *LDAP* en caso de que en la primera máquina ocurriera algún fallo, evitando así perder el servicio durante el tiempo que nos lleve arreglar este fallo. Esto obviamente, en un caso de alta disponibilidad, es muy importante como ya os podéis imaginar.

¿Y como trabajarán estos dos servidores conjuntamente? Pues también es muy simple. Se trata de ir replicando los datos y las informaciones del servidor principal, al secundario, de manera que siempre estén sincronizados.

**Importante:** en algunos momentos del *post* haremos uso de las palabras **proveedor** y **consumidor**. Éstas, harán referencia, respectivamente, a *servidor principal* y *servidor secundario*.

Una vez tenemos la idea de para que nos serviría este servidor de respaldo, voy a pasar a explicar los distintos métodos de los que disponemos a la hora de realizar esta configuración. La herramienta encargada de llevar a cabo estas sincronizaciones recibe el nombre de **LDAP Sync Replication engine**, aunque es más conocido como **syncrepl**. Es un motor de replicación que permite que un servidor *LDAP* mantenga una "copia de seguridad". Utiliza el protocolo **LDAP Content Synchronization**, que soporta dos tipos de sincronización:

- **pull-based:** el cliente consulta periódicamente al servidor para actualizaciones.

- **push-based:** el cliente queda esperando que el servidor le envíe actualizaciones en tiempo real.

Tenemos diferentes opciones de implementación:

- **Master-slave**

    Existe un sólo servidor principal *(master)* capaz de realizar actualizaciones, estas se replican a uno o más servidores secundarios *(slaves)*.

- **Delta-syncrepl**

    Cada vez que se realiza un cambio en un atributo de un objeto, *syncrepl* copia todo el objeto al servidor de respaldo.

    Este método, es una variante de *syncrepl* que busca hacer más eficiente la transferencia de información enviando solamente los datos modificados. Es utilizado en casos donde se realiza gran cantidad de modificaciones, por ejemplo, en casos donde se tiene una rutina periódica que modifica gran cantidad de atributos.

- **N-Way Multi-master**

    Utiliza *syncrepl* para replicar los datos a múltiples proveedores.

    Evita tener un punto único de falla, ya que si un proveedor falla otro continuará aceptando cambios.

    Puede causar inconsistencias, ya que, por ejemplo, si hay al menos dos proveedores activos pero debido a problemas de red unos clientes ven uno y otros clientes ven al otro. En este caso, puede ser difícil llegar a unificar luego la información de ambos proveedores.

- **MirrorMode**

    Es una configuración híbrida que garantiza la consistencia de la replicación *single-master*, mientras provee alta disponibilidad como las soluciones *multi-master*.

    Dos proveedores se configuran para replicarse mutuamente (como en *multi-master*) pero un *front-end* externo dirige las escrituras solamente a uno de los dos servidores. El servidor secundario sólo se usará para escrituras si el primario no funciona, caso en el que el *frontend* *(single point of failure?)* dirigirá las escrituras a al secundario.

    Cuando el servidor primario es reparado y reiniciado, automáticamente se actualizarán sus datos a partir del servidor secundario.

- **Syncrepl Proxy Mode**

    Se utiliza en algunas configuraciones donde el consumidor no puede iniciar la comunicación con el proveedor por restricciones del *firewall*.

    En este caso, *syncrepl* se debe ejecutar desde un tercer equipo, que sí llegara al proveedor y así sí sería posible iniciar la comunicación del proveedor con el consumidor real.

Ya conocemos todas las opciones que disponemos para elegir. En mi caso, pienso que la más adecuada para lo que estoy buscando, sería el método **MirrorMode**, ya que garantiza la sincronización de todos los datos incluso cuando falla el servidor principal y nos aporta unas desventajas mínimas y que prácticamente no me afectan, como es, el uso de un dispositivo externo que se encargue de comprobar qué proveedor se encuentra actualmente activo.

Por fin, llegó el momento de empezar a realizar las configuraciones en sí, para ello, antes, he tenido que realizar en **Sancho**, la instalación de *LDAP* y asegurarme que haga uso del protocolo *ldaps://*. Me he ayudado, de los *posts* que cité al principio de este artículo.

Hecho esto, en la máquina que actuará como servidor principal, es decir, **Freston**, empezaremos con la configuración.

Como sabemos, ya que lo hemos visto en los *posts* anteriores acerca de *LDAP*, la mayoría de configuraciones se llevan a cabo a partir de ficheros con extensión `.ldif` que insertaremos. Para llevar a cabo este proceso, necesitaremos crear seis ficheros distintos.

Creamos el primer fichero `.ldif` que definirá el usuario **mirrormode** y lo creará. En mi caso, se llamará `mirrormode1.ldif` y tendrá el siguiente aspecto:

<pre>
dn: uid=mirrormode,dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: account
objectClass: simpleSecurityObject
description: usuario LDAP
userPassword: {SSHA}Sgk2gyc+tAc3P2dQ+lKphIikCZOWsuGp
</pre>

Habéis podido notar que la contraseña que he introducido se encuentra encriptada, y esto es porque la he cifrado previamente con la herramienta `slappasswd`, ya que sino la contraseña quedaría en texto plano al público.

<pre>
root@freston:~# slappasswd
New password:
Re-enter new password:
{SSHA}Sgk2gyc+tAc3P2dQ+lKphIikCZOWsuGp
</pre>

Una vez tenemos ese archivo listo, lo insertamos mediante el siguiente comando:

<pre>
root@freston:~# ldapadd -x -D "cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org" -W -f mirrormode1.ldif
Enter LDAP Password:
adding new entry "uid=mirrormode,dc=javierpzh,dc=gonzalonazareno,dc=org"
</pre>

Debemos asignarle permisos de lectura y escritura al nuevo usuario, por tanto, creamos un nuevo fichero, que recibirá el nombre `mirrormode2.ldif`:

<pre>
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: to attrs=userPassword
  by self =xw
  by dn.exact="cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org" =xw
  by dn.exact="uid=mirrormode,dc=javierpzh,dc=gonzalonazareno,dc=org" read
  by anonymous auth
  by * none
olcAccess: to *
  by anonymous auth
  by self write
  by dn.exact="uid=mirrormode,dc=javierpzh,dc=gonzalonazareno,dc=org" read
  by users read
  by * none
</pre>

De nuevo, añadimos y asignamos los cambios con este comando:

<pre>
root@freston:~# ldapmodify -H ldapi:/// -Y EXTERNAL -f mirrormode2.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}mdb,cn=config"
</pre>

Pasamos con el tercer archivo, `mirrormode3.ldif`, este será el encargado de cargar el módulo **syncprov** que es necesario para que se lleve a cabo la sincronización. El resultado del contenido de este fichero sería:

<pre>
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov
</pre>

Lo importamos con el comando:

<pre>
root@freston:~# ldapmodify -H ldapi:/// -Y EXTERNAL -f mirrormode3.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=module{0},cn=config"
</pre>

El cuarto archivo sería `mirrormode4.ldif`, y este se encargará de establecer la configuración del módulo que hemos cargado en el paso anterior:

<pre>
dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
changetype: add
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpCheckpoint: 100 10
</pre>

Añadimos la nueva configuración:

<pre>
root@freston:~# ldapmodify -H ldapi:/// -Y EXTERNAL -f mirrormode4.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "olcOverlay=syncprov,olcDatabase={1}mdb,cn=config"
</pre>

Es el turno de asignarle un número identificativo al servidor, para ello creamos el archivo `mirrormode5.ldif`:

<pre>
dn: cn=config
changetype: modify
add: olcServerId
olcServerId: 1
</pre>

Añadimos los cambios del nuevo archivo:

<pre>
root@freston:~# ldapmodify -H ldapi:/// -Y EXTERNAL -f mirrormode5.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=config"
</pre>

Llegamos al sexto y último fichero necesario, `mirrormode6.ldif`, que será el encargado de habilitar la propia sincronización:

<pre>
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncrepl
olcsyncrepl: rid=000
  provider=ldaps://sancho.javierpzh.gonzalonazareno.org
  type=refreshAndPersist
  retry="5 5 300 +"
  searchbase="dc=javierpzh,dc=gonzalonazareno,dc=org"
  attrs="*,+"
  bindmethod=simple
  binddn="uid=mirrormode,dc=javierpzh,dc=gonzalonazareno,dc=org"
  credentials=[contraseña]
-
add: olcDbIndex
olcDbIndex: entryUUID eq
olcDbIndex: entryCSN eq
-
replace: olcMirrorMode
olcMirrorMode: TRUE
</pre>

Importamos el último fichero de configuración:

<pre>
root@freston:~# ldapmodify -H ldapi:/// -Y EXTERNAL -f mirrormode6.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}mdb,cn=config"
</pre>

Hecho esto, ya habríamos terminado de configurar el servidor principal de *LDAP*, así que vamos a pasar con el servidor secundario. En éste, tendremos que realizar exactamente la misma configuración cambiando dos pequeños detalles.

El primero de ellos es que debemos cambiar en el llamado `mirrormode5.ldif` el valor del campo **olcServerId**, ya que esto indica el número identificativo del servidor, en mi caso le he asignado el valor **2**.

Y por último, debemos cambiar en el fichero `mirrormode6.ldif` la línea **provider** y asignarle como valor la dirección del servidor principal, para que haga referencia a éste. En mi caso **ldaps://freston.javierpzh.gonzalonazareno.org**.

Terminada la configuración en ambas máquinas, vamos a proceder a realizar una serie de pruebas para comprobar que el funcionamiento es el correcto.

**Zona de pruebas**

En este punto, ya tendríamos ambos servidores replicados, por lo que vamos a pasar a hacer una prueba y a consultar en el servidor secundario los elementos, de manera que deben aparecer los datos que fueron creados en el principal.

Realizamos la consulta:

<pre>
root@sancho:~# ldapsearch -x -b "dc=javierpzh,dc=gonzalonazareno,dc=org"
...

# javierpzh.gonzalonazareno.org
dn: dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: javierpzh.gonzalonazareno.org
dc: javierpzh

# admin, javierpzh.gonzalonazareno.org
dn: cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator

# mirrormode, javierpzh.gonzalonazareno.org
dn: uid=mirrormode,dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: account
objectClass: simpleSecurityObject
description: usuario LDAP
uid: mirrormode

# search result
search: 2
result: 0 Success
...
</pre>

Podemos apreciar que nos muestra todos los datos que fueron creados en el primer servidor.

Como última prueba, he preparado un fichero `.ldif` que insertará en el servidor principal, es decir, en *Freston*, una nueva unidad organizativa: **Prueba**.

El contenido de este fichero `prueba.ldif` es el siguiente. Podemos descargar el fichero [aquí](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/aso_configurar_LDAP_en_alta_disponibilidad/prueba.ldif):

<pre>
dn: ou=Prueba,dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: organizationalUnit
ou: Prueba
</pre>

Para cargar la configuración de este nuevo fichero, debemos hacer uso del siguiente comando:

<pre>
root@freston:~# ldapadd -x -D "cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org" -f prueba.ldif -W
Enter LDAP Password:
adding new entry "ou=Prueba,dc=javierpzh,dc=gonzalonazareno,dc=org"
</pre>

Si ahora hacemos una nueva consulta desde el servidor de respaldo, es decir, *Sancho*:

<pre>
root@sancho:~# ldapsearch -x -b "dc=javierpzh,dc=gonzalonazareno,dc=org"
...

# javierpzh.gonzalonazareno.org
dn: dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: javierpzh.gonzalonazareno.org
dc: javierpzh

# admin, javierpzh.gonzalonazareno.org
dn: cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator

# mirrormode, javierpzh.gonzalonazareno.org
dn: uid=mirrormode,dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: account
objectClass: simpleSecurityObject
description: usuario LDAP
uid: mirrormode

# Prueba, javierpzh.gonzalonazareno.org
dn: ou=Prueba,dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: organizationalUnit
ou: Prueba

# search result
search: 2
result: 0 Success
...
</pre>

De nuevo vemos que los datos se encuentran sincronizados, por tanto este *post* habría terminado.
