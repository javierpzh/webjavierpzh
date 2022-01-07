---
layout: post
---

## Gestión de paquetes

Todos los ejercicios están realizados en una máquina **CentOS 7**.

**1. Modifica la configuración de red de DHCP a estática.**

Para realizar esta modificación debemos editar el fichero `/etc/sysconfig/network-scripts/ifcfg-eth0`, y establecer este bloque en él:

<pre>
BOOTPROTO=static
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
IPADDR=X.X.X.X
NETMASK=X.X.X.X
GATEWAY=X.X.X.X
DNS1=X.X.X.X
DNS2=X.X.X.X
DNSX=X.X.X.X
</pre>

Reiniciamos y aplicamos los cambios en las interfaces de red:

<pre>
systemctl restart network.service
</pre>

**2. Actualiza el sistema a las versiones más recientes de los paquetes instalados.**

Para realizar una actualización de todos los paquetes instalados en el sistema, empleamos este comando:

<pre>
yum update
</pre>

Cuando se ejecuta este comando, `yum` comenzará a comprobar en sus repositorios si existe una versión actualizada del software que el sistema tiene instalado actualmente. Una vez que revisa la lista de repositorios y nos informa de que paquetes se pueden actualizar, introducimos `y` y pulsando *intro* se nos actualizarán todos los paquetes.

**3. Instala los repositorios adicionales EPEL y CentOSPlus.**

El siguiente comando nos permite listar todos los repositorios que tenemos activos:

<pre>
[root@quijote ~]# yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.airenetworks.es
 * extras: mirror.airenetworks.es
 * updates: mirror.airenetworks.es
repo id                                         repo name                                         status
base/7/x86_64                                   CentOS-7 - Base                                   10,072
extras/7/x86_64                                 CentOS-7 - Extras                                    448
updates/7/x86_64                                CentOS-7 - Updates                                   293
repolist: 10,813
</pre>

El repositorio **EPEL (Extra Packages for Enterprise Linux)** es un repositorio de paquetes de código abierto y gratuitos. Estos repositorios nos permiten instalar aplicaciones que no están incluidas por defecto en los repositorios base de *CentOS* y que contiene gran cantidad de herramientas para administración de redes, herramientas de sysadmin, monitorización, ...

Los repositorios *EPEL* están mantenidos por el equipo **Fedora** siguiendo todas las directrices de calidad y compatibilidad por lo que podemos agregar este repositorio con total tranquilidad.

Para instalar el repositorio **EPEL** tenemos que descargar un archivo con extensión *.rpm* y después instalarlo. Para descargar el archivo *.rpm* ejecutamos el siguiente comando:

- Centos 7.0: `wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm`

Si queréis instalar `wget`:

<pre>
yum install wget
</pre>

Instalamos el paquete descargado:

<pre>
[root@quijote ~]# rpm -ivh epel-release-latest-7.noarch.rpm
warning: epel-release-latest-7.noarch.rpm: Header V3 RSA/SHA256 Signature, key ID 352c64e5: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:epel-release-7-12                ################################# [100%]
</pre>

Listamos de nuevo los repositorios activos:

<pre>
[root@quijote ~]# yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
epel/x86_64/metalink                                                             |  14 kB  00:00:00     
 * base: mirror.airenetworks.es
 * epel: mirror.slu.cz
 * extras: mirror.airenetworks.es
 * updates: mirror.airenetworks.es
epel                                                                             | 4.7 kB  00:00:00     
(1/3): epel/x86_64/group_gz                                                      |  95 kB  00:00:00     
(2/3): epel/x86_64/updateinfo                                                    | 1.0 MB  00:00:01     
(3/3): epel/x86_64/primary_db                                                    | 6.9 MB  00:00:07     
repo id                           repo name                                                       status
base/7/x86_64                     CentOS-7 - Base                                                 10,072
epel/x86_64                       Extra Packages for Enterprise Linux 7 - x86_64                  13,470
extras/7/x86_64                   CentOS-7 - Extras                                                  448
updates/7/x86_64                  CentOS-7 - Updates                                                 293
repolist: 24,283
</pre>

