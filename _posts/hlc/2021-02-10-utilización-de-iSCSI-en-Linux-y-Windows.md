---
layout: post
---

En este artículo vamos a configurar un escenario con *Vagrant* que incluirá varias máquinas, y permitirá realizar la configuración de un servidor **iSCSI** y dos clientes, uno *Linux* y otro *Windows*.

## ¿Qué es iSCSI? ¿Cómo funciona?

**iSCSI** es un extensión de *SCSI*, que es un protocolo para comunicación de dispositivos. *SCSI* suele usarse en dispositivos conectados físicamente a un *host* o servidor, tales como discos duros, lectoras de CDs, ... En *iSCSI*, los comandos *SCSI* que manejan el dispositivo, se envían a través de la red. De forma que en vez de tener un disco *SCSI* conectado físicamente a nuestro equipo, lo conectamos por medio de la red.

¿Eso quiere decir que es lo mismo que *Samba* o *NFS*? Pues no, ya que esos sistemas trabajan importando un sistema de archivos mediante la red, mientras que *iSCSI* importa todo el dispositivo hardware por la red, de manera que en el cliente es detectado como un dispositivo *SCSI* más. Todo esto se hace de forma transparente, como si el disco estuviera conectado directamente al hardware.

Es una gran alternativa económica a *FiberChannel*.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/iscsi.png" />

Y respecto a la **velocidad**, ¿es rápido, es lento? Un requisito indispensable de un buen disco es que sea rápido. Los discos *SCSI* suelen entregar excelentes tasas de transferencia. Pero recordemos que *iSCSI* se lleva sobre la red, por eso mismo, *iSCSI* es recomendado solo para redes conmutadas de alta velocidad.

La velocidad de transferencia del *iSCSI* es de **1000 MB/seg**, aunque debido al protocolo, la velocidad baja hasta *800 MB/seg*. En caso de que utilicemos tarjetas *DUAL CHANNEL*, podremos llegar a *1600 MB/seg*, teniendo en cuenta las pérdidas por protocolo.

Respecto al **acceso a los datos**, en teoría, *iSCSI* no soporta múltiples conexiones a la vez. Por ejemplo, dos equipos no podrían utilizar el mismo disco *iSCSI* para escribir en él. Eso sería como tener un disco rígido conectado a dos máquinas a la vez. Lo más probable es que surgieran inconsistencias en los datos o problemas en los accesos de lectura y escritura de la información.

Aún así, existen alternativas para que *iSCSI* pueda soportar múltiples usuarios. Por ejemplo, el global *filesystem (GFS)* de *RedHat*, que es un *filesystem* especialmente diseñado para permitir concurrencia de usuarios en dispositivos que normalmente no lo permiten, como *iSCSI*.

Hablemos sobre el **target iSCSI**. En pocas palabras, es el servidor. Un *target* puede ofrecer uno o más recursos *iSCSI* por la red. En las soluciones *Linux* para *iSCSI*, no hace falta que el dispositivo a exportar sea necesariamente un disco *SCSI*. Se pueden usar medios de almacenamiento de distinta naturaleza como:

- Particiones RAID
- Particiones LVM
- Discos enteros
- Particiones comunes
- Archivos
- Dispositivos de CD

Y por el otro lado, nos encontramos con el **iniciador iSCSI**. El iniciador es el cliente de *iSCSI*. Generalmente el iniciador consta de dos partes: los módulos o *drivers* que proveen soporte para que el sistema operativo pueda reconocer discos de tipo *iSCSI* y un programa que gestiona las conexiones a dichos discos. En *Linux* hay varias opciones, y en las últimas versiones de *Windows* nos encontramos con un iniciador instalado por defecto.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/iscsi2.png" />

Creo que no hace falta decirlo, pero por si acaso, imaginemos tener un *target* montado en *Linux*, obviamente podremos utilizar los discos de dicho servidor en sistemas *Windows*, *MacOSX* o incluso *Solaris*.


## Configuración de target iSCSI y conexión con iniciador iSCSI

En primer lugar, vamos a crear el escenario *Vagrant* que comentamos anteriormente. Para ello, he creado este fichero [Vagrantfile](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/Vagrantfile.txt), en el que defino el servidor *iSCSI* y el cliente, en este caso, el cliente *Linux*.

Explicado esto, vamos a empezar con la instalación del siguiente paquete en la parte del **servidor**.

Necesitaremos instalar el paquete `tgt` que es el que nos proporcionará todo el *software* necesario para trabajar con *iSCSI*.

<pre>
apt install tgt -y
</pre>

