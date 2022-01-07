---
layout: post
---

En este *post* vamos a ver el sistema de ficheros **Btrfs**.

#### Características

**Btrfs** *(B-tree FS)* es un sistema de archivos **copy-on-write** *(CoW)* anunciado por *Oracle Corporation* para *GNU/Linux*. *Btrfs* existe porque los desarrolladores querían expandir la funcionalidad de un sistema de archivos para incluir funcionalidades adicionales tales como agrupación, instantáneas y sumas de verificación.

El proyecto comenzó en *Oracle*, pero desde entonces, otras compañías importantes han desempeñado un papel en el desarrollo, como pueden ser *Facebook*, *Intel*, *Netgear*, *Red Hat* y *SUSE*.

Veamos algunas características de este sistema de ficheros:

- 2^64 bytes = 16 EiB *(Exbibyte)* tamaño máximo de archivo

- Empaquetado eficiente en espacio de archivos pequeños y directorios indexados

- Asignación dinámica de inodos (no se fija un número máximo de archivos al crear el sistema de archivos)

- *Snapshots* escribibles y *snapshots* de *snapshots*

- Subvolúmenes

- *Mirroring* y *Striping* a nivel de objeto

- Comprobación de datos y metadatos

- Compresión

- *Copy-on-write* del registro de todos los datos y metadatos

- Gran integración con *device-mapper* para soportar múltiples dispositivos, con varios algoritmos de RAID incluidos

- Comprobación del sistema de archivos sin desmontar y comprobación muy rápida del sistema de archivos desmontado

- Copias de seguridad incrementales eficaces y *mirroring* del sistema de archivos

- Modo optimizado para SSD

- Desfragmentación sin desmontar


#### Escenario de trabajo

Para empezar a trabajar con este sistema de ficheros, he creado un escenario en *OpenStack* que se resume en una instancia con *Debian*, a la que le he añadido tres volúmenes de 1 GB cada uno, como podemos observar aquí:

<pre>
root@btrfs:~# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    254:0    0   2G  0 disk
└─vda1 254:1    0   2G  0 part /
vdb    254:16   0   1G  0 disk
vdc    254:32   0   1G  0 disk
vdd    254:48   0   1G  0 disk
</pre>

Pasemos con la instalación.

#### Instalación

Para instalar *Btrfs* en nuestro sistema *Debian*, tenemos disponible el paquete **btrfs-tools**, que incluye todas las herramientas y características de este sistema de ficheros.

<pre>
apt install btrfs-tools -y
</pre>

Ya habremos instalado las herramientas.

#### Gestión de los discos

En primer lugar, vamos a formatear uno de estos volúmenes y asignarle como sistema de ficheros *Btrfs*. Para ello, hacemos uso de la herramienta `mkfs.()` seguido del dispositivo:

<pre>
root@btrfs:~# mkfs.btrfs /dev/vdb
</pre>

Comprobamos que hemos asignado este *filesystem* correctamente:

<pre>
root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.4M    51% /
vdb    btrfs        800a0dc3-d7d2-433a-8445-69e0d09d99cd                
vdc
vdd
</pre>

Efectivamente ya estaríamos gestionando el dispositivo `vdb` con *Btrfs*.

#### RAID

¿Y qué pasa si quisiéramos crear un sistema **RAID** con los 3 nuevos volúmenes? Bien, pues para llevar a cabo esto, nos valdría con introducir el mismo comando que hemos utilizado para formatear un dispositivo, pero indicando los tres discos en este caso.

Esto ocurre ya que *Btrfs* lo interpreta como un RAID para su gestión aunque no lo estemos indicando. Si queremos indicar el tipo de RAID que debe crear, podemos utilizar los parámetros `-d` y `-m` para especificar el perfil de redundancia para los datos y metadatos. En mi caso, voy a crear un RAID 1, que recordemos que se caracteriza por duplicar el almacenamiento de los datos en todos los dispositivos:

