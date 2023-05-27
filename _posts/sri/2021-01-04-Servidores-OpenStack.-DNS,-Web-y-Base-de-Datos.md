---
layout: post
---

En este *post* vamos a realizar la instalación de tres servidores: DNS, Web y Base de Datos. Estos servidores se encontrarán en el escenario de OpenStack montado en artículos anteriores. Si quieres saber más acerca del escenario, puedes visitar los siguientes *posts*:

- [Creación del escenario de trabajo en OpenStack](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html)
- [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html)

## Servidor DNS

**Vamos a instalar un servidor DNS en *Freston* que nos permita gestionar la resolución directa e inversa de nuestros nombres. Mi subdominio dentro del dominio principal `gonzalonazareno.org`, se llamará `javierpzh.gonzalonazareno.org`.**

Vamos a instalar el servidor bind9:

<pre>
apt install bind9 -y
</pre>

Una vez instalado, vamos a pasar a definir las vistas que vamos a crear posteriormente. Para ello, nos dirigimos al fichero `/etc/bind/named.conf.local` y añadimos los siguientes bloques que definirán cada una de las vistas:

<pre>
view red_externa {
        match-clients {172.22.0.0/15; 192.168.202.2;};

        include "/etc/bind/zones.rfc1918";
        include "/etc/bind/named.conf.default-zones";

        zone "javierpzh.gonzalonazareno.org" {
          type master;
          file "db.externa.javierpzh.gonzalonazareno.org";
        };
};

view red_DMZ {
        match-clients {10.0.2.0/24;};

        include "/etc/bind/zones.rfc1918";
        include "/etc/bind/named.conf.default-zones";

        zone "javierpzh.gonzalonazareno.org" {
          type master;
          file "db.DMZ.javierpzh.gonzalonazareno.org";
        };

        zone "1.0.10.in-addr.arpa" {
          type master;
          file "db.1.0.10";
        };

        zone "2.0.10.in-addr.arpa" {
          type master;
          file "db.2.0.10";
        };
};

view red_interna {
        match-clients {10.0.1.0/24; localhost;};

        include "/etc/bind/zones.rfc1918";
        include "/etc/bind/named.conf.default-zones";

        zone "javierpzh.gonzalonazareno.org" {
          type master;
          file "db.interna.javierpzh.gonzalonazareno.org";
        };

        zone "1.0.10.in-addr.arpa" {
          type master;
          file "db.1.0.10";
        };

        zone "2.0.10.in-addr.arpa" {
          type master;
          file "db.2.0.10";
        };
};
</pre>

Vamos a explicar las líneas que acabamos de añadir.

En primer lugar, vemos que hemos añadido tres vistas distintas, una para cada una de las redes con las que vamos a interaccionar. La primera está destinada a la **red externa**, la segunda a la **red DMZ**, y la tercera a la **red interna**.

Al principio de cada vista, he introducido una línea llamada **match-clients**. Esta línea identifica desde que red será accesible esa vista.

Podemos ver que he escrito una línea que hacer referencia a un archivo llamado `zones.rfc1918`, que es un fichero de configuración de las zonas privadas que queremos definir.

Los bloques definen las zonas de las que el servidor tiene autoridad, la **zona de resolución directa** `javierpzh.gonzalonazareno.org`, y sus correspondientes **zonas de resolución inversa** `1.0.10.in-addr.arpa` y `2.0.10.in-addr.arpa`, además vemos como hemos especificado que actúen como **maestro**.

Una vez explicado, como vamos a utilizar distintas vistas, debemos dirigirnos al fichero `/etc/bind/named.conf` y comentar (para comentar se utilizan dos caracteres `/`) o eliminar la siguiente línea:

<pre>
include "/etc/bind/named.conf.default-zones";
</pre>

Hecho esto, tenemos que dirigirnos al fichero `/etc/bind/named.conf.options`, e introducir las siguientes líneas:

<pre>
allow-query { 172.22.0.0/15;10.0.1.0/24;10.0.2.0/24;192.168.202.2; };

allow-recursion { any; };

allow-query-cache { any; };
</pre>

