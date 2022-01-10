---
layout: post
---

## Almacenamiento

#### Los contenedores son efímeros

**Los contenedores son efímeros**, es decir, los ficheros, datos y configuraciones que creamos en los contenedores sobreviven a las paradas de los mismos, pero, sin embargo, son destruidos si el contenedor es destruido.

Veamos un ejemplo:

<pre>
$ docker run -d --name my-apache-app -p 8080:80 httpd:2.4
ac50cc24ef71ae0263be7794278600d5cc4f085b88cebbf97b7b268212f2a82f

$ docker exec my-apache-app bash -c 'echo "<\h1\>Hola<\/h1\>" > htdocs/index.html'

$ curl http://localhost:8080
<\h1\>Hola<\/h1\>

$ docker rm -f my-apache-app
my-apache-app

$ docker run -d --name my-apache-app -p 8080:80 httpd:2.4
bb94716205c780ec4a3a2695722fb35ac616ae4cea573308d9446208afb164dc

$ curl http://localhost:8080
<\html\><\body\><\h1\>It works!<\/h1\><\/body\><\/html\>
</pre>

Vemos como al eliminar el contenedor, la información que habíamos guardado en el fichero `index.html` se pierde, y al crear un nuevo contenedor ese fichero tendrá el contenido original.

**NOTA: En la instrucción `docker exec` hemos ejecutado el comando con *bash* `-c` que nos permite ejecutar uno o más comandos en el contenedor de forma más compleja (por ejemplo, indicando ficheros dentro del contenedor).**


#### Los datos en los contenedores

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/docker.png" />

Ante la situación anteriormente descrita, *Docker* nos proporciona varias soluciones para persistir los datos de los contenedores. En este *post* nos vamos a centrar en las dos que considero que son más importantes:

- **volúmenes docker**
- **bind mount**
- **tmpfs mounts**: almacenan en memoria la información (no lo vamos a ver con detalle)

#### Volúmenes docker y bind mount

- **Volúmenes docker:** si elegimos conseguir la persistencia usando volúmenes, estamos haciendo que los datos de los contenedores que nosotros decidamos, se almacenen en una parte del sistema de ficheros que es gestionada por *Docker* y a la que, debido a sus permisos, sólo *Docker* tendrá acceso. En Linux se guardan en la ruta `/var/lib/docker/volumes`. Este tipo de volúmenes se suele usar en los siguiente casos:

    - Para compartir datos entre contenedores. Simplemente tendrán que usar el mismo volumen.
    - Para copias de seguridad ya sea para que sean usadas posteriormente por otros contenedores o para mover esos volúmenes a otros *hosts*.
    - Cuando quiero almacenar los datos de mi contenedor no localmente, sino en un proveedor *cloud*.

- **Bind mounts:** si elegimos conseguir la persistencia de los datos de los contenedores usando *bind mount*, lo que estamos haciendo es “mapear” (montar) una parte de nuestro sistema de ficheros, de la que normalmente tenemos el control, con una parte del sistema de ficheros del contenedor. De esta manera conseguimos:

    - Compartir ficheros entre el *host* y los *containers*.
    - Que otras aplicaciones que no sean *Docker* tengan acceso a esos ficheros, ya sean código, ficheros, ...

#### Gestionando volúmenes

Algunos comando útiles para trabajar con volúmenes *Docker*:

- **docker volumen create:** crea un volumen con el nombre indicado.
- **docker volume rm:** elimina el volumen indicado.
- **docker volumen prune:** para eliminar los volúmenes que no están siendo usados por ningún contenedor.
- **docker volume ls:** nos proporciona una lista de los volúmenes creados y algo de información adicional.
- **docker volume inspect:** nos dará una información mucho más detallada de el volumen que hayamos elegido.

#### Asociando almacenamiento a los contenedores

Veamos como podemos usar los volúmenes y los *bind mounts* en los contenedores. Para cualquiera de los dos casos lo haremos mediante el uso de dos *flags* de la orden *docker run*:

- El *flag* `--volume` o `-v`
- El *flag* `--mount`

Es importante que tengamos en cuenta dos cosas importantes a la hora de realizar estas operaciones:

