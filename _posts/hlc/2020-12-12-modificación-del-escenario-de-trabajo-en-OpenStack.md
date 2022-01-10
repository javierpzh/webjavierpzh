---
layout: post
---

**En este *post* voy a realizar modificaciones sobre un escenario de *OpenStack* que fue creado anteriormente y cuya explicación se encuentra en [este post](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html), por si quieres saber más al respecto.**

**Vamos a modificar el escenario que tenemos actualmente en OpenStack para que se adecúe a la realización de todas las prácticas en todos los módulos de 2º, en particular para que tenga una estructura más real a la de varios equipos detrás de un cortafuegos, separando los servidores en dos redes: red interna y DMZ. Para ello vamos a reutilizar todo lo hecho hasta ahora y añadiremos una máquina más: Frestón**

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/escenario2.png" />

#### 1. Creación de la red DMZ:

- **Nombre: DMZ de (nombre de usuario)**
- **10.0.2.0/24**

Vamos a crear una nueva red, en esta caso, una **red DMZ**, que se situará entre la red interna y la externa.

Para crearla, nos dirigimos a nuestro panel de administración de *OpenStack* y nos situamos en la sección de **Redes**. Una vez aquí, *clickamos* en el botón llamado **+ Crear red**, y se nos abrirá un menú, donde debemos indicar las características de la red que queremos crear:

En el primer apartado de este asistente, indicamos el nombre que poseerá nuestra nueva red:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ1.png" />

En segundo lugar, indicamos las direcciones de red que abarcará, y deshabilitaremos la puerta de enlace ya que no nos va hacer falta debido a que vamos a poner a *Dulcinea* como *gateway*:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ2.png" />

Por último, vamos a dejar marcada la opción de **Habilitar DHCP** que viene de manera predeterminada, para que de esta forma, nos dé una dirección IP de manera automática cuando conectemos una instancia.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ3.png" />

Hecho esto, ya tendríamos nuestra red DMZ creada, como podemos observar:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ4.png" />

Hemos finalizado este primer ejercicio.

#### 2. Creación de las instancias:

- **Freston:**

    - **Debian Buster sobre volumen de 10GB con sabor m1.mini**
    - **Conectada a la red interna**
    - **Accesible indirectamente a través de dulcinea**
    - **IP estática**

Antes de crear la propia instancia en sí, vamos a crear el volumen sobre el que posteriormente generaremos la instancia **Freston**. Para ello he creado un volumen con estas preferencias:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearvolumenfreston.png" />

Una vez ha terminado el proceso de creación del nuevo volumen, obtenemos como resultado:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearvolumenfrestonfin.png" />

Y ahora, un detalle importante que hay que tener en cuenta antes de realizar el lanzamiento de la nueva instancia es, que si recordamos, a la **red interna**, le deshabilitamos el **servidor DHCP**, por lo que si ahora generamos esta nueva instancia perteneciente a esta red, no adquirirá ninguna dirección mediante *DHCP*, por lo que será inaccesible, porque recordemos que a esta máquina también se accederá a través de *Dulcinea*. Por tanto, vamos a habilitar el servidor *DHCP* de la red interna.

Ahora sí, es momento de crear la nueva instancia.

Para crearla, nos dirigimos hacia nuestro panel de administración de *OpenStack* y nos situamos en la sección de **Instancias**. Una vez aquí, *clickamos* en el botón llamado **+ Lanzar instancia**, y se nos abrirá un menú, donde debemos indicar las características de la instancia que queremos crear:

En el primer apartado de este asistente, indicamos el nombre que poseerá nuestra nueva instancia:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfreston1.png" />

Ahora establecemos que el origen de arranque sea el volumen creado previamente:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfreston2.png" />

Como **Sabor** indicamos que tenga un **m1.mini**.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfreston3.png" />

Y por último, le asignamos la red a la que va a pertenecer esta máquina.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfreston4.png" />

Aquí podemos ver como hemos creado esta instancia correctamente y que pertenece a la red interna, ya que posee una dirección **10.0.1.6**

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfrestonfin.png" />

Vamos a probar a acceder a **Freston** a través de *Dulcinea*:

<pre>
debian@dulcinea:~$ ssh debian@10.0.1.6
The authenticity of host '10.0.1.6 (10.0.1.6)' can't be established.
ECDSA key fingerprint is SHA256:uR1IwMruxlhVJzsAB7UuqHlyR7r+6xqyVhwFXxvX6PM.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.0.1.6' (ECDSA) to the list of known hosts.
Linux freston 4.19.0-11-cloud-amd64 #1 SMP Debian 4.19.146-1 (2020-09-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