De manera que el contenido total del fichero sería:

<pre>
options {
        directory "/var/cache/bind";

        dnssec-validation auto;

        listen-on-v6 { any; };

        recursion yes;

        allow-query { 172.22.0.0/15;10.0.1.0/24;10.0.2.0/24;192.168.202.2; };

        allow-recursion { any; };

        allow-query-cache { any; };

        listen-on { any; };

        allow-transfer { none; };

};
</pre>

Ahora, vamos a configurar las zonas que definimos en el paso anterior. En mi caso copio el fichero `/etc/bind/db.empty` para utilizarlo como plantilla de los nuevos archivos de configuración.

En primer lugar, voy a definir y configurar la zona que utilizaremos en la vista destinada para la **red externa**:

<pre>
root@freston:~# cp /etc/bind/db.empty /var/cache/bind/db.externa.javierpzh.gonzalonazareno.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `db.externa.javierpzh.gonzalonazareno.org`:

<pre>
$TTL    86400
@       IN      SOA     dulcinea.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      dulcinea.javierpzh.gonzalonazareno.org.

$ORIGIN javierpzh.gonzalonazareno.org.

dulcinea        IN      A       172.22.200.183
www             IN      CNAME   dulcinea
</pre>

Voy a explicar el bloque añadido.

Vemos que hay un apartado llamado **Serial**, este apartado es muy importante, ya que es el identificador de la zona, que debemos incrementar cada vez que hagamos un cambio. Se recomienda que el valor sea de este formato **YYMMDDNN**, es decir, la fecha de modificación y el número de la modificación. En mi caso he establecido **20123001** pues estoy realizando esta práctica el *30 de diciembre de 2020* y es la primera modificación que hago.

Los registros de tipo **SOA** representan la autoridad sobre la zona.

El registro de tipo **NS** define el servidor con privilegios sobre la zona.

El registro **$ORIGIN** se usa para que las líneas que se especifiquen debajo de él, sean autocompletadas con el dominio especificado en dicho registro. Esto nos sirve para evitar poner en cada registro que creemos, la zona, es decir, a los próximos registros que creemos, se les añadirá automáticamente la zona `javierpzh.gonzalonazareno.org`.

Los registros de tipo **A** especifican la direcciones IP correspondientes al dominio.

Los registros de tipo **CNAME** sirven para apuntar hacia otro de los registros de tipo **A** ya existentes. De manera que es mucho más fácil y cómodo hacer referencia a una dirección a través de un nombre en vez de con la propia dirección en sí.

Explicados estos detalles, vamos a continuar con la siguiente zona que se empleará para la vista de la **red DMZ**. Vuelvo a copiar el fichero `/etc/bind/db.empty` para utilizarlo como plantilla:

<pre>
root@freston:~# cp /etc/bind/db.empty /var/cache/bind/db.DMZ.javierpzh.gonzalonazareno.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `db.DMZ.javierpzh.gonzalonazareno.org`:

<pre>
$TTL    86400
@       IN      SOA     freston.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      freston.javierpzh.gonzalonazareno.org.

$ORIGIN javierpzh.gonzalonazareno.org.

freston         IN      A       10.0.1.6
dulcinea        IN      A       10.0.2.10
sancho          IN      A       10.0.1.8
quijote         IN      A       10.0.2.6
www             IN      CNAME   quijote
bd              IN      CNAME   sancho
ldap            IN      CNAME   freston
</pre>

Seguimos con la siguiente zona, esta, se empleará para la vista de la **red interna**. Vuelvo a copiar el fichero `/etc/bind/db.empty` para utilizarlo como plantilla:

<pre>
root@freston:~# cp /etc/bind/db.empty /var/cache/bind/db.interna.javierpzh.gonzalonazareno.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `db.interna.javierpzh.gonzalonazareno.org`:

<pre>
$TTL    86400
@       IN      SOA     freston.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      freston.javierpzh.gonzalonazareno.org.

$ORIGIN javierpzh.gonzalonazareno.org.

freston         IN      A       10.0.1.6
dulcinea        IN      A       10.0.1.11
sancho          IN      A       10.0.1.8
quijote         IN      A       10.0.2.6
www             IN      CNAME   quijote
bd              IN      CNAME   sancho
</pre>