Por otra parte, voy a instalar el paquete `lvm2` para crear un grupo de volúmenes y posteriormente un volumen lógico en el primero de los discos adicionales que he añadido, pero **importante**, no es necesario crear volúmenes lógicos para utilizarlos como discos *iSCSI*, yo lo voy a hacer para mostrar que *iSCSI* también puede trabajar con ellos.

<pre>
apt install lvm2 -y
</pre>

El primer paso que voy a llevar a cabo, es la creación del grupo de volúmenes con su correspondiente volumen lógico, si tú no vas a utilizar volúmenes lógicos, lógicamente no hace falta que lo hagas:

<pre>
root@servidor:~# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  20G  0 disk
└─sda1   8:1    0  20G  0 part /
sdb      8:16   0   1G  0 disk
sdc      8:32   0   1G  0 disk
sdd      8:48   0   1G  0 disk

root@servidor:~# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

root@servidor:~# vgcreate vollogs /dev/sdb
  Volume group "vollogs" successfully created

root@servidor:~# lvcreate -L 500M -n vollog1 vollogs
  Logical volume "vollog1" created.
</pre>

Bien, una vez tenemos el volumen lógico creado, vamos a pasar con la configuración del **target**, es decir, del servidor. Su fichero de configuración será creado en la ruta `/etc/tgt/conf.d/` y recibirá el nombre `target1.conf`. En él debemos añadir el siguiente bloque que será el encargado de definir nuestro *target*.

<pre>
<\target iqn.iscsi.com:target1\>
    driver iscsi
    controller_tid 1
    backing-store /dev/vollogs/vollog1
<\/target\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Hecho esto, reiniciamos el servicio:

<pre>
systemctl restart tgt
</pre>

Reiniciado el servicio, debe haber detectado el nuevo *target iSCSI*, así que vamos a comprobarlo:

<pre>
root@servidor:~# tgtadm --lld iscsi --op show --mode target
Target 1: iqn.iscsi.com:target1
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00010000
            SCSI SN: beaf10
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: null
            Backing store path: None
            Backing store flags:
        LUN: 1
            Type: disk
            SCSI ID: IET     00010001
            SCSI SN: beaf11
            Size: 524 MB, Block size: 512
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: rdwr
            Backing store path: /dev/vollogs/vollog1
            Backing store flags:
    Account information:
    ACL information:
        ALL
</pre>

Efectivamente, nos muestra su información, por lo que el comportamiento es el esperado y el *target* se encuentra bien configurado.

Es hora de pasar con la configuración del **iniciador**. Para trabajar con el cliente *iSCSI*, debemos instalar el siguiente paquete:

<pre>
apt install open-iscsi -y
</pre>

Una vez instalado, pasaremos a configurarlo, por lo que editaremos el fichero `/etc/iscsi/iscsid.conf` y en él añadiremos la siguiente línea:

<pre>
iscsid.startup = automatic
</pre>

Después de realizar las modificaciones, reiniciamos el servicio:

<pre>
systemctl restart open-iscsi
</pre>

En teoría, ya nuestro cliente debe conectar con nuestro *target* que se encuentra en la máquina *servidor*. Para comprobarlo utilizaremos el siguiente comando:

<pre>
root@clientelinux:~# iscsiadm -m discovery -t st -p 192.168.0.57
192.168.0.57:3260,1 iqn.iscsi.com:target1
</pre>

Podemos apreciar como efectivamente nos reporta la información correcta del *target* configurado anteriormente, por lo que obviamente puede conectar con él.

El siguiente paso sería conectarnos al propio *target*. Para elo utilizaremos el siguiente comando:

<pre>
iscsiadm -m node -T iqn.iscsi.com:target1 --portal "192.168.0.57" --login
</pre>

El resultado sería el siguiente:

<pre>
root@clientelinux:~# iscsiadm -m node -T iqn.iscsi.com:target1 --portal "192.168.0.57" --login
Logging in to [iface: default, target: iqn.iscsi.com:target1, portal: 192.168.0.57,3260] (multiple)
Login to [iface: default, target: iqn.iscsi.com:target1, portal: 192.168.0.57,3260] successful.

root@clientelinux:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
└─sda1   8:1    0   20G  0 part /
sdb      8:16   0  500M  0 disk
</pre>

¡Vaya! En primer lugar, podemos ver como la conexión se ha completado con éxito, y en segundo lugar, podemos apreciar como automáticamente nuestro sistema ha detectado un nuevo dispositivo, que obviamente es el volumen lógico creado al principio del ejercicio, y que se encuentra en la máquina *servidor*.

Vamos a ver si podemos *juguetear* un poco con este nuevo disco remoto, así que vamos a intentar crear una nueva partición y de ser posible, intentar asignarle un sistema de ficheros y montando el resultante dispositivo de bloques.