debian@freston:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:4a:d0:53 brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.6/24 brd 10.0.1.255 scope global dynamic eth0
       valid_lft 86277sec preferred_lft 86277sec
    inet6 fe80::f816:3eff:fe4a:d053/64 scope link
       valid_lft forever preferred_lft forever
debian@freston:~$
</pre>

Vemos como efectivamente hemos accedido a **Freston**.

Es el momento de realizar las configuraciones necesarias en esta nueva máquina.

En primer lugar vamos a asignarle una **dirección IP estática**. Para ello editamos el fichero `/etc/network/interfaces`:

<pre>
nano /etc/network/interfaces
</pre>

En él, establecemos un bloque como este, en el que indicamos que la interfaz **eth0** (la que está conectada a la red interna), posea una dirección IP estática, cuya dirección es la **10.0.1.6**, cuya máscara de red es una 255.255.255.0, es decir, una **/24**, que la puerta de enlace es la **10.0.1.11**, es decir, la IP de *Dulcinea*, y que utilice esos DNS indicados.

<pre>
allow-hotplug eth0
iface eth0 inet static
address 10.0.1.6
netmask 255.255.255.0
gateway 10.0.1.11
</pre>

Reiniciamos y aplicamos los cambios en las interfaces de red:

<pre>
systemctl restart networking
</pre>

Vamos a ver si se ha aplicado correctamente la configuración deseada:

<pre>
debian@freston:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:4a:d0:53 brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.6/24 brd 10.0.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::f816:3eff:fe4a:d053/64 scope link
       valid_lft forever preferred_lft forever

debian@freston:~$ ip r
default via 10.0.1.11 dev eth0 onlink
10.0.1.0/24 dev eth0 proto kernel scope link src 10.0.1.6
169.254.169.254 via 10.0.1.1 dev eth0

debian@freston:~$ ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=63 time=1.63 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=63 time=1.60 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=63 time=1.50 ms
^C
--- 10.0.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 6ms
rtt min/avg/max/mdev = 1.499/1.575/1.628/0.071 ms

debian@freston:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=43.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=111 time=42.8 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=111 time=43.8 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 42.825/43.297/43.751/0.448 ms

debian@freston:~$ ping www.google.es
ping: www.google.es: Temporary failure in name resolution
</pre>

Podemos observar como todos los cambios se han aplicado, como además ya poseemos conexión a internet, pero aún no podemos hacer uso de la resolución de nombres.

Esto se debe a que, esta instancia, posee un fichero `/etc/resolv.conf` que se genera de manera dinámica, por lo que debemos buscar alguna forma de indicarle a ese fichero que utilice los servidores DNS de los que queremos hacer uso.

Para hacer esto, tendemos que modificar el fichero `/etc/resolvconf/resolv.conf.d/base` e indicar ahí las direcciones de los servidores DNS, y así incluirá a estos en cada arranque/reinicio.

<pre>
nano /etc/resolvconf/resolv.conf.d/base
</pre>

En mi caso, he añadido el **10.0.1.11**, es decir, *Dulcinea*, y el **8.8.8.8**, que pertenece a *Google*, por lo que el fichero quedaría así:

<pre>
nameserver 10.0.1.11
nameserver 8.8.8.8
</pre>

Reiniciamos de nuevo y aplicamos los cambios:

<pre>
systemctl restart networking
</pre>

Y volvemos a intentar hacer uso de la resolución de nombres:

<pre>
debian@freston:~$ ping www.google.es
PING www.google.es (216.58.211.35) 56(84) bytes of data.
64 bytes from muc03s14-in-f3.1e100.net (216.58.211.35): icmp_seq=1 ttl=112 time=128 ms
64 bytes from muc03s14-in-f3.1e100.net (216.58.211.35): icmp_seq=2 ttl=112 time=52.9 ms
64 bytes from muc03s14-in-f3.1e100.net (216.58.211.35): icmp_seq=3 ttl=112 time=45.6 ms
^C
--- www.google.es ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 45.578/75.632/128.400/37.432 ms
</pre>

Ahora sí resuelve por nombres, por lo que ya habríamos terminado las configuraciones de red.

Vamos a pasar ahora a configurar la resolución estática, para ello editamos el fichero `/etc/hosts`:

<pre>
nano /etc/hosts
</pre>

La resolución estática lo que hace, es que cuando intentemos resolver un nombre, busca en este fichero si tiene su dirección IP guardada, por lo que nos facilita y nos acomoda mucho el trabajo.