Ya hemos instalado el repositorio **EPEL**.

El repositorio **CentOSPlus** contiene paquetes que son mejoras para los paquetes en los repositorios *CentOS base* + *CentOS updates*. Estos paquetes no son parte de la distribución mayor y extienden la funcionalidad a costa de la compatibilidad con el proveedor.

Para instalar el repositorio **CentOSPlus** tenemos que editar el fichero `/etc/yum.repos.d/CentOS-Base.repo` y sustituir el bloque de *CentOSPlus* que viene por defecto por este otro:

<pre>
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
#baseurl=http://mirror.centos.org/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos5
includepkgs=postfix-*
exclude=postfix-*plus*
</pre>

Ejecutamos el siguiente comando para adicionar lo siguiente a las secciones *[base]* y *[update]* correspondientes en el fichero `/etc/yum.repos.d/CentOS-Base.repo`, de forma que no obtenga paquetes *postfix* desde allí nunca más:

<pre>
exclude=postfix-*
</pre>

Si listamos de nuevo los repositorios activos:

<pre>
[root@quijote ~]# yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.airenetworks.es
 * centosplus: mirror.airenetworks.es
 * epel: mirror.etf.bg.ac.rs
 * extras: mirror.airenetworks.es
 * updates: mirror.airenetworks.es
base                                                                             | 3.6 kB  00:00:00     
centosplus                                                                       | 2.9 kB  00:00:00     
extras                                                                           | 2.9 kB  00:00:00     
updates                                                                          | 2.9 kB  00:00:00     
centosplus/7/x86_64/primary_db                                                   | 1.2 MB  00:00:00     
repo id                            repo name                                                      status
base/7/x86_64                      CentOS-7 - Base                                                10,072
centosplus/7/x86_64                CentOS-7 - Plus                                                  0+34
epel/x86_64                        Extra Packages for Enterprise Linux 7 - x86_64                 13,470
extras/7/x86_64                    CentOS-7 - Extras                                                 448
updates/7/x86_64                   CentOS-7 - Updates                                                293
repolist: 24,283
</pre>

Vemos como también hemos añadido el repositorio *CentOSPlus*.

**4. Instala el paquete que proporciona el programa dig, explicando los pasos que has dado para encontrarlo.**



**5. Explica qué comando utilizarías para ver la información del paquete kernel instalado.**

Para ver que versiones de kernel tenemos instaladas:

<pre>
[root@quijote ~]# rpm -q kernel
kernel-3.10.0-1127.el7.x86_64
kernel-3.10.0-1160.2.2.el7.x86_64
</pre>

Para ver que versión de kernel estamos utilizando ahora mismo:

<pre>
[root@quijote ~]# uname -a
Linux quijote.novalocal 3.10.0-1160.2.2.el7.x86_64 #1 SMP Tue Oct 20 16:53:08 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
</pre>

**6. Instala el repositorio adicional "elrepo" e instala el último núcleo disponible del mismo (5.9.X).**

El primer paso para habilitar este repositorio consiste en importar la llave GPG. Esto hará que `yum` lo considere fiable a la hora de instalar paquetes del mismo:

<pre>
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
</pre>

Ahora, lo habilitamos con el siguiente comando:

<pre>
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
</pre>

Listamos de nuevo los repositorios activos:

<pre>
[root@quijote ~]# yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.airenetworks.es
 * centosplus: mirror.airenetworks.es
 * elrepo: mirror.cedia.org.ec
 * epel: mirror.nextlayer.at
 * extras: mirror.airenetworks.es
 * updates: mirror.airenetworks.es
