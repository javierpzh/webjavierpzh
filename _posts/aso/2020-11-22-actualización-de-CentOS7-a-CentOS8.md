---
layout: post
---

Vamos a realizar la actualización de la instancia **Quijote**, que creamos en este [post](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html) la cuál posee un sistema **CentOS 7**. Mostraré como actualizar a **CentOS 8**, garantizando que todos los servicios previos continúen funcionando.

Para comprobar la versión de *CentOS* que tenemos instalada en este momento:

<pre>
[root@quijote ~]# cat /etc/redhat-release
CentOS Linux release 7.8.2003 (Core)
</pre>

Lo primero que tenemos que realizar si queremos subir de *CentOS 7* a *CentOS 8*, sería instalar el repositorio **EPEL** (Extra Packages Enterprise Linux). Recordemos que el gestor de paquetes predeterminado es *CentOS 7* es `yum`.

<pre>
yum install epel-release -y
</pre>

Debemos tener instaladas las herramientas para el gestor de paquetes `yum` y la herramienta `rpmconf`, para resolver los posibles conflictos en las configuraciones de paquetes *rpm*. Para instalar ambos paquetes:

<pre>
yum install yum-utils rpmconf -y
</pre>

Ejecutamos el siguiente comando, para comprobar si existen conflictos como acabamos de comentar.

<pre>
rpmconf -a
</pre>

Cuando hemos verificado que no hay ningún problema, vamos a eliminar los paquetes huérfanos y que nos resultan innecesarios:

<pre>
package-cleanup --orphans

package-cleanup --leaves
</pre>

En *CentOS 8*, el gestor de paquetes predeterminado no es `yum`, sino que se utiliza `dnf`, por tanto vamos a instalarlo, aunque realmente podemos seguir utilizando `yum` sin problemas, o conviviendo con los dos:

<pre>
yum install dnf -y
</pre>

Como ya hemos instalado y tenemos disponible el nuevo gestor de paquetes, podemos prescindir de `yum`. En mi caso ya no me interesa, por eso me deshago de él, pero si lo queremos conservar podemos saltarnos este paso.

<pre>
dnf remove yum yum-metadata-parser -y

rm -rf /etc/yum
</pre>

Vamos a llevar a cabo una actualización de todos los paquetes del sistema:

<pre>
dnf upgrade -y
</pre>

Ha llegado el momento de iniciar la actualización y de instalar los paquetes necesarios para *CentOS 8* que encontramos en los repositorios oficiales. Los instalamos:

<pre>
dnf install \http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-repos-8.2-2.2004.0.2.el8.x86_64.rpm \http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-release-8.2-2.2004.0.2.el8.x86_64.rpm \http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8.2-2.2004.0.2.el8.noarch.rpm
</pre>

Toca actualizar de nuevo el repositorio *EPEL*:

<pre>
dnf upgrade epel-release -y
</pre>

Eliminamos los archivos temporales innecesarios.

<pre>
dnf clean all
</pre>

Ahora es el paso de eliminar el kérnel de *CentOS 7*, que lógicamente no vamos a utilizar más ya que luego vamos a instalar el nuevo kérnel:

<pre>
rpm -e `rpm -q kernel`
</pre>

Se nos van a presentar varios conflictos, para resolverlos también nos deshacemos de este paquete:

<pre>
rpm -e --nodeps sysvinit-tools
</pre>

Y por fin, empezamos la actualización a *CentOS 8*:

<pre>
dnf --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
</pre>

Puede que varios paquetes relacionados con **Python**, nos produzcan conflictos, así que para resolverlo, desinstalamos el paquete con este comando:

<pre>
dnf remove python36-rpmconf-1.0.22-1.el7.noarch
</pre>

Ejecutamos de nuevo el comando para iniciar la actualización y ahora sí debe terminar de manera correcta:

<pre>
dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
</pre>

Una vez finalizada exitosamente la actualización, para terminar, nos quedaría instalar el kérnel del nuevo *CentOS 8*:

<pre>
dnf install kernel-core -y
</pre>

Y por último, vamos a instalar los paquetes mínimos del sistema:

<pre>
dnf groupupdate "Core" "Minimal Install" -y
</pre>

Reiniciamos el sistema:

<pre>
reboot
</pre>

Al intentar conectarme de nuevo a la máquina mediante *SSH* no me dejaba, y dirigiéndome a la consola de *OpenStack*, porque recordemos que *Quijote* es una instancia de mi proyecto, pude comprobar como el fichero de configuración que establecía la IP de la interfaz *eth0* estática, se había reiniciado. Volví a configurar el fichero `/etc/sysconfig/network-scripts/ifcfg-eth0`:

<pre>
BOOTPROTO=static
DEVICE=eth0
HWADDR=fa:16:3e:5c:3d:c5
MTU=8950
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
IPADDR=10.0.1.13
NETMASK=255.255.255.0
GATEWAY=10.0.1.3
DNS1=10.0.1.3
DNS2=8.8.8.8
</pre>