Añadimos estas líneas:

<pre>
127.0.1.1 freston.javierpzh.gonzalonazareno.org freston freston.novalocal
127.0.0.1 localhost

10.0.1.11 dulcinea.javierpzh.gonzalonazareno.org dulcinea
10.0.1.8 sancho.javierpzh.gonzalonazareno.org sancho
10.0.1.13 quijote.javierpzh.gonzalonazareno.org quijote
</pre>

Me he dado cuenta de una cosa al reiniciar la máquina *Freston*, y es que en cada inicio se restablece el fichero `/etc/hosts`. Para cambiar este funcionamiento, tenemos que dirigirnos al fichero `/etc/cloud/cloud.cfg` y buscar esta línea:

<pre>
manage_etc_hosts: true
</pre>

Le cambiamos el valor a *false*:

<pre>
manage_etc_hosts: false
</pre>

Y ya habríamos configurado la resolución estática en *Freston*.

También he añadido la línea correspondiente a las máquinas *Dulcinea*, *Sancho* y *Quijote*, para que ellas también puedan hacer uso de la resolución estática con *Freston*. Les he añadido esta línea:

<pre>
10.0.1.6 freston.javierpzh.gonzalonazareno.org freston
</pre>

Por último, vamos a configurar nuestro reloj utilizando un servidor **NTP** externo, pero nos encontraremos con que tendremos conflictos entre los servicios `systemd-timesyncd` y `ntpd`. En mi caso voy a desinstalar el paquete `ntp` para solucionar el problema:

<pre>
apt remove --purge ntp -y
</pre>

Hecho esto, introducimos el siguiente comando y seleccionamos la configuración que nos interese:

<pre>
dpkg-reconfigure tzdata
</pre>

Comprobamos que tenemos la hora correcta y el servidor **NTP** activo y sincronizado:

<pre>
root@freston:~# timedatectl
               Local time: Sat 2020-12-12 23:36:24 CET
           Universal time: Sat 2020-12-12 22:36:24 UTC
                 RTC time: Sat 2020-12-12 22:36:25
                Time zone: Europe/Madrid (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
</pre>

Ahora sí, hemos terminado todas las configuraciones en *Freston*.

Aunque antes de salir de esta máquina, aún me quedaría algo por hacer, y no es más que llevar a cabo la creación del usuario **profesor**, usuario que puede utilizar `sudo` sin contraseña.

Para crear un usuario en *Debian*, tenemos que hacer uso del comando `useradd`, pero bien, si queremos que en el nuevo usuario se creen las carpetas automáticamente en el directorio `/home` debemos introducir la opción `-m`:

<pre>
root@freston:~# useradd profesor -m -s /bin/bash

root@freston:~# passwd profesor
New password:
Retype new password:
passwd: password updated successfully

root@freston:~# ls /home/
debian	profesor
</pre>

También le he asignando una contraseña que es **profesor**, por si alguna vez nos es necesaria, aunque normalmente no nos hará falta ya que accederemos mediante claves públicas-privadas.

He copiado todas las claves públicas de los profesores al fichero `.ssh/authorized_keys` del usuario *profesor*.

<pre>
mkdir .ssh

nano .ssh/authorized_keys

chmod 700 .ssh/

chmod 600 .ssh/authorized_keys
</pre>

**Importante:** hay que cambiar los permisos de la carpeta `.ssh` a *700*, y del fichero `authorized_keys` a *600*.


#### 3. Modificación de la ubicación de quijote

- **Pasa de la red interna a la DMZ y su direccionamiento tiene que modificarse apropiadamente**

Es hora de realizar el último cambio del ejercicio, y no es más que cambiar la ubicación de la máquina **Quijote** a la nueva **red DMZ**, ya que actualmente pertenece a la red interna.

Para llevar a cabo esta modificación, nos dirigimos a nuestro panel de administración de *OpenStack* y nos situamos en la sección de **Instancias**. Una vez aquí, *clickamos* en la pequeña flecha del final, y se nos desplegará este menú de opciones, donde debemos seleccionar **Desconectar interfaz**:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/menu.png" />

Seleccionamos la interfaz a desconectar, en este caso la interfaz conectada a la red interna:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/desconectarredinterna.png" />

Y una vez hecho esto, en el mismo menú de opciones, debemos seleccionar **Conectar interfaz**,  y seleccionar la **red DMZ**. Vemos como ahora *Quijote*, posee una dirección IP **10.0.2.6**.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/quijoteredDMZ.png" />

Recordemos, que a las instancias *Sancho*, *Quijote* y *Freston*, accedemos mediante *Dulcinea*, por lo que, si queremos acceder a *Quijote*, debe tener conexión con *Dulcinea*, y esto solo es posible si añadimos una nueva interfaz a *Dulcinea* para que también pertenezca a la **red DMZ**, por lo que también la vamos a añadir.

Aquí podemos ver el resultado:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/dulcinearedDMZ.png" />

Vamos a comprobar que realmente podemos acceder a *Quijote* a través de *Dulcinea*:

<pre>
debian@dulcinea:~$ ssh centos@10.0.2.6
The authenticity of host '10.0.2.6 (10.0.2.6)' can't be established.
ECDSA key fingerprint is SHA256:E66o30JGSL5dZglKXltZaOAzuVHOWZUqdopacdi72m8.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.0.2.6' (ECDSA) to the list of known hosts.
Last login: Sat Dec 12 23:33:20 2020 from 10.0.1.11

[centos@quijote ~]$
</pre>

Efectivamente la respuesta es positiva.

Por último, vamos a establecer estas nuevas direcciones que han obtenido *Dulcinea* y *Quijote* como estáticas.

En el caso de **Dulcinea**:

<pre>
debian@dulcinea:~# ip a

...

4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:8d:98:da brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.10/24 brd 10.0.2.255 scope global dynamic eth2
       valid_lft 85985sec preferred_lft 85985sec
    inet6 fe80::f816:3eff:fe8d:98da/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Vemos que ha obtenido por *DHCP* la dirección **10.0.2.10** en la interfaz **eth2**, por lo tanto esta le vamos a asignar de manera estática.

Editamos el fichero `/etc/network/interfaces`:

<pre>
nano /etc/network/interfaces
</pre>

Quedaría de tal forma el bloque de la interfaz *eth2*:

<pre>
allow-hotplug eth2
iface eth2 inet static
address 10.0.2.10
netmask 255.255.255.0
</pre>

Reiniciamos y aplicamos los cambios en las interfaces de red:

<pre>
systemctl restart networking
</pre>

Vamos a comprobar las direcciones:

<pre>
root@dulcinea:~# ip a

...

4: eth2: <BROADCAST,MULTICAST> mtu 8950 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether fa:16:3e:8d:98:da brd ff:ff:ff:ff:ff:ff
</pre>

Anda, la interfaz *eth2*, se encuentra en estado **DOWN**, es decir, apagada. Por defecto esta interfaz no se va a levantar en cada arranque, por lo que tendríamos que hacer uso del comando `ifup eth2` cada vez que quisiéramos hacer uso de esta interfaz. Esto no es lo que estamos buscando, por tanto, vamos a encontrar una solución.

Vamos a editar el fichero `/etc/network/interfaces.d/*`:

<pre>
nano /etc/network/interfaces.d/*
</pre>

En él nos vamos a encontrar:

<pre>
auto lo
iface lo inet loopback
    dns-nameservers 192.168.202.2

auto eth0
iface eth0 inet dhcp
    mtu 8950

auto eth1
iface eth1 inet dhcp
    mtu 8950
</pre>

Vemos como no apreciamos ninguna referencia sobre la interfaz *eth2*, por lo que vamos a añadir este bloque:

<pre>
auto eth2
iface eth2 inet dhcp
    mtu 8950
</pre>

En este punto, reiniciamos de nuevo:

<pre>
systemctl restart networking
</pre>

Y comprobamos de nuevo las direcciones:

<pre>
root@dulcinea:~# ip a

...

4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:8d:98:da brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.10/24 brd 10.0.2.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::f816:3eff:fe8d:98da/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Ahora sí nos encontramos con la interfaz en estado **UP** y con la configuración correcta.

Recordemos que *Dulcinea* es la máquina que hace de *router*, por lo que todas las conexiones pasan por ella, y es la que se encarga de redirigir las peticiones.

En el primer [post](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html), configuramos una regla de *iptables* para que recondujera las peticiones provenientes de la red *10.0.1.0/24* hacia la interfaz **eth0** que es mediante la que está conectada al exterior. Pero esta regla obviamente no nos sirve para que *Quijote* que ahora pertenece a la red *10.0.2.0/24*, posea conexión a internet, por lo que tenemos que crear una nueva regla para esta red.

Si lo recordamos, para hacer **NAT** en **Dulcinea** y que así **Quijote** tenga acceso a internet, tenemos que modificar el grupo de seguridad de *Dulcinea* y deshabilitar la seguridad de todos sus puertos, es decir, quitarle las reglas de cortafuegos, para luego añadirle nuestra propia regla de `iptables`.

Para ello tenemos que configurar *OpenStack* para administrar nuestro proyecto desde la línea de comandos, que es desde donde vamos a realizar este proceso.

Primeramente. vamos a ver los detalles de esta instancia:

<pre>
(openstack) javier@debian:~/entornos_virtuales/openstack$ openstack server show Dulcinea
+-----------------------------+-----------------------------------------------------------------------------------------------------------------------+
| Field                       | Value                                                                                                                 |
+-----------------------------+-----------------------------------------------------------------------------------------------------------------------+
| OS-DCF:diskConfig           | AUTO                                                                                                                  |
| OS-EXT-AZ:availability_zone | nova                                                                                                                  |
| OS-EXT-STS:power_state      | Running                                                                                                               |
| OS-EXT-STS:task_state       | None                                                                                                                  |
| OS-EXT-STS:vm_state         | active                                                                                                                |
| OS-SRV-USG:launched_at      | 2020-11-14T17:44:11.000000                                                                                            |
| OS-SRV-USG:terminated_at    | None                                                                                                                  |
| accessIPv4                  |                                                                                                                       |
| accessIPv6                  |                                                                                                                       |
| addresses                   | red de javier.perezh=10.0.0.8, 172.22.200.183; red interna de javier.perezh=10.0.1.11; DMZ de javier.perezh=10.0.2.10 |
| config_drive                |                                                                                                                       |
| created                     | 2020-11-14T17:43:42Z                                                                                                  |
| flavor                      | m1.mini (12)                                                                                                          |
| hostId                      | 1cd650c7bff842c92682e8bc3d0d184f4ddcc2e41fc41ae8487eeb6a                                                              |
| id                          | 73f609c8-9724-4e54-818d-a9bdf0cb43fe                                                                                  |
| image                       |                                                                                                                       |
| key_name                    | msi_debian_clave_publica                                                                                              |
| name                        | Dulcinea                                                                                                              |
| progress                    | 0                                                                                                                     |
| project_id                  | 678e0304a62c445ba78d3b825cb4f1ab                                                                                      |
| properties                  |                                                                                                                       |
| security_groups             | name='default'                                                                                                        |
| status                      | ACTIVE                                                                                                                |
| updated                     | 2020-11-22T11:38:44Z                                                                                                  |
| user_id                     | fc6228f3de9b2e4abfc00a526192e37c323cde31412ffd98d1bf7c584915f35a                                                      |
| volumes_attached            | id='dab6f14b-ec83-4d5a-9940-0f4bb35f864a'                                                                             |
+-----------------------------+-----------------------------------------------------------------------------------------------------------------------+
</pre>

Vemos como efectivamente posee el grupo de seguridad `default` comentando anteriormente.

Procedemos a eliminar este grupo de seguridad:

<pre>
(openstack) javier@debian:~/entornos_virtuales/openstack$ openstack server remove security group Dulcinea default
</pre>

Si vemos de nuevo los detalles de **Dulcinea**:

<pre>
(openstack) javier@debian:~/entornos_virtuales/openstack$ openstack server show Dulcinea
+-----------------------------+-----------------------------------------------------------------------------------------------------------------------+
| Field                       | Value                                                                                                                 |
+-----------------------------+-----------------------------------------------------------------------------------------------------------------------+
| OS-DCF:diskConfig           | AUTO                                                                                                                  |
| OS-EXT-AZ:availability_zone | nova                                                                                                                  |
| OS-EXT-STS:power_state      | Running                                                                                                               |
| OS-EXT-STS:task_state       | None                                                                                                                  |
| OS-EXT-STS:vm_state         | active                                                                                                                |
| OS-SRV-USG:launched_at      | 2020-11-14T17:44:11.000000                                                                                            |
| OS-SRV-USG:terminated_at    | None                                                                                                                  |
| accessIPv4                  |                                                                                                                       |
| accessIPv6                  |                                                                                                                       |
| addresses                   | red de javier.perezh=10.0.0.8, 172.22.200.183; red interna de javier.perezh=10.0.1.11; DMZ de javier.perezh=10.0.2.10 |
| config_drive                |                                                                                                                       |
| created                     | 2020-11-14T17:43:42Z                                                                                                  |
| flavor                      | m1.mini (12)                                                                                                          |
| hostId                      | 1cd650c7bff842c92682e8bc3d0d184f4ddcc2e41fc41ae8487eeb6a                                                              |
| id                          | 73f609c8-9724-4e54-818d-a9bdf0cb43fe                                                                                  |
| image                       |                                                                                                                       |
| key_name                    | msi_debian_clave_publica                                                                                              |
| name                        | Dulcinea                                                                                                              |
| progress                    | 0                                                                                                                     |
| project_id                  | 678e0304a62c445ba78d3b825cb4f1ab                                                                                      |
| properties                  |                                                                                                                       |
| status                      | ACTIVE                                                                                                                |
| updated                     | 2020-11-22T11:38:44Z                                                                                                  |
| user_id                     | fc6228f3de9b2e4abfc00a526192e37c323cde31412ffd98d1bf7c584915f35a                                                      |
| volumes_attached            | id='dab6f14b-ec83-4d5a-9940-0f4bb35f864a'                                                                             |
+-----------------------------+-----------------------------------------------------------------------------------------------------------------------+
</pre>

Podemos apreciar como ya no nos muestra el apartado **security_groups** ya que no posee ningún grupo de seguridad, lo que significa por tanto, que lo hemos eliminado.

Al eliminar el grupo de seguridad, se habilita un cortafuegos por defecto de *OpenStack*, que es la seguridad del puerto, que no permite el tráfico.

Tenemos que deshabilitar la seguridad del puerto mediante el cual *Dulcinea* está conectada a la red **10.0.2.0/24**, recordemos que está conectada mediante la dirección **10.0.2.10**. Si miramos la lista de los puertos:

<pre>
(openstack) javier@debian:~/entornos_virtuales/openstack$ openstack port list
+--------------------------------------+------------------------------------------------+-------------------+--------------------------------------------------------------------------+--------+
| ID                                   | Name                                           | MAC Address       | Fixed IP Addresses                                                       | Status |
+--------------------------------------+------------------------------------------------+-------------------+--------------------------------------------------------------------------+--------+
| 07c0dbe5-af6c-4be4-9087-7525d0fe4edf |                                                | fa:16:3e:79:62:a5 | ip_address='10.0.2.1', subnet_id='a3961a3c-d8bf-40c8-a1d9-0939bd2e01fd'  | ACTIVE |
| 0f26b5cf-2d67-49bc-bdd4-b2fd6d2910e4 |                                                | fa:16:3e:8c:8f:15 | ip_address='10.0.1.1', subnet_id='87427d1a-bd9d-400a-935b-02c56aaf7748'  | ACTIVE |
| 2531063e-74f3-44d3-a268-0d2868599eee |                                                | fa:16:3e:2b:1c:c7 | ip_address='10.0.0.8', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3'  | ACTIVE |
| 2a4cd134-aad2-4d5d-9a22-8cdcdc745d52 |                                                | fa:16:3e:7c:f2:76 | ip_address='10.0.0.3', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3'  | ACTIVE |
| 338db52a-895b-4dcd-a85f-ad1706b26beb | prueba_cortafuegos-r1_network_ext-27wokbxnx23j | fa:16:3e:2b:d4:7e | ip_address='10.0.0.16', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3' | DOWN   |
| 382e2ad1-1645-4963-a913-68c82e260662 |                                                | fa:16:3e:f3:86:31 | ip_address='10.0.0.9', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3'  | ACTIVE |
| 4552e4e4-b593-47b2-8d7f-ea1d0b503d7d |                                                | fa:16:3e:b6:48:45 | ip_address='10.0.2.6', subnet_id='a3961a3c-d8bf-40c8-a1d9-0939bd2e01fd'  | ACTIVE |
| 4b74d3ee-c877-4c20-820d-69e502c51034 |                                                | fa:16:3e:28:24:d0 | ip_address='10.0.0.2', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3'  | ACTIVE |
| 50c06762-bfce-499f-95b3-ef3a3708f906 |                                                | fa:16:3e:4b:ab:f9 | ip_address='10.0.0.1', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3'  | ACTIVE |
| a0ea0fd0-91a9-4727-ba3f-b0e764dc0e23 |                                                | fa:16:3e:8d:98:da | ip_address='10.0.2.10', subnet_id='a3961a3c-d8bf-40c8-a1d9-0939bd2e01fd' | ACTIVE |
| e1517753-2766-4856-a1aa-9f6df4e70d8d |                                                | fa:16:3e:24:f3:f9 | ip_address='10.0.1.11', subnet_id='87427d1a-bd9d-400a-935b-02c56aaf7748' | ACTIVE |
| e225a306-9713-4e4a-bd14-888c01479784 |                                                | fa:16:3e:84:9b:94 | ip_address='10.0.1.8', subnet_id='87427d1a-bd9d-400a-935b-02c56aaf7748'  | ACTIVE |
| f1b3ec4a-e9fb-4d4a-9b6f-276dbb460786 |                                                | fa:16:3e:4a:d0:53 | ip_address='10.0.1.6', subnet_id='87427d1a-bd9d-400a-935b-02c56aaf7748'  | ACTIVE |
+--------------------------------------+------------------------------------------------+-------------------+--------------------------------------------------------------------------+--------+
</pre>

Nos interesa el ID del puerto, ya que necesitamos utilizar el siguiente comando para deshabilitar la seguridad de este puerto:

<pre>
(openstack) javier@debian:~/entornos_virtuales/openstack$ openstack port set --disable-port-security a0ea0fd0-91a9-4727-ba3f-b0e764dc0e23
</pre>

Una vez hemos deshabilitado el cortafuegos que establece la seguridad del puerto, la máquina vuelve a estar accesible, ya que ahora la máquina tiene abiertos todo el rango de puertos completo, porque ahora no posee ningún cortafuegos.

Obviamente esto, no es recomendable en situaciones donde la máquina no se encuentre en un entorno que tengamos controlado, yo lo hago porque *Dulcinea* se encuentra en una nube privada, además de que vamos a establecer un cortafuegos desde dentro de la instancia.

Ahora volvemos a *Dulcinea* y creamos la regla de `iptables` necesaria:

<pre>
iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eth0 -j MASQUERADE
</pre>

**Importante:** es muy recomendable instalar el paquete `iptables-persistent`, ya que esto hará que en cada arranque del sistema las reglas que hemos configurado se levanten automáticamente, siempre y cuando las guardemos en el fichero `/etc/iptables/rules.v4`. Por tanto vamos a guardar esta regla para que se levente en cada inicio:

<pre>
iptables-save > /etc/iptables/rules.v4
</pre>

Lógicamente tenemos habilitado el **bit de forward**, ya que en el primer *post* lo establecimos a *1* de manera permanente.

Para terminar de trabajar en *Dulcinea*, vamos a corregir la resolución estática de nombres, ya que la IP de *Quijote* ha cambiado. En el fichero `/etc/hosts` sustituimos la antigua línea que hacía referencia a *Quijote* por esta:

<pre>
10.0.2.6 quijote.javierpzh.gonzalonazareno.org quijote
</pre>

En este punto, vamos a pasar a la máquina **Quijote**:

<pre>
[centos@quijote ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc fq_codel state UP group default qlen 1000
    link/ether fa:16:3e:b6:48:45 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.6/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 84200sec preferred_lft 84200sec
    inet6 fe80::275d:a225:a9a0:a43f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
</pre>

Para establecer el direccionamiento estático en *CentOS 8*, debemos editar el fichero `/etc/sysconfig/network-scripts/ifcfg-eth0`:

<pre>
nano /etc/sysconfig/network-scripts/ifcfg-eth0
</pre>

En él, vamos a sustituir el bloque existente por este, en el que indicamos que la IP estática que le estamos asignando es la **10.0.2.6**, cuya máscara de red es una **255.255.255.0**, que la puerta de enlace es la **10.0.2.10**, es decir, la IP de *Dulcinea* en esta red, y que utilice esos **DNS** indicados. Parece que ya hemos terminado toda la configuración necesaria pero no, ya que si nos fijamos bien, la **dirección de hardware** de la interfaz, ha cambiado también, por lo que también debemos modificar el valor del apartado **HWADDR** por el nuevo valor *fa:16:3e:b6:48:45*. Es importante establecer en el apartado **ONBOOT** el valor *yes*, ya que esto hará que esta configuración se active en cada inicio del sistema.

<pre>
BOOTPROTO=static
DEVICE=eth0
MTU=8950
HWADDR=fa:16:3e:b6:48:45
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
IPADDR=10.0.2.6
NETMASK=255.255.255.0
GATEWAY=10.0.2.10
DNS1=10.0.2.10
DNS2=8.8.8.8
</pre>

Reiniciamos y aplicamos los cambios en las interfaces de red:

<pre>
systemctl restart network.service
</pre>

Vamos a comprobar las direcciones:

<pre>
[root@quijote ~]# ip a

...

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc fq_codel state UP group default qlen 1000
    link/ether fa:16:3e:b6:48:45 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.6/24 brd 10.0.2.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::f816:3eff:feb6:4845/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Nos encontramos la interfaz con la configuración correcta.

Vamos a probar la conexión al exterior realizando un *ping* a `www.google.es`:

<pre>
[centos@quijote ~]$ ping www.google.es
PING www.google.es (216.58.215.131) 56(84) bytes of data.
64 bytes from mad41s04-in-f3.1e100.net (216.58.215.131): icmp_seq=1 ttl=112 time=42.9 ms
64 bytes from mad41s04-in-f3.1e100.net (216.58.215.131): icmp_seq=2 ttl=112 time=42.9 ms
64 bytes from mad41s04-in-f3.1e100.net (216.58.215.131): icmp_seq=3 ttl=112 time=42.7 ms
^C
--- www.google.es ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 42.734/42.857/42.939/0.088 ms
</pre>

Poseemos conectividad al exterior.

Para terminar la tarea, vamos a modificar el fichero `/etc/hosts` de esta máquina *Quijote* para corregir la resolución estática de *Dulcinea* que ahora ha cambiado de IP para esta red. Sustituimos la antigua línea que hacía referencia a *Dulcinea* por esta:

<pre>
10.0.2.10 dulcinea.javierpzh.gonzalonazareno.org dulcinea
</pre>

Con esto, habríamos terminado todo el proceso de modificaciones.

Vamos a probar la resolución estática:

<pre>
[centos@quijote ~]$ ping dulcinea
PING dulcinea.javierpzh.gonzalonazareno.org (10.0.2.10) 56(84) bytes of data.
64 bytes from dulcinea.javierpzh.gonzalonazareno.org (10.0.2.10): icmp_seq=1 ttl=64 time=0.547 ms
64 bytes from dulcinea.javierpzh.gonzalonazareno.org (10.0.2.10): icmp_seq=2 ttl=64 time=0.802 ms
64 bytes from dulcinea.javierpzh.gonzalonazareno.org (10.0.2.10): icmp_seq=3 ttl=64 time=0.810 ms
^C
--- dulcinea.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 32ms
rtt min/avg/max/mdev = 0.547/0.719/0.810/0.126 ms

[centos@quijote ~]$ ping sancho
PING sancho.javierpzh.gonzalonazareno.org (10.0.1.8) 56(84) bytes of data.
64 bytes from sancho.javierpzh.gonzalonazareno.org (10.0.1.8): icmp_seq=1 ttl=63 time=2.98 ms
64 bytes from sancho.javierpzh.gonzalonazareno.org (10.0.1.8): icmp_seq=2 ttl=63 time=1.44 ms
64 bytes from sancho.javierpzh.gonzalonazareno.org (10.0.1.8): icmp_seq=3 ttl=63 time=1.95 ms
^C
--- sancho.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 1.442/2.123/2.979/0.641 ms

[centos@quijote ~]$ ping freston
PING freston.javierpzh.gonzalonazareno.org (10.0.1.6) 56(84) bytes of data.
64 bytes from freston.javierpzh.gonzalonazareno.org (10.0.1.6): icmp_seq=1 ttl=63 time=2.75 ms
64 bytes from freston.javierpzh.gonzalonazareno.org (10.0.1.6): icmp_seq=2 ttl=63 time=1.93 ms
64 bytes from freston.javierpzh.gonzalonazareno.org (10.0.1.6): icmp_seq=3 ttl=63 time=1.73 ms
^C
--- freston.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 1.727/2.135/2.748/0.441 ms
</pre>

Antes de finalizar el *post*, me gustaría aclarar que aunque no haya comentado nada de cambiar los ficheros `/etc/hosts` de las máquinas *Sancho* y *Freston*, si queremos seguir utilizando la resolución estática en estas máquinas a la hora de hacer referencia a *Quijote*, debemos modificar la línea que hace referencia a *Quijote*, por esta otra:

<pre>
10.0.2.6 quijote.javierpzh.gonzalonazareno.org quijote
</pre>

Y a lo mejor alguien se pregunta, como se conectarían estas máquinas con *Quijote* si no se encuentran en la misma red, pues bien, al estar todas conectadas a *Dulcinea*, realizan una conexión hacia esta, y la propia *Dulcinea* las hace conectar con *Quijote*. El mismo proceso se llevaría a cabo en el caso de que fuese *Quijote* el que quisiese conectar con *Sancho* o *Freston*.

Se me ha olvidado comentarlo, pero como tenemos configuradas de manera estáticas, todas las direcciones IP de las distintas máquinas, podemos deshabilitar los servidores *DHCP* de las distintas redes, tanto de la red interna, como de la red *DMZ*.