<pre>
root@btrfs:~# mkfs.btrfs -d raid1 -m raid1 /dev/vdb /dev/vdc /dev/vdd
btrfs-progs v4.20.1
See http://btrfs.wiki.kernel.org for more information.

/dev/vdb appears to contain an existing filesystem (btrfs).
ERROR: use the -f option to force overwrite of /dev/vdb
</pre>

Al haber utilizado anteriormente el disco `vdb` nos avisa que ya tiene un sistema de ficheros y que si queremos asignarle nuevamente este *filesystem*, tendremos que indicar el parámetro `-f` y de esta manera forzarlo.

<pre>
root@btrfs:~# mkfs.btrfs -f -d raid1 -m raid1 /dev/vdb /dev/vdc /dev/vdd
btrfs-progs v4.20.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               1675b6b0-4741-4341-bb5b-403e1e7c2932
Node size:          16384
Sector size:        4096
Filesystem size:    3.00GiB
Block group profiles:
  Data:             RAID1           153.56MiB
  Metadata:         RAID1           153.56MiB
  System:           RAID1             8.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Number of devices:  3
Devices:
   ID        SIZE  PATH
    1     1.00GiB  /dev/vdb
    2     1.00GiB  /dev/vdc
    3     1.00GiB  /dev/vdd
</pre>

Vemos como efectivamente ahora poseen *Btrfs*:

<pre>
root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.4M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdd    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932
</pre>

Además de poseer este sistema de ficheros, apreciamos como los identificadores de los tres dispositivos son idénticos, esto se debe a que el sistema lo identifica como tan sólo uno.

Os preguntaréis como haríamos para añadir un nuevo disco a este RAID ya existente, antes de verlo, vamos a montar el sistema RAID en nuestro sistema:

<pre>
root@btrfs:~# mount /dev/vdb /mnt/

root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.1M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932  734.9M     1% /mnt
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdd    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                

root@btrfs:~# btrfs scrub start /mnt/
scrub started on /mnt/, fsid 1675b6b0-4741-4341-bb5b-403e1e7c2932 (pid=640)

root@btrfs:~# btrfs scrub status /mnt/
scrub status for 1675b6b0-4741-4341-bb5b-403e1e7c2932
	scrub started at Mon Jan 18 18:10:43 2021 and finished after 00:00:00
	total bytes scrubbed: 512.00KiB with 0 errors
</pre>

Una vez montado nuestro RAID, vamos a añadir un nuevo dispositivo, en este caso el llamado `vde`:

<pre>
root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.1M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932  581.3M     1% /mnt
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdd    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vde
</pre>

Vemos que no posee el sistema *Btrfs*, y es una unidad nueva, lo añadimos:

<pre>
root@btrfs:~# btrfs device add /dev/vde /mnt/

root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.1M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932    1.1G     1% /mnt
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdd    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vde    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 320.00KiB
	devid    1 size 1.00GiB used 595.12MiB path /dev/vdb
	devid    2 size 1.00GiB used 665.56MiB path /dev/vdc
	devid    3 size 1.00GiB used 441.56MiB path /dev/vdd
	devid    4 size 1.00GiB used 0.00B path /dev/vde
</pre>

Ya habríamos añadido este nuevo dispositivo pero aún nos faltaría activar el balanceo de carga para que se reparta la información entre los discos, incluyendo el nuevo que hemos añadido.

<pre>
root@btrfs:~# btrfs balance start --full-balance /mnt/
Done, had to relocate 5 out of 5 chunks

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 320.00KiB
	devid    1 size 1.00GiB used 288.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 416.00MiB path /dev/vdc
	devid    3 size 1.00GiB used 256.00MiB path /dev/vdd
	devid    4 size 1.00GiB used 448.00MiB path /dev/vde
</pre>

En este punto, sí se habría añadido completamente el disco y su funcionamiento sería el correcto.

Para seguir, vamos a probar a ver que pasaría en caso de que uno de los discos fallara, por ejemplo el `vdd`, por tanto, el sistema ya no lo reconoce e identifica un fallo en el sistema RAID, y he añadido el nuevo disco `vdf` para que sustituya al anterior y así se pueda restaurar el RAID correctamente.