<pre>
root@clientelinux:~# gdisk /dev/sdb
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: not present
  BSD: not present
  APM: not present
  GPT: not present

Creating new GPT entries.

Command (? for help): n
Partition number (1-128, default 1):
First sector (34-1023966, default = 2048) or {+-}size{KMGTP}:
Last sector (2048-1023966, default = 1023966) or {+-}size{KMGTP}:
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300):
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/sdb.
The operation has completed successfully.

root@clientelinux:~# mkfs.ext4 /dev/sdb1
mke2fs 1.44.5 (15-Dec-2018)
Creating filesystem with 510956 1k blocks and 128016 inodes
Filesystem UUID: 0009d2d9-5fba-4bfa-9e18-6f0fc8a963cc
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729, 204801, 221185, 401409

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

root@clientelinux:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
└─sda1   8:1    0   20G  0 part /
sdb      8:16   0  500M  0 disk
└─sdb1   8:17   0  499M  0 part

root@clientelinux:~# mount /dev/sdb1 /mnt

root@clientelinux:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
└─sda1   8:1    0   20G  0 part /
sdb      8:16   0  500M  0 disk
└─sdb1   8:17   0  499M  0 part /mnt
</pre>

Y sí, estamos manejando un dispositivo de manera remota, con el que podemos interactuar como con cualquiera de nuestros dispositivos físicos.


## Automontaje del target con systemd

Este proceso es bastante sencillo, y como es de esperar, se llevará a cabo completamente en la parte del cliente. En primer lugar, debemos indicarle a `open-iscsi` que realice la conexión a dicho *target* de manera automática durante el arranque del sistema, ejecutando para ello el comando:

<pre>
iscsiadm -m node -T iqn.iscsi.com:target1 --portal "192.168.0.57" -o update -n node.startup -v automatic
</pre>

Posteriormente, debemos dirigirnos a la ruta `/etc/systemd/system/` y crear un nuevo fichero en el que definiremos la nueva unidad de **systemd**. En mi caso, creo el fichero `/etc/systemd/system/iSCSI.mount`, y su contenido es el siguiente:

<pre>
[Unit]
Description=Montar el disco iSCSI

[Mount]
What=/dev/sdb1
Where=/iSCSI
Type=ext4
Options=_netdev

[Install]
WantedBy=multi-user.target
</pre>

Tras definir esta nueva unidad, debemos reiniciar el siguiente servicio para poder hacer uso de ella:

<pre>
systemctl daemon-reload
</pre>

Hecho esto, tan solo nos quedaría comprobar que el disco actualmente no se encuentra montado en nuestro sistema, y crear su punto de montaje, que en mi caso, he especificado que sea la ruta `/iSCSI`. Tras ello, podremos montar/desmontar nuestro disco *iSCSI* a través de *systemd*:

<pre>
root@clientelinux:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
└─sda1   8:1    0   20G  0 part /
sdb      8:16   0  500M  0 disk
└─sdb1   8:17   0  499M  0 part

root@clientelinux:~# cd ..

root@clientelinux:/# mkdir iSCSI

root@clientelinux:/# systemctl start iSCSI.mount

root@clientelinux:/# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
└─sda1   8:1    0   20G  0 part /
sdb      8:16   0  500M  0 disk
└─sdb1   8:17   0  499M  0 part /iSCSI

root@clientelinux:/# systemctl stop iSCSI.mount

root@clientelinux:/# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
└─sda1   8:1    0   20G  0 part /
sdb      8:16   0  500M  0 disk
└─sdb1   8:17   0  499M  0 part

root@clientelinux:/# systemctl enable iSCSI.mount
Created symlink /etc/systemd/system/multi-user.target.wants/iSCSI.mount → /etc/systemd/system/iSCSI.mount.

root@clientelinux:/# reboot
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.

javier@debian:~/Vagrant/Deb10-iSCSI$ vagrant ssh clientelinux
...

vagrant@clientelinux:~$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
└─sda1   8:1    0   20G  0 part /
sdb      8:16   0  500M  0 disk
└─sdb1   8:17   0  499M  0 part /iSCSI
</pre>

La nueva unidad funciona correctamente, por lo que este apartado estaría terminado.


## Configuración de target con 2 LUN y autenticación por CHAP

El cliente *Windows* lo he creado con interfaz gráfica y también se encuentra conectado en modo puente a mi red doméstica, al igual que esta máquina.

En este caso, no utilizaré volúmenes lógicos como anteriormente.