- Al usar tanto volúmenes como *bind mounts*, el contenido de lo que tenemos sobrescribirá la carpeta destino en el sistema de ficheros del contenedor en caso de que exista.
- Si nuestra carpeta origen no existe y hacemos un *bind mount*, esa carpeta se creará pero lo que tendremos en el contenedor es una carpeta vacía.
- Si usamos imágenes de *DockerHub*, debemos leer la información que cada imagen nos proporciona en su página, ya que esa información suele indicar cómo persistir los datos de esa imagen, ya sea con volúmenes o *bind mounts*, y cuáles son las carpetas importantes en caso de ser imágenes que contengan ciertos servicios (web, base de datos, ...).

#### Trabajando con volúmenes docker:

- **Crea un volumen docker que se llame `miweb`.**

Creamos el nuevo volumen:

<pre>
javier@debian:~$ docker volume create miweb
miweb

javier@debian:~$ docker volume ls
DRIVER              VOLUME NAME
local               051b59979e0527c228be360c9b7568856a8cf37b16b9ce415f3e5fa48b812891
local               e1be424428521f02e06f73a92c2100b8cc42aaf813680bc3ee792c1353ae3abf
local               miweb
</pre>

Listo.

- **Crea un contenedor desde la imagen `php:7.4-apache` donde montes en el directorio `/var/www/html`, (que sabemos que es el *document root* del servidor que nos ofrece esa imagen) el volumen docker que has creado.**

Creamos el contenedor:

<pre>
javier@debian:~$ docker pull php:7.4-apache
7.4-apache: Pulling from library/php
a076a628af6f: Already exists
02bab8795938: Already exists
657d9d2c68b9: Already exists
f47b5ee58e91: Already exists
2b62153f094c: Already exists
60b09083723b: Already exists
1701d4d0a478: Already exists
bae0c4dc63ea: Already exists
a1c05958a901: Already exists
5964d339be93: Already exists
1319bb6aacaa: Already exists
71860efe761d: Already exists
c5a84dbdd6a5: Already exists
Digest: sha256:584d2109fa4f3f0cf25358828254dc5668882167634384ad68537a3069d31652
Status: Downloaded newer image for php:7.4-apache

javier@debian:~$ docker run -d --name pruebavolumendocker -v miweb:/var/www/html -p 8080:80 php:7.4-apache
9b350c4f505b085d9633f8f46bb3a200266d4d09785c6311adae82daf1834403
</pre>

Listo.

- **Utiliza el comando `docker cp` para copiar un fichero `info.php` en el directorio `/var/www/html`.**

Copiamos el archivo `info.php`:

<pre>
javier@debian:~$ docker cp info.php pruebavolumendocker:/var/www/html
</pre>

Listo.

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `info.php`.**

Nos dirigimos a la dirección `http://localhost:8080/info.php`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/info.php.png" />

Efectivamente podemos visualizar el fichero `info.php`.

- **Borra el contenedor.**

Eliminamos el contenedor:

<pre>
javier@debian:~$ docker rm -f pruebavolumendocker
pruebavolumendocker
</pre>

Listo.

- **Crea un nuevo contenedor y monta el mismo volumen como en el ejercicio anterior.**

Creamos el contenedor:

<pre>
javier@debian:~$ docker run -d --name pruebavolumendocker2 -v miweb:/var/www/html -p 8080:80 php:7.4-apache
4fe9ed47558cbc4e44c73c2d4507228828bf003048c137491df434ec6e3ca58c
</pre>

Listo.

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `info.php`. ¿Seguía existiendo ese fichero?**

Podemos ver que sí, ya que estamos utilizando el mismo volumen.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/info.php2.png" />



#### Trabajando con bind mount:

- **Crea un directorio en tu *host* y dentro crea un fichero `index.html`.**

Creamos el directorio y el fichero:

<pre>
javier@debian:~$ mkdir pruebadocker

javier@debian:~$ nano pruebadocker/index.html
</pre>

Listo.

- **Crea un contenedor desde la imagen `php:7.4-apache` donde montes en el directorio `/var/www/html` el directorio que has creado por medio de bind mount.**

Creamos el contenedor:

<pre>
javier@debian:~$ docker run -d --name bindmount -v /home/javier/pruebadocker:/var/www/html -p 8080:80 php:7.4-apache
6796f397cf0f9c1331778dc917caff72885bf3e594272d46e1fa65f3b58c686f
</pre>