<pre>
root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.1M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932    1.5G     1% /mnt
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vde    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdf

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 256.00KiB
	devid    1 size 1.00GiB used 288.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 32.00MiB path /dev/vdc
	devid    4 size 1.00GiB used 416.00MiB path /dev/vde
	*** Some devices missing
</pre>

Vemos como nos detecta el fallo debido a que falta un dispositivo, y procedemos a sustituirlo:

<pre>
root@btrfs:~# btrfs device add /dev/vdf /mnt/ && btrfs device delete /dev/vdd /mnt/

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 320.00KiB
	devid    1 size 1.00GiB used 288.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 448.00MiB path /dev/vdc
	devid    4 size 1.00GiB used 256.00MiB path /dev/vde
	devid    6 size 1.00GiB used 416.00MiB path /dev/vdf
</pre>

Hecho esto, habríamos resuelto este problema y habríamos sustituido el disco estropeado.

Bien, ¿y si tuviéramos dudas entre elegir RAID mediante *Btrfs* o mediante la herramienta `mdadm`, qué diferencia tendríamos entre ellas? Pues para responder esta pregunta es necesario conocer las ventajas y los inconvenientes de cada una de las opciones, así que pasaremos a analizarlas.

Una ventaja de RAID software mediante `mdadm` es que sencillo de realizar, forma un sistema estable y tiene un mayor rendimiento. Por otro lado, con *Btrfs* los datos se encuentran protegidos con un mayor sistema de seguridad. Pero sobre todo, la principal diferencia, es que haciendo uso de *Btrfs*, podemos crear un RAID 1 con discos de diferentes tamaños, incluso con la posibilidad de ampliarlos, mientras que con `mdadm` es necesario el mismo tamaño en los discos. Por último, una cosa que no he comentado anteriormente y es bastante interesante, es que por ejemplo, hemos montado un RAID 1, que consta de 4 discos de 1 GB cada uno, y conociendo las características de este tipo de RAID, el espacio total sería de 1 GB, como el menor de sus discos, pues vamos a comprobar el tamaño de este RAID:

<pre>
root@btrfs:~# df -h
Filesystem      Size  Used Avail Use% Mounted on

...

/dev/vdb        2.0G   17M  1.7G   1% /mnt
</pre>

¡Anda! Resulta que duplica el tamaño esperado, y esto es porque *Btrfs* gestiona el almacenamiento de una manera distinta, ya que reparte la información entre los diferentes dispositivos, aprovechando el máximo espacio posible, al mismo tiempo que asegura que la información se encuentra lo más segura posible. Así que imaginemos que creamos un RAID 1 con discos de distintos tamaños, ya no tendríamos el inconveniente de que el tamaño será igual al menor de sus discos.

Lógicamente la elección de uno u otro es algo subjetivo y dependerá de gustos, costumbres y necesidades, pero en resumen, poseemos más flexibilidad y muchas más características útiles en el RAID con *Btrfs* respecto al RAID con `mdadm`.


#### Compresión

Como vimos al principio del artículo cuando enumerábamos las características de *Btrfs*, este sistema de ficheros posee la capacidad para realizar la llamada **compresión al vuelo**, por tanto, en este apartado vamos a realizar algunos ejercicios y pruebas de este funcionamiento.

Antes de empezar, me gustaría explicar un poco que significa este término y para qué nos sirve. Es la posibilidad de almacenar la información comprimida, y en el momento que necesitemos hacer uso de esta información, el propio sistema es capaz de descomprimirla, leerla y acto seguido, volverla a comprimir para almacenarla. Esto nos da la posibilidad de almacenar muchísima más información que la que en un principio podríamos guardar, ya que como sabemos, un archivo comprimido reduce bastante su tamaño original.

Existen dos maneras de compresión al vuelo, que son las llamadas **ZLIB** y **LZO**.

¿Y qué diferencias hay entre estas dos opciones?

