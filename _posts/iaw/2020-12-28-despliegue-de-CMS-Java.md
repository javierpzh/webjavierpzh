---
layout: post
---

**En esta práctica vamos a desplegar un [CMS escrito en Java](https://java-source.net/open-source/content-managment-systems). Puedes escoger la aplicación que vas a desplegar de CMS escritos en Java o de [Aplicaciones Java en Bitnami](https://bitnami.com/tag/java).**

#### Aplicación escogida y su funcionalidad

He decidido escoger el **CMS escrito en Java**, llamado **Guacamole**.

*Apache Guacamole* es una herramienta libre que nos permite conectarnos remotamente a un servidor mediante el navegador web sin necesidad de usar un cliente.

Gracias a HTML5, una vez tengamos instalado y configurado *Apache Guacamole*, tan solo tenemos que conectarnos mediante el navegador web para empezar a trabajar remotamente.


#### Guía de los pasos fundamentales para realizar la instalación

1. Instalar *tomcat 9*.

2. Comprobar el acceso al puerto 8080.

3. Buscar un archivo `.war` y almacenarlo en la ruta `/var/lib/tomcat9/webapps`.

4. Acceder a la aplicación.

5. Realizar un **proxy inverso** en **Apache2** y realizar la configuración necesaria.

A continuación vamos a realizar la instalación de *tomcat 9* y de la aplicación en sí.

Antes de nada, necesitaremos un equipo donde trabajar. Yo voy a instalar una máquina virtual, y para ello, voy a utilizar *Vagrant*. He creado este *Vagrantfile*:

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "debian/buster64"

  config.vm.network "private_network", ip: "192.168.200.20"

end
</pre>

Una vez estamos en nuestro equipo de trabajo, en primer lugar, debemos instalar **Tomcat**, en mi caso, voy a instalar la versión *9*.

*Tomcat* requiere que **Java** esté instalado para poder ejecutar cualquier código de aplicación web *Java*.

<pre>
apt install default-jdk -y
</pre>

Instalado *Java*, ya podemos proceder a instalar *Tomcat*. Para ello:

<pre>
apt install tomcat9 -y
</pre>

Para comprobar el funcionamiento de una forma más visual, podemos conectarnos desde un navegador web mediante la dirección IP de la máquina especificando el puerto **8080**:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_despliegue_de_CMS_Java/tomcat8080.png" />

Vemos que está funcionando correctamente.

En este punto, ya podemos descargar el fichero `.war`.

¿Alguien se pregunta qué es un fichero `.war`?

Un fichero `.war` es una aplicación web que permite a *Tomcat* acceder a su utilización. El fichero `.war` tiene que ser descomprimido para ser leído.

Nos descargamos el fichero `.war` de la [página oficial de Apache Guacamole](https://guacamole.apache.org/releases/). En mi caso, descargo la última versión, que en este momento es la **1.2.0**. La he descargado desde mi máquina y la he pasado mediante `scp` a la máquina virtual *Vagrant*, aquí podemos ver que ya lo tenemos:

<pre>
root@buster:~# ls
guacamole-1.2.0.war
</pre>

Una vez la hemos descargado, tenemos que mover el archivo `.war` al directorio `/var/lib/tomcat9/webapps`, y podremos apreciar como automáticamente, al almacenar el fichero en esta ruta, se descomprime generando una carpeta llamada `guacamole-1.2.0` que es la que contiene la aplicación:

<pre>
root@buster:~# mv guacamole-1.2.0.war /var/lib/tomcat9/webapps

root@buster:~# ls /var/lib/tomcat9/webapps/
guacamole-1.2.0  guacamole-1.2.0.war  ROOT

root@buster:~# ls /var/lib/tomcat9/webapps/guacamole-1.2.0
app	   guacamole-common-js	guacamole.min.css  index.html	META-INF	       WEB-INF
fonts	   guacamole.css	guacamole.min.js   layouts	relocateParameters.js
generated  guacamole.js		images		   license.txt	translations
</pre>

Antes de probar a acceder desde el navegador, en mi caso, prefiero cambiarle el nombre a este nuevo directorio, para así no tener que escribir también la versión en cada acceso a la web:

<pre>
root@buster:/var/lib/tomcat9/webapps# mv guacamole-1.2.0 guacamole

root@buster:/var/lib/tomcat9/webapps# ls
guacamole  guacamole-1.2.0.war	ROOT
</pre>

Me he dado cuenta, que al cambiarle el nombre, el fichero `.war` vuelve a generar otra vez la carpeta `guacamole-1.2.0`. Parece ser que al cambiarle el nombre, este fichero detecta que la carpeta no está creada y la vuelve a originar de manera automática. Para solucionar esto, he eliminado el fichero `.war` y el nuevo directorio, de manera que ahora solo poseo el directorio `guacamole`.

Hecho esto, vamos a probar a acceder a la dirección `192.168.200.20:8080/guacamole`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_despliegue_de_CMS_Java/guacamole8080.png" />

Vemos que podemos acceder a la aplicación.

Hecho esto, vamos a llevar a cabo el último paso, que sería el de configurar nuestro servidor web **Apache** para que nos sirva nuestro CMS *Guacamole*, para lo que debemos realizar un **proxy inverso**.

Procedemos a instalar nuestro servidor web, para ello utilizamos el siguiente comando:

<pre>
apt install apache2 apache2-utils -y
</pre>

Ahora, necesitamos instalar el paquete que contiene los módulos fundamentales para conectar *Apache* con *tomcat9*:

<pre>
apt install libapache2-mod-jk -y
</pre>

Habilitamos los siguiente módulos:

<pre>
a2enmod proxy proxy_http
</pre>

Instalado y habilitado, vamos a crear un nuevo *virtualhost*. He copiado el fichero `000-default.conf` para que me sirva de plantilla para el *virtualhost* que verdaderamente voy a configurar, que es el llamado `guacamole.conf`:

<pre>
root@buster:/etc/apache2/sites-available# cp 000-default.conf guacamole.conf

root@buster:/etc/apache2/sites-available# nano guacamole.conf
</pre>

Editamos el nuevo *virtualhost* y queda con este aspecto:

<pre>
<\VirtualHost *:80\>

        ServerName www.guacamole-javierpzh.com

        ServerAdmin webmaster@localhost
        DocumentRoot /srv/www/guacamole

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        <\Location /guacamole/\>
          Order allow,deny
          Allow from all
          ProxyPass http://localhost:8080/guacamole/ flushpackets=on
          ProxyPassReverse http://localhost:8080/guacamole/
        <\/Location\>

<\/VirtualHost\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

El último bloque, hace referencia y sirve para configurar el *proxy inverso*.

También podemos ver, como he especificado que el contenido de esta web, estará en `/srv/www/guacamole`, pues bien, para que *Apache* sea capaz de buscar en dicho directorio, debemos dirigirnos al fichero `/etc/apache2/apache2.conf`, y descomentar o añadir el siguiente bloque, ya que por defecto, solo nos proporciona el contenido almacenado en `/var/`:

<pre>
<\Directory /srv/\>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
<\/Directory\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

En este punto, solo nos quedaría crear un fichero `index.html` en la ruta `/srv/www/guacamole`. En mi caso el contenido de este fichero es el siguiente:

<pre>
<\h1\>Si quieres ir a Guacamole,haz click <\a href=http://www.guacamole-javierpzh.com/guacamole/#/\> aqui<\/a\><\/h1\>
</pre>

**Atención:** a estas líneas hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiarlas, debemos tener en cuenta esto.

Por último, vamos a reiniciar nuestro servidor web:

<pre>
systemctl restart apache2
</pre>

Voy a añadir a mi máquina anfitriona la siguiente línea en el fichero `/etc/hosts` para poder utilzar la
resolución estática:

<pre>
192.168.200.20  www.guacamole-javierpzh.com
</pre>

Nos dirigimos a nuestro navegador e introducimos la dirección `www.guacamole-javierpzh.com`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_despliegue_de_CMS_Java/proxyinverso.png" />

Hacemos *click* para dirigirnos al enlace:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_despliegue_de_CMS_Java/guacamoleapache.png" />

Ya estaríamos viendo nuestra aplicación servida por nuestro servidor web *Apache*, por lo que habríamos terminado con el *post*.