Listo.

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `index.html`.**

Nos dirigimos a la dirección `http://localhost:8080`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/bindmount1.png" />

Podemos visualizar la información.

- **Modifica el contenido del fichero `index.html` en tu *host* y comprueba que al refrescar la página ofrecida por el contenedor, el contenido ha cambiado.**

Modificamos el contenido del fichero `index.html`:

<pre>
javier@debian:~$ nano pruebadocker/index.html
</pre>

Nos dirigimos a la dirección `http://localhost:8080`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/bindmount2.png" />

Efectivamente ha cambiado el contenido.

- **Borra el contenedor**

Eliminamos el contenedor:

<pre>
javier@debian:~$ docker rm -f bindmount
bindmount
</pre>

Listo.

- **Crea un nuevo contenedor y monta el mismo directorio como en el ejercicio anterior.**

Creamos el contenedor:

<pre>
javier@debian:~$ docker run -d --name bindmount2 -v /home/javier/pruebadocker:/var/www/html -p 8080:80 php:7.4-apache
5a1d596d751ae93fb1acc99f32f830573e89652cfb5d3a4900cfc9c835ea2fdb
</pre>

Listo.

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `index.html`. ¿Se sigue viendo el mismo contenido?**

Al igual que en el ejercicio anterior, podemos ver que sí, ya que estamos utilizando el mismo volumen.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/bindmount2.png" />


#### Trabajando con contenedores con almacenamiento persistente

- **Crea un contenedor desde la imagen *Nextcloud* (usando *sqlite*) configurando el almacenamiento como nos muestra la documentación de la imagen en *Docker Hub* (pero utilizando bind mount). Sube algún fichero.**

Creamos el contenedor:

<pre>
javier@debian:~$ mkdir nextcloud

javier@debian:~$ docker run -d --name Nextcloud -v /home/javier/nextcloud:/var/www/html -p 8080:80 nextcloud
1fd90edb9161d28a68c58799ddeea2c58ce0acec3e85663997baae9987709274
</pre>

Nos dirigimos a la dirección `http://localhost:8080`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/nextcloud.png" />

Lo instalamos con una base de datos **sqlite** y una vez lo tengamos instalado, subimos cualquier fichero. En mi caso he subido el fichero llamado **logojp.jpg**.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/nextcloud2.png" />

Listo.

- **Elimina el contenedor.**

Eliminamos el contenedor:

<pre>
javier@debian:~$ docker rm -f Nextcloud
Nextcloud
</pre>

Listo.

- **Crea un contenedor nuevo con la misma configuración de volúmenes. Comprueba que la información que teníamos (ficheros, usuaurio, …), sigue existiendo.**

Creamos el nuevo contenedor llamado **Nextcloud2**:

<pre>
javier@debian:~$ docker run -d --name Nextcloud2 -v /home/javier/nextcloud:/var/www/html -p 8080:80 nextcloud
b102fd06e36cba2e26db09414359892e3ad403a64715f7e4311cad460b2d7684
</pre>

Nos dirigimos a la dirección `http://localhost:8080`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/nextcloud3.png" />

Podemos ver como esta vez no nos pide instalar la aplicación, sino que directamente nos pide que iniciemos sesión. Iniciamos sesión con el usuario creado anteriormente y visualizamos los archivos:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/nextcloud4.png" />

Efectivamente se encuentra el logo que hemos subido en el anterior contenedor, por lo que no hemos perdido la información al eliminar el contenedor.

- **Comprueba el contenido de directorio que se ha creado en el *host*.**

Visualizamos el contenido del directorio `/home/javier/nextcloud`:

<pre>
javier@debian:~/nextcloud$ ls
3rdparty  config       core         data        lib           ocs           remote.php  status.php
apps      console.php  cron.php     index.html  occ           ocs-provider  resources   themes
AUTHORS   COPYING      custom_apps  index.php   ocm-provider  public.php    robots.txt  version.php
</pre>

Podemos ver como efectivamente se encuentran todos los datos de la web.


## Redes

#### Introducción a las redes en docker

