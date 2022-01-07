---
layout: post
---

**En este artículo vamos a implementar un sistema de copias de seguridad para las máquinas del escenario de *OpenStack* y la máquina de *OVH*.**

En primer lugar, me gustaría aclarar un poco cuál va a ser el entorno de trabajo, y es que el escenario sobre el que vamos a trabajar, ha sido construido en diferentes *posts* previamente elaborados. Los dejo ordenados a continuación por si te interesa:

- [Creación del escenario de trabajo en OpenStack](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html)
- [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html)
- [Servidores OpenStack: DNS, Web y Base de Datos](https://javierpzh.github.io/servidores-openstack-dns-web-y-base-de-datos.html)

He hecho más tareas sobre este escenario, las puedes encontrar todas [aquí](https://javierpzh.github.io/tag/openstack.html).

Respecto al equipo de **OVH**, se trata de un *VPS* con un sistema *Debian*.

Explicado esto, vamos a pasar con el contenido del *post* en cuestión, no sin antes explicar un poco la aplicación que vamos a utilizar y sus componentes.

## Bacula

He decidido escoger **Bacula** como aplicación para llevar a cabo este sistema de *backups*.

*Bacula* es una colección de herramientas de respaldo capaz de cubrir las necesidades de respaldo de equipos bajo redes IP. Se basa en una arquitectura cliente-servidor que resulta eficaz y fácil de manejar, dada la amplia gama de funciones y características que brinda. Además, debido a su desarrollo y estructura modular, *Bacula* se adapta tanto al uso personal como profesional, desde un equipo hasta grandes parques de servidores. Todo el conjunto de elementos que forman *Bacula* trabajan en sincronía y son totalmente compatibles con bases de datos como **MySQL**, **SQLite** y **PostgreSQL**.

#### Componentes de *Bacula*

- **Director *(DIR, bacula-director)*:** es el programa servidor que supervisa todas las funciones necesarias para las operaciones de copia de seguridad y restauración. Es el eje central de *Bacula* y en él se declaran todos los parámetros necesarios. Se ejecuta como un *demonio* en el servidor.

- **Storage *(SD, bacula-sd)*:** es el programa que gestiona las unidades de almacenamiento donde se almacenarán los datos. Es el responsable de escribir y leer en los medios que utilizaremos para nuestras copias de seguridad. Se ejecuta como un *demonio* en la máquina propietaria de los medios utilizados. En muchos casos será en el propio servidor, pero también puede ser otro equipo independiente.

- **Catalog**: es la base de datos (*MySQL* en mi caso) que almacena la información necesaria para localizar donde se encuentran los datos salvaguardados de cada archivo, de cada cliente, ... En muchos casos será en el propio servidor, pero también puede ser otro equipo independiente.

- **Console *(bconsole)*:** es el programa que permite la interacción con el *Director* para todas las funciones del servidor. La versión original es una aplicación en modo texto *(bconsole)*. Existen igualmente aplicaciones GUI para Windows y Linux *(Webmin, Bacula Admin Tool, Bacuview, Webacula, Reportula, Bacula-Web, ...)*.

- **File *(FD)*:** este servicio, conocido como *cliente* o servidor de ficheros está instalado en cada máquina a salvaguardar y es específico al sistema operativo donde se ejecuta. Responsable para enviar al *Director* los datos cuando este lo requiera.

#### Conceptos importantes

Para manejar mejor *Bacula* es importante conocer ciertos conceptos:

- Un **backup** consiste en una tarea *(JOB)*, un conjunto de directorios/archivos *(FILESET)*, un cliente *(CLIENT)*, un horario *(SCHEDULE)* y unos recursos *(POOL)*.

- El **FILESET** es lo que vamos a guardar, el *CLIENT* es la proveniencia de los datos, el *SCHEDULE* determina cuando lo vamos a ejecutar y el *POOL* es el destino de la copia de seguridad.

- Normalmente, una combinación **CLIENT/FILESET** generará un determinado *JOB*. Además de los *JOB* de *backup*, existirán también *JOB* de *restore* y otros de control y administración.

- Los medios de almacenamiento se definen como **POOL**. El *POOL* es un conjunto de volúmenes, son ficheros que actúan como un disco duro, y dentro de ellos están las copias de seguridad.


## Sistema de copias de seguridad

En mi caso, he decidido escoger como servidor (también conocido como **director**) de copias de seguridad a **Dulcinea** (máquina que también actuará como cliente). Le he añadido un nuevo volumen de 10 GB de espacio, donde se irán almacenando las copias de las distintas máquinas.

Empezaremos por instalar el *software* de *Bacula* y *MySQL*.

<pre>
apt install mariadb-server mariadb-client bacula bacula-common-mysql bacula-director-mysql -y
</pre>

Durante la instalación de *Bacula*, nos saldrá este mensaje emergente, en el que seleccionaremos **Yes**, para especificarle a la aplicación que deseamos configurarla con la base de datos *MySQL*:

<pre>
┌───────────────────────────────┤ Configuring bacula-director-mysql ├───────────────────────────────┐
│                                                                                                   │
│ The bacula-director-mysql package must have a database installed and configured before it can be  │
│ used. This can be optionally handled with dbconfig-common.                                        │
│                                                                                                   │
│ If you are an advanced database administrator and know that you want to perform this              │
│ configuration manually, or if your database has already been installed and configured, you        │
│ should refuse this option. Details on what needs to be done should most likely be provided in     │
│ /usr/share/doc/bacula-director-mysql.                                                             │
│                                                                                                   │
│ Otherwise, you should probably choose this option.                                                │
│                                                                                                   │
│ Configure database for bacula-director-mysql with dbconfig-common?                                │
│                                                                                                   │
│                            <\Yes\>                               <\No\>                           │
│                                                                                                   │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
</pre>

A continuación, nos pedirá que introduzcamos una contraseña y habremos finalizado el proceso de instalación.

Vamos a pasar directamente con el fichero de configuración del director *Bacula*, que se encuentra en `/etc/bacula/bacula-dir.conf`. En este archivo nos encontraremos diferentes secciones, que tenemos que diferenciar, veamos la primera, que se trata de la configuración del **director** de copias de seguridad:

<pre>
Director {
  Name = dulcinea-dir
  DIRport = 9101
  QueryFile = "/etc/bacula/scripts/query.sql"
  WorkingDirectory = "/var/lib/bacula"
  PidDirectory = "/run/bacula"
  Maximum Concurrent Jobs = 20
  Password = "bacula"
  Messages = Daemon
  DirAddress = 10.0.1.11
}
</pre>

La siguiente sección trata de las tareas que se van a realizar, es decir, los procesos encargados de hacer las copias de seguridad.

En este apartado tendremos bloques como el siguiente:

<pre>
JobDefs {
  Name =
  Type =
  Level =
  Client =
  FileSet =
  Schedule =
  Storage =
  Messages =
  Pool =
  SpoolAttributes =
  Priority =
  Write Bootstrap =
}
</pre>

Os preguntaréis qué es cada apartado, pues vamos a verlos uno a uno:

- **Name:** nombre de la tarea

- **Type:** tipo de tarea (*backup*)

- **Level:** nivel de la tarea

- **Client:** nombre del cliente en el que se va a ejecutar esta tarea

- **FileSet:** información que va a copiar. Será definida más adelante en el apartado *FileSet*

- **Schedule:** programación que tendrá dicha tarea

- **Storage:** nombre del cargador virtual automático que cargará el recurso de almacenamiento

- **Messages:** tipo de mensaje, indica como mandará los mensajes de sucesos

- **Pool:** indicaremos el nombre del apartado *Pool* que se configurará mas adelante y en él estamos indicando el volumen de almacenamiento donde se creará y almacenará las copias

- **SpoolAttributes:** esta opción permite trabajar con los atributos del *Spool* en un fichero temporal

- **Priority:** indica el nivel de prioridad

- **Write Bootstrap:** este apartado indica donde esta el fichero *bacula*

En mi caso, introduciré tres tipos de tareas distintas, una para las copias diarias, otra para las copias semanales y otra para las copias mensuales, de manera que me queda un bloque como el siguiente:

<pre>
JobDefs {
  Name = "BackupDiario"
  Type = Backup
  Level = Incremental
  Client = dulcinea-fd
  FileSet = "Full Set"
  Schedule = "Daily"
  Storage = volcopias
  Messages = Standard
  Pool = Daily
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}

JobDefs {
  Name = "BackupSemanal"
  Type = Backup
  Level = Incremental
  Client = dulcinea-fd
  FileSet = "Full Set"
  Schedule = "Weekly"
  Storage = volcopias
  Messages = Standard
  Pool = Weekly
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}

JobDefs {
  Name = "BackupMensual"
  Type = Backup
  Level = Incremental
  Client = dulcinea-fd
  FileSet = "Full Set"
  Schedule = "Monthly"
  Storage = volcopias
  Messages = Standard
  Pool = Monthly
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}
</pre>

A continuación nos encontramos con la sección donde definiremos las tareas de los clientes a los que vamos a realizar las copias de seguridad. Dentro de los siguientes bloques, indicamos el nombre de la tarea con la que va a ir relacionado y el nombre del cliente (se definirá más adelante). Introduciremos tantos bloques **Job** como tareas tengamos que asignar a los clientes. En mi caso:

<pre>
# Dulcinea
Job {
  Name = "Dulcinea-Diario"
  Client = "dulcinea-fd"
  JobDefs = "BackupDiario"
  FileSet= "Dulcinea-Datos"
}

Job {
  Name = "Dulcinea-Semanal"
  Client = "dulcinea-fd"
  JobDefs = "BackupSemanal"
  FileSet= "Dulcinea-Datos"
}

Job {
  Name = "Dulcinea-Mensual"
  Client = "dulcinea-fd"
  JobDefs = "BackupMensual"
  FileSet= "Dulcinea-Datos"
}

# Sancho
Job {
  Name = "Sancho-Diario"
  Client = "sancho-fd"
  JobDefs = "BackupDiario"
  FileSet= "Sancho-Datos"
}

Job {
  Name = "Sancho-Semanal"
  Client = "sancho-fd"
  JobDefs = "BackupSemanal"
  FileSet= "Sancho-Datos"
}

Job {
  Name = "Sancho-Mensual"
  Client = "sancho-fd"
  JobDefs = "BackupMensual"
  FileSet= "Sancho-Datos"
}

# Freston
Job {
  Name = "Freston-Diario"
  Client = "freston-fd"
  JobDefs = "BackupDiario"
  FileSet= "Freston-Datos"
}

Job {
  Name = "Freston-Semanal"
  Client = "freston-fd"
  JobDefs = "BackupSemanal"
  FileSet= "Freston-Datos"
}

Job {
  Name = "Freston-Mensual"
  Client = "freston-fd"
  JobDefs = "BackupMensual"
  FileSet= "Freston-Datos"
}

# Quijote
Job {
  Name = "Quijote-Diario"
  Client = "quijote-fd"
  JobDefs = "BackupDiario"
  FileSet= "Quijote-Datos"
}

Job {
  Name = "Quijote-Semanal"
  Client = "quijote-fd"
  JobDefs = "BackupSemanal"
  FileSet= "Quijote-Datos"
}

Job {
  Name = "Quijote-Mensual"
  Client = "quijote-fd"
  JobDefs = "BackupMensual"
  FileSet= "Quijote-Datos"
}

# vpsjavierpzh
Job {
  Name = "vpsjavierpzh-Diario"
  Client = "vpsjavierpzh-fd"
  JobDefs = "BackupDiario"
  FileSet= "vpsjavierpzh-Datos"
}

Job {
  Name = "vpsjavierpzh-Semanal"
  Client = "vpsjavierpzh-fd"
  JobDefs = "BackupSemanal"
  FileSet= "vpsjavierpzh-Datos"
}

Job {
  Name = "vpsjavierpzh-Mensual"
  Client = "vpsjavierpzh-fd"
  JobDefs = "BackupMensual"
  FileSet= "vpsjavierpzh-Datos"
}
</pre>

Igualmente que hemos definido en los clientes las tareas de *backups*, debemos definir las tareas de restauración (*restore*), para poder restaurar las copias de seguridad. En esta sección, tendremos bloques con el siguiente aspecto:

- **Name:** nombre de la tarea

- **Type:** tipo que de la tarea (*restore*)

- **Client:** cliente al que le vamos a poder realizar la restauración de la copia

- **Storage:** nombre del cargador virtual automático que cargará el recurso de almacenamiento

- **FileSet:** tipo de tarea al que hace referencia la copia de la que queremos realizar la restauración

- **Pool:** indicaremos el nombre del apartado *Pool* que se configurará mas adelante y en él estamos indicando el volumen de almacenamiento donde se creará y almacenará las copias

- **Messages:** tipo de mensaje, indica como mandará los mensajes de sucesos

En mi caso, introduzco los siguientes bloques:

<pre>
# Dulcinea
Job {
  Name = "DulcineaRestore"
  Type = Restore
  Client=dulcinea-fd
  Storage = volcopias
  FileSet="Dulcinea-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Sancho
Job {
  Name = "SanchoRestore"
  Type = Restore
  Client=sancho-fd
  Storage = volcopias
  FileSet="Sancho-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Freston
Job {
  Name = "FrestonRestore"
  Type = Restore
  Client=freston-fd
  Storage = volcopias
  FileSet="Freston-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Quijote
Job {
  Name = "QuijoteRestore"
  Type = Restore
  Client=quijote-fd
  Storage = volcopias
  FileSet="Quijote-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# vpsjavierpzh
Job {
  Name = "vpsjavierpzhRestore"
  Type = Restore
  Client=vpsjavierpzh-fd
  Storage = volcopias
  FileSet="vpsjavierpzh-Datos"
  Pool = Backup-Restore
  Messages = Standard
}
</pre>

Seguimos con la sección donde indicaremos, que tipo de información se almacenarán en los *backups*, indicando que directorios se copiarán y cuáles no, y el tipo de almacenamiento, que en mi caso se tratará de un almacenamiento comprimido para así ahorrar espacio.

<pre>
# Full Set
FileSet {
 Name = "Full Set"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/cache
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Dulcinea
FileSet {
 Name = "Dulcinea-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/cache
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Sancho
FileSet {
 Name = "Sancho-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/cache
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Freston
FileSet {
 Name = "Freston-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Quijote
FileSet {
 Name = "Quijote-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# vpsjavierpzh
FileSet {
 Name = "vpsjavierpzh-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}
</pre>

Llegamos a la sección de los bloques de tipo **SCHEDULE**, en éstos definiremos la programación de estas tareas, es decir, cuando se llevarán a cabo cada una. En mi caso:

<pre>
Schedule {
 Name = "Daily"
 Run = Level=Incremental Pool=Daily daily at 02:00
}

Schedule {
 Name = "Weekly"
 Run = Level=Full Pool=Weekly sun at 02:00
}

Schedule {
 Name = "Monthly"
 Run = Level=Full Pool=Monthly 1st sun at 02:00
}
</pre>

Estamos llegando al final de la configuración de este fichero, en este caso nos encontramos con los equipos clientes, cuyos bloques incluirán las siguientes opciones:

- **Name:** Nombre distintivo del cliente

- **Address:** Direccion ip del cliente

- **FDPort:** el puerto, dejamos el valor por defecto

- **Catalog:** dejamos el valor por defecto

- **Password:** contraseña del cliente

- **File Retention:** dejamos el valor por defecto

- **Job Retention:** dejamos el valor por defecto

- **AutoPrune:** dejamos el valor por defecto

Añado mis clientes:

<pre>
# Dulcinea
Client {
 Name = dulcinea-fd
 Address = 10.0.1.11
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Sancho
Client {
 Name = sancho-fd
 Address = 10.0.1.8
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Freston
Client {
 Name = freston-fd
 Address = 10.0.1.6
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Quijote
Client {
 Name = quijote-fd
 Address = 10.0.2.6
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# vpsjavierpzh
Client {
 Name = vpsjavierpzh-fd
 Address = 51.210.105.17
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}
</pre>

Una vez definidos los clientes, lo que tendremos que definir es que tipo de almacenamiento vamos a tener, en mi caso, los parámetros a modificar son:

- **Name:** para que concuerde con el que hacemos referencia al principio del fichero en el segundo apartado

- **Address:** dirección IP, indicaremos la de nuestro propio servidor para así indicar donde almacenar la información

- **SDPort:** el puerto, dejamos el valor por defecto

- **Password:** para que sea la misma que hemos indicado anteriormente

- **Device:** tipo de dispositivo que en nuestro caso es *File*

- **Media Type:** dejamos el valor por defecto

- **Maximum Concurrent Jobs:** dejamos el valor por defecto

Nos quedaría un bloque como este:

<pre>
Storage {
 Name = volcopias
 Address = 10.0.1.11
 SDPort = 9103
 Password = "bacula"
 Device = FileChgr1
 Media Type = File
 Maximum Concurrent Jobs = 10
}
</pre>

En la sección **Catalog**, nos encontraremos con la configuración relativa a la base de datos:

<pre>
Catalog {
  Name = MyCatalog
  dbname = "bacula"; DB Address = "localhost"; DB Port= "3306"; dbuser = "bacula"; dbpassword = "bacula"
}
</pre>

Nos encontramos frente a la última sección a editar, que no es otra que dónde se encuentran los bloques **Pool**. En ellos nos encontramos con estos parámetros:

- **Name:** nombre del *pool*

- **Pool type:** tipo de *pool*

- **Recycle:** reciclado automático de los volúmenes, está activado por defecto

- **AutoPrune:** expirador automáticos de los volúmenes, está activado por defecto

- **Volume Retention:** tiempo de retención que deseamos almacenar los *backups* realizados

- **Maximum Volume Bytes:** dejamos el valor por defecto

- **Maximum Volumes:** dejamos el valor por defecto

- **Label Format:** dejamos el valor por defecto

Introduzco los siguientes bloques:

<pre>
Pool {
 Name = Daily
 Pool Type = Backup
 Recycle = yes
 AutoPrune = yes
 VolumeRetention = 8d
}

Pool {
 Name = Weekly
 Pool Type = Backup
 Recycle = yes
 AutoPrune = yes
 VolumeRetention = 32d
}

Pool {
 Name = Monthly
 Pool Type = Backup
 Recycle = yes
 AutoPrune = yes
 VolumeRetention = 365d
}

Pool {
 Name = Backup-Restore
 Pool Type = Backup
 Recycle = yes
 AutoPrune = yes
 Volume Retention = 366 days
 Maximum Volume Bytes = 50G
 Maximum Volumes = 100
 Label Format = "Remoto"
}
</pre>

En este punto, ya habríamos terminado de modificar el fichero `/etc/bacula/bacula-dir.conf`, ya que los apartados siguientes los dejaríamos como vienen por defecto.

Para comprobar que no hay ningún error en nuestra configuración anterior, podemos emplear el siguiente comando:

<pre>
bacula-dir -tc /etc/bacula/bacula-dir.conf
</pre>

¿No nos reporta ningún error? Perfecto, podemos seguir con el siguiente punto.

Al principio comenté que había añadido un nuevo volumen en el que iría almacenando las distintas copias, pero ese nuevo disco aún no se encuentra montado en el sistema, por tanto vamos a proceder a prepararlo para su correcto funcionamiento.

Vamos a crear en él una partición nueva:

<pre>
root@dulcinea:~# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    254:0    0  10G  0 disk
└─vda1 254:1    0  10G  0 part /
vdb    254:16   0  10G  0 disk

root@dulcinea:~# gdisk /dev/vdb
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: not present
  BSD: not present
  APM: not present
  GPT: not present

Creating new GPT entries.

Command (? for help): n
Partition number (1-128, default 1):
First sector (34-20971486, default = 2048) or {+-}size{KMGTP}:
Last sector (2048-20971486, default = 20971486) or {+-}size{KMGTP}:
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300):
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/vdb.
The operation has completed successfully.

root@dulcinea:~# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    254:0    0  10G  0 disk
└─vda1 254:1    0  10G  0 part /
vdb    254:16   0  10G  0 disk
└─vdb1 254:17   0  10G  0 part
</pre>

Bien, ahora nos quedaría asignarle un sistema de ficheros (en mi caso, *ext4*) y montarlo en nuestro sistema, pero además me interesa que se monte automáticamente en cada arranque del sistema, por tanto, también lo añadiré al fichero `/etc/fstab`. Crearé un directorio `/bacula`, ruta donde se montará este nuevo dispositivo y además se almacenarán las distintas copias:

<pre>
root@dulcinea:~# mkfs.ext4 /dev/vdb1
mke2fs 1.44.5 (15-Dec-2018)
Creating filesystem with 2621179 4k blocks and 655360 inodes
Filesystem UUID: 436fe1ec-96a3-4531-9815-74254d6a730d
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@dulcinea:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b    7.7G    17% /
vdb                                                                     
└─vdb1 ext4         436fe1ec-96a3-4531-9815-74254d6a730d

root@dulcinea:~# mkdir -p /bacula/backup

root@dulcinea:~# chown -R bacula:bacula /bacula/

root@dulcinea:~# chmod 755 -R /bacula/backup/

root@dulcinea:~# cd ../

root@dulcinea:/# ls -l
...
drwxr-xr-x  3 bacula bacula  4096 Jan 28 12:05 bacula
...

root@dulcinea:/# ls -l /bacula/
total 4
drwxr-xr-x 2 bacula bacula 4096 Jan 28 12:05 backup
</pre>

Lo último que nos quedaría por realizar es la configuración del `/etc/fstab`, para lo que añadimos la siguiente línea:

<pre>
UUID=436fe1ec-96a3-4531-9815-74254d6a730d       /bacula ext4    defaults        0       0
</pre>

Hecho esto, vamos a indicarle a nuestro sistema que vuelve a leer este fichero de configuración (lo que sería lo mismo que un reinicio), con el siguiente comando:

<pre>
root@dulcinea:~# mount -a

root@dulcinea:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b    7.7G    17% /
vdb                                                                     
└─vdb1 ext4         436fe1ec-96a3-4531-9815-74254d6a730d    9.2G     0% /bacula
</pre>

Pasamos con el fichero `/etc/bacula/bacula-sd.conf`. En él se encuentran los paŕametros del director, que, al fin y al cabo, será el encargado de utilizar el nuevo volumen.

Haré igual que con el primer fichero, y lo he ordenado por secciones. En ésta primera, nos encontramos con la definición del nombre del director, además de su dirección IP:

<pre>
Storage {                             # definition of myself
  Name = dulcinea-sd
  SDPort = 9103                  # Director's port
  WorkingDirectory = "/var/lib/bacula"
  Pid Directory = "/run/bacula"
  Plugin Directory = "/usr/lib/bacula"
  Maximum Concurrent Jobs = 20
  SDAddress = 10.0.1.11
}
</pre>

La siguiente sección define el director encargado de conectar con el *demonio* **Storage**, que acabamos de definir anteriormente. Como en mi caso, es el mismo director, los diferencio con las terminaciones ("*-sd*" y "*-dir*"). También indicamos la contraseña que estamos utilizando:

<pre>
Director {
  Name = dulcinea-dir
  Password = "bacula"
}
</pre>

Este apartado se encargará de proporcionarle al director los permisos adecuados para que pueda ver el estado del proceso de almacenamiento de las copias. Se le añade la terminación "*-mon*":

<pre>
Director {
  Name = dulcinea-mon
  Password = "bacula"
  Monitor = yes
}
</pre>

Nos encontramos ante la última sección del fichero, en ella se define el cargador automático virtual, que si recordamos hicimos mención a él en el primer fichero. En el primer bloque hacemos referencia al dispositivo que se configura en el segundo bloque:

<pre>
Autochanger {
  Name = FileChgr1
  Device = FileStorage
  Changer Command = ""
  Changer Device = /dev/null
}

Device {
  Name = FileStorage
  Media Type = File
  Archive Device = /bacula/backup
  LabelMedia = yes;                   # lets Bacula label unlabeled media
  Random Access = Yes;
  AutomaticMount = yes;               # when device opened, read it
  RemovableMedia = no;
  AlwaysOpen = no;
  Maximum Concurrent Jobs = 5
}
</pre>

Al igual que con el primer fichero, para comprobar que no hay ningún error en nuestra configuración, vamos a emplear el siguiente comando:

<pre>
bacula-sd -tc /etc/bacula/bacula-sd.conf
</pre>

¿No nos reporta ningún error? Perfecto, podemos seguir con el siguiente y último fichero por parte del servidor.

Vamos a reiniciar los servicios que hacen uso de los ficheros modificados hasta este punto para que las nuevas configuraciones sean cargadas, y además los habilitaremos para que se inicien en cada arranque:

<pre>
systemctl restart bacula-sd.service
systemctl enable bacula-sd.service
systemctl restart bacula-director.service
systemctl enable bacula-director.service
</pre>

Estamos a punto de terminar las configuraciones del servidor, de hecho nos falta tan sólo un fichero, y es el `/etc/bacula/bconsole.conf`. Este fichero contiene la configuración que nos permite acceder a la consola, y dentro de él tendremos que asegurarnos que los apartados de nombre, dirección y contraseña se encuentran correctamente.

<pre>
Director {
  Name = dulcinea-dir
  DIRport = 9101
  address = 10.0.1.11
  Password = "bacula"
}
</pre>

Hecho esto, habremos terminado la configuración en la parte del director.

Pasamos a la parte de los **clientes**.

Aunque hayamos terminado de configurar el servidor, aún no hemos terminado nuestro trabajo en **Dulcinea**, ya que esta máquina también va a formar parte de los clientes como hemos visto antes. Hay que decir que las configuraciones de los clientes se realizan todas de la misma forma, por lo que, explicaré ésta primera con más detalle y las siguientes obviando los hechos.

El primer paso sería instalar el *software* necesario, que en *Dulcinea* ya se encuentra instalado, y además habilitar su funcionamiento en cada inicio:

<pre>
apt install bacula-client -y
systemctl enable bacula-fd.service
</pre>

En *CentOS* (*Quijote*) se instala con el comando:

<pre>
dnf install bacula-client -y
</pre>

El fichero que debemos modificar es el que se encuentra en la ruta `/etc/bacula/bacula-fd.conf`.

En dicho archivo indicaremos los parámetros del director, que en este primer caso, es el propio equipo. Además, indicaremos el director que gestionará el *demonio*. También tendremos que definir el cliente, del que debemos indicar el nombre y la dirección IP. Por último, en el bloque llamado *Messages*, indicaremos el nombre del director, esto nos permitirá realizar un *restore* cuando nos sea necesario.

En mi caso, el fichero `/etc/bacula/bacula-fd.conf` de la máquina *Dulcinea* queda de esta forma:

<pre>
Director {
  Name = dulcinea-dir
  Password = "bacula"
}

Director {
  Name = dulcinea-mon
  Password = "bacula"
  Monitor = yes
}

FileDaemon {                          # this is me
  Name = dulcinea-fd
  FDport = 9102                  # where we listen for the director
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 10.0.1.11
}

Messages {
  Name = Standard
  director = dulcinea-dir = all, !skipped, !restored
}
</pre>

Una vez terminada la configuración, reiniciamos el servicio y aplicaremos los cambios:

<pre>
systemctl restart bacula-fd.service
</pre>

Llegó el turno de **Sancho**. Su configuración queda de la siguiente forma:

<pre>
Director {
  Name = dulcinea-dir
  Password = "bacula"
}

Director {
  Name = dulcinea-mon
  Password = "bacula"
  Monitor = yes
}

FileDaemon {                          # this is me
  Name = sancho-fd
  FDport = 9102                  # where we listen for the director
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 10.0.1.8
}

Messages {
  Name = Standard
  director = dulcinea-dir = all, !skipped, !restored
}
</pre>

Es el turno de **Freston**. Su configuración queda de la siguiente forma:

<pre>
Director {
  Name = dulcinea-dir
  Password = "bacula"
}

Director {
  Name = dulcinea-mon
  Password = "bacula"
  Monitor = yes
}

FileDaemon {                          # this is me
  Name = freston-fd
  FDport = 9102                  # where we listen for the director
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 10.0.1.6
}

Messages {
  Name = Standard
  director = dulcinea-dir = all, !skipped, !restored
}
</pre>

En **Quijote** el contenido del fichero sería:

<pre>
Director {
  Name = dulcinea-dir
  Password = "bacula"
}

Director {
  Name = dulcinea-mon
  Password = "bacula"
  Monitor = yes
}

FileDaemon {                          # this is me
  Name = quijote-fd
  FDport = 9102                  # where we listen for the director
  WorkingDirectory = /var/spool/bacula
  Pid Directory = /var/run
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib64/bacula
}

Messages {
  Name = Standard
  director = dulcinea-dir = all, !skipped, !restored
}
</pre>

En la máquina de **OVH** el fichero tendría este aspecto:

<pre>
Director {
  Name = dulcinea-dir
  Password = "bacula"
}

Director {
  Name = dulcinea-mon
  Password = "bacula"
  Monitor = yes
}

FileDaemon {                          # this is me
  Name = vpsjavierpzh-fd
  FDport = 9102                  # where we listen for the director
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 51.210.105.17
}

Messages {
  Name = Standard
  director = dulcinea-dir = all, !skipped, !restored
}
</pre>

En teoría, ya tendríamos configurados todos los clientes, por lo que supuestamente ya podrían conectar con nuestro director ubicado en *Dulcinea*. Vamos a ver si es así, pero antes, debemos reiniciar los servicios del director:

<pre>
root@dulcinea:~# systemctl restart bacula-fd.service

root@dulcinea:~# systemctl restart bacula-sd.service

root@dulcinea:~# systemctl restart bacula-director.service

root@dulcinea:~# bconsole
Connecting to Director 10.0.1.11:9101
1000 OK: 103 dulcinea-dir Version: 9.4.2 (04 February 2019)
Enter a period to cancel a command.

*status client
The defined Client resources are:
     1: dulcinea-fd
     2: sancho-fd
     3: freston-fd
     4: quijote-fd
     5: vpsjavierpzh-fd
Select Client (File daemon) resource (1-5): 1
Connecting to Client dulcinea-fd at 10.0.1.11:9102

dulcinea-fd Version: 9.4.2 (04 February 2019)  x86_64-pc-linux-gnu debian 10.5
Daemon started 28-Jan-21 14:11. Jobs: run=0 running=0.
 Heap: heap=114,688 smbytes=23,250 max_bytes=23,267 bufs=70 max_bufs=70
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so

Running Jobs:
Director connected at: 28-Jan-21 14:25
No Jobs running.
====

Terminated Jobs:
====

*status client
The defined Client resources are:
     1: dulcinea-fd
     2: sancho-fd
     3: freston-fd
     4: quijote-fd
     5: vpsjavierpzh-fd
Select Client (File daemon) resource (1-5): 2
Connecting to Client sancho-fd at 10.0.1.8:9102

sancho-fd Version: 9.4.2 (04 February 2019)  x86_64-pc-linux-gnu ubuntu 20.04
Daemon started 28-Jan-21 13:27. Jobs: run=0 running=0.
 Heap: heap=110,592 smbytes=22,002 max_bytes=22,019 bufs=68 max_bufs=68
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so

Running Jobs:
Director connected at: 28-Jan-21 14:25
No Jobs running.
====

Terminated Jobs:
====

*status client
The defined Client resources are:
The defined Client resources are:
     1: dulcinea-fd
     2: sancho-fd
     3: freston-fd
     4: quijote-fd
     5: vpsjavierpzh-fd
Select Client (File daemon) resource (1-5): 3
Connecting to Client freston-fd at 10.0.1.6:9102

freston-fd Version: 9.4.2 (04 February 2019)  x86_64-pc-linux-gnu debian 10.5
Daemon started 28-Jan-21 13:29. Jobs: run=0 running=0.
 Heap: heap=114,688 smbytes=23,242 max_bytes=23,260 bufs=70 max_bufs=70
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so

Running Jobs:
Director connected at: 28-Jan-21 14:25
No Jobs running.
====

Terminated Jobs:
====

*status client
The defined Client resources are:
     1: dulcinea-fd
     2: sancho-fd
     3: freston-fd
     4: quijote-fd
     5: vpsjavierpzh-fd
Select Client (File daemon) resource (1-5): 4
Connecting to Client quijote-fd at 10.0.2.6:9102
Failed to connect to Client quijote-fd.

*status client
The defined Client resources are:
     1: dulcinea-fd
     2: sancho-fd
     3: freston-fd
     4: quijote-fd
     5: vpsjavierpzh-fd
Select Client (File daemon) resource (1-5): 5
Connecting to Client vpsjavierpzh-fd at 51.210.105.17:9102

vpsjavierpzh-fd Version: 9.4.2 (04 February 2019)  x86_64-pc-linux-gnu debian 10.5
Daemon started 28-Jan-21 14:52. Jobs: run=0 running=0.
 Heap: heap=114,688 smbytes=22,016 max_bytes=22,033 bufs=68 max_bufs=68
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so

Running Jobs:
Director connected at: 28-Jan-21 14:58
No Jobs running.
====

Terminated Jobs:
====
</pre>

Vaya, parece que con *Quijote* no llega a conectar, pero con los otros equipos sí. La cuestión es que hay que recordar que *CentOS* incorpora un *firewall* por defecto bastante restrictivo, por lo que debemos abrir los puertos que utiliza *Bacula*:

<pre>
[root@quijote ~]# firewall-cmd --permanent --add-port=9101/tcp
success

[root@quijote ~]# firewall-cmd --permanent --add-port=9102/tcp
success

[root@quijote ~]# firewall-cmd --permanent --add-port=9103/tcp
success

[root@quijote ~]# firewall-cmd --reload
success
</pre>

Vamos a probar de nuevo a ver si ahora se produce la conexión con *Quijote*:

<pre>
root@dulcinea:~# bconsole
Connecting to Director 10.0.1.11:9101
1000 OK: 103 dulcinea-dir Version: 9.4.2 (04 February 2019)
Enter a period to cancel a command.

*status client
The defined Client resources are:
     1: dulcinea-fd
     2: sancho-fd
     3: freston-fd
     4: quijote-fd
     5: vpsjavierpzh-fd
Select Client (File daemon) resource (1-5): 4
Connecting to Client quijote-fd at 10.0.2.6:9102

quijote-fd Version: 9.0.6 (20 November 2017) x86_64-redhat-linux-gnu redhat (Core)
Daemon started 28-Jan-21 13:43. Jobs: run=0 running=0.
 Heap: heap=102,400 smbytes=21,976 max_bytes=21,993 bufs=68 max_bufs=68
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so

Running Jobs:
Director connected at: 28-Jan-21 14:28
No Jobs running.
====

Terminated Jobs:
====
</pre>

Ahora sí se conecta, problema resuelto.

Una vez hemos comprobado que las conexiones se realizan, debemos crear los nodos de almacenamiento, donde se irán guardando las diferentes copias.

<pre>
root@dulcinea:~# bconsole
Connecting to Director 10.0.1.11:9101
1000 OK: 103 dulcinea-dir Version: 9.4.2 (04 February 2019)
Enter a period to cancel a command.

*label
Automatically selected Catalog: MyCatalog
Using Catalog "MyCatalog"
Automatically selected Storage: volcopias
Enter new Volume name: backup-diario
Defined Pools:
     1: Backup-Restore
     2: Daily
     3: Default
     4: File
     5: Monthly
     6: Scratch
     7: Weekly
Select the Pool (1-7): 2
Connecting to Storage daemon volcopias at 10.0.1.11:9103 ...
Sending label command for Volume "backup-diario" Slot 0 ...
3000 OK label. VolBytes=255 VolABytes=0 VolType=1 Volume="backup-diario" Device="FileStorage" (/bacula/backup)
Catalog record for Volume "backup-diario", Slot 0  successfully created.
Requesting to mount FileChgr1 ...
3906 File device ""FileStorage" (/bacula/backup)" is always mounted.

*label
Automatically selected Catalog: MyCatalog
Using Catalog "MyCatalog"
Automatically selected Storage: volcopias
Enter new Volume name: backup-semanal
Defined Pools:
     1: Backup-Restore
     2: Daily
     3: Default
     4: File
     5: Monthly
     6: Scratch
     7: Weekly
Select the Pool (1-7): 7
Connecting to Storage daemon volcopias at 10.0.1.11:9103 ...
Sending label command for Volume "backup-semanal" Slot 0 ...
3000 OK label. VolBytes=257 VolABytes=0 VolType=1 Volume="backup-semanal" Device="FileStorage" (/bacula/backup)
Catalog record for Volume "backup-semanal", Slot 0  successfully created.
Requesting to mount FileChgr1 ...
3906 File device ""FileStorage" (/bacula/backup)" is always mounted.

*label
Automatically selected Storage: volcopias
Enter new Volume name: backup-mensual
Defined Pools:
     1: Backup-Restore
     2: Daily
     3: Default
     4: File
     5: Monthly
     6: Scratch
     7: Weekly
Select the Pool (1-7): 5
Connecting to Storage daemon volcopias at 10.0.1.11:9103 ...
Sending label command for Volume "backup-mensual" Slot 0 ...
3000 OK label. VolBytes=258 VolABytes=0 VolType=1 Volume="backup-mensual" Device="FileStorage" (/bacula/backup)
Catalog record for Volume "backup-mensual", Slot 0  successfully created.
Requesting to mount FileChgr1 ...
3906 File device ""FileStorage" (/bacula/backup)" is always mounted.
</pre>

Para terminar, y escribiendo esto varias semanas más tarde, vamos a comprobar que las copias se están realizando de manera correcta y por supuesto, automática.

<pre>
*status client=dulcinea-fd
Connecting to Client dulcinea-fd at 10.0.1.11:9102

dulcinea-fd Version: 9.4.2 (04 February 2019)  x86_64-pc-linux-gnu debian 10.5
Daemon started 09-Feb-21 12:34. Jobs: run=4 running=0.
 Heap: heap=126,976 smbytes=23,327 max_bytes=681,576 bufs=77 max_bufs=161
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so

Running Jobs:
Director connected at: 13-Feb-21 12:43
No Jobs running.
====

Terminated Jobs:
 JobId  Level    Files      Bytes   Status   Finished        Name
===================================================================
    47  Incr        101    18.23 M  OK       06-Feb-21 02:00 Dulcinea-Diario
    52  Incr        126    18.70 M  OK       07-Feb-21 02:00 Dulcinea-Diario
    53  Full      4,952    47.55 M  OK       07-Feb-21 02:31 Dulcinea-Semanal
    54  Full      4,953    53.34 M  OK       07-Feb-21 03:01 Dulcinea-Mensual
    67  Incr        100    29.05 M  OK       08-Feb-21 02:00 Dulcinea-Diario
    72  Incr        580    51.11 M  OK       09-Feb-21 02:00 Dulcinea-Diario
    77  Incr        560    31.45 M  OK       10-Feb-21 02:00 Dulcinea-Diario
    82  Incr        141    29.21 M  OK       11-Feb-21 02:00 Dulcinea-Diario
    87  Incr        103    30.76 M  OK       12-Feb-21 02:00 Dulcinea-Diario
    92  Incr        103    30.89 M  OK       13-Feb-21 02:00 Dulcinea-Diario
====

*status client=freston-fd
Connecting to Client freston-fd at 10.0.1.6:9102

freston-fd Version: 9.4.2 (04 February 2019)  x86_64-pc-linux-gnu debian 10.5
Daemon started 09-Feb-21 12:33. Jobs: run=4 running=0.
 Heap: heap=126,976 smbytes=23,325 max_bytes=679,213 bufs=77 max_bufs=155
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so

Running Jobs:
Director connected at: 13-Feb-21 12:43
No Jobs running.
====

Terminated Jobs:
 JobId  Level    Files      Bytes   Status   Finished        Name
===================================================================
    49  Incr         48    2.348 M  OK       06-Feb-21 02:00 Freston-Diario
    58  Incr         60    2.920 M  OK       07-Feb-21 02:00 Freston-Diario
    59  Full      3,277    53.23 M  OK       07-Feb-21 02:30 Freston-Semanal
    60  Full      3,277    53.24 M  OK       07-Feb-21 03:01 Freston-Mensual
    69  Incr         48    1.487 M  OK       08-Feb-21 02:00 Freston-Diario
    74  Incr        482    84.39 M  OK       09-Feb-21 02:00 Freston-Diario
    79  Incr        642    29.99 M  OK       10-Feb-21 02:00 Freston-Diario
    84  Incr         94    27.96 M  OK       11-Feb-21 02:00 Freston-Diario
    89  Incr         50    963.8 K  OK       12-Feb-21 02:00 Freston-Diario
    94  Incr         50    1.001 M  OK       13-Feb-21 02:00 Freston-Diario
====

*status client=quijote-fd
Connecting to Client quijote-fd at 10.0.2.6:9102

quijote-fd Version: 9.0.6 (20 November 2017) x86_64-redhat-linux-gnu redhat (Core)
Daemon started 02-Feb-21 12:54. Jobs: run=11 running=0.
 Heap: heap=8,192 smbytes=23,297 max_bytes=1,139,409 bufs=77 max_bufs=281
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so

Running Jobs:
Director connected at: 13-Feb-21 12:43
No Jobs running.
====

Terminated Jobs:
 JobId  Level      Files    Bytes   Status   Finished        Name
===================================================================
    50  Incr          49    21.17 M  OK       06-Feb-21 02:00 Quijote-Diario
    61  Incr          49    21.17 M  OK       07-Feb-21 02:00 Quijote-Diario
    62  Full      21,048    209.2 M  OK       07-Feb-21 02:31 Quijote-Semanal
    63  Full      21,048    209.2 M  OK       07-Feb-21 03:02 Quijote-Mensual
    70  Incr          78    21.20 M  OK       08-Feb-21 02:00 Quijote-Diario
    75  Incr       1,977    75.43 M  OK       09-Feb-21 02:00 Quijote-Diario
    80  Incr         245    51.14 M  OK       10-Feb-21 02:00 Quijote-Diario
    85  Incr      14,058    101.5 M  OK       11-Feb-21 02:01 Quijote-Diario
    90  Incr          52    21.32 M  OK       12-Feb-21 02:00 Quijote-Diario
    95  Incr          62    22.35 M  OK       13-Feb-21 02:00 Quijote-Diario
====
</pre>

Podemos ver, como he puesto de ejemplo a las máquinas **Dulcinea**, **Freston** y **Quijote**, y en todas ellas se están realizando correctamente todas las copias, lo que significa que el sistema de copias de seguridad se encuentra funcionando correctamente, y el contenido del *post* habría finalizado.