Reinicié el servicio:

<pre>
systemctl restart network.service
</pre>

Y probé a acceder de nuevo, ahora lógicamente sí accedí mediante *SSH* a través de *Dulcinea*.

Reinicié la máquina y comprobé como volvía a perder la configuración como yo suponía que iba a pasar. Configuré de nuevo el fichero `/etc/sysconfig/network-scripts/ifcfg-eth0` y procedí a crear el siguiente fichero para evitar que los cambios se perdieran en cada inicio del sistema:

<pre>
touch /etc/cloud/cloud-init.disabled
</pre>

Con esto solucioné mi principal problema.

Ahora, si miramos de nuevo la versión de *CentOS* y la versión de kérnel que estamos utilizando:

<pre>
[root@quijote ~]# cat /etc/redhat-release
CentOS Linux release 8.2.2004 (Core)

[root@quijote ~]# uname -r
4.18.0-193.28.1.el8_2.x86_64
</pre>

Vemos como hemos actualizado nuestro sistema y nuestro kérnel y ahora está corriendo *CentOS 8*.

Para finalizar, vamos a probar a hacer un ping a *Dulcinea*, *Sancho* y `www.google.es`, para asegurarnos que funciona correctamente la resolución estática y tiene conexión a internet, además de hacer uso de la resolución de nombres:

<pre>
[root@quijote ~]# ping dulcinea
PING dulcinea.javierpzh.gonzalonazareno.org (10.0.1.3) 56(84) bytes of data.
64 bytes from dulcinea.javierpzh.gonzalonazareno.org (10.0.1.3): icmp_seq=1 ttl=64 time=0.712 ms
64 bytes from dulcinea.javierpzh.gonzalonazareno.org (10.0.1.3): icmp_seq=2 ttl=64 time=0.693 ms
64 bytes from dulcinea.javierpzh.gonzalonazareno.org (10.0.1.3): icmp_seq=3 ttl=64 time=0.685 ms
^C
--- dulcinea.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 37ms
rtt min/avg/max/mdev = 0.685/0.696/0.712/0.032 ms

[root@quijote ~]# ping sancho
PING sancho.javierpzh.gonzalonazareno.org (10.0.1.8) 56(84) bytes of data.
64 bytes from sancho.javierpzh.gonzalonazareno.org (10.0.1.8): icmp_seq=1 ttl=64 time=2.13 ms
64 bytes from sancho.javierpzh.gonzalonazareno.org (10.0.1.8): icmp_seq=2 ttl=64 time=1.20 ms
64 bytes from sancho.javierpzh.gonzalonazareno.org (10.0.1.8): icmp_seq=3 ttl=64 time=0.743 ms
^C
--- sancho.javierpzh.gonzalonazareno.org ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 0.743/1.357/2.132/0.578 ms

[root@quijote ~]# ping www.google.es
PING www.google.es (172.217.17.3) 56(84) bytes of data.
64 bytes from mad07s09-in-f3.1e100.net (172.217.17.3): icmp_seq=1 ttl=112 time=43.7 ms
64 bytes from mad07s09-in-f3.1e100.net (172.217.17.3): icmp_seq=2 ttl=112 time=64.5 ms
64 bytes from mad07s09-in-f3.1e100.net (172.217.17.3): icmp_seq=3 ttl=112 time=44.0 ms
^C
--- www.google.es ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 43.773/50.790/64.546/9.727 ms
</pre>

Efectivamente, obtenemos la respuesta esperada. Antes de terminar, quise comprobar si el reloj se encontraba sincronizado, ya que esto también lo configuré en *CentOS 7*:

<pre>
[root@quijote ~]# timedatectl
               Local time: Wed 2020-11-25 19:05:32 UTC
           Universal time: Wed 2020-11-25 19:05:32 UTC
                 RTC time: Wed 2020-11-25 19:05:31
                Time zone: UTC (UTC, +0000)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
</pre>

Vemos como nos muestra que el reloj se encuentra sincronizado, pero si nos fijamos la zona horaria que está utilizando no es la que yo quisiera, ya que me interesa que se sincronice con la zona `Europe/Madrid (CET, +0100)`. Para realizar este cambio vamos a utilizar el siguiente comando:

<pre>
[root@quijote ~]# timedatectl set-timezone Europe/Madrid
</pre>

Si miramos de nuevo el reloj:

<pre>
[root@quijote ~]# timedatectl status
               Local time: Wed 2020-11-25 20:08:49 CET
           Universal time: Wed 2020-11-25 19:08:49 UTC
                 RTC time: Wed 2020-11-25 19:08:48
                Time zone: Europe/Madrid (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
</pre>

Ahora sí, vamos que la respuesta es la correcta, así que hemos terminado la actualización a *CentOS 8* de manera satisfactoria.
