---
layout: post
---

## Control de acceso

El **Control de acceso** en un servidor web nos permite determinar desde donde podemos acceder a los recursos del servidor.

En **apache2.2** se utilizan las siguientes directivas: [order](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#order), [allow](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#allow) y [deny](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#deny). Un buen manual para que quede más claro lo puedes encontrar en este [enlace](http://systemadmin.es/2011/04/la-directiva-order-de-apache). La directiva [satisfy](http://httpd.apache.org/docs/2.2/mod/core.html#satisfy) controla como se debe comportar el servidor cuando tenemos autorizaciones de control de acceso (allow, deny,…) y tenemos autorizaciones de usuarios (require).

En **apache2.4** se utilizan las siguientes directivas: [Require](https://httpd.apache.org/docs/2.4/es/mod/mod_authz_core.html#require), [RequireAll](https://httpd.apache.org/docs/2.4/es/mod/mod_authz_core.html#requireall), [RequireAny](https://httpd.apache.org/docs/2.4/es/mod/mod_authz_core.html#requireany) y [RequireNone](https://httpd.apache.org/docs/2.4/es/mod/mod_authz_core.html#requirenone)

**1. Comprueba el control de acceso por defecto que tiene el virtual host por defecto (000-default).**

De manera predeterminada, el fichero de configuración `000-default` tiene este control de acceso:

<pre>
VirtualHost *:80
</pre>

Vemos que el control de acceso es de cualquier dirección, mientras el puerto establecido sea el 80.

## Autentificación básica

El servidor web Apache puede acompañarse de distintos módulos para proporcionar diferentes modelos de autenticación. La primera forma que veremos es la más simple. Usamos para ello el módulo de autenticación básica que viene instalada “de serie” con cualquier Apache: [mod_auth_basic](http://httpd.apache.org/docs/2.4/es/mod/mod_auth_basic.html). La configuración que tenemos que añadir en el fichero de definición del Virtual Host a proteger podría ser algo así:

<pre>
<\Directory "/var/www/miweb/privado">
  AuthUserFile "/etc/apache2/claves/passwd.txt"
  AuthName "Palabra de paso"
  AuthType Basic
  Require valid-user
<\/Directory>
</pre>

El método de autentificación básica se indica en la directiva [AuthType](http://httpd.apache.org/docs/2.4/es/mod/core.html#authtype).

- En `Directory` escribimos el directorio a proteger, que puede ser el raíz de nuestro Virtual Host o un directorio interior a este.
- En [AuthUserFile](http://httpd.apache.org/docs/2.4/es/mod/mod_authn_file.html#authuserfile) ponemos el fichero que guardará la información de usuarios y contraseñas que debería de estar, como en este ejemplo, en un directorio que no sea visitable desde nuestro Apache. Ahora comentaremos la forma de generarlo.
- Por último, en [AuthName](http://httpd.apache.org/docs/2.4/es/mod/core.html#authname) personalizamos el mensaje que aparecerá en la ventana del navegador que nos pedirá la contraseña.
- Para controlar el control de acceso, es decir, que usuarios tienen permiso para obtener el recurso utilizamos las siguientes directivas: [AuthGroupFile](http://httpd.apache.org/docs/2.4/es/mod/mod_authz_groupfile.html#authgroupfile), [Require user](http://httpd.apache.org/docs/2.4/es/mod/core.html#require), [Require group](http://httpd.apache.org/docs/2.4/es/mod/core.html#require).

El fichero de contraseñas se genera mediante la utilidad `htpasswd`. Su sintaxis es bien sencilla. Para añadir un nuevo usuario al fichero operamos así:

<pre>
htpasswd /etc/apache2/claves/passwd.txt carolina
New password:
Re-type new password:
Adding password for user carolina
</pre>

Para crear el fichero de contraseñas con la introducción del primer usuario tenemos que añadir la opción `-c` (create) al comando anterior. Si por error la seguimos usando al incorporar nuevos usuarios borraremos todos los anteriores, así que cuidado con esto. Las contraseñas, como podemos ver a continuación, no se guardan en claro. Lo que se almacena es el resultado de aplicar una [función hash](https://es.wikipedia.org/wiki/Funci%C3%B3n_hash):

<pre>
josemaria:rOUetcAKYaliE
carolina:hmO6V4bM8KLdw
alberto:9RjyKKYK.xyhk
</pre>

Para denegar el acceso a algún usuario basta con que borremos la línea correspondiente al mismo. No es necesario que le pidamos a Apache que vuelva a leer su configuración cada vez que hagamos algún cambio en este fichero de contraseñas.

La principal ventaja de este método es su sencillez. Sus inconvenientes: lo incómodo de delegar la generación de nuevos usuarios en alguien que no sea un administrador de sistemas o de hacer un front-end para que sea el propio usuario quien cambie su contraseña. Y, por supuesto, que dichas contraseñas viajan en claro a través de la red. Si queremos evitar esto último podemos crear una [instancia Apache con SSL](https://blog.unlugarenelmundo.es/2008/09/23/chuletillas-y-viii-apache-2-con-ssl-en-debian/).

### Cómo funciona este método de autentificación

Cuando desde el cliente intentamos acceder a una URL que esta controlada por el método de autentificación básico:

**1. El servidor manda una respuesta del tipo 401 *HTTP/1.1 401 Authorization Required* con una cabecera `WWW-Authenticate` al cliente de la forma:**

<pre>
WWW-Authenticate: Basic realm="Palabra de paso"
</pre>

**2. El navegador del cliente muestra una ventana emergente preguntando por el nombre de usuario y contraseña y cuando se rellena se manda una petición con una cabecera `Authorization`**:

<pre>
Authorization: Basic am9zZTpqb3Nl
</pre>

En realidad la información que se manda es el **nombre de usuario** y la **contraseña en base 64**, que se puede decodificar fácilmente con cualquier [utilidad](https://www.base64decode.org/).

## Autentificación tipo digest

La autentificación tipo **digest** soluciona el problema de la transferencia de contraseñas en claro sin necesidad de usar SSL. El procedimiento, como veréis, es muy similar al tipo básico pero cambiando algunas de las directivas y usando la utilidad `htdigest` en lugar de `htpassword` para crear el fichero de contraseñas. El módulo de autenticación necesario suele venir con Apache pero no habilitado por defecto. Para activarlo usamos la utilidad `a2enmod` y, a continuación reiniciamos el servidor Apache:

<pre>
a2enmod auth_digest
/etc/init.d/apache2 restart
</pre>

Luego incluimos una sección como esta en el fichero de configuración de nuestro Virtual Host:

<pre>
<\Directory "/var/www/miweb/privado">
  AuthType Digest
  AuthName "dominio"
  AuthUserFile "/etc/claves/digest.txt"
  Require valid-user
<\/Directory>
</pre>

Como vemos, es muy similar a la configuración necesaria en la autenticación básica. La directiva `AuthName` que en la autenticación básica se usaba para mostrar un mensaje en la ventana que pide el usuario y contraseña, ahora se usa también para identificar un nombre de dominio (realm) que debe de coincidir con el que aparezca después en el fichero de contraseñas. Dicho esto, vamos a generar dicho fichero con la utilidad htdigest:

<pre>
htdigest -c /etc/claves/digest.txt dominio josemaria
Adding password for josemaria in realm dominio.
New password:
Re-type new password:
</pre>

Al igual que ocurría con `htpassword`, la opción `-c` (create) sólo debemos de usarla al crear el fichero con el primer usuario. Luego añadiremos los restantes usuarios prescindiendo de ella. A continuación vemos el fichero que se genera después de añadir un segundo usuario:

<pre>
josemaria:dominio:8d6af4e11e38ee8b51bb775895e11e0f
gemma:dominio:dbd98f4294e2a49f62a486ec070b9b8c
</pre>

### Cómo funciona este método de autentificación

Cuando desde el cliente intentamos acceder a una URL que esta controlada por el método de autentificación de tipo digest:

**1. El servidor manda una respuesta del tipo 401 *HTTP/1.1 401 Authorization Required* con una cabecera `WWW-Authenticate` al cliente de la forma:**

<pre>
WWW-Authenticate: Digest realm="dominio",
                  nonce="cIIDldTpBAA=9b0ce6b8eff03f5ef8b59da45a1ddfca0bc0c485",
                  algorithm=MD5,
                  qop="auth"
</pre>

**2. El navegador del cliente muestra una ventana emergente preguntando por el nombre de usuario y contraseña y cuando se rellena se manda una petición con una cabecera `Authorization`**

<pre>
Authorization	Digest username="jose",
               realm="dominio",
               nonce="cIIDldTpBAA=9b0ce6b8eff03f5ef8b59da45a1ddfca0bc0c485",
               uri="/digest/",
               algorithm=MD5,
               response="814bc0d6644fa1202650e2c404460a21",
               qop=auth,
               nc=00000001,
               cnonce="3da69c14300e446b"
</pre>

La información que se manda es responde que en este caso esta cifrada usando md5 y que se calcula de la siguiente manera:

- Se calcula el md5 del nombre de usuario, del dominio (realm) y la contraseña, la llamamos **HA1**.
- Se calcula el md5 del método de la petición (por ejemplo GET) y de la uri a la que estamos accediendo, la llamamos **HA2**.
- El reultado que se manda es el md5 de HA1, un número aleatorio (nonce), el contador de peticiones (nc), el qop y el HA2.

Una vez que lo recibe el servidor, puede hacer la misma operación y comprobar si la información que se ha enviado es válida, con lo que se permitiría el acceso.

## Ejercicios

**Crea un escenario en Vagrant o reutiliza uno de los que tienes en ejercicios anteriores, que tenga un servidor con una red pública, y una privada y un cliente conectado a la red privada. Crea un host virtual `departamentos.iesgn.org`.**

He creado este fichero Vagrantfile para definir el escenario:

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

 config.vm.define :servidor do |servidor|
  servidor.vm.box="debian/buster64"
  servidor.vm.hostname="servidor"
  servidor.vm.network :public_network, :bridge=>"wlo1"
  servidor.vm.network :private_network, ip: "192.168.150.1", virtualbox__intnet: "redprivadaApache"
 end

 config.vm.define :cliente do |cliente|
  cliente.vm.box="debian/buster64"
  cliente.vm.hostname="cliente"
  cliente.vm.network :private_network, ip: "192.168.150.10", virtualbox__intnet: "redprivadaApache"
 end

end
</pre>

Confirmamos que en la máquina **servidor** se han creado correctamente las interfaces de red pública y privada:

<pre>
vagrant@servidor:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86000sec preferred_lft 86000sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:5b:f1:f9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.38/24 brd 192.168.0.255 scope global dynamic eth1
       valid_lft 86009sec preferred_lft 86009sec
    inet6 fe80::a00:27ff:fe5b:f1f9/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:28:bb:c2 brd ff:ff:ff:ff:ff:ff
    inet 192.168.150.1/24 brd 192.168.150.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe28:bbc2/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Podemos ver como la IP pública que posee es la **192.168.0.38** y la IP privada la **192.168.150.1**. Pero aún no hemos cambiado la puerta de enlace para que tenga conectividad a internet a través de la máquina anfitriona:

<pre>
vagrant@servidor:~$ sudo ip r replace default via 192.168.0.1

vagrant@servidor:~$ ip r
default via 192.168.0.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.38
192.168.150.0/24 dev eth2 proto kernel scope link src 192.168.150.1
</pre>

Ya sí puede acceder a mi router doméstico y por tanto posee conexión.

Vamos a hacer lo mismo para la máquina **cliente**. Vemos las interfaces de red:

<pre>
vagrant@cliente:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 85783sec preferred_lft 85783sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:93:04:32 brd ff:ff:ff:ff:ff:ff
    inet 192.168.150.10/24 brd 192.168.150.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe93:432/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Nos ha creado bien la dirección IP de la red privada, que es la **192.168.150.10**. Cambiamos la puerta de enlace para que tenga conexión a la máquina servidor:

<pre>
vagrant@cliente:~$ sudo ip r replace default via 192.168.150.1

vagrant@cliente:~$ ip r
default via 192.168.150.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.150.0/24 dev eth1 proto kernel scope link src 192.168.150.10
</pre>

Y ahora sí, tenemos configuradas las dos máquinas correctamente y podemos empezar a realizar los procedimientos.

Vamos a instalar **apache**. Para esto, antes de nada voy a actualizar los paquetes necesarios, y voy a desinstalar los que ya no hagan falta. Esto lo hago porque la box que estoy utilizando es de **Debian 10.4** y a día de hoy la versión estable es la **10.6**:

<pre>
apt update && apt upgrade -y && apt autoremove -y && apt install apache2 -y
</pre>

Una vez instalado Apache, podemos empezar a realizar las configuraciones. Lo primero antes de crear el sitio web, es habilitar la ruta donde vamos a crear la estructura de nuestra página. En mi caso la voy a situar en `/srv/departamentos`, esta dirección por defecto no viene habilitada para servir los archivos que creemos, por tanto, lo primero sería darle permisos, y para ello vamos a descomentar las siguientes líneas en `/etc/apache2/apache2.conf`:

<pre>
<\Directory /srv/\>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
<\/Directory\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

El siguiente paso sería crear el archivo de configuración del sitio web. Podemos copiar el fichero por defecto, que se encuentra en `/etc/apache2/sites-available` y a partir de éste, personalizar el nuevo:

<pre>
root@servidor:/etc/apache2/sites-available# cp 000-default.conf departamentos.conf

root@servidor:/etc/apache2/sites-available# nano departamentos.conf
</pre>

Editamos las siguientes líneas del fichero `departamentos.conf`:

<pre>
ServerName departamentos.iesgn.org
DocumentRoot /srv/departamentos
</pre>

Una vez terminado este fichero, tenemos que activar esta página:

<pre>
root@servidor:/etc/apache2/sites-available# a2ensite departamentos.conf
Enabling site departamentos.
To activate the new configuration, you need to run:
  systemctl reload apache2
</pre>

Ya solo nos falta crear el `index.html` que hemos especificado en la configuración de la página que se iba a encontrar en la ruta `/srv/departamentos`:

<pre>
root@servidor:/srv# mkdir departamentos

root@servidor:/srv# cd departamentos/

root@servidor:/srv/departamentos# nano index.html
</pre>

Reiniciamos el servicio y ya podemos visualizar la página.

<pre>
systemctl restart apache2
</pre>

Ojo, para poder ver esta web, debemos indicar en el archivo `/etc/hosts` de nuestra máquina anfitriona esta línea:

<pre>
192.168.0.38    departamentos.iesgn.org
</pre>

Y para poder ver esta web en la máquina **cliente**, debemos indicar en su archivo `/etc/hosts` esta línea:

<pre>
192.168.150.1    departamentos.iesgn.org
</pre>

**1. A la URL `departamentos.iesgn.org/intranet` sólo se debe tener acceso desde el cliente de la red local, y no se pueda acceder desde la anfitriona por la red pública. A la URL `departamentos.iesgn.org/internet`, sin embargo, sólo se debe tener acceso desde la anfitriona por la red pública, y no desde la red local.**

Lo primero sería crear en `/srv/departamentos` dos carpetas: una para **intranet** y otra para **internet**, y dentro de ellas crear un fichero `index.html`:

<pre>
root@servidor:srv/departamentos# mkdir intranet

root@servidor:srv/departamentos# cd intranet/

root@servidor:srv/departamentos/intranet# cp ../index.html ./

root@servidor:srv/departamentos/intranet# nano index.html

root@servidor:srv/departamentos/intranet# cd ..

root@servidor:srv/departamentos# mkdir internet

root@servidor:srv/departamentos# cp index.html ./internet/

root@servidor:srv/departamentos# cd internet/

root@servidor:srv/departamentos/internet# nano index.html
</pre>

Una vez tenemos creados las dos páginas webs, es el momento de establecer el control de acceso.

Las restricciones de acceso se llevan a cabo en el fichero de configuración de la web, es decir, en `/etc/apache2/sites-available/departamentos.conf`. Se nos pide que a la página `Intranet` pueda acceder la máquina conectada a la red local **192.168.150.0/24**, es decir nuestra mv, cuya IP es **192.168.150.10**, y a la página `Internet` cualquier equipo que no pertenezca a la red local.
Para ello el fichero debe quedar así:

<pre>
<\Directory /srv/departamentos/intranet \>
 Require ip 192.168.150
<\/Directory\>

<\Directory /srv/departamentos/internet \>
 <\RequireAll\>
   Require all granted
   Require not ip 192.168.150
 <\/RequireAll\>
<\/Directory\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Reiniciamos el servicio:

<pre>
systemctl restart apache2
</pre>

Con esto lo que estamos haciendo es:

- **Máquina anfitrión:** permitirle el acceso a la página `departamentos.iesgn.org/internet/`.

    - Si accedemos a `departamentos.iesgn.org/internet/`:

    <img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/anfitrioninternet.png" />

    - Si accedemos a `departamentos.iesgn.org/intranet/`:

    <img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/anfitrionintranet.png" />

- **Máquina cliente:** permitirle el acceso a la página `departamentos.iesgn.org/intranet/`.

    - Si accedemos a `departamentos.iesgn.org/internet/`:

    <img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/mvinternet.png" />

    - Si accedemos a `departamentos.iesgn.org/intranet/`:

    <img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/mvintranet.png" />


**2. Autentificación básica. Limita el acceso a la URL `departamentos.iesgn.org/secreto`. Comprueba las cabeceras de los mensajes HTTP que se intercambian entre el servidor y el cliente. ¿Cómo se manda la contraseña entre el cliente y el servidor?. Entrega una breve explicación del ejercicio.**

Lo primero sería crear en `/srv/departamentos` la carpeta **secreto** y dentro de ella crear un fichero `index.html`:

<pre>
root@servidor:/srv/departamentos# mkdir secreto

root@servidor:/srv/departamentos# cp index.html ./secreto/

root@servidor:/srv/departamentos# cd secreto/

root@servidor:/srv/departamentos/secreto# nano index.html
</pre>

Ahora vamos a configurar para que a la página `departamentos.iesgn.org/secreto` solo se pueda acceder si la persona está autorizada y posee un usuario y una contraseña.

Para ello, lo primero sería crear el **archivo de contraseñas** de Apache:

<pre>
root@servidor:/srv/departamentos/secreto# htpasswd -c /srv/departamentos/secreto/.htpasswd javier
New password:
Re-type new password:
Adding password for user javier
</pre>

Si quisiéramos añadir un nuevo usuario, deberíamos introducir el mismo comando pero sin la opción `-c`, ya que sino, nos crearía un nuevo un archivo machacando el ya existente.

Nos quedaría especificar en el `/etc/apache2/sites-available/departamentos.conf` esta configuración de autenticación básica. Debemos añadir algo así:

<pre>
<\Directory /srv/departamentos/secreto \>
 AuthType Basic
 AuthName "Identifiquese para acceder a esta pagina"
 AuthUserFile /srv/departamentos/secreto/.htpasswd
 Require valid-user
<\/Directory\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Reiniciamos el servicio:

<pre>
systemctl restart apache2
</pre>

Si ahora probamos a acceder a `departamentos.iesgn.org/secreto`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacion.png" />

Vemos que nos pide que iniciemos sesión ya que el contenido está protegido. Vamos a ver que puede pasar:

- Iniciamos sesión correctamente:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacioncompleta.png" />

- No iniciamos sesión o de manera incorrecta:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacionfallida.png" />

A primera vista podemos creer que este método de autenticación es segura, pero aún no he comentado el gran fallo que tiene. ¿Qué es lo último que deseamos cuando nos *logueamos* en una web? Exacto, que nuestras credenciales y nuestros datos no se conozcan y sean seguros, pues la **autenticación básica** no cuida esto, sino que envía nuestras contraseñas sin ningún tipo de cifrado y al descubierto, por lo que estamos totalmente expuestos.

He hecho una prueba capturando el tráfico, en la que podemos ver como cualquiera que esté escuchando el tráfico de la red, podría ver nuestros datos.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/wiresharkautenticacionbasica.png" />

Si nos fijamos en la línea seleccionada, que hace referencia a la petición que hemos hecho con nuestras credenciales, podemos ver como nos muestra la contraseña.

**3. Cómo hemos visto la autentificación básica no es segura, modifica la autentificación para que sea del tipo `digest`, y sólo sea accesible a los usuarios pertenecientes al grupo `directivos`. Comprueba las cabeceras de los mensajes HTTP que se intercambian entre el servidor y el cliente. ¿Cómo funciona esta autentificación?**

(Me he equivocado y he añadido los usuarios al grupo **gruposecreto** en vez de **directivos**).

Para llevar a cabo una autenticación de tipo **Digest**, antes debemos habilitar su módulo:

<pre>
a2enmod auth_digest
</pre>

 El proceso es muy parecido al anterior, por tanto lo primero sería crear el **archivo de contraseñas**:

<pre>
root@servidor:/srv/departamentos/secreto# htdigest -c /srv/departamentos/secreto/.htdigest gruposecreto javier
Adding password for javier in realm gruposecreto.
New password:
Re-type new password:
</pre>

A diferencia de la autenticación básica, en esta debemos añadir un nombre de domino, es decir, un grupo al que va a pertenecer el usuario.

Si quisiéramos añadir un nuevo usuario, deberíamos introducir el mismo comando pero sin la opción `-c`, ya que sino, nos crearía un nuevo un archivo machacando el ya existente.

Nos quedaría especificar en el `/etc/apache2/sites-available/departamentos.conf` esta configuración de autenticación básica. Debemos añadir algo así:

<pre>
<\Directory /srv/departamentos/secreto \>
 AuthType Digest
 AuthName "gruposecreto"
 AuthUserFile /srv/departamentos/secreto/.htdigest
 Require valid-user
<\/Directory\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Reiniciamos el servicio:

<pre>
systemctl restart apache2
</pre>

Si ahora probamos a acceder a `departamentos.iesgn.org/secreto`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacionhtdigest.png" />

Vemos que nos pide que iniciemos sesión ya que el contenido está protegido. Vamos a ver que puede pasar:

- Iniciamos sesión correctamente:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacioncompletahtdigest.png" />

- No iniciamos sesión o de manera incorrecta:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacionfallida.png" />

Antes vimos que la **autenticación básica** no era segura, vamos a ver si la **autenticación digest** lo es.

He hecho una prueba capturando el tráfico.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/wiresharkautenticaciondigest.png" />

Si nos fijamos en la línea seleccionada, que hace referencia a la petición que hemos hecho con nuestras credenciales, podemos ver como no nos muestra la contraseña como pasaba anteriormente.

**4. Vamos a combinar el control de acceso (tarea 6) y la autenticación (tareas 7 y 8), y vamos a configurar el virtual host para que se comporte de la siguiente manera: el acceso a la URL `departamentos.iesgn.org/secreto` se hace forma directa desde la intranet, desde la red pública te pide la autenticación. Muestra el resultado al profesor.**

Si queremos que los equipos conectados a la red local, es decir, los que posean una IP **192.168.150.X**, accedan de manera directa a la URL `departamentos.iesgn.org/secreto`, pero los demás equipos tengan que iniciar sesión y validarse para acceder, debemos editar el fichero `/etc/apache2/sites-available/departamentos.conf` de manera que tenga este aspecto:

<pre>
<\Directory /srv/departamentos/secreto \>
 AuthType Digest
 AuthName "gruposecreto"
 AuthUserFile /srv/departamentos/secreto/.htpasswd
 Require valid-user
 <\RequireAll\>
  Require all granted
  Require ip 192.168.150
 <\/RequireAll\>
<\/Directory\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Reiniciamos el servicio:

<pre>
systemctl restart apache2
</pre>

Si ahora probamos a acceder a `departamentos.iesgn.org/secreto`:

- **Máquina anfitrión:**

    <img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/internetaccesomedianteautentificacion.png" />

- **Máquina cliente:**

    <img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_control_de_acceso_autenticacion_y_autorizacion/intranetaccesodirecto.png" />