elrepo                                                                           | 2.9 kB  00:00:00     
elrepo/primary_db                                                                | 481 kB  00:00:00     
repo id                        repo name                                                          status
base/7/x86_64                  CentOS-7 - Base                                                    10,072
centosplus/7/x86_64            CentOS-7 - Plus                                                      0+34
elrepo                         ELRepo.org Community Enterprise Linux Repository - el7                130
epel/x86_64                    Extra Packages for Enterprise Linux 7 - x86_64                     13,470
extras/7/x86_64                CentOS-7 - Extras                                                     448
updates/7/x86_64               CentOS-7 - Updates                                                    293
repolist: 24,413
</pre>

Se ha añadido correctamente.

Para instalar el último kérnel que esté disponible en este repositorio,

Recordemos que estamos utilizando esta versión de kérnel:

<pre>
[root@quijote ~]# uname -r
3.10.0-1160.2.2.el7.x86_64
</pre>

Si los paquetes de kérnel disponibles con el siguiente comando:

<pre>
[root@quijote ~]# yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * elrepo-kernel: mirror.pit.teraswitch.com
elrepo-kernel                                                                    | 2.9 kB  00:00:00     
elrepo-kernel/primary_db                                                         | 1.9 MB  00:00:01     
Available Packages
elrepo-release.noarch                               7.0-5.el7.elrepo                       elrepo-kernel
kernel-lt.x86_64                                    4.4.243-1.el7.elrepo                   elrepo-kernel
kernel-lt-devel.x86_64                              4.4.243-1.el7.elrepo                   elrepo-kernel
kernel-lt-doc.noarch                                4.4.243-1.el7.elrepo                   elrepo-kernel
kernel-lt-headers.x86_64                            4.4.243-1.el7.elrepo                   elrepo-kernel
kernel-lt-tools.x86_64                              4.4.243-1.el7.elrepo                   elrepo-kernel
kernel-lt-tools-libs.x86_64                         4.4.243-1.el7.elrepo                   elrepo-kernel
kernel-lt-tools-libs-devel.x86_64                   4.4.243-1.el7.elrepo                   elrepo-kernel
kernel-ml.x86_64                                    5.9.8-1.el7.elrepo                     elrepo-kernel
kernel-ml-devel.x86_64                              5.9.8-1.el7.elrepo                     elrepo-kernel
kernel-ml-doc.noarch                                5.9.8-1.el7.elrepo                     elrepo-kernel
kernel-ml-headers.x86_64                            5.9.8-1.el7.elrepo                     elrepo-kernel
kernel-ml-tools.x86_64                              5.9.8-1.el7.elrepo                     elrepo-kernel
kernel-ml-tools-libs.x86_64                         5.9.8-1.el7.elrepo                     elrepo-kernel
kernel-ml-tools-libs-devel.x86_64                   5.9.8-1.el7.elrepo                     elrepo-kernel
perf.x86_64                                         5.9.8-1.el7.elrepo                     elrepo-kernel
python-perf.x86_64                                  5.9.8-1.el7.elrepo                     elrepo-kernel
</pre>

Podemos ver como la versión de kérnel más reciente es la **5.9.8**, mientras que la que estamos utilizando actualmente es la **3.10.0**.

Procedemos a la instalación de este kernel ejecutando lo siguiente:

<pre>
yum --enablerepo=elrepo-kernel install kernel-ml
</pre>

Aceptamos la descarga y la instalación de los paquetes.

Una vez instalado tenemos que configurar para que seleccione este kérnel de manera predeterminada, para ello editamos el fichero `/etc/default/grub` y cambiamos el valor de la línea **GRUB_DEFAULT** a **0**.

Ejecutamos la siguiente línea para actualizar la configuración de GRUB:

<pre>
grub2-mkconfig -o /boot/grub2/grub.cfg
</pre>

Reiniciamos el sistema. Comprobamos de nuevo la versión de kérnel que estamos utilizando:

<pre>
[root@quijote ~]# uname -r
5.9.8-1.el7.elrepo.x86_64
</pre>

**7. Busca las versiones disponibles para instalar del núcleo linux e instala la más nueva.**



**8. Muestra el contenido del paquete del último núcleo instalado.**