Aunque hasta ahora no lo hemos tenido en cuenta, cada vez que creamos un contenedor, esté se conecta a una red virtual, y*Docker* hace una configuración del sistema (usando interfaces puente e *iptables*) para que la máquina tenga una IP interna, tenga acceso al exterior, podamos mapear (DNAT) puertos, ...).

<pre>
$ docker run -it --rm debian bash -c "ip a"
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
28: eth0@if29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
</pre>

**NOTA:** Hemos usado la opción `--rm` para que, cuando el proceso termine de ejecutarse, el contenedor se elimine.

Observamos que el contenedor tiene una IP en la red `172.17.0.0/16`. Además podemos comprobar que se ha creado un *bridge* en el *host*, al que se conectan los contenedores:

<pre>
$ ip a
...
5: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:be:71:11:9e brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:beff:fe71:119e/64 scope link
       valid_lft forever preferred_lft forever
...
</pre>

Además podemos comprobar que se han creado distintas cadenas en el cortafuegos para gestionar la comunicación de los contenedores. Podemos ejecutar: `iptables -L -n` y `iptables -L -n - t nat` y verificarlo.

#### Tipos de redes en Docker

Cuando instalamos *Docker* tenemos las siguientes redes predefinidas:

<pre>
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
ec77cfd20583        bridge              bridge              local
69bb21378df5        host                host                local
089cc966eaeb        none                null                local
</pre>

Por defecto los contenedores que creamos se conectan a la red de tipo *bridge* llamada **bridge** (por defecto el direccionamiento de esta red es `172.17.0.0/16`). Los contenedores conectados a esta red que quieren exponer algún puerto al exterior tienen que usar la opción `-p` para mapear puertos.

Este tipo de red nos va a permitir:

- Aislar los distintos contenedores que tengamos en distintas subredes *Docker*, de tal manera que desde cada una de las subredes solo podremos acceder a los equipos de esa misma subred.
- Aislar los contenedores del acceso exterior.
- Publicar servicios que tengamos en los contenedores mediante redirecciones que *Docker* implementará con las pertinentes reglas de *iptables*.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/redesdocker.png" />

Si conectamos un contenedor a la red *host*, el contenedor estaría en la misma red que el *host* (por lo tanto toma direccionamiento del servidor *DHCP* de nuestra red). Además los puerto son accesibles directamente desde el *host*. Por ejemplo:

<pre>
$ docker run -d --name mi_servidor --network host josedom24/aplicacionweb:v1

$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS               NAMES
135c742af1ff        josedom24/aplicacionweb:v1   "/usr/sbin/apache2ct…"   3 seconds ago       Up 2 seconds                                  mi_servidor
</pre>

Si probamos a acceder directamente al puerto 80 del servidor, podremos ver la página web.

La red *none* no configurará ninguna IP para el contenedor y no tiene acceso a la red externa ni a otros contenedores. Tiene la dirección *loopback* y se puede usar para ejecutar trabajos por lotes.

#### Gestionando las redes en Docker

Tenemos que hacer una diferenciación entre dos tipos de redes **bridged**:

- La red creada por defecto por *Docker* para que funcionen todos los contenedores.
- Y las redes *bridged* definidas por el usuario.

Esta red *bridged*, que es la usada por defecto por los contenedores, se diferencia en varios aspectos de las redes *bridged* que creamos nosotros. Estos aspectos son los siguientes:

- Las redes que nosotros definimos proporcionan resolución DNS entre los contenedores, cosa que la red por defecto no hace, a no ser que usemos opciones que ya se consideran *deprectated* (`--link`).
- Se pueden conectar en caliente a los contenedores redes *bridged* definidas por el usuario. Si uso la red por defecto tengo que parar previamente el contenedor.
- Nos permite gestionar de manera más segura el aislamiento de los contenedores, ya que si no indico una red al arrancar un contenedor, éste se incluye en la red por defecto, donde pueden convivir servicios que no tengan nada que ver.
- Tenemos más control sobre la configuración de las redes si las definimos nosotros. Los contenedores de la red por defecto comparten todos la misma configuración de red (MTU, reglas *iptables*, ...).
- Los contenedores dentro de la red *bridge* comparten todos ciertas variables de entorno, lo que puede provocar ciertos conflictos.

En definitiva, es importante que nuestro contenedores en producción, se estén ejecutando sobre una red definida por el usuario.

Para gestionar las redes creadas por el usuario:

- **docker network ls:** listado de las redes
- **docker network create:** creación de redes. Ejemplos:
    - `docker network create red1`
    - `docker network create -d bridge --subnet 172.24.0.0./16 --gateway 172.24.0.1 red2`
- **docker network rm/prune:** borra redes. Teniendo en cuenta que se no puede borrar una red que tenga contenedores que la estén usando, primero deberíamos borrar los contenedores, o desconectar la red de ese contenedor.
- **docker network inspect:** nos da información de la red

**NOTA:** Cada red *Docker* que creemos, creará un puente de red específico. Podemos ver con `ip a`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_docker/redesdocker2.png" />

#### Asociación de redes a los contenedores

Imaginemos que hemos creado dos redes definidas por el usuario:

<pre>
$ docker network create --subnet 172.28.0.0/16 --gateway 172.28.0.1 red1
$ docker network create red2
</pre>

Vamos a trabajar en un primer momento con la *red1*. Vamos a crear dos contenedores conectados a dicha red:

<pre>
$ docker run -d --name my-apache-app --network red1 -p 8080:80 httpd:2.4
</pre>

Lo primero que vamos a comprobar es la resolución DNS:

<pre>
$ docker run -it --name contenedor1 --network red1 debian bash
root@98ab5a0c2f0c:/# apt update && apt install dnsutils -y
...
root@98ab5a0c2f0c:/# dig my-apache-app
...
;; ANSWER SECTION:
my-apache-app.		600	IN	A	172.28.0.2
...
;; SERVER: 127.0.0.11#53(127.0.0.11)
...
</pre>

Ahora podemos probar como podemos conectar un contenedor a una red. Para ello, usaremos `docker network connect` y para desconectarla usaremos `docker network disconnect`.

<pre>
$ docker network connect red2 contenedor1

$ docker start contenedor1
contenedor1

$ docker attach contenedor1
root@98ab5a0c2f0c:/# ip a
...
46: eth0@if47: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    ...
    inet 172.28.0.4/16 brd 172.28.255.255 scope global eth0
...
48: eth1@if49: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
...    
    inet 172.18.0.3/16 brd 172.18.255.255 scope global eth1
...
</pre>

Tanto al crear un contenedor con el *flag* `--network`, como con la instrucción `docker network connect`, podemos usar algunos otros *flags*:

- `--dns`: para establecer unos servidores DNS predeterminados
- `--ip6`: para establecer la dirección de red ipv6
- `--hostname` o `-h`: para establecer el nombre de *host* del contenedor. Si no lo establezco será el ID del mismo.

#### Instalación de WordPress

Para la instalación de WordPress necesitamos dos contenedores: la base de datos (imagen *mariadb*) y el servidor web con la aplicación (imagen *wordpress*). Los dos contenedores tienen que estar en la misma red y deben tener acceso por nombres (resolución DNS), ya que en un principio no sabemos que IP va a poseer cada contenedor. Por lo tanto vamos a crear los contenedores en la misma red:

<pre>
docker network create red_wp
</pre>

Siguiendo la documentación de la imagen *mariadb* y la imagen *wordpress* podemos ejecutar los siguientes comandos para crear los dos contenedores:

<pre>
docker run -d --name servidor_mysql \
           --network red_wp \
           -v /opt/mysql_wp:/var/lib/mysql \
           -e MYSQL_DATABASE=bd_wp \
           -e MYSQL_USER=user_wp \
           -e MYSQL_PASSWORD=asdasd \
           -e MYSQL_ROOT_PASSWORD=asdasd \
           mariadb

...

docker run -d --name servidor_wp \
             --network red_wp \
             -v /opt/wordpress:/var/www/html/wp-content \
             -e WORDPRESS_DB_HOST=servidor_mysql \
             -e WORDPRESS_DB_USER=user_wp \
             -e WORDPRESS_DB_PASSWORD=asdasd \
             -e WORDPRESS_DB_NAME=bd_wp \
             -p 80:80 \
             wordpress

...

javier@debian:~$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                NAMES
454c7149baba        wordpress           "docker-entrypoint.s…"   8 seconds ago        Up 7 seconds        0.0.0.0:80->80/tcp   servidor_wp
1923a8dc9f48        mariadb             "docker-entrypoint.s…"   About a minute ago   Up About a minute   3306/tcp             servidor_mysql
</pre>