Ya hemos creado y configurado las tres zonas de **resolución directa** que necesitamos, ahora vamos a pasar con las de **resolución inversa**.

Para estas, podemos tomar como plantilla otro archivo, el `/etc/bind/db.127`. Lo guardaremos de nuevo en `/var/cache/bind` con los nombres `db.1.0.10` y `db.2.0.10`.

<pre>
root@freston:~# cp /etc/bind/db.127 /var/cache/bind/db.1.0.10

root@freston:~# cp /etc/bind/db.127 /var/cache/bind/db.2.0.10
</pre>

Antes de mostrar como quedarían estos ficheros, hay que decir que por cada registro de tipo **A** que tengamos en nuestro archivo que contiene la zona directa, tenemos que añadir un registro de tipo **PTR**.

En mi caso, el fichero `/var/cache/bind/db.1.0.10` tendría este aspecto:

<pre>
$TTL    604800
@       IN      SOA     freston.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      freston.javierpzh.gonzalonazareno.org.

$ORIGIN 1.0.10.in-addr.arpa.

11     IN      PTR     dulcinea
6      IN      PTR     freston
8      IN      PTR     sancho
</pre>

En mi caso, el fichero `/var/cache/bind/db.2.0.10` tendría este aspecto:

<pre>
$TTL    604800
@       IN      SOA     freston.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      freston.javierpzh.gonzalonazareno.org.

$ORIGIN 2.0.10.in-addr.arpa.

10    IN      PTR     dulcinea
6     IN      PTR     quijote
</pre>

Hemos terminado de crear las diferentes zonas, y tan solo nos quedaría crear la regla **DNAT** en **Dulcinea** para poder realizar las consultas a nuestro servidor DNS instalado en **Freston**.

Añadimos la siguiente regla:

<pre>
iptables -t nat -A PREROUTING -p udp --dport 53 -i eth0 -j DNAT --to 10.0.1.6:53
</pre>

Esta regla, lo que hace, es redirigir el tráfico que proviene desde la interfaz **eth0** y su destino es el puerto **53**, a la dirección **10.0.1.6:53**, es decir, la IP de **Freston** y el puerto **53** de dicha máquina, donde se encontrará nuestro servidor DNS.

**Importante:** es muy recomendable instalar el paquete `iptables-persistent`, ya que esto hará que en cada arranque del sistema las reglas que hemos configurado se levanten automáticamente, siempre y cuando las guardemos en el fichero `/etc/iptables/rules.v4`. Por tanto vamos a guardar esta regla para que se levente en cada inicio:

<pre>
iptables-save > /etc/iptables/rules.v4
</pre>

Reiniciamos el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Bien, hemos terminado de configurar nuestro servidor DNS, pero debemos configurar nuestros clientes para que hagan uso de este servidor. El fichero que establece e indica que servidores DNS se utilizarán es el `/etc/resolv.conf`. El contenido de este archivo se obtiene de manera automática por DHCP en cada arranque del sistema, por lo cuál, nos interesa crear una configuración que evite este comportamiento, de manera que el fichero se vuelva estático.

Aunque pensándolo mejor, en mi caso al menos, creo que me interesa más que en vez de volver completamente estático el fichero, siga obteniendo los servidores DNS proporcionados por DHCP, pero con la diferencia de que en primer lugar, es decir, la primera opción siempre sea mi propio servidor DNS.

Esto me servirá para que en el caso, de que en mi DNS ocurra algún error o no se encuentre disponible en algún momento, pueda seguir utilizando otros servidores.

**En las máquinas Debian y Ubuntu (Dulcinea, Sancho y Freston) :**

Utilizaremos la herramienta `resolvconf`, para instalarla:

<pre>
apt install resolvconf -y
</pre>

Ahora, debemos dirigirnos al fichero `/etc/resolvconf/resolv.conf.d/head` que inicialmente posee este aspecto:

<pre>
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
</pre>

Y añadir estas líneas, de manera que el contenido total sería el siguiente:

<pre>
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN

nameserver 10.0.1.6
search javierpzh.gonzalonazareno.org
</pre>

Si ahora reiniciamos las máquinas y miramos el contenido del fichero `/etc/resolv.conf`:

En el caso de *Dulcinea*:

<pre>
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN

nameserver 10.0.1.6
search javierpzh.gonzalonazareno.org
...
</pre>

En el caso de *Sancho*:

<pre>
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
# 127.0.0.53 is the systemd-resolved stub resolver.
# run "systemd-resolve --status" to see details about the actual nameservers.

nameserver 10.0.1.6
search javierpzh.gonzalonazareno.org
...
</pre>

En el caso de *Freston*:

<pre>
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN

nameserver 10.0.1.6
search javierpzh.gonzalonazareno.org
...
</pre>

Podemos apreciar como las máquinas además de los servidores obtenidos por DHCP, poseen en primer lugar y por tanto, con prioridad mi DNS, que será al que se le consulte siempre que esté disponible y sea capaz de resolver la petición.

**En la máquina CentOS (Quijote) :**

No he conseguido encontrar, ni siquiera sé si existe la herramienta que hemos utilizado para las otras máquinas, por lo cuál el proceso será distinto.

He decidido editar el fichero `/etc/sysconfig/network-scripts/ifcfg-eth0`, que si recordamos ya configuramos en los primeros *posts* sobre este escenario, y establecer en él los servidores DNS que deseamos utilizar. De manera que las líneas que hacen referencia a los DNS serían las siguientes:

<pre>
DNS1=10.0.1.6
DNS2=10.0.2.10
DNS3=8.8.8.8
</pre>

Si reiniciamos la máquina y visualizamos el contenido del fichero `/etc/resolv.conf`:

<pre>
# Generated by NetworkManager
nameserver 10.0.1.6
...
</pre>

Posee el aspecto que deseamos, pero aún nos falta por añadir la línea:

<pre>
search javierpzh.gonzalonazareno.org
</pre>

(Aún no he conseguido configurarla para que permanezca a pesar de los reinicios, así que de momento la he añadido hasta que lo consiga.)

Hecho esto, ahora nuestros clientes utilizarán el servidor DNS *bind9* ubicado en *Freston*.

Como ya poseemos un servidor DNS bien configurado, podemos eliminar las entradas referentes a los distintos equipos en el fichero `/etc/hosts` de manera que no nos hará falta hacer uso de la resolución estática.

Voy a mostrar, como por ejemplo, puedo hacer uso del DNS desde **Quijote**:

<pre>
[centos@quijote ~]$ ping dulcinea
PING dulcinea.javierpzh.gonzalonazareno.org (10.0.2.10) 56(84) bytes of data.
64 bytes from dulcinea.2.0.10.in-addr.arpa (10.0.2.10): icmp_seq=1 ttl=64 time=0.735 ms
64 bytes from dulcinea.2.0.10.in-addr.arpa (10.0.2.10): icmp_seq=2 ttl=64 time=0.913 ms
64 bytes from dulcinea.2.0.10.in-addr.arpa (10.0.2.10): icmp_seq=3 ttl=64 time=0.605 ms
^C
--- dulcinea.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 0.605/0.751/0.913/0.126 ms

[centos@quijote ~]$ ping sancho
PING sancho.javierpzh.gonzalonazareno.org (10.0.1.8) 56(84) bytes of data.
64 bytes from sancho.1.0.10.in-addr.arpa (10.0.1.8): icmp_seq=1 ttl=63 time=2.67 ms
64 bytes from sancho.1.0.10.in-addr.arpa (10.0.1.8): icmp_seq=2 ttl=63 time=1.78 ms
64 bytes from sancho.1.0.10.in-addr.arpa (10.0.1.8): icmp_seq=3 ttl=63 time=1.68 ms
^C
--- sancho.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 1.677/2.041/2.666/0.443 ms