- **LZO**: es una compresión mas rápida pero menos exigente, lo que penaliza la capacidad de compresión, es decir, no llega a comprimir tanto la información.
- **ZLIB**: es más exigente y por ello, comprime más la información, con el *hándicap* en cuanto a tiempo y en cuanto a la carga de CPU, que es un poco mayor.

En mi caso voy a utilizar la opción *LZIB*. La compresión con esta opción, se lleva a cabo con el siguiente comando:

<pre>
mount -o compress=zlib /dev/(dispositivo) /(punto de montaje)/
</pre>

En mi caso, voy a comprimir el volumen denominado `vdb`, por lo que utilizo el siguiente comando:

<pre>
mount -o compress=zlib /dev/vdb /mnt/
</pre>

Hay que recordar que esta unidad, pertenece al RAID 1 creado anteriormente, que constaba de 4 discos de 1 GB cada uno, obteniendo un espacio total de **2 GB**:

<pre>
root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 256.00KiB
	devid    1 size 1.00GiB used 288.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 448.00MiB path /dev/vdc
	devid    4 size 1.00GiB used 256.00MiB path /dev/vde
	devid    6 size 1.00GiB used 416.00MiB path /dev/vdf
</pre>

Dicho esto, vamos a probar a introducir la máxima información posible, para comprobar que podemos almacenar más espacio del que realmente poseemos gracias a la compresión. Con el siguiente comando vamos crear un fichero lleno de ceros, y posteriormente, miraremos el espacio que realmente ocupa dicho fichero.

<pre>
root@btrfs:~# dd if=/dev/zero of=/mnt/fichero
dd: writing to '/mnt/fichero': No space left on device
113354259+0 records in
113354258+0 records out
58037380096 bytes (58 GB, 54 GiB) copied, 835.45 s, 69.5 MB/s

root@btrfs:~# ls -la /mnt/ && du -h /mnt/
total 56677152
drwxr-xr-x  1 root root          34 Jan 22 16:20 .
drwxr-xr-x 18 root root        4096 Jan 18 18:06 ..
-rw-r--r--  1 root root 58037380096 Jan 22 16:34 fichero

55G	/mnt/
</pre>

¡Vaya! Resulta que dicho fichero ocupa alrededor de **55 GB**, cuando el espacio total del RAID era de 2 GB. Por si acaso, vamos a ver de nuevo los detalles de esta unidad:

<pre>
root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 1.79GiB
	devid    1 size 1.00GiB used 1023.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 1023.00MiB path /dev/vdc
	devid    4 size 1.00GiB used 1023.00MiB path /dev/vde
	devid    6 size 1.00GiB used 1023.00MiB path /dev/vdf
</pre>

Y efectivamente, estamos almacenando un fichero comprimido de 55 GB, en un espacio real de 1.79 GiB.


#### Copy on Write (CoW)

**Copy on Write** conocido también por sus siglas **CoW**, es una optimización que permite almacenar una sola vez copias de datos indistinguibles. Es en el momento en el que una de estas copias se modifica en el que se realiza físicamente la copia. Así, aquellas copias que no llegan a modificarse nunca, solo existen en apariencia y remiten a los datos originales.

Para realizar ejercicios y mostrar el funcionamiento de *CoW*, voy a eliminar en primer lugar, el fichero creado en el apartado anterior y de esta manera seguir trabajando con la totalidad del RAID, aunque también podría sacar un disco del RAID y trabajar con él, pero prefiero la primera opción.

<pre>
root@btrfs:/mnt# ls
fichero

root@btrfs:/mnt# rm fichero

root@btrfs:/mnt# df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdb        2.0G   17M  1.7G   1% /mnt
</pre>

En el apartado anterior trabajamos con el RAID, así que vamos a cambiar y ahora simplemente vamos a trabajar con un disco, para ello voy a eliminar el disco `vdf` del RAID y posteriormente desmontaré el sistema RAID, y montaré el nuevo disco en el sistema:

<pre>
root@btrfs:~# btrfs device delete /dev/vdf /mnt/

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 3 FS bytes used 6.91MiB
	devid    1 size 1.00GiB used 352.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 32.00MiB path /dev/vdc
	devid    4 size 1.00GiB used 320.00MiB path /dev/vde

root@btrfs:~# umount /mnt/

root@btrfs:~# mkfs.btrfs /dev/vdf
btrfs-progs v4.20.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               d59c6498-b013-4bd5-bf6e-6e2838ce8894
Node size:          16384
Sector size:        4096
Filesystem size:    1.00GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         DUP              51.19MiB
  System:           DUP               8.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1     1.00GiB  /dev/vdf

root@btrfs:~# mount /dev/vdf /mnt/
</pre>

Ahora voy a proceder a crear un fichero que será con el que trabajaremos:

<pre>
root@btrfs:~# dd if=/dev/zero of=/mnt/ficheroprueba bs=2048 count=100k
102400+0 records in
102400+0 records out
209715200 bytes (210 MB, 200 MiB) copied, 2.06027 s, 102 MB/s

root@btrfs:~# ls /mnt/
ficheroprueba

root@btrfs:~# btrfs fi usage /mnt
Overall:
    Device size:		   1.00GiB
    Device allocated:		 462.38MiB
    Device unallocated:		 561.62MiB
    Device missing:		     0.00B
    Used:			 200.92MiB
    Free (estimated):		 705.42MiB	(min: 424.61MiB)
    Data ratio:			      1.00
    Metadata ratio:		      2.00
    Global reserve:		  16.00MiB	(used: 0.00B)

Data,single: Size:344.00MiB, Used:200.20MiB
   /dev/vdf	 344.00MiB

Metadata,DUP: Size:51.19MiB, Used:352.00KiB
   /dev/vdf	 102.38MiB

System,DUP: Size:8.00MiB, Used:16.00KiB
   /dev/vdf	  16.00MiB

Unallocated:
   /dev/vdf	 561.62MiB
</pre>

Vemos que el fichero ocupa un espacio de **200 MB**. Bien, ahora vamos a realizar una copia de éste. Le indicamos el parámetro `--reflink=always` para que nos permita realizar un clon del fichero, es decir, una copia aparente basada en *CoW*.

<pre>
root@btrfs:~# cp --reflink=always /mnt/ficheroprueba /mnt/ficheropruebaCoW

root@btrfs:~# ls /mnt/
ficheroprueba  ficheropruebaCoW

root@btrfs:~# btrfs fi usage /mnt
Overall:
    Device size:		   1.00GiB
    Device allocated:		 462.38MiB
    Device unallocated:		 561.62MiB
    Device missing:		     0.00B
    Used:			 200.92MiB
    Free (estimated):		 705.42MiB	(min: 424.61MiB)
    Data ratio:			      1.00
    Metadata ratio:		      2.00
    Global reserve:		  16.00MiB	(used: 0.00B)

Data,single: Size:344.00MiB, Used:200.20MiB
   /dev/vdf	 344.00MiB

Metadata,DUP: Size:51.19MiB, Used:352.00KiB
   /dev/vdf	 102.38MiB

System,DUP: Size:8.00MiB, Used:16.00KiB
   /dev/vdf	  16.00MiB

Unallocated:
   /dev/vdf	 561.62MiB
</pre>

Apreciamos que el nuevo fichero no ha afectado en absoluto al espacio ocupado del dispositivo, ya que aún no se ha realizado ninguna modificación.


#### Deduplicación

¿En qué consiste la **deduplicación**?

Consiste en identificar cuándo los datos se han escrito dos veces y combinarlos en una misma extensión del disco, con el objetivo de optimizar al máximo el espacio de almacenamiento utilizado, eliminando copias duplicadas o repetidas de datos.

Para hacer uso de la deduplicación de datos debemos instalar el siguiente paquete:

<pre>
apt install duperemove -y
</pre>

Vamos a utilizar de nuevo el dispositivo `vdf`, para ello voy a formatearlo de nuevo:

<pre>
root@btrfs:~# umount /mnt