Algunas observaciones:

- El contenedor *servidor_mysql* ejecuta un *script* `docker-entrypoint.sh` que es el encargado, a partir de las variables de entorno, de configurar la base de datos: crea un usuario, crea la base de datos, cambia la contraseña del usuario *root*, ... y termina ejecutando el servidor *mariadb*.

- Los creadores de la imagen *mariadb*, han tenido en cuenta que el contenedor, tiene que permitir la conexión desde otra máquina, por lo que, en su configuración, se encuentra comentado el parámetro `bind-address`.

- Del mismo modo, el contenedor *servidor_wp* ejecuta un *script* `docker-entrypoint.sh`, que entre otras cosas, a partir de las variables de entorno, ha creado el fichero `wp-config.php` de *WordPress*, por lo que durante la instalación no nos pedirá las credenciales de la base de datos.

- Si nos fijamos, la variable de entorno `WORDPRESS_DB_HOST` la hemos inicializado al nombre del servidor de base de datos. Como ambos contenedores están conectados a la misma red definida por el usuario, el contenedor *WordPress* al intentar acceder al nombre *servidor_mysql*, estará accediendo al contenedor de la base de datos.

- El servicio al que vamos a acceder desde el exterior es al servidor web, es por lo que hemos mapeado los puertos con la opción `-p`. Sin embargo, en el contenedor de la base de datos no es necesario mapear los puertos porque no vamos a acceder a ella desde el exterior. Eso sí, el contenedor *servidor_wp*, sí puede acceder al puerto 3306 del *servidor_mysql* sin problemas, ya que están conectados a la misma red.

Para terminar, vamos a ver si realmente las configuraciones que hemos realizado mediante parámetros a la hora de crear los contenedores se han llevado a cabo.

Primeramente, vamos a comprobar en el fichero `wp-config.php` del contenedor de *WordPress*, que los parámetros de conexión a la base de datos son los mismos que los indicados en las variables de entorno.

<pre>
javier@debian:~$ docker exec servidor_wp cat wp-config.php
...

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'bd_wp');

/** MySQL database username */
define( 'DB_USER', 'user_wp');

/** MySQL database password */
define( 'DB_PASSWORD', 'asdasd');

/** MySQL hostname */
define( 'DB_HOST', 'servidor_mysql');

...
</pre>

Bien, vemos que sí.

Ahora vamos a comprobar que los contenedores posean conexión entre sí mediante resolución de nombres, para ello, vamos a intentar realizar un *ping* desde el contenedor *servidor_wp* usando el nombre *servidor_mysql* (tendremos que instalar el paquete `iputils-ping` en el contenedor).

<pre>
javier@debian:~$ docker exec -it servidor_wp /bin/bash

root@454c7149baba:/var/www/html# apt update
...

root@454c7149baba:/var/www/html# apt install iputils-ping
...

root@454c7149baba:/var/www/html# ping servidor_mysql
PING servidor_mysql (172.18.0.2) 56(84) bytes of data.
64 bytes from servidor_mysql.red_wp (172.18.0.2): icmp_seq=1 ttl=64 time=0.127 ms
64 bytes from servidor_mysql.red_wp (172.18.0.2): icmp_seq=2 ttl=64 time=0.093 ms
64 bytes from servidor_mysql.red_wp (172.18.0.2): icmp_seq=3 ttl=64 time=0.094 ms
^C
--- servidor_mysql ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 22ms
rtt min/avg/max/mdev = 0.093/0.104/0.127/0.019 ms
</pre>

Efectivamente el *ping* se ha realizado correctamente.

Por último, vamos a comprobar que en el fichero `/etc/mysql/mariadb.conf.d/50-server.cnf` del contenedor con la base de datos, se encuentre comentado el parámetro `bind-address` como he indicado anteriormente.

<pre>
javier@debian:~$ docker exec servidor_mysql cat /etc/mysql/mariadb.conf.d/50-server.cnf
...

# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
#bind-address            = 127.0.0.1

...
</pre>

En este caso la respuesta vuelve a ser afirmativa, por lo que acabamos de comprobar que todas las configuraciones se han llevado a cabo de la manera esperada.

.