[centos@quijote ~]$ ping freston
PING freston.javierpzh.gonzalonazareno.org (10.0.1.6) 56(84) bytes of data.
64 bytes from freston.1.0.10.in-addr.arpa (10.0.1.6): icmp_seq=1 ttl=63 time=1.15 ms
64 bytes from freston.1.0.10.in-addr.arpa (10.0.1.6): icmp_seq=2 ttl=63 time=1.60 ms
64 bytes from freston.1.0.10.in-addr.arpa (10.0.1.6): icmp_seq=3 ttl=63 time=1.73 ms
^C
--- freston.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 6ms
rtt min/avg/max/mdev = 1.148/1.492/1.734/0.254 ms

[centos@quijote ~]$ ping www
PING quijote.javierpzh.gonzalonazareno.org (10.0.2.6) 56(84) bytes of data.
64 bytes from quijote.2.0.10.in-addr.arpa (10.0.2.6): icmp_seq=1 ttl=64 time=0.052 ms
64 bytes from quijote.2.0.10.in-addr.arpa (10.0.2.6): icmp_seq=2 ttl=64 time=0.106 ms
64 bytes from quijote.2.0.10.in-addr.arpa (10.0.2.6): icmp_seq=3 ttl=64 time=0.100 ms
^C
--- quijote.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 66ms
rtt min/avg/max/mdev = 0.052/0.086/0.106/0.024 ms

[centos@quijote ~]$ ping ldap
PING freston.javierpzh.gonzalonazareno.org (10.0.1.6) 56(84) bytes of data.
64 bytes from freston.1.0.10.in-addr.arpa (10.0.1.6): icmp_seq=1 ttl=63 time=1.23 ms
64 bytes from freston.1.0.10.in-addr.arpa (10.0.1.6): icmp_seq=2 ttl=63 time=1.75 ms
64 bytes from freston.1.0.10.in-addr.arpa (10.0.1.6): icmp_seq=3 ttl=63 time=1.68 ms
^C
--- freston.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 1.226/1.550/1.747/0.230 ms
</pre>

Vemos que nos resuelve todos los nombres, por tanto habríamos terminado el servidor DNS.

(José Domingo, si quieres el próximo día en clase te muestro cualquier prueba de funcionamiento).


## Servidor Web

**En *Quijote (CentOS)* (Servidor que está en la DMZ) vamos a instalar un servidor web *Apache*. Vamos a configurar el servidor para que sea capaz de ejecutar código PHP (para ello vamos a usar un servidor de aplicaciones `php-fpm`).**

Antes de instalar el servidor web, vamos a dirigirnos a **Dulcinea** y vamos a crear la regla necesaria para hacer **DNAT**. La regla es la siguiente:

<pre>
iptables -t nat -A PREROUTING -p tcp --dport 80 -i eth0 -j DNAT --to 10.0.2.6:80
</pre>

Esta regla, lo que hace, es redirigir el tráfico que proviene desde la interfaz **eth0** y su destino es el puerto **80**, a la dirección **10.0.2.6:80**, es decir, la IP de **Quijote** y el puerto **80** de dicha máquina, donde se encontrará nuestro servidor web.

**Importante:** es muy recomendable instalar el paquete `iptables-persistent`, ya que esto hará que en cada arranque del sistema las reglas que hemos configurado se levanten automáticamente, siempre y cuando las guardemos en el fichero `/etc/iptables/rules.v4`. Por tanto vamos a guardar esta regla para que se levente en cada inicio:

<pre>
iptables-save > /etc/iptables/rules.v4
</pre>

Una vez tenemos creada la regla *DNAT* en *Dulcinea*, procedemos a instalar el servidor web **Apache** en **Quijote**, que lo vamos a instalar con este comando, ya que en **CentOS**, *Apache* se incluye en el paquete **httpd**:

<pre>
dnf install httpd -y
</pre>

Una vez instalado, debemos abrir los puertos *80* y *443*, que utilizará *Apache*, ya que por defecto, en el *firewall* de *CentOS*, vienen cerrados.

<pre>
[root@quijote ~]# firewall-cmd --permanent --add-service=http
success

[root@quijote ~]# firewall-cmd --permanent --add-service=https
success

[root@quijote ~]# firewall-cmd --permanent --add-port=80/tcp
success

