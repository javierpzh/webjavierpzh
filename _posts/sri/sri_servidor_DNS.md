---
layout: post
---
Servidor DNS
Category: Servicios de Red e Internet
Date: 2020/12/11
Header_Cover: theme/images/banner-servicios.jpg
Tags: DNS, bind9, dnsmasq

### Escenario

1. **En nuestra red local tenemos un servidor Web que sirve dos páginas web: `www.iesgn.org`, `departamentos.iesgn.org`.**

2. **Vamos a instalar en nuestra red local un servidor DNS (lo puedes instalar en el mismo equipo que tiene el servidor web).**

3. **Voy a suponer en este documento que el nombre del servidor DNS va a ser `pandora.iesgn.org`. El nombre del servidor de tu prácticas será `tunombre.iesgn.org`.**

### Servidor DNSmasq

**Instala el servidor DNS *dnsmasq* en `pandora.iesgn.org` y configúralo para que los clientes puedan conocer los nombres necesarios.**

He creado una instancia en el *cloud* de **OpenStack** que será la máquina que actuará como **servidor**, posee una dirección IP **172.22.200.174**.

Las dos páginas servidas por *Apache2* las he creado pero voy a omitir su explicación, pues ya tengo otras entradas en las que hablo expresamente de esto. Te dejo este enlace por si quieres saber algo más de [Apache2](https://javierpzh.github.io/tag/apache.html).

**Importante:** como estamos trabajando en el *cloud*, he tenido que abrir el puerto **53/UDP**, ya que es el puerto que se utiliza para recibir las peticiones de parte de los clientes.

Una vez en ella, lo primero que debemos hacer es instalar el siguiente paquete:

<pre>
apt install dnsmasq -y
</pre>

Para comenzar a configurar el servidor *dnsmasq*, empezaremos por descomentar la siguiente línea en el fichero `/etc/dnsmasq.conf` para que el servidor *dnsmasq* pueda leer en caso de que sea necesario, es decir, cuando él mismo no pueda resolver una petición, la configuración del fichero `/etc/resolv.conf`:

<pre>
strict-order
</pre>

En este fichero, también debemos buscar la directiva **interface**, descomentarla y establecerle como valor, la interfaz de red de nuestra máquina, en mi caso es la **eth0**, de manera que el resultado sería este:

<pre>
interface=eth0
</pre>

Con esto, ya habríamos terminado la configuración del servicio `dnsmasq`.

Vamos a cambiar el nombre de la máquina, para ello, editamos el fichero `/etc/hostname`. En mi caso la máquina se llamará `javierpzh` por lo que el contenido del fichero es:

<pre>
javierpzh
</pre>

Si vemos, actualmente el *prompt* de la máquina posee este aspecto:

<pre>
root@servidor-dns:~#
</pre>

Debemos reiniciar la máquina para que este cambio se aplique, pero antes, vamos a modificar el fichero `/etc/hosts` para cambiar el **hostname** y el **FQDN** de la máquina.

Antes de hacer esto, por experiencia, ya sé, que al reiniciar la máquina se restablecerá el fichero `/etc/hosts`. Para cambiar este funcionamiento, tenemos que dirigirnos al fichero `/etc/cloud/cloud.cfg` y buscar esta línea:

<pre>
manage_etc_hosts: true
</pre>

Le cambiamos el valor a *false*:

<pre>
manage_etc_hosts: false
</pre>

Ahora sí, vamos a cambiar el fichero `/etc/hosts`. Nos interesa cambiar la línea con la dirección **127.0.1.1** que es la que hace referencia a la propia máquina. Establezco como **FQDN** `javierpzh.iesgn.org` y como **hostname**, `javierpzh`:

<pre>
127.0.1.1 javierpzh.iesgn.org javierpzh
</pre>

Hecho esto, vamos a reiniciar la máquina con el comando `reboot`.

Si después del reinicio volvemos a mirar el *prompt*:

<pre>
root@javierpzh:~#
</pre>

Vemos como hemos modificado correctamente el *hostname* de la máquina.

Vamos a mirar también el *FQDN*:

<pre>
root@javierpzh:~# hostname
javierpzh

root@javierpzh:~# hostname -f
javierpzh.iesgn.org
</pre>

También lo hemos modificado. Con esto, habríamos terminado todo el trabajo en la máquina *servidor*.

#### Tarea 1: Modifica los clientes para que utilicen el nuevo servidor DNS. Realiza una consulta a `www.iesgn.org`, y a `www.josedomingo.org`. Realiza una prueba de funcionamiento para comprobar que el servidor *dnsmasq* funciona como caché DNS. Muestra el fichero hosts del cliente para demostrar que no estás utilizando resolución estática. Realiza una consulta directa al servidor *dnsmasq*. ¿Se puede realizar resolución inversa?

La máquina que actuará como **cliente**, será mi máquina anfitriona.

Una vez en el *cliente*, vamos a instalar el paquete `dnsutils`, para poder hacer uso de la herramienta `dig`:

<pre>
apt install dnsutils -y
</pre>

Una vez instalado este paquete, vamos a añadir en el fichero `/etc/resolv.conf`, que contiene los servidores DNS que va a utilizar esta máquina, esta línea para indicar que haga uso del servidor DNS que hemos creado:

<pre>
nameserver 172.22.200.174
</pre>

Añadimos la línea `nameserver 172.22.200.174`, cuya dirección corresponde a la IP de la máquina servidor.

Hecho esto, podemos realizar una consulta a `www.iesgn.org`:

<pre>
javier@debian:~$ dig www.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 30160
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.iesgn.org.			IN	A

;; ANSWER SECTION:
www.iesgn.org.		0	IN	A	172.22.200.174

;; Query time: 97 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 13:56:32 CET 2020
;; MSG SIZE  rcvd: 58
</pre>

Vemos como nos está respondiendo nuestro servidor DNS, ya que nos indica que la respuesta viene de la IP **172.22.200.174**.

Realizo una consulta a `departamentos.iesgn.org`:

<pre>
javier@debian:~$ dig departamentos.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> departamentos.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32409
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;departamentos.iesgn.org.	IN	A

;; ANSWER SECTION:
departamentos.iesgn.org. 0	IN	A	172.22.200.174

;; Query time: 242 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 13:57:36 CET 2020
;; MSG SIZE  rcvd: 68
</pre>

Vemos como de nuevo nos está respondiendo nuestro servidor DNS.

Hago una consulta a `www.josedomingo.org`, la cual me debería responder ya que en el servidor hemos realizado la configuración adecuada para que pueda utilizar DNS externos en caso de que sea necesario:

<pre>
javier@debian:~$ dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18210
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 5, ADDITIONAL: 6

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: cd4b754d056f0763b14e40b65fd8b2fa0fe587d46fbb0cd0 (good)
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	900	IN	CNAME	endor.josedomingo.org.
endor.josedomingo.org.	365	IN	A	37.187.119.60

;; AUTHORITY SECTION:
josedomingo.org.	82635	IN	NS	ns1.cdmon.net.
josedomingo.org.	82635	IN	NS	ns5.cdmondns-01.com.
josedomingo.org.	82635	IN	NS	ns4.cdmondns-01.org.
josedomingo.org.	82635	IN	NS	ns2.cdmon.net.
josedomingo.org.	82635	IN	NS	ns3.cdmon.net.

;; ADDITIONAL SECTION:
ns1.cdmon.net.		160610	IN	A	35.189.106.232
ns2.cdmon.net.		160610	IN	A	35.195.57.29
ns3.cdmon.net.		160610	IN	A	35.157.47.125
ns4.cdmondns-01.org.	82635	IN	A	52.58.66.183
ns5.cdmondns-01.com.	160610	IN	A	52.59.146.62

;; Query time: 700 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 13:58:34 CET 2020
;; MSG SIZE  rcvd: 318
</pre>

Vemos que el tiempo de respuesta ha sido de **700 msec**, algo bastante elevado, aunque supongo que es porque estoy trabajando desde casa a través de la VPN.

Vamos a realizar de nuevo una consulta a `www.josedomingo.org`, la cual me debería responder más rápida que la anterior ya que este servidor funciona como **caché DNS**:

<pre>
javier@debian:~$ dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64502
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	846	IN	CNAME	endor.josedomingo.org.
endor.josedomingo.org.	311	IN	A	37.187.119.60

;; Query time: 81 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 13:59:27 CET 2020
;; MSG SIZE  rcvd: 99
</pre>

Vemos que esta vez el tiempo de respuesta ha sido de **81 msec**, muchísimo más reducido que la primera vez, lo que demuestra que este servidor funciona como *caché DNS*. Además, vuelvo a decir que estoy en casa, si estuviera en clase, seguramente el tiempo de respuesta hubiera sido de unos pocos *msec*.

Por último, vamos a comprobar la resolución inversa haciendo una consulta a la IP de la dirección `endor.josedomingo.org` que es la *37.187.119.60*:

<pre>
javier@debian:~$ dig -x 37.187.119.60

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> -x 37.187.119.60
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 60847
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ab7414b8c67b8dae299df1475fd8b528f0540c2f00c10f05 (good)
;; QUESTION SECTION:
;60.119.187.37.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
60.119.187.37.in-addr.arpa. 86370 IN	PTR	ns330309.ip-37-187-119.eu.

;; AUTHORITY SECTION:
119.187.37.in-addr.arpa. 172763	IN	NS	ns104.ovh.net.
119.187.37.in-addr.arpa. 172763	IN	NS	dns104.ovh.net.

;; Query time: 230 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:07:52 CET 2020
;; MSG SIZE  rcvd: 170
</pre>

Vemos que nos ha respondido de nuevo nuestro servidor DNS, por lo que también podríamos realizar resoluciones inversas.


### Servidor bind9

**Desinstala el servidor *dnsmasq* del ejercicio anterior e instala un servidor DNS *bind9*. Las características del servidor DNS que queremos instalar son las siguientes:**

- **El servidor DNS se llama `pandora.iesgn.org` y por supuesto, va a ser el servidor con autoridad para la zona `iesgn.org`.**

- **Vamos a suponer que tenemos un servidor para recibir los correos que se llame `correo.iesgn.org` y que está en la dirección x.x.x.200 (esto es ficticio).**

- **Vamos a suponer que tenemos un servidor FTP que se llame `ftp.iesgn.org` y que está en x.x.x.201 (esto es ficticio).**

- **Además queremos nombrar a los clientes.**

- **También hay que nombrar a los *virtualhosts* de apache: `www.iesgn.org` y `departementos.iesgn.org`.**

- **Se tienen que configurar la zona de resolución inversa.**


#### Tarea 2: Realiza la instalación y configuración del servidor *bind9* con las características anteriormente señaladas. Entrega las zonas que has definido.

Una vez hemos desinstalado el servidor **dnsmasq**, antes de instalar el servidor DNS **bind9**, vamos a realizar de nuevo una consulta a `www.josedomingo.org` para ver que servidor DNS nos responde ahora:

<pre>
javier@debian:~$ dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54806
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	900	IN	CNAME	endor.josedomingo.org.
endor.josedomingo.org.	900	IN	A	37.187.119.60

;; Query time: 76 msec
;; SERVER: 212.166.132.110#53(212.166.132.110)
;; WHEN: mar dic 15 14:13:01 CET 2020
;; MSG SIZE  rcvd: 84
</pre>

Vemos que ahora nos ha respondido un servidor DNS que ha obtenido por DHCP, cuya dirección es *212.166.132.110*, y que ya lógicamente no responde el que habíamos creado nosotros.

Realizada esta comprobación, sí vamos a instalar el servidor **bind9**:

<pre>
apt install bind9 -y
</pre>

Una vez instalado, debemos modificar su fichero de configuración, para ello nos dirigimos a `/etc/bind/named.conf.local` y añadimos el siguiente bloque:

<pre>
include "/etc/bind/zones.rfc1918";

zone "iesgn.org" {
        type master;
        file "/var/cache/bind/db.iesgn.org";
};

zone "200.22.172.in-addr.arpa" {
        type master;
        file "/var/cache/bind/db.200.22.172";
};
</pre>

Vamos a explicar las líneas que acabamos de añadir.

En primer lugar, hemos escrito una línea que hacer referencia a un archivo llamado `zones.rfc1918`, que es un fichero de configuración de las zonas privadas que queremos definir.

Los bloques definen las zonas de las que el servidor tiene autoridad, la **zona de resolución directa** `iesgn.org` con su correspondiente **zona de resolución inversa** `200.22.172.in-addr.arpa`, además vemos como hemos especificado que actúen como **maestro**.

Una vez explicado, tenemos que dirigirnos al fichero `/etc/bind/named.conf.options`, y aquí debemos introducir las siguientes líneas:

<pre>
recursion yes;
allow-recursion { any; };
listen-on { any; };
allow-transfer { none; };
</pre>

De manera, que el fichero `/etc/bind/named.conf.options` quedaría así:

<pre>
options {
        directory "/var/cache/bind";

        dnssec-validation auto;

        listen-on-v6 { any; };

        recursion yes;

        allow-recursion { any; };

        listen-on { any; };

        allow-transfer { none; };

};
</pre>

Ahora, vamos a configurar las zonas que definimos en el paso anterior. En mi caso copio el fichero `/etc/bind/db.empty` para utilizarlo como plantilla del nuevo archivo de configuración de esta **zona de resolución directa** `iesgn.org`.

<pre>
root@javierpzh:~# cp /etc/bind/db.empty /var/cache/bind/db.iesgn.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `db.iesgn.org`:

<pre>
$TTL    86400
@       IN      SOA     javierpzh.iesgn.org. root.localhost. (
                        20121501        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      javierpzh.iesgn.org.
@       IN      MX      10      correo.iesgn.org.

$ORIGIN iesgn.org.

javierpzh       IN      A       172.22.200.174
correo          IN      A       172.22.200.200
ftp             IN      A       172.22.200.201
www             IN      CNAME   javierpzh
departamentos   IN      CNAME   javierpzh
</pre>

Voy a explicar el bloque añadido.

Vemos que hay un apartado llamado **Serial**, este apartado es muy importante, ya que es el identificador de la zona, que debemos incrementar cada vez que hagamos un cambio. Se recomienda que el valor sea de este formato **YYMMDDNN**, es decir, la fecha de modificación y el número de la modificación. En mi caso he establecido **20121501** pues estoy realizando esta práctica el *15 de diciembre de 2020* y es la primera modificación que hago.

Los registros de tipo **SOA** representan las autoridad sobre las zonas.

El registro de tipo **NS** define el servidor con privilegios sobre la zona.

El registro de tipo **MX** indica que hacemos referencia a un servidor de correos.

El registro **$ORIGIN** se usa para que las líneas que se especifiquen debajo de él, sean autocompletadas con el dominio especificado en dicho registro. Esto nos sirve para evitar poner en cada registro que creemos, la zona, es decir, a los próximos registros que creemos, se les añadirá automáticamente la zona `iesgn.org`.

Los registros de tipo **A** especifican la direcciones IP correspondientes al dominio.

Los registros de tipo **CNAME** sirven para apuntar hacia otro de los registros de tipo **A** ya existentes. De manera que es mucho más fácil y cómodo hacer referencia a una dirección a través de un nombre en vez de con la propia dirección en sí.

Explicado estos detalles, reiniciamos el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Vamos a añadir al fichero `/etc/resolv.conf` de la máquina cliente la siguiente línea con la IP del servidor DNS (si ya la hemos añadido en la tarea 1, no hace falta obviamente):

<pre>
nameserver 172.22.200.174
</pre>

Hecho esto, ahora nuestro cliente utilizará nuestro servidor DNS *bind9*.

Antes hemos definido un registro **SOA** para definir la autoridad sobre la zona `iesgn.org`, que en teoría debería ser `javierpzh`. ¿Lo comprobamos? Vamos a asegurarnos. Para verificar la autoridad de una zona, hacemos uso del comando `dig ns (zona)`:

<pre>
javier@debian:~$ dig ns iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> ns iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32712
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 7b0f823027cdfdfb67ddfadd5fd8bdf3915ecc13d47da118 (good)
;; QUESTION SECTION:
;iesgn.org.			IN	NS

;; ANSWER SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; Query time: 81 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:45:22 CET 2020
;; MSG SIZE  rcvd: 106
</pre>

Efectivamente, la autoridad sobre esta zona es `javierpzh`.

Hacemos una consulta al servidor DNS y preguntamos por la dirección `javierpzh.iesgn.org`:

<pre>
javier@debian:~$ dig javierpzh.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> javierpzh.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 65344
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 3dcc5f35481cc4c49e80ce955fd8e176f2da3aa5d4f91551 (good)
;; QUESTION SECTION:
;javierpzh.iesgn.org.		IN	A

;; ANSWER SECTION:
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; Query time: 86 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:45:44 CET 2020
;; MSG SIZE  rcvd: 106
</pre>

Ahora, haremos una consulta al servidor DNS y preguntaremos por el **servidor de correos** que hemos especificado, es decir, `correo.iesgn.org`:

<pre>
javier@debian:~$ dig mx iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> mx iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64754
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 0aca65684d6e77395f68519c5fd8be1045e75fe0b0b94080 (good)
;; QUESTION SECTION:
;iesgn.org.			IN	MX

;; ANSWER SECTION:
iesgn.org.		86400	IN	MX	10 correo.iesgn.org.

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
correo.iesgn.org.	86400	IN	A	172.22.200.200
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; Query time: 83 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:45:52 CET 2020
;; MSG SIZE  rcvd: 145
</pre>

Vemos como nos responde con la información de este servidor de correos ficticio.

Ahora, haremos una consulta al servidor DNS y preguntaremos por el **servidor FTP** que hemos especificado, es decir, `ftp.iesgn.org`:

<pre>
javier@debian:~$ dig ftp.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> ftp.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5805
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: b890f6dcd25d80c0dc4ea1085fd8be2f91ea9ad925c3fdb5 (good)
;; QUESTION SECTION:
;ftp.iesgn.org.			IN	A

;; ANSWER SECTION:
ftp.iesgn.org.		86400	IN	A	172.22.200.201

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; Query time: 84 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:46:23 CET 2020
;; MSG SIZE  rcvd: 126
</pre>

Vemos como nos responde con la información de este servidor FTP ficticio.

Vamos a probar si funcionan como deberían los registros *CNAME* haciendo una consulta a las direcciones `www.iesgn.org` y `departamentos.iesgn.org`:

<pre>
javier@debian:~$ dig www.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31627
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 294d876823b5bdd01a9627555fd8be65f78ac8bcb0b12c73 (good)
;; QUESTION SECTION:
;www.iesgn.org.			IN	A

;; ANSWER SECTION:
www.iesgn.org.		86400	IN	CNAME	javierpzh.iesgn.org.
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; Query time: 84 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:47:17 CET 2020
;; MSG SIZE  rcvd: 124

------------------------------------------------------------------------

javier@debian:~$ dig departamentos.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> departamentos.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 65267
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 6966c6cb36feec24d45b37dd5fd8be7de106924826689110 (good)
;; QUESTION SECTION:
;departamentos.iesgn.org.	IN	A

;; ANSWER SECTION:
departamentos.iesgn.org. 86400	IN	CNAME	javierpzh.iesgn.org.
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; Query time: 203 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:47:41 CET 2020
;; MSG SIZE  rcvd: 134
</pre>

Lógicamente como he comentado antes, funciona.

Por último, vamos a realizar una consulta a `www.josedomingo.org`:

<pre>
javier@debian:~$ dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 46237
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 5, ADDITIONAL: 6

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 2d75623a8efbcd2bb12aaea35fd8e32de5465209b63c40be (good)
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	386	IN	CNAME	endor.josedomingo.org.
endor.josedomingo.org.	386	IN	A	37.187.119.60

;; AUTHORITY SECTION:
josedomingo.org.	85885	IN	NS	ns5.cdmondns-01.com.
josedomingo.org.	85885	IN	NS	ns1.cdmon.net.
josedomingo.org.	85885	IN	NS	ns4.cdmondns-01.org.
josedomingo.org.	85885	IN	NS	ns2.cdmon.net.
josedomingo.org.	85885	IN	NS	ns3.cdmon.net.

;; ADDITIONAL SECTION:
ns1.cdmon.net.		172285	IN	A	35.189.106.232
ns2.cdmon.net.		172285	IN	A	35.195.57.29
ns3.cdmon.net.		172285	IN	A	35.157.47.125
ns4.cdmondns-01.org.	85885	IN	A	52.58.66.183
ns5.cdmondns-01.com.	172285	IN	A	52.59.146.62

;; Query time: 99 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:48:02 CET 2020
;; MSG SIZE  rcvd: 318
</pre>

Para terminar esta tarea, vamos a configurar la zona inversa de nuestra servidor DNS *bind9*.

Al igual que hicimos al principio del ejercicio, vamos a tomar como plantilla un archivo, pero esta vez será el `/etc/bind/db.127` y lo guardaremos de nuevo en `/var/cache/bind` con el nombre `db.200.22.172`.

<pre>
cp /etc/bind/db.127 /var/cache/bind/db.200.22.172
</pre>

Antes de mostrar como quedaría este fichero, hay que decir que por cada registro de tipo **A** que tengamos en nuestro archivo que contiene la zona directa, sin incluir las páginas webs, tenemos que añadir un registro de tipo **PTR**.

En mi caso, el fichero `/var/cache/bind/db.200.22.172` tendría este aspecto:

<pre>
$TTL    604800
@       IN      SOA     javierpzh.iesgn.org. root.localhost. (
                        20121501        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      javierpzh.iesgn.org.

$ORIGIN 200.22.172.in-addr.arpa.

174     IN      PTR     javierpzh.iesgn.org.
200     IN      PTR     correo.iesgn.org.
201     IN      PTR     ftp.iesgn.org.
</pre>

Reiniciamos el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Para comprobar que funciona la resolución inversa, vamos a hacer una consulta inversa. Para hacer esto utilizamos el comando `dig -x (IP)`:

<pre>
javier@debian:~$ dig -x 172.22.200.174

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> -x 172.22.200.174
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 21938
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 7d3b873b603a177806bc97575fd8c12a2de7c483ab5f1672 (good)
;; QUESTION SECTION:
;174.200.22.172.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
174.200.22.172.in-addr.arpa. 604800 IN	PTR	javierpzh.iesgn.org.

;; AUTHORITY SECTION:
200.22.172.in-addr.arpa. 604800	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; Query time: 79 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:59:06 CET 2020
;; MSG SIZE  rcvd: 147
</pre>

Parece que el servidor resuelve consultas inversas, pero vamos a hacer una prueba más realizando otra consulta inversa, esta vez al servidor de correos.

<pre>
javier@debian:~$ dig -x 172.22.200.200

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> -x 172.22.200.200
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 61164
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 8551cca364e2557b2396263f5fd8c14e6b958e7180155dcf (good)
;; QUESTION SECTION:
;200.200.22.172.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
200.200.22.172.in-addr.arpa. 604800 IN	PTR	correo.iesgn.org.

;; AUTHORITY SECTION:
200.22.172.in-addr.arpa. 604800	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; Query time: 81 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:59:42 CET 2020
;; MSG SIZE  rcvd: 154
</pre>

Vemos que también funciona correctamente, por lo que este ejercicio estaría terminado.


### Servidor DNS esclavo

##### El servidor DNS actual funciona como *DNS maestro*. Vamos a instalar un nuevo servidor DNS que va a estar configurado como *DNS esclavo* del anterior, donde se van a ir copiando periódicamente las zonas del *DNS maestro*. Suponemos que el nombre del servidor *DNS esclavo* se va llamar `afrodita.iesgn.org`.

#### Tarea 3: Realiza la instalación del servidor *DNS esclavo*. Documenta los siguientes apartados:

- **Entrega la configuración de las zonas del maestro y del esclavo.**

- **Comprueba si las zonas definidas en el maestro tienen algún error con el comando adecuado.**

- **Comprueba si la configuración de `named.conf` tiene algún error con el comando adecuado.**

- **Reinicia los servidores y comprueba en los *logs* si hay algún error. No olvides incrementar el número de serie en el registro SOA si has modificado la zona en el maestro.**

- **Muestra la salida del log donde se demuestra que se ha realizado la transferencia de zona.**

Antes de nada, me gustaría explicar por encima para que servirá este **servidor esclavo**. Este nuevo servidor DNS, estará de alguna forma sincronizado con el **maestro** y nos ayudará en caso de que el *servidor maestro* no pueda procesar/responder una petición, de manera, que actuará este *servidor esclavo* y responderá él la petición. Es muy útil para casos de caídas del primer servidor, para casos donde queramos utilizar estos servidores en alta disponibilidad, ...

He creado una segunda instancia en el *cloud*, también con un sistema *Debian Buster*, para que actúe como **esclavo**. Posee la dirección **172.22.200.253**.

**Importante:** como estamos trabajando en el *cloud*, he tenido que abrir el puerto **53/TCP**, ya que es el puerto que se utiliza para la transferencia de archivos, de manera que si no lo tenemos abierto, el *esclavo* no recibirá las zonas del *maestro*.

Pero antes de empezar a trabajar con esta máquina, debemos configurar el servidor **maestro**, que será el que hemos estado utilizando antes, para que permita que las zonas se puedan transferir a este servidor **esclavo**. Para ello nos dirigimos al fichero `/etc/bind/named.conf.local`, en el que si recordamos, antes añadimos dos bloques que hacían referencia a ambas zonas (directa e inversa). Bien, pues tenemos que introducir dos nuevas directivas en cada uno de los bloques, estas directivas son las llamadas **allow-transfer** y **notify yes**. El resultado final del contenido del fichero sería:

<pre>
include "/etc/bind/zones.rfc1918";

zone "iesgn.org" {
        type master;
        file "/var/cache/bind/db.iesgn.org";
	allow-transfer { 172.22.200.253; };
	notify yes;
};

zone "200.22.172.in-addr.arpa" {
        type master;
        file "/var/cache/bind/db.200.22.172";
	allow-transfer { 172.22.200.253; };
	notify yes;
};
</pre>

Vamos a comprobar que este fichero posee una sintaxis correcta:

<pre>
root@javierpzh:~# named-checkconf

root@javierpzh:~#
</pre>

Si no nos devuelve ninguna salida, significa que la sintaxis es correcta.

Hecho esto, tendremos que editar los ficheros `/var/cache/bind/db.iesgn.org` y `/var/cache/bind/db.200.22.172` y añadir un registro de tipo **NS** y de tipo **A** o de tipo **PTR**, según el fichero, haciendo referencia a **afrodita**.

El resultado final del fichero `/var/cache/bind/db.iesgn.org` sería:

<pre>
$TTL    86400
@       IN      SOA     javierpzh.iesgn.org. root.localhost. (
                              1         ; Serial
                         604800         ; Refresh
                         86400         ; Retry
                         2419200         ; Expire
                         86400 )       ; Negative Cache TTL
;
@       IN      NS      javierpzh.iesgn.org.
@       IN      NS      afrodita.iesgn.org.
@       IN      MX      10      correo.iesgn.org.

$ORIGIN iesgn.org.

javierpzh       IN      A       172.22.200.174
afrodita        IN      A       172.22.200.253
correo          IN      A       172.22.200.200
ftp             IN      A       172.22.200.201
www             IN      CNAME   javierpzh
departamentos   IN      CNAME   javierpzh
</pre>

El resultado final del fichero `/var/cache/bind/db.200.22.172` sería:

<pre>
$TTL    604800
@       IN      SOA     javierpzh.iesgn.org. root.localhost. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      javierpzh.iesgn.org.
@       IN      NS      afrodita.iesgn.org.

$ORIGIN 200.22.172.in-addr.arpa.

174     IN      PTR     javierpzh.iesgn.org.
253     IN      PTR     afrodita.iesgn.org.
200     IN      PTR     correo.iesgn.org.
201     IN      PTR     ftp.iesgn.org.
</pre>

Vamos a comprobar que este fichero posee una sintaxis correcta:

<pre>
root@javierpzh:~# named-checkzone iesgn.org /var/cache/bind/db.iesgn.org
zone iesgn.org/IN: loaded serial 20121801
OK

root@javierpzh:~# named-checkzone 200.22.172.in-addr.arpa /var/cache/bind/db.200.22.172
zone 200.22.172.in-addr.arpa/IN: loaded serial 20121502
OK
</pre>

Vemos que la sintaxis es correcta.

Reiniciamos el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Ahora sí, nos dirigimos a esta nueva máquina, en la que he vuelto a realizar los mismos pasos previos que llevé a cabo con la primera instancia. Su **hostname** será **afrodita** y su **FQDN**, **afrodita.iesgn.org**.

Instalamos el servidor DNS:

<pre>
apt install bind9 -y
</pre>

Como hicimos anteriormente al instalar el servidor DNS **bind9**, vamos a configurar el fichero `/etc/bind/named.conf.local` añadiendo el siguiente bloque que define las dos zonas sobre las que este servidor *esclavo* tendrá autoridad. El contenido del fichero quedaría así:

<pre>
include "/etc/bind/zones.rfc1918";

zone "iesgn.org" {
        type slave;
        file "db.iesgn.org";
        masters { 172.22.200.174; };
};

zone "200.22.172.in-addr.arpa" {
        type slave;
        file "db.200.22.172";
        masters { 172.22.200.174; };
};
</pre>

Podemos observar, como en el tipo hemos indicado **slave**, es decir, **esclavo**, y también hemos añadido una directiva **masters** que sirve para indicar cuál es la IP del servidor **maestro**.

También tenemos que dirigirnos al fichero `/etc/bind/named.conf.options`, y aquí, al igual que antes, debemos introducir las siguientes líneas:

<pre>
recursion yes;
allow-recursion { any; };
listen-on { any; };
allow-transfer { none; };
</pre>

De manera, que el fichero `/etc/bind/named.conf.options` quedaría así:

<pre>
options {
        directory "/var/cache/bind";

        dnssec-validation auto;

        listen-on-v6 { any; };

        recursion yes;

        allow-recursion { any; };

        listen-on { any; };

        allow-transfer { none; };

};
</pre>

Tras editar ambos ficheros, ya habríamos terminado la configuración de este nuevo servidor *esclavo*, por tanto vamos a reiniciar el servicio para aplicar los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Tras unos segundos, nuestro nuevo servidor habría obtenido la transferencia de las zonas desde el servidor *maestro* por lo que ya tendríamos trabajando ambos servidores conjuntamente. Si visualizamos el estado del servidor:

<pre>
root@afrodita:~# systemctl status bind9
● bind9.service - BIND Domain Name Server
   Loaded: loaded (/lib/systemd/system/bind9.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2020-12-18 11:45:33 UTC; 4h 40min ago
     Docs: man:named(8)
  Process: 768 ExecStart=/usr/sbin/named $OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 771 (named)
    Tasks: 4 (limit: 562)
   Memory: 11.9M
   CGroup: /system.slice/bind9.service
           └─771 /usr/sbin/named -u bind

Dec 18 11:45:34 afrodita named[771]: zone 200.22.172.in-addr.arpa/IN: Transfer started.
Dec 18 11:45:34 afrodita named[771]: transfer of '200.22.172.in-addr.arpa/IN' from 172.22.200.174#53: connected using 10.0.0.5#45093
Dec 18 11:45:34 afrodita named[771]: zone 200.22.172.in-addr.arpa/IN: transferred serial 20121502
Dec 18 11:45:34 afrodita named[771]: transfer of '200.22.172.in-addr.arpa/IN' from 172.22.200.174#53: Transfer status: success
Dec 18 11:45:34 afrodita named[771]: transfer of '200.22.172.in-addr.arpa/IN' from 172.22.200.174#53: Transfer completed: 1 messages, 8 records, 266 bytes, 0.003 secs (88666 bytes/sec)
Dec 18 11:45:34 afrodita named[771]: zone 200.22.172.in-addr.arpa/IN: sending notifies (serial 20121502)
Dec 18 11:45:34 afrodita named[771]: client @0x7fc9140c72c0 172.22.200.253#56966: received notify for zone '200.22.172.in-addr.arpa'
Dec 18 11:45:34 afrodita named[771]: zone 200.22.172.in-addr.arpa/IN: refused notify from non-master: 172.22.200.253#56966
Dec 18 11:45:34 afrodita named[771]: managed-keys-zone: Key 20326 for zone . acceptance timer complete: key now trusted
Dec 18 11:45:34 afrodita named[771]: resolver priming query complete
</pre>

A través de los mensajes podemos ver como se han llevado a cabo la transferencia de las zonas, por lo que si ahora visualizamos los archivos que hay en la ruta `/var/cache/bind/`:

<pre>
root@afrodita:~# ls /var/cache/bind/
db.200.22.172  db.iesgn.org  managed-keys.bind	managed-keys.bind.jnl
</pre>

Efectivamente, podemos ver como se han copiado las zonas a este servidor *esclavo*.


#### Tarea 4: Documenta los siguientes apartados:

- **Configura un cliente para que utilice los dos servidores como servidores DNS.**

- **Realiza una consulta con `dig` tanto al maestro como al esclavo para comprobar que las respuestas son autorizadas. ¿En qué te tienes que fijar?**

- **Solicita una copia completa de la zona desde el cliente. ¿Qué tiene que ocurrir? Solicita una copia completa desde el esclavo. ¿Qué tiene que ocurrir?**

Hecho esto, nos dirigimos a nuestro equipo anfitrión y añadimos al fichero `resolv.conf` la siguiente línea:

<pre>
nameserver 172.22.200.253
</pre>

Esta línea hace referencia a la de **afrodita**, es decir, la IP del servidor *esclavo*.

Vamos a hacer una consulta al *maestro* y otra al *esclavo* para ver las diferencias:

<pre>
javier@debian:~$ dig +norec @172.22.200.174 iesgn.org. soa

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> +norec @172.22.200.174 iesgn.org. soa
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18061
;; flags: qr aa ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 87db148fead0ec5efc52e7c75fdcdbf65feade950b86e84e (good)
;; QUESTION SECTION:
;iesgn.org.			IN	SOA

;; ANSWER SECTION:
iesgn.org.		86400	IN	SOA	javierpzh.iesgn.org. root.localhost. 20121801 604800 86400 2419200 86400

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	afrodita.iesgn.org.
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
afrodita.iesgn.org.	86400	IN	A	172.22.200.253
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; Query time: 84 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: vie dic 18 17:42:30 CET 2020
;; MSG SIZE  rcvd: 195

javier@debian:~$ dig +norec @172.22.200.253 iesgn.org. soa

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> +norec @172.22.200.253 iesgn.org. soa
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 52681
;; flags: qr aa ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 708e697a25ccee2e550d50375fdcdbfe545d6d60af91c97c (good)
;; QUESTION SECTION:
;iesgn.org.			IN	SOA

;; ANSWER SECTION:
iesgn.org.		86400	IN	SOA	javierpzh.iesgn.org. root.localhost. 20121801 604800 86400 2419200 86400

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.
iesgn.org.		86400	IN	NS	afrodita.iesgn.org.

;; ADDITIONAL SECTION:
afrodita.iesgn.org.	86400	IN	A	172.22.200.253
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; Query time: 82 msec
;; SERVER: 172.22.200.253#53(172.22.200.253)
;; WHEN: vie dic 18 17:42:38 CET 2020
;; MSG SIZE  rcvd: 195
</pre>

A la primera consulta nos ha respondido el *maestro* y a la segunda el *esclavo* como podemos ver. Vemos que ambas, los dos servidores aparecen autorizados.

Ahora vamos a solicitar una copia de la zona desde el cliente.

<pre>
javier@debian:~$ dig @172.22.200.174 iesgn.org. axfr

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> @172.22.200.174 iesgn.org. axfr
; (1 server found)
;; global options: +cmd
; Transfer failed.
</pre>

Vemos que no nos deja. Vamos a probar desde el *esclavo*:

<pre>
root@afrodita:~# dig @172.22.200.174 iesgn.org. axfr

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> @172.22.200.174 iesgn.org. axfr
; (1 server found)
;; global options: +cmd
iesgn.org.		86400	IN	SOA	javierpzh.iesgn.org. root.localhost. 20121801 604800 86400 2419200 86400
iesgn.org.		86400	IN	NS	afrodita.iesgn.org.
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.
iesgn.org.		86400	IN	MX	10 correo.iesgn.org.
afrodita.iesgn.org.	86400	IN	A	172.22.200.253
correo.iesgn.org.	86400	IN	A	172.22.200.200
departamentos.iesgn.org. 86400	IN	CNAME	javierpzh.iesgn.org.
ftp.iesgn.org.		86400	IN	A	172.22.200.201
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174
www.iesgn.org.		86400	IN	CNAME	javierpzh.iesgn.org.
iesgn.org.		86400	IN	SOA	javierpzh.iesgn.org. root.localhost. 20121801 604800 86400 2419200 86400
;; Query time: 2 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: Fri Dec 18 16:49:46 UTC 2020
;; XFR size: 11 records (messages 1, bytes 336)
</pre>

Desde *afrodita* sí nos deja. Obviamente, esto se debe a que anteriormente configuramos el servidor *maestro* para que únicamente copiara las zonas a la dirección IP de *afrodita* y denegamos las transferencias por defecto a los clientes.


#### Tarea 5: Funcionamiento del DNS esclavo:

- **Realiza una consulta desde el cliente y comprueba que servidor está respondiendo.**

- **Posteriormente apaga el servidor maestro y vuelve a realizar una consulta desde el cliente ¿quién responde?**

Bien, voy a realizar una consulta desde el cliente a la dirección `www.iesgn.org`:

<pre>
javier@debian:~$ dig www.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 55227
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 2, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 2ff9d322943323d91597cd795fdcde7dba3b3d77ee6e0e3a (good)
;; QUESTION SECTION:
;www.iesgn.org.			IN	A

;; ANSWER SECTION:
www.iesgn.org.		86400	IN	CNAME	javierpzh.iesgn.org.
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	afrodita.iesgn.org.
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
afrodita.iesgn.org.	86400	IN	A	172.22.200.253

;; Query time: 83 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: vie dic 18 17:53:17 CET 2020
;; MSG SIZE  rcvd: 163
</pre>

Nos ha respondido el servidor *maestro* como era de esperar, pero, ¿qué pasaría si el servidor *maestro* fallase? Para responder esta pregunta vamos a apagar el servidor *maestro* y vamos a volver a realizar la consulta.

<pre>
root@javierpzh:~# systemctl stop bind9
</pre>

Hacemos de nuevo la consulta:

<pre>
javier@debian:~$ dig www.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35402
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 2, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: fb9bc1e0d4727820581d4c515fdcdee93cdb5125eb5afc07 (good)
;; QUESTION SECTION:
;www.iesgn.org.			IN	A

;; ANSWER SECTION:
www.iesgn.org.		86400	IN	CNAME	javierpzh.iesgn.org.
javierpzh.iesgn.org.	86400	IN	A	172.22.200.174

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	afrodita.iesgn.org.
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
afrodita.iesgn.org.	86400	IN	A	172.22.200.253

;; Query time: 83 msec
;; SERVER: 172.22.200.253#53(172.22.200.253)
;; WHEN: vie dic 18 17:55:05 CET 2020
;; MSG SIZE  rcvd: 163
</pre>

Vemos como ahora la respuesta viene de parte de la dirección **172.22.200.253**, es decir, la IP de **afrodita** que es el servidor **esclavo**. Esto significa que obviamente hemos realizado correctamente la configuración y en caso de que nuestro servidor *maestro* dejara de funcionar, comenzaríamos a utilizar nuestro servidor *esclavo*.


### Delegación de dominios

**Tenemos un servidor DNS que gestiona la zona correspondiente al nombre de dominio `iesgn.org`, en esta ocasión queremos delegar el subdominio `informatica.iesgn.org` para que lo gestione otro servidor DNS. Por lo tanto tenemos un escenario con dos servidores DNS:**

- **`pandora.iesgn.org`, es servidor DNS autorizado para la zona `iesgn.org`.**

- **`ns.informatica.iesgn.org`, es el servidor DNS para la zona `informatica.iesgn.org` y, está instalado en otra máquina.**

**Los nombres que vamos a tener en ese subdominio son los siguientes:**

- **`www.informatica.iesgn.org` corresponde a un sitio web que está alojado en el servidor web del departamento de informática.**

- **Vamos a suponer que tenemos un servidor FTP que se llame `ftp.informatica.iesgn.org` y que está en la misma máquina.**

- **Vamos a suponer que tenemos un servidor para recibir los correos que se llame `correo.informatica.iesgn.org`.**

#### Tarea 6: Realiza la instalación y configuración del nuevo servidor DNS con las características anteriormente señaladas.

Utilizaré la máquina **afrodita** para realizar la delegación del dominio.

Vamos a ponernos en situación, tenemos la primera máquina, es decir, el servidor **maestro** como servidor con autoridad sobre la zona `iesgn.org`. Bien, pues desde este servidor vamos a configurar la delegación del subdominio `informatica.iesgn.org` al servidor **esclavo**, es decir, a **afrodita**.

Para realizar esta delegación, debemos editar el fichero `/var/cache/bind/db.iesgn.org` y añadir el siguiente bloque:

<pre>
$ORIGIN informatica.iesgn.org.

@       IN      NS      afrodita

afrodita        IN      A       172.22.200.253
</pre>

Vemos como hemos creado un nuevo registro **$ORIGIN** para el subdominio `informatica.iesgn.org`, al que le hemos asignado un registro **NS** con *afrodita*, lo que indica que ésta será el servidor con autoridad sobre este subdominio. Luego, creamos un registro de tipo **A** con la IP de *afrodita*.

De manera que el contenido final del fichero `/var/cache/bind/db.iesgn.org` sería este:

<pre>
$TTL    86400
@       IN      SOA     javierpzh.iesgn.org. root.localhost. (
                        20121801        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      javierpzh.iesgn.org.
@       IN      NS      afrodita.iesgn.org.
@       IN      MX      10      correo.iesgn.org.

$ORIGIN iesgn.org.

javierpzh       IN      A       172.22.200.174
afrodita        IN      A       172.22.200.253
correo          IN      A       172.22.200.200
ftp             IN      A       172.22.200.201
www             IN      CNAME   javierpzh
departamentos   IN      CNAME   javierpzh


$ORIGIN informatica.iesgn.org.

@       IN      NS      afrodita

afrodita        IN      A       172.22.200.253
</pre>

Es muy importante aumentar el valor del campo **serial**, que hemos comentado su funcionamiento.

Ahora tendríamos que reiniciar el servidor:

<pre>
systemctl restart bind9
</pre>

En este punto, debemos dirigirnos al servidor *esclavo* sobre el que hemos realizado la delegación, y en él, configurar esta nueva zona sobre la que tenemos autoridad.

Editamos el fichero `etc/bind/named.conf.local` y añadimos el siguiente bloque:

<pre>
zone "informatica.iesgn.org" {
        type master;
        file "db.informatica.iesgn.org";
};
</pre>

De manera que el contenido final del fichero `etc/bind/named.conf.local` sería este:

<pre>
include "/etc/bind/zones.rfc1918";

zone "iesgn.org" {
        type slave;
        file "db.iesgn.org";
        masters { 172.22.200.174; };
};

zone "200.22.172.in-addr.arpa" {
        type slave;
        file "db.200.22.172";
        masters { 172.22.200.174; };
};

zone "informatica.iesgn.org" {
        type master;
        file "db.informatica.iesgn.org";
};
</pre>

Solo nos quedaría crear el nuevo fichero `db.informatica.iesgn.org`, que lógicamente se encontrará en `/var/cache/bind/`. Para ello vamos a copiar de nuevo el archivo `/etc/bind/db.empty` para tomarlo como referencia:

<pre>
root@afrodita:~# cp /etc/bind/db.empty /var/cache/bind/db.informatica.iesgn.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `/var/cache/bind/db.informatica.iesgn.org` que quedará así:

<pre>
$TTL    86400
@       IN      SOA     afrodita.informatica.iesgn.org. root.localhost. (
                        20121802        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      afrodita.informatica.iesgn.org.
@       IN      MX      10      correo.informatica.iesgn.org.

$ORIGIN informatica.iesgn.org.

afrodita        IN      A       172.22.200.253
correo          IN      A       172.22.200.200
www             IN      A       172.22.200.210
ftp             IN      CNAME   afrodita
</pre>

Reiniciamos el servidor:

<pre>
systemctl restart bind9
</pre>


#### Tarea 7: Realiza las consultas dig/nslookup desde los clientes preguntando por los siguientes:

- **Dirección de `www.informatica.iesgn.org`, `ftp.informatica.iesgn.org`.**

- **El servidor DNS que tiene configurado la zona del dominio `informatica.iesgn.org`. ¿Es el mismo que el servidor DNS con autoridad para la zona `iesgn.org`?**

- **El servidor de correo configurado para `informatica.iesgn.org`.**

Vamos a realizar todas las consultas, pero vamos a especificar que las haga al servidor **maestro**, para así ver que realmente se ha llevado a cabo la delegación.

Consulta a `www.informatica.iesgn.org`:

<pre>
javier@debian:~$ dig @172.22.200.174 www.informatica.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> @172.22.200.174 www.informatica.iesgn.org
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35861
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: df597e5fc5042a3d1b834c045fdcec456c2f5ebc5f532415 (good)
;; QUESTION SECTION:
;www.informatica.iesgn.org.	IN	A

;; ANSWER SECTION:
www.informatica.iesgn.org. 86315 IN	CNAME	afrodita.informatica.iesgn.org.
afrodita.informatica.iesgn.org.	86315 IN A	172.22.200.253

;; AUTHORITY SECTION:
informatica.iesgn.org.	86400	IN	NS	afrodita.informatica.iesgn.org.

;; Query time: 103 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: vie dic 18 18:52:05 CET 2020
;; MSG SIZE  rcvd: 135
</pre>

Consulta a `ftp.informatica.iesgn.org`:

<pre>
javier@debian:~$ dig @172.22.200.174 ftp.informatica.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> @172.22.200.174 ftp.informatica.iesgn.org
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18527
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 16942171957d80ca85c43c805fdcec68f1630535c8a99fd0 (good)
;; QUESTION SECTION:
;ftp.informatica.iesgn.org.	IN	A

;; ANSWER SECTION:
ftp.informatica.iesgn.org. 86400 IN	CNAME	afrodita.informatica.iesgn.org.
afrodita.informatica.iesgn.org.	86280 IN A	172.22.200.253

;; AUTHORITY SECTION:
informatica.iesgn.org.	86400	IN	NS	afrodita.informatica.iesgn.org.

;; Query time: 88 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: vie dic 18 18:52:40 CET 2020
;; MSG SIZE  rcvd: 135
</pre>

Consulta al servidor de correos de `informatica.iesgn.org`:

<pre>
javier@debian:~$ dig @172.22.200.174 mx informatica.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> @172.22.200.174 mx informatica.iesgn.org
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 28235
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 40dae1383db02b79b8b07f425fdcec8626ce79eeca478866 (good)
;; QUESTION SECTION:
;informatica.iesgn.org.		IN	MX

;; ANSWER SECTION:
informatica.iesgn.org.	86400	IN	MX	10 correo.informatica.iesgn.org.

;; AUTHORITY SECTION:
informatica.iesgn.org.	86400	IN	NS	afrodita.informatica.iesgn.org.

;; ADDITIONAL SECTION:
afrodita.informatica.iesgn.org.	86250 IN A	172.22.200.253

;; Query time: 88 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: vie dic 18 18:53:10 CET 2020
;; MSG SIZE  rcvd: 140
</pre>

Consulta al servidor DNS que tiene autoridad sobre la zona `informatica.iesgn.org`:

<pre>
javier@debian:~$ dig +norec @172.22.200.174 informatica.iesgn.org. soa

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> +norec @172.22.200.174 informatica.iesgn.org. soa
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 30757
;; flags: qr ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 78b294bb2b52138b040de9255fdceca9a949decb712417aa (good)
;; QUESTION SECTION:
;informatica.iesgn.org.		IN	SOA

;; AUTHORITY SECTION:
informatica.iesgn.org.	86400	IN	NS	afrodita.informatica.iesgn.org.

;; ADDITIONAL SECTION:
afrodita.informatica.iesgn.org.	86215 IN A	172.22.200.253

;; Query time: 83 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: vie dic 18 18:53:45 CET 2020
;; MSG SIZE  rcvd: 117
</pre>

Todas las consultas nos devuelven los resultados que esperábamos, por lo que con esto, habríamos terminado el contenido de este *post*.