root@btrfs:~# mkfs.btrfs -f /dev/vdf
btrfs-progs v4.20.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               6e1e1285-8652-445b-b44f-af22438387fc
Node size:          16384
Sector size:        4096
Filesystem size:    1.00GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         DUP              51.19MiB
  System:           DUP               8.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1     1.00GiB  /dev/vdf

root@btrfs:~# mount /dev/vdf /mnt/
</pre>

Ahora vamos a crear un fichero de **100 MB**:

<pre>
root@btrfs:~# dd if=/dev/zero of=/mnt/pruebadeduplicacion bs=2048 count=50k
51200+0 records in
51200+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 1.04235 s, 101 MB/s

root@btrfs:~# ls /mnt/
pruebadeduplicacion

root@btrfs:~# du -h /mnt/pruebadeduplicacion
100M	/mnt/pruebadeduplicacion

root@btrfs:~# df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdf        1.0G  117M  805M  13% /mnt

root@btrfs:~# btrfs fi usage /mnt
Overall:
    Device size:		   1.00GiB
    Device allocated:		 238.38MiB
    Device unallocated:		 785.62MiB
    Device missing:		     0.00B
    Used:			 100.57MiB
    Free (estimated):		 805.55MiB	(min: 412.74MiB)
    Data ratio:			      1.00
    Metadata ratio:		      2.00
    Global reserve:		  16.00MiB	(used: 0.00B)

Data,single: Size:120.00MiB, Used:100.07MiB
   /dev/vdf	 120.00MiB

Metadata,DUP: Size:51.19MiB, Used:240.00KiB
   /dev/vdf	 102.38MiB

System,DUP: Size:8.00MiB, Used:16.00KiB
   /dev/vdf	  16.00MiB

Unallocated:
   /dev/vdf	 785.62MiB
</pre>

Una vez creado, apreciamos que en nuestro dispositivo se encuentran en uso **100 MB**, es decir, lo esperado, pero ahora vamos a almacenar una copia del mismo fichero:

<pre>
root@btrfs:~# cp /mnt/pruebadeduplicacion /mnt/pruebadeduplicacion2

root@btrfs:~# ls /mnt
pruebadeduplicacion  pruebadeduplicacion2

root@btrfs:~# df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdf        1.0G  217M  705M  24% /mnt

root@btrfs:~# btrfs fi usage /mnt
Overall:
    Device size:		   1.00GiB
    Device allocated:		 350.38MiB
    Device unallocated:		 673.62MiB
    Device missing:		     0.00B
    Used:			 200.88MiB
    Free (estimated):		 705.49MiB	(min: 368.68MiB)
    Data ratio:			      1.00
    Metadata ratio:		      2.00
    Global reserve:		  16.00MiB	(used: 0.00B)

Data,single: Size:232.00MiB, Used:200.13MiB
   /dev/vdf	 232.00MiB

Metadata,DUP: Size:51.19MiB, Used:368.00KiB
   /dev/vdf	 102.38MiB

System,DUP: Size:8.00MiB, Used:16.00KiB
   /dev/vdf	  16.00MiB

Unallocated:
   /dev/vdf	 673.62MiB
</pre>

Podemos ver como ahora se encuentran en uso **200 MB**.

Es el momento de aplicar la deduplicación, para ello aplicamos el siguiente comando:

<pre>
root@btrfs:~# duperemove -dr /mnt
Gathering file list...
Using 1 threads for file hashing phase
[1/2] (50.00%) csum: /mnt/pruebadeduplicacion
[2/2] (100.00%) csum: /mnt/pruebadeduplicacion2
Total files:  2
Total hashes: 1600
Loading only duplicated hashes from hashfile.
Hashing completed. Using 1 threads to calculate duplicate extents. This may take some time.
[########################################]
Search completed with no errors.             
Simple read and compare of file data found 1 instances of extents that might benefit from deduplication.
Showing 2 identical extents of length 104857600 with id 19b81479
Start		Filename
0	"/mnt/pruebadeduplicacion2"
0	"/mnt/pruebadeduplicacion"
Using 1 threads for dedupe phase
[0x5649765e0c00] (1/1) Try to dedupe extents with id 19b81479
[0x5649765e0c00] Dedupe 1 extents (id: 19b81479) with target: (0, 104857600), "/mnt/pruebadeduplicacion2"
Comparison of extent info shows a net change in shared extents of: 209715200
</pre>

Si observamos la salida del comando, podemos ver como nos hace referencia a ambos ficheros, pero, ¿realmente habremos ahorrado el espacio? Vamos a comprobarlo:

<pre>
root@btrfs:~# ls /mnt
pruebadeduplicacion  pruebadeduplicacion2

root@btrfs:~# df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdf        1.0G  117M  805M  13% /mnt

root@btrfs:~# btrfs fi usage /mnt
Overall:
    Device size:		   1.00GiB
    Device allocated:		 238.38MiB
    Device unallocated:		 785.62MiB
    Device missing:		     0.00B
    Used:			 100.62MiB
    Free (estimated):		 805.50MiB	(min: 412.69MiB)
    Data ratio:			      1.00
    Metadata ratio:		      2.00
    Global reserve:		  16.00MiB	(used: 0.00B)

Data,single: Size:120.00MiB, Used:100.12MiB
   /dev/vdf	 120.00MiB

Metadata,DUP: Size:51.19MiB, Used:240.00KiB
   /dev/vdf	 102.38MiB

System,DUP: Size:8.00MiB, Used:16.00KiB
   /dev/vdf	  16.00MiB

Unallocated:
   /dev/vdf	 785.62MiB
</pre>

¡Bien! Efectivamente la deduplicación ha surgido efecto y tan solo estamos ocupando **100 MB** en nuestro dispositivo gracias a *Btrfs*.


#### Redimensión

En este apartado vamos a analizar las redimensiones del espacio en dispositivos que disponen de *Btrfs*.

Empezaremos viendo el caso de disminuir el espacio, para el que tendríamos que utilizar el siguiente comando:

<pre>
root@btrfs:~# btrfs filesystem show /mnt/
Label: none  uuid: 6e1e1285-8652-445b-b44f-af22438387fc
	Total devices 1 FS bytes used 100.31MiB
	devid    1 size 1.00GiB used 238.38MiB path /dev/vdf

root@btrfs:~# btrfs filesystem resize -100M /mnt/
Resize '/mnt/' of '-100M'

root@btrfs:~# btrfs filesystem show /mnt/
Label: none  uuid: 6e1e1285-8652-445b-b44f-af22438387fc
	Total devices 1 FS bytes used 100.31MiB
	devid    1 size 924.00MiB used 238.38MiB path /dev/vdf
</pre>

Hemos reducido el espacio del dispositivo en 100 MB.

Por el contrario, si lo que quisiéramos fuera aumentar el espacio utilizaríamos el mismo comando pero cambiando el signo a `+`:

<pre>
root@btrfs:~# btrfs filesystem show /mnt/
Label: none  uuid: 6e1e1285-8652-445b-b44f-af22438387fc
	Total devices 1 FS bytes used 100.31MiB
	devid    1 size 924.00MiB used 238.38MiB path /dev/vdf

root@btrfs:~# btrfs filesystem resize +100M /mnt/
Resize '/mnt/' of '+100M'

root@btrfs:~# btrfs filesystem show /mnt/
Label: none  uuid: 6e1e1285-8652-445b-b44f-af22438387fc
	Total devices 1 FS bytes used 100.31MiB
	devid    1 size 1.00GiB used 238.38MiB path /dev/vdf
</pre>

Hemos aumentado el espacio del dispositivo en 100 MB.


#### Desfragmentación

Hasta ahora, prácticamente todo lo que hemos visto de *Btrfs* han sido aspectos positivos, pero tiene un pequeño punto negativo, y éste es, que sufre fragmentación. Sin embargo, también disponemos de una herramienta para aplicar una **desfragmentación** en caso de que fuera necesario.

Si queremos realizar una desfragmentación tenemos que introducir el siguiente comando:

<pre>
root@btrfs:~# btrfs filesystem defrag /mnt
</pre>

Si queremos realizar una desfragmentación recursiva tenemos que introducir el siguiente comando:

<pre>
root@btrfs:~# btrfs filesystem defrag -r /mnt
</pre>

Listo.


#### Conversión de sistemas de ficheros basados en ext*

Otra de las características de *Btrfs*, es que permite convertir sistemas **ext2**, **ext3** y **ext4** a **Btrfs**.

Las conversiones deben realizarse en sistemas de ficheros que se encuentran desmontados.

Explicado esto, vamos a realizar una conversión de un sistema de ficheros *ext4* a *Btrfs*, para ello voy a formatear el dispositivo `vdf` con un sistema de ficheros *ext4*:

<pre>
root@btrfs:~# mkfs.ext4 /dev/vdf
mke2fs 1.44.5 (15-Dec-2018)
/dev/vdf contains a btrfs file system
Proceed anyway? (y,N) y
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: a8e136e4-06a5-4183-ae6a-e22dca2a4658
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

root@btrfs:~# lsblk -f | grep 'vdf'
vdf    ext4         a8e136e4-06a5-4183-ae6a-e22dca2a4658
</pre>

Hecho esto, y desmontado, vamos a usar `btrfs-convert` para convertir el dispositivo con formato *ext4* a un dispositivo formateado en *Btrfs*:

<pre>
root@btrfs:~# btrfs-convert /dev/vdf
-bash: btrfs-convert: command not found
</pre>

Como se puede ver, me aparece que no dispongo del comando `btrfs-convert` y según lo que he leído, esta herramienta se incluye en el paquete `btrfs-progs` y dicho paquete se encuentra instalado. Bueno, en caso de tener disponible el comando `btrfs-convert`, esta sería la manera de utilizarlo.

Por último, debemos editar el fichero `/etc/fstab` para cambiar la columna del sistema de ficheros de *ext4* a *Btrfs*.


#### Cifrado

Para finalizar el artículo, vamos a ver el **cifrado** con *Btrfs*.

Necesitamos instalar el siguiente paquete en nuestro sistema:

<pre>
apt install cryptsetup -y
</pre>

Una vez instalado, vamos a crear un fichero llamado *KeyFile* y lo cifraremos:

<pre>
root@btrfs:~# dd if=/dev/urandom of=/root/KeyFile bs=1 count=4096
4096+0 records in
4096+0 records out
4096 bytes (4.1 kB, 4.0 KiB) copied, 0.018509 s, 221 kB/s
</pre>

Vamos a cifrar el disco `vdf` con el comando:

<pre>
root@btrfs:~# dd if=/dev/urandom of=/root/KeyFile bs=1 count=4096
4096+0 records in
4096+0 records out
4096 bytes (4.1 kB, 4.0 KiB) copied, 0.0185828 s, 220 kB/s
root@btrfs:~# cryptsetup luksFormat --key-file /root/KeyFile /dev/vdf
WARNING: Device /dev/vdf already contains a 'btrfs' superblock signature.

WARNING!
========
This will overwrite data on /dev/vdf irrevocably.

Are you sure? (Type uppercase yes): YES
</pre>

El disco ya se encontraría cifrado, pero si queremos que utilice una contraseña debemos usar este comando:

<pre>
root@btrfs:~# cryptsetup luksFormat /dev/vdf
WARNING: Device /dev/vdf already contains a 'crypto_LUKS' superblock signature.

WARNING!
========
This will overwrite data on /dev/vdf irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase for /dev/vdf:
Verify passphrase:
</pre>

Para descifrar el disco, introduciremos:

<pre>
root@btrfs:~# cryptsetup open /dev/vdf vdf
Enter passphrase for /dev/vdf:
</pre>

Una vez introducida la contraseña habríamos terminado.

Vistos estos apartados, el contenido de este *post* habría finalizado.