[root@quijote ~]# firewall-cmd --permanent --add-port=443/tcp
success

[root@quijote ~]# firewall-cmd --reload
success

[root@quijote ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources:
  services: dhcpv6-client http https ssh
  ports: 443/tcp 80/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
</pre>

Habilitamos para que este servicio se inicie en cada arranque del sistema.

<pre>
[root@quijote ~]# systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
</pre>

Hecho esto, si nos dirigimos nuestro navegador e introducimos la dirección `www.javierpzh.gonzalonazareno.org`, nos debe aparecer una página como esta:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_Servidores_OpenStack_DNS_Web_y_Base_de_Datos/quijoteapache.png" />

Vemos que accediendo a `www.javierpzh.gonzalonazareno.org` nos muestra la página servida por nuestro servidor web, que se encuentra en *Quijote*, por lo que, tanto la regla *DNAT* creada en *Dulcinea*, como el servidor *httpd*, funcionan correctamente.

En *Centos*, la instalación de un servidor *Apache* es distinta respecto a lo que estamos acostumbrados a utilizar, *Debian*. Podemos apreciar que no poseemos ni la carpeta `sites-availables` ni la carpeta de `sites-enabled`, por lo que nosotros mismos vamos a proceder a crearlas, para ello nos dirigimos al directorio `/etc/httpd` y las creamos:

<pre>
[root@quijote ~]# ls /etc/httpd/
conf  conf.d  conf.modules.d  logs  modules  run  state

[root@quijote ~]# mkdir /etc/httpd/{sites-availables,sites-enabled}

[root@quijote ~]# ls /etc/httpd/
conf  conf.d  conf.modules.d  logs  modules  run  sites-availables  sites-enabled  state
</pre>

Una vez disponemos de las carpetas donde almacenaremos nuestros *virtualhost*, debemos dirigirnos al fichero `/etc/httpd/conf/httpd.conf` e indicar que los *virtualhost* se almacenan en la carpeta `sites-enabled`. Para ello añadimos la siguiente línea en dicho fichero:

<pre>
IncludeOptional sites-enabled/*.conf
</pre>

Hecho esto, ya procederemos a crear nuestro primer *virtualhost*. En mi caso recibirá el nombre de `javierpzh.gonzalonazareno.conf` y poseerá este aspecto:

<pre>
<\VirtualHost *:80\>

    ServerName www.javierpzh.gonzalonazareno.org
    DocumentRoot /var/www/iesgn

    ErrorLog /var/www/iesgn/log/error.log
    CustomLog /var/www/iesgn/log/requests.log combined

<\/VirtualHost\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Ahora, vamos a habilitar este nuevo *virtualhost*, creando un enlace simbólico hacia la ruta `/etc/httpd/sites-enabled`.

<pre>
[root@quijote sites-availables]# ln -s /etc/httpd/sites-availables/javierpzh.gonzalonazareno.conf /etc/httpd/sites-enabled/
</pre>

En este punto, tan solo nos quedaría crear un fichero `index.html` en la ruta especificada en el apartado **DocumentRoot**, que en mi caso, es `/var/www/iesgn`. Mi fichero `index.html` quedaría así:

<pre>
<\h1\>Pagina de Javier Perez Hidalgo, alumno del Gonzalo Nazareno<\/h1\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

También debemos crear dentro del directorio `/var/www/iesgn`, una carpeta llamada `log`.

Debemos modificar la política de **SELinux**:

<pre>
setsebool -P httpd_unified 1
</pre>

Reiniciamos nuestro servidor web:

<pre>
systemctl restart httpd
</pre>

Y accedemos de nuevo a la dirección `www.javierpzh.gonzalonazareno.org`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_Servidores_OpenStack_DNS_Web_y_Base_de_Datos/quijoteapachevirtualhost.png" />

Vemos como nos muestra el nuevo *virtualhost*.

Por último, vamos a configurar este servidor para que ejecute código **PHP**. Utilizaremos el servidor de aplicaciones `php-fpm`, por tanto, lo instalamos:

<pre>
dnf install php php-fpm -y
</pre>

Una vez instalado, vamos a habilitar su arranque en cada inicio del sistema:

<pre>
[root@quijote iesgn]# systemctl enable php-fpm
Created symlink /etc/systemd/system/multi-user.target.wants/php-fpm.service → /usr/lib/systemd/system/php-fpm.service.
</pre>

Hecho esto, ya habríamos instalado nuestro servidor de aplicaciones *PHP*, pero vamos a comprobar que funciona de manera correcta. Para esto, vamos a añadir a nuestro *virtualhost* los siguientes bloques:

<pre>
<\Proxy "unix:/run/php-fpm/www.sock|fcgi://php-fpm"\>
    ProxySet disablereuse=off
<\/Proxy\>

<\FilesMatch \.php$\>
    SetHandler proxy:fcgi://php-fpm
<\/FilesMatch\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

En la ruta `/var/www/iesgn` voy a crear un archivo llamado `info.php` que contendrá la siguiente línea: `<?php phpinfo(); ?>`.

Si accedemos a la dirección `www.javierpzh.gonzalonazareno.org/info.php`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_Servidores_OpenStack_DNS_Web_y_Base_de_Datos/quijoteapachephpinfo.png" />

Vemos como nuestro servidor ejecuta código *PHP*, por lo que habríamos terminado.


## Servidor de base de datos

**En *Sancho (Ubuntu)* vamos a instalar un servidor de base de datos *MariaDB* `bd.javierpzh.gonzalonazareno.org`.**

El primer paso sería instalar nuestro gestor de base de datos, **MySQL**, por tanto, lo instalamos:

<pre>
apt install mariadb-server mariadb-client -y
</pre>

Una vez lo hemos instalado, vamos a configurar una serie de opciones con el comando `mysql_secure_installation`. Vamos a especificarle una **contraseña de root**, vamos a **eliminar los usuarios anónimos**, vamos a especificar que queremos **desactivar el acceso remoto** a la base de datos, en resumen, vamos a restablecer la base de datos, con nuestras preferencias. Esta es una manera de asegurar el servicio. Aquí muestro el proceso:

<pre>
root@sancho:~# mysql_secure_installation

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
 ... Success!

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

Es el turno de crear un usuario propio, asignarle privilegios y especificarle que sea accesible desde *Quijote*, es decir, desde **10.0.2.6**, ya que éste tiene la IP estática. Para hacer esto debemos conectarnos como *root*:

<pre>
root@sancho:~# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 39
Server version: 10.3.25-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'javierquijote'@'10.0.2.6' IDENTIFIED BY 'contraseña';
Query OK, 0 rows affected (0.050 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'javierquijote'@'10.0.2.6';
Query OK, 0 rows affected (0.152 sec)

MariaDB [(none)]> exit
Bye
</pre>

Una vez tenemos el usuario al que accederemos remotamente, nos quedaría configurar el acceso remoto a nuestro servidor *MySQL*, para ello, debemos modificar el fichero de configuración `/etc/mysql/mariadb.conf.d/50-server.cnf` y buscar la línea `bind-address = 127.0.0.1` y sustituirla por la siguiente:

<pre>
bind-address = 0.0.0.0
</pre>

Esto hará que el servidor escuche las peticiones que provienen de todas las interfaces, a diferencia del punto anterior, que estaba configurado para que solo escuchara en *localhost*.

Hecho esto podemos dirigirnos al **cliente**, es decir, vamos a comprobar el acceso remoto desde *Quijote*. Para ello necesitamos instalar *MariaDB*:

<pre>
dnf install mariadb -y
</pre>

Ahora probamos a acceder:

<pre>
mysql -h sancho -u javierquijote -p
</pre>

El parámetro **-h** indica la dirección del servidor (como nuestro DNS resuelve el nombre de *Sancho* no hace falta indicar su dirección), y los parámetros **-u** y **-p**, como ya sabemos, indican el usuario y la autenticación mediante contraseña.

Obtenemos este resultado:

<pre>
[root@quijote ~]# mysql -h sancho -u javierquijote -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 66
Server version: 10.3.25-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
</pre>

Hemos accedido correctamente por lo que habríamos finalizado este *post*.