Al igual que en primer apartado, para crear un nuevo *target* en el **servidor**, deberemos crear un nuevo fichero en la ruta `/etc/tgt/conf.d/`, este recibirá el nombre `target2.conf` y su contenido será el siguiente:

<pre>
<\target iqn.iscsi2.com:target2\>
    driver iscsi
    controller_tid 2
    backing-store /dev/sdc
    backing-store /dev/sdd
    incominguser javier passwordjavier
<\/target\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Hecho esto, reiniciamos el servicio:

<pre>
systemctl restart tgt
</pre>

Reiniciado el servicio, debe haber detectado el nuevo *target iSCSI*, así que vamos a comprobarlo:

<pre>
root@servidor:~# tgtadm --lld iscsi --op show --mode target
Target 1: iqn.iscsi.com:target1
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
        I_T nexus: 1
            Initiator: iqn.1993-08.org.debian:01:42628863363 alias: clientelinux
            Connection: 0
                IP Address: 192.168.0.58
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00010000
            SCSI SN: beaf10
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: null
            Backing store path: None
            Backing store flags:
        LUN: 1
            Type: disk
            SCSI ID: IET     00010001
            SCSI SN: beaf11
            Size: 524 MB, Block size: 512
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: rdwr
            Backing store path: /dev/vollogs/vollog1
            Backing store flags:
    Account information:
    ACL information:
        ALL
Target 2: iqn.iscsi2.com:target2
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00020000
            SCSI SN: beaf20
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: null
            Backing store path: None
            Backing store flags:
        LUN: 1
            Type: disk
            SCSI ID: IET     00020001
            SCSI SN: beaf21
            Size: 1074 MB, Block size: 512
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: rdwr
            Backing store path: /dev/sdc
            Backing store flags:
        LUN: 2
            Type: disk
            SCSI ID: IET     00020002
            SCSI SN: beaf22
            Size: 1074 MB, Block size: 512
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: rdwr
            Backing store path: /dev/sdd
            Backing store flags:
    Account information:
        javier
    ACL information:
        ALL
</pre>

Efectivamente, nos muestra su información, además del *target1* configurado anteriormente, por lo que el comportamiento es el esperado y el nuevo *target* se encuentra bien configurado.

Es hora de pasar con la configuración del **iniciador**. Ya en la máquina *Windows*, vamos a dirigirnos a la configuración de *iSCSI*.

Una vez estamos en la ventana de propiedades del *iniciador iSCSI*, nos situamos en la pestaña **Detección**, y *clickamos* en el botón llamado **Detectar portal**, hecho esto, se nos abrirá una ventana como la siguiente, en la que indicaremos la dirección IP del *target* y el puerto:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/windows1.png" />

Añadido nuestro servidor, si nos dirigimos en la pestaña **Destinos**, podremos apreciar como se han añadido a nuestra lista los dos *targets*, aunque actualmente se encuentran en un estado inactivo. Para activar la conexión al segundo *target*, *clickamos* en **Conectar**. Acto seguido nos aparecerá una ventana emergente, en la que tendremos que abrir las opciones avanzadas, y en ellas, activaremos la opción llamada **Habilitar inicio de sesión CHAP**, e introduciremos nuestras credenciales.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/windows2.png" />

Tras ello, podremos disfrutar de nuestro cliente *Windows* conectado a nuestro *target*.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/windows3.png" />

Una vez conectado, si nos dirigimos a **Crear y formatear particiones del disco duro**, podremos visualizar como se han añadido los dos nuevos discos a nuestro sistema:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/windows4.png" />

Hecho esto, debemos inicializar ambos discos en nuestro sistema, para ello simplemente hacemos *click* derecho sobre el apartado de la izquierda y seleccionamos **Inicializar disco**. Nos aparecerá la siguiente ventana:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/windows5.png" />

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/windows6.png" />

Una vez los tengamos inicializados en nuestro sistema ya tendrán una tabla de particiones en su interior, de forma que tan sólo nos quedaría establecer un sistema de ficheros NTFS en ellos. Para ello, haremos *click* derecho sobre cada uno de ellos y seleccionaremos la opción llamada **Nuevo volumen simple**.

Se nos abrirá una nueva ventana emergente que nos guiará mediante el proceso, el cuál consiste en pulsar **Siguiente** en repetidas ocasiones. El resultado final sería el siguiente:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/windows7.png" />

Podemos ver como efectivamente ya poseen un sistema de ficheros NTFS, de manera que ya se encontrarían totalmente operativos en el sistema.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_utilización_de_iSCSI_en_Linux_y_Windows/windows8.png" />

Con esto, ya hemos visto todo el contenido referente a este *post*, por lo que finalizaría aquí.
