---
layout: post
---

**En esta tarea se va a crear el escenario de trabajo que se va a usar durante todo el curso, que va a constar inicialmente de 3 instancias con nombres relacionados con el libro "Don Quijote de la Mancha".**

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/escenario.png" />

**Pasos a realizar:**

**1. Creación de la red interna:**

- **Nombre red interna de (nombre de usuario)**
- **10.0.1.0/24**

Vamos a llevar a cabo la creación de la red interna **10.0.1.0/24**, a la cuál pertenecerán las máquinas **Dulcinea**, **Sancho** y **Quijote**.

Antes de nada, para trabajar con el *cloud* tendremos que levantar la VPN:

<pre>
systemctl start openvpn.service
</pre>

Una vez estemos dentro de nuestro gestor de proyectos de **OpenStack**, empezaremos la creación de la red. Nos dirigimos al apartado **Redes**, y seleccionamos la opción **+ Crear red**:

Se nos abre esta ventana en la que estableceremos la configuración de la nueva red:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/red.png" />

Indicamos la dirección de la red y deshabilitamos la puerta de enlace ya que no nos va hacer falta debido a que vamos a poner a *Dulcinea* como *gateway*:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/redsubred.png" />

Dejamos marcada la opción de **Habilitar DHCP** que viene de manera predeterminada, para que de esta forma, nos dé una dirección IP de manera automática cuando levantemos las instancias.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/confirmarred.png" />

Y esta sería la red que hemos creado:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/redcreada.png" />

**2. Creación de las instancias:**

- **Dulcinea:**

    - **Debian Buster sobre volumen de 10GB con sabor m1.mini**
    - **Accesible directamente a través de la red externa y con una IP flotante**
    - **Conectada a la red interna, de la que será la puerta de enlace**

Vamos a realizar el proceso de la creación de **Dulcinea**. Esta máquina hará de puerta de enlace para el resto de máquinas de la red *10.0.1.0/24*.

Vamos a crear las instancias a partir de un volumen con una imagen, por tanto, creamos el volumen:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/volumenDulcinea.png" />

*Dulcinea* incorporará un sistema **Debian Buster 10.6**.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/volumenDulcineacreado.png" />

Una vez hemos creado el volumen, podemos crear la instancia a partir de éste. Asignamos un nombre a la instancia:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/dulcineanombre.png" />

Establecemos que el origen de arranque sea el volumen creado previamente:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/dulcineaasociovolumen.png" />

Como **Sabor** indicamos que tenga un **m1.mini**.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/dulcineasabor.png" />

Y por último, le asignamos las redes a las que va a pertenecer esta máquina.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/dulcineared.png" />

*Dulcinea* necesita conectividad al exterior, ya que con ella vamos a hacer NAT, por tanto le asignamos una IP flotante. El resultado de la máquina creada sería este:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/dulcineacreada.png" />

Comprobamos que nos podemos conectar a *Dulcinea* mediante nuestro par de claves, ya que tengo configurado para que todas las instancias que se creen posean mi clave pública, para así yo poder identificarme con mi clave privada. Introduzco la opción `-A`, que sirve para que la máquina *Dulcinea*, nos herede las claves de la primera, de forma que así podremos establecer una conexión mediante el par de claves con las máquinas *Sancho* y *Quijote*.

<pre>
javier@debian:~$ ssh -A debian@172.22.200.183
The authenticity of host '172.22.200.183 (172.22.200.183)' can't be established.
ECDSA key fingerprint is SHA256:1wDmV/NJYTeQhItsUhSJlPsidjDLiqt0oUOmx+e3d8M.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.22.200.183' (ECDSA) to the list of known hosts.
Linux dulcinea 4.19.0-11-cloud-amd64 #1 SMP Debian 4.19.146-1 (2020-09-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

debian@dulcinea:~$
</pre>

- **Sancho:**

    - **Ubuntu 20.04 sobre volumen de 10GB con sabor m1.mini**
    - **Conectada a la red interna**
    - **Accesible indirectamente a través de dulcinea**

Vamos a repetir el mismo proceso para crear la máquina *Sancho* que incorporará un sistema **Ubuntu 20.04**.

Creamos el volumen:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/volumenSanchocreado.png" />

El resultado de la instancia creada sería este:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/sanchocreada.png" />

Comprobamos que desde *Dulcinea* nos podemos conectar a esta nueva máquina:

<pre>
debian@dulcinea:~$ ssh ubuntu@10.0.1.8
The authenticity of host '10.0.1.8 (10.0.1.8)' can't be established.
ECDSA key fingerprint is SHA256:LNxHmLUNlXhnC2jDs2DZ6EAs+4kPca2/LBCtKfmNtLQ.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.0.1.8' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-48-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat Nov 14 18:03:38 UTC 2020

  System load:  0.08              Processes:             95
  Usage of /:   12.8% of 9.52GB   Users logged in:       0
  Memory usage: 35%               IPv4 address for ens3: 10.0.1.8
  Swap usage:   0%

1 update can be installed immediately.
0 of these updates are security updates.
To see these additional updates run: apt list --upgradable


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@sancho:~$
</pre>

- **Quijote:**

    - **CentOS 7 sobre volumen de 10GB con sabor m1.mini**
    - **Conectada a la red interna**
    - **Accesible indirectamente a través de dulcinea**

Y por último repetimos el proceso para crear a **Quijote** que incorporará un sistema **CentOS 7**.

Creamos el volumen:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/volumenQuijotecreado.png" />

El resultado de la instancia creada sería este:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/quijotecreada.png" />

Comprobamos que desde *Dulcinea* nos podemos conectar a esta nueva máquina:

<pre>
debian@dulcinea:~$ ssh centos@10.0.1.13
The authenticity of host '10.0.1.13 (10.0.1.13)' can't be established.
ECDSA key fingerprint is SHA256:kZHztAbFW707wQg8BfcVd8+R/Kp/DZJseK5kwLO/xTU.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.0.1.13' (ECDSA) to the list of known hosts.

[centos@quijote ~]$
</pre>

**3. Configuración de NAT en Dulcinea (Es necesario deshabilitar la seguridad en todos los puertos de Dulcinea) Ver este [vídeo](https://youtu.be/jqfILWzHrS0).**

Para hacer NAT en **Dulcinea** y que así **Quijote** y **Sancho** tengan acceso a internet, tenemos que modificar el grupo de seguridad de **Dulcinea** y deshabilitar la seguridad de todos sus puertos, es decir, quitarle las reglas de cortafuegos, para luego añadirle nuestra propia regla de `iptables`.

Para ello tenemos que configurar *OpenStack* para administrar nuestro proyecto desde la línea de comandos, que es desde donde vamos a realizar este proceso.

Vamos a crear un entorno virtual y trabajaremos desde aquí. Es necesario instalar estos paquetes:

<pre>
apt install python-virtualenv python3-pip -y
</pre>

Creamos nuestro entorno virtual:

<pre>
javier@debian:~/openstack$ python3 -m venv openstack

javier@debian:~/openstack$ source openstack/bin/activate

(openstack) javier@debian:~/openstack$
</pre>

Una vez estemos en nuestro entorno virtual, vamos a realizar la instalación del paquete `python-openstackclient`, que es el que necesitamos para administrar nuestra cuenta de *OpenStack*. Antes de realizar la instalación recomiendo actualizar la herramienta `pip`.

<pre>
(openstack) javier@debian:~/openstack$ pip install --upgrade pip

(openstack) javier@debian:~/openstack$ pip install python-openstackclient
</pre>

Una vez tenemos instalado este paquete, nos quedaría vincular nuestra cuenta. Para llevar a cabo el proceso de vinculación, debemos dirigirnos desde el navegador hacia el gestor de nuestro proyecto, e irnos al apartado de **Acceso y seguridad** y **Acceso a la API**. Obtendremos esta salida:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/accesoalaAPI.png" />

Podemos observar que nos muestra unos ficheros para descargar, debemos hacer click en el llamado **Descargar fichero RC de OpenStack v3**. Una vez descargado, lo movemos al directorio donde hemos creado el entorno virtual.

<pre>
(openstack) javier@debian:~/openstack$ ls
 openstack  'Proyecto de javier.perezh-openrc.sh'
</pre>

En mi caso, el archivo descargado recibe el nombre **Proyecto de javier.perezh-openrc.sh**, y en él, vamos a introducir la siguiente línea, donde especificaremos la ruta donde se encuentra el certificado del Gonzalo Nazareno, que es la entidad que maneja los proyectos de *OpenStack*, entre los cuáles se encuentra el mío.

<pre>
export OS_CACERT=/etc/ssl/certs/gonzalonazareno.crt
</pre>

En este punto, ya podríamos iniciar el proceso de vinculación desde la terminal. Ejecutamos el siguiente comando para verificar nuestras credenciales e iniciar sesión.

<pre>
(openstack) javier@debian:~/openstack$ source 'Proyecto de javier.perezh-openrc.sh'
Please enter your OpenStack Password for project Proyecto de javier.perezh as user javier.perezh:
</pre>

Si hemos introducido correctamente la contraseña, ya podríamos administrar nuestro proyecto desde la terminal. Por ejemplo, podemos listar nuestras instancias:

<pre>
javier@debian:~/openstack$ openstack server list
+--------------------------------------+-------------+--------+---------------------------------------------------------------------------------------+-------+---------+
| ID                                   | Name        | Status | Networks                                                                              | Image | Flavor  |
+--------------------------------------+-------------+--------+---------------------------------------------------------------------------------------+-------+---------+
| 5c572aa6-3ca4-49a8-8e1c-b9f472988b84 | Quijote     | ACTIVE | red interna de javier.perezh=10.0.1.13                                                |       | m1.mini |
| 044c375b-d088-4165-8668-a55775f9fabb | Sancho      | ACTIVE | red interna de javier.perezh=10.0.1.8                                                 |       | m1.mini |
| 73f609c8-9724-4e54-818d-a9bdf0cb43fe | Dulcinea    | ACTIVE | red de javier.perezh=10.0.0.8, 172.22.200.183; red interna de javier.perezh=10.0.1.11 |       | m1.mini |
| 650210f7-e31c-40e7-8a9d-53b7e6cb038e | PracticaDNS | ACTIVE | red de javier.perezh=10.0.0.11, 172.22.200.174                                        |       | m1.mini |
+--------------------------------------+-------------+--------+---------------------------------------------------------------------------------------+-------+---------+
</pre>

Vemos como nos muestra las instancias creadas, entre las cuáles se encuentran las tres que formarán el escenario, **Quijote**, **Sancho** y **Dulcinea**.

Antes estuvimos realizando las comprobaciones de que efectivamente nos podíamos conectar a estas máquinas, esto se debe a que tiene un grupo de seguridad asociado, llamado `default`, que por defecto se asocia a las instancias que lanzamos, y que permite esta opción, entre otras.

Lo que vamos a hacer es eliminar este grupo de seguridad a **Dulcinea**, por tanto, ya no podríamos conectarnos a ella, pero luego vamos a deshabilitar la seguridad de puertos, y ya de nuevo, sería accesible mediante *SSH*.

Primeramente. vamos a ver los detalles de esta instancia:

<pre>
(openstack) javier@debian:~/openstack$ openstack server show Dulcinea
+-----------------------------+---------------------------------------------------------------------------------------+
| Field                       | Value                                                                                 |
+-----------------------------+---------------------------------------------------------------------------------------+
| OS-DCF:diskConfig           | AUTO                                                                                  |
| OS-EXT-AZ:availability_zone | nova                                                                                  |
| OS-EXT-STS:power_state      | Running                                                                               |
| OS-EXT-STS:task_state       | None                                                                                  |
| OS-EXT-STS:vm_state         | active                                                                                |
| OS-SRV-USG:launched_at      | 2020-11-14T17:44:11.000000                                                            |
| OS-SRV-USG:terminated_at    | None                                                                                  |
| accessIPv4                  |                                                                                       |
| accessIPv6                  |                                                                                       |
| addresses                   | red de javier.perezh=10.0.0.8, 172.22.200.183; red interna de javier.perezh=10.0.1.11 |
| config_drive                |                                                                                       |
| created                     | 2020-11-14T17:43:42Z                                                                  |
| flavor                      | m1.mini (12)                                                                          |
| hostId                      | 1cd650c7bff842c92682e8bc3d0d184f4ddcc2e41fc41ae8487eeb6a                              |
| id                          | 73f609c8-9724-4e54-818d-a9bdf0cb43fe                                                  |
| image                       | N/A (booted from volume)                                                              |
| key_name                    | msi_debian_clave_publica                                                              |
| name                        | Dulcinea                                                                              |
| progress                    | 0                                                                                     |
| project_id                  | 678e0304a62c445ba78d3b825cb4f1ab                                                      |
| properties                  |                                                                                       |
| security_groups             | name='default'                                                                        |
|                             | name='default'                                                                        |
| status                      | ACTIVE                                                                                |
| updated                     | 2020-11-14T17:44:12Z                                                                  |
| user_id                     | fc6228f3de9b2e4abfc00a526192e37c323cde31412ffd98d1bf7c584915f35a                      |
| volumes_attached            | id='dab6f14b-ec83-4d5a-9940-0f4bb35f864a'                                             |
+-----------------------------+---------------------------------------------------------------------------------------+
</pre>

Vemos como efectivamente posee el grupo de seguridad `default` comentando anteriormente.

Procedemos a eliminar este grupo de seguridad:

<pre>
(openstack) javier@debian:~/openstack$ openstack server remove security group Dulcinea default
</pre>

Si vemos de nuevo los detalles de **Dulcinea**:

<pre>
(openstack) javier@debian:~/openstack$ openstack server show Dulcinea
+-----------------------------+---------------------------------------------------------------------------------------+
| Field                       | Value                                                                                 |
+-----------------------------+---------------------------------------------------------------------------------------+
| OS-DCF:diskConfig           | AUTO                                                                                  |
| OS-EXT-AZ:availability_zone | nova                                                                                  |
| OS-EXT-STS:power_state      | Running                                                                               |
| OS-EXT-STS:task_state       | None                                                                                  |
| OS-EXT-STS:vm_state         | active                                                                                |
| OS-SRV-USG:launched_at      | 2020-11-14T17:44:11.000000                                                            |
| OS-SRV-USG:terminated_at    | None                                                                                  |
| accessIPv4                  |                                                                                       |
| accessIPv6                  |                                                                                       |
| addresses                   | red de javier.perezh=10.0.0.8, 172.22.200.183; red interna de javier.perezh=10.0.1.11 |
| config_drive                |                                                                                       |
| created                     | 2020-11-14T17:43:42Z                                                                  |
| flavor                      | m1.mini (12)                                                                          |
| hostId                      | 1cd650c7bff842c92682e8bc3d0d184f4ddcc2e41fc41ae8487eeb6a                              |
| id                          | 73f609c8-9724-4e54-818d-a9bdf0cb43fe                                                  |
| image                       | N/A (booted from volume)                                                              |
| key_name                    | msi_debian_clave_publica                                                              |
| name                        | Dulcinea                                                                              |
| progress                    | 0                                                                                     |
| project_id                  | 678e0304a62c445ba78d3b825cb4f1ab                                                      |
| properties                  |                                                                                       |
| status                      | ACTIVE                                                                                |
| updated                     | 2020-11-14T17:44:12Z                                                                  |
| user_id                     | fc6228f3de9b2e4abfc00a526192e37c323cde31412ffd98d1bf7c584915f35a                      |
| volumes_attached            | id='dab6f14b-ec83-4d5a-9940-0f4bb35f864a'                                             |
+-----------------------------+---------------------------------------------------------------------------------------+
</pre>

Podemos apreciar como ya no nos muestra el apartado **security_groups** ya que no posee ningún grupo de seguridad, lo que significa por tanto, que lo hemos eliminado.

Al eliminar el grupo de seguridad, se habilita un cortafuegos por defecto de *OpenStack*, que es la seguridad del puerto, que no permite el tráfico.

Por tanto, si ahora intentamos hacer un ping, o conectarnos mediante *SSH*:

<pre>
(openstack) javier@debian:~/openstack$ ping 172.22.200.183
PING 172.22.200.183 (172.22.200.183) 56(84) bytes of data.
^C
--- 172.22.200.183 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 106ms

(openstack) javier@debian:~/openstack$ ssh debian@172.22.200.183
^C
</pre>

Ya no responde y por tanto hemos perdido la conectividad a ella.

Si miramos la lista de los puertos:

<pre>
javier@debian:~/openstack$ openstack port list
+--------------------------------------+------+-------------------+--------------------------------------------------------------------------+--------+
| ID                                   | Name | MAC Address       | Fixed IP Addresses                                                       | Status |
+--------------------------------------+------+-------------------+--------------------------------------------------------------------------+--------+
| 2531063e-74f3-44d3-a268-0d2868599eee |      | fa:16:3e:2b:1c:c7 | ip_address='10.0.0.8', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3'  | ACTIVE |
| 2cffa116-c4b4-45e5-865f-5c40f6868eaa |      | fa:16:3e:5c:3d:c5 | ip_address='10.0.1.13', subnet_id='87427d1a-bd9d-400a-935b-02c56aaf7748' | ACTIVE |
| 34576fb0-2015-4d8d-b4c4-4e506713a84b |      | fa:16:3e:08:8c:c3 | ip_address='10.0.1.1', subnet_id='87427d1a-bd9d-400a-935b-02c56aaf7748'  | ACTIVE |
| 4b74d3ee-c877-4c20-820d-69e502c51034 |      | fa:16:3e:28:24:d0 | ip_address='10.0.0.2', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3'  | ACTIVE |
| 50c06762-bfce-499f-95b3-ef3a3708f906 |      | fa:16:3e:4b:ab:f9 | ip_address='10.0.0.1', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3'  | ACTIVE |
| a849802c-5c9d-41c1-94c5-59226fb2fe1a |      | fa:16:3e:65:96:2b | ip_address='10.0.0.11', subnet_id='98c0ae2f-d2ee-48a3-9122-f1369a6e99b3' | ACTIVE |
| e1517753-2766-4856-a1aa-9f6df4e70d8d |      | fa:16:3e:24:f3:f9 | ip_address='10.0.1.11', subnet_id='87427d1a-bd9d-400a-935b-02c56aaf7748' | ACTIVE |
| e225a306-9713-4e4a-bd14-888c01479784 |      | fa:16:3e:84:9b:94 | ip_address='10.0.1.8', subnet_id='87427d1a-bd9d-400a-935b-02c56aaf7748'  | ACTIVE |
+--------------------------------------+------+-------------------+--------------------------------------------------------------------------+--------+
</pre>

Sabiendo que **Dulcinea** posee dos puertos, y estos corresponden a las IPs de *Dulcinea*, es decir, la **10.0.0.8** y la **10.0.1.11**, podemos apreciar el **ID** de cada uno de los puertos, las **MAC**, ...
Nos interesan los **ID** de los puertos, ya que necesitamos utilizar el siguiente comando para deshabilitar la seguridad de estos puertos:

<pre>
(openstack) javier@debian:~/openstack$ openstack port set --disable-port-security 2531063e-74f3-44d3-a268-0d2868599eee
(openstack) javier@debian:~/openstack$ openstack port set --disable-port-security e1517753-2766-4856-a1aa-9f6df4e70d8d
</pre>

Una vez hemos deshabilitado el cortafuegos que establece la seguridad del puerto, la máquina vuelve a estar accesible, ya que ahora la máquina tiene abiertos todo el rango de puertos completo, porque ahora no posee ningún cortafuegos.

Obviamente esto, no es recomendable en situaciones donde la máquina no se encuentre en un entorno que tengamos controlado, yo lo hago porque **Dulcinea** se encuentra en una nube privada, además de que vamos a establecer un cortafuegos desde dentro de la instancia.

Si volvemos a hacerle ping y a intentar una conexión mediante *SSH*:

<pre>
(openstack) javier@debian:~/openstack$ ping 172.22.200.183
PING 172.22.200.183 (172.22.200.183) 56(84) bytes of data.
64 bytes from 172.22.200.183: icmp_seq=1 ttl=61 time=94.7 ms
64 bytes from 172.22.200.183: icmp_seq=2 ttl=61 time=181 ms
64 bytes from 172.22.200.183: icmp_seq=3 ttl=61 time=111 ms
^C
--- 172.22.200.183 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 94.691/128.790/180.895/37.426 ms

(openstack) javier@debian:~/openstack$ ssh -A debian@172.22.200.183
Linux dulcinea 4.19.0-11-cloud-amd64 #1 SMP Debian 4.19.146-1 (2020-09-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Nov 14 17:48:05 2020 from 172.23.0.46

debian@dulcinea:~$
</pre>

Vemos que **Dulcinea** es completamente accesible.

**4. Definición de contraseña en todas las instancias (para poder modificarla desde consola en caso necesario).**

Vamos a establecerle contraseñas a los usuarios, tanto al usuario sin privilegios como a *root*, de las tres instancias. Normalmente no nos va a ser necesario ya que accedemos mediante el par de claves, pero es muy recomendable para poder acceder a ellas si fuera necesario mediante la consola. Para ello vamos a utilizar la herramienta `passwd`.

**Dulcinea:**

<pre>
root@dulcinea:/home/debian# passwd debian
New password:
Retype new password:
passwd: password updated successfully

root@dulcinea:/home/debian# passwd root
New password:
Retype new password:
passwd: password updated successfully
</pre>

**Sancho:**

<pre>
root@sancho:/home/ubuntu# passwd ubuntu
New password:
Retype new password:
passwd: password updated successfully

root@sancho:/home/ubuntu# passwd root
New password:
Retype new password:
passwd: password updated successfully
</pre>

**Quijote:**

<pre>
[root@quijote centos]# passwd centos
Changing password for user centos.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.

[root@quijote centos]# passwd root
Changing password for user root.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
</pre>

**5. Modificación de las instancias sancho y quijote para que usen direccionamiento estático y dulcinea como puerta de enlace.**

Para realizar este paso, en **Dulcinea** debemos habilitar el **bit de forward** y añadir la regla de `iptables` necesaria.

Para habilitar el **bit de forward** de manera permanente necesitamos editar el siguiente fichero de configuración:

<pre>
root@dulcinea:~# nano /etc/sysctl.conf
</pre>

Dentro de este, debemos buscar la línea `#net.ipv4.ip_forward=1` y descomentarla.

Ejecutamos el siguiente comando para aplicar los cambios:

<pre>
root@dulcinea:~# sysctl -p /etc/sysctl.conf
net.ipv4.ip_forward = 1
</pre>

Nos faltaría añadir la regla de *iptables* necesaria, para ello vamos a visualizar nuestras interfaces de red:

<pre>
root@dulcinea:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:2b:1c:c7 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.8/24 brd 10.0.0.255 scope global dynamic eth0
       valid_lft 83294sec preferred_lft 83294sec
    inet6 fe80::f816:3eff:fe2b:1cc7/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:24:f3:f9 brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.11/24 brd 10.0.1.255 scope global dynamic eth1
       valid_lft 83294sec preferred_lft 83294sec
    inet6 fe80::f816:3eff:fe24:f3f9/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Queremos que todo el tráfico que provenga de la red **10.0.1.0/24**, sea reconducido hacia la interfaz **eth0** para que así salga por esta, por tanto la regla a añadir es:

<pre>
iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
</pre>

Hemos habilitado el **bit de forward** y hemos añadido la regla de `iptables` que necesitamos para que todo el tráfico que provenga de la red **10.0.1.0/24**, salga por la interfaz **eth0**, que es la red que se conecta con el exterior, por tanto ya habríamos configurado lo necesario en **Dulcinea**.

**Importante:** es muy recomendable instalar el paquete `iptables-persistent`, ya que esto hará que en cada arranque del sistema las reglas que hemos configurado se levanten automáticamente, siempre y cuando las guardemos en el fichero `/etc/iptables/rules.v4`. Por tanto vamos a guardar esta regla para que se levente en cada inicio:

<pre>
iptables-save > /etc/iptables/rules.v4
</pre>

**Dulcinea**

Vamos a establecerle una IP estática. Como se trata de un sistema operativo *Debian*, debemos editar el fichero `/etc/network/interfaces`.

<pre>
nano /etc/network/interfaces
</pre>

En este fichero vamos a escribir la siguiente configuración:

<pre>
# The normal eth0
allow-hotplug eth0
iface eth0 inet static
address 10.0.0.8
netmask 255.255.255.0
gateway 10.0.0.1

# Additional interfaces, just in case we're using
# multiple networks

allow-hotplug eth1
iface eth1 inet static
address 10.0.1.11
netmask 255.255.255.0
</pre>

En este bloque indicamos que:

- La interfaz **eth0** que es la que se conecta a la red **10.0.0.0/24**, posea una dirección IP estática, le estamos asignando la que se nos ha establecido por DHCP, la **10.0.0.8**, cuya máscara de red es una **255.255.255.0**, y cuya puerta de salida es la **10.0.0.1**.

- La interfaz **eth1** que es la que se conecta a nuestra red interna, posea una dirección IP estática, le estamos asignando la que se nos ha establecido por DHCP, la **10.0.1.11**, cuya máscara de red es una **255.255.255.0**.

Reiniciamos y aplicamos los cambios en las interfaces de red:

<pre>
systemctl restart networking
</pre>

**Sancho**

Para establecer el direccionamiento estático en **Ubuntu**, debemos editar el fichero `/etc/netplan/50-cloud-init.yaml`.

<pre>
nano /etc/netplan/50-cloud-init.yaml
</pre>

En este fichero nos encontramos con esta configuración predeterminada:

<pre>
network:
    version: 2
    ethernets:
        ens3:
            dhcp4: true
            match:
                macaddress: fa:16:3e:84:9b:94
            mtu: 8950
            set-name: ens3
</pre>

Debemos sustituirlo por este bloque, en el que indicamos que el **DHCP4** pasa a ser desactivado, que la IP estática que le estamos asignando es la **10.0.1.8**, cuya máscara de red es una **255.255.255.0**, de ahí el **/24**, que la puerta de enlace es la **10.0.1.11**, es decir, la IP de *Dulcinea*, y que utilice esos **DNS** indicados.

<pre>
network:
    version: 2
    ethernets:
        ens3:
            dhcp4: false
            match:
                macaddress: fa:16:3e:84:9b:94
            mtu: 8950
            set-name: ens3
            addresses: [10.0.1.8/24]
            gateway4: 10.0.1.11
            nameservers:
              addresses: [10.0.1.11, 8.8.8.8]
</pre>


Reiniciamos y aplicamos los cambios en las interfaces de red:

<pre>
netplan apply
</pre>

También reinicio la máquina para verificar que en cada inicio se aplicará esta configuración (aunque realmente es lo mismo):

<pre>
root@sancho:~# reboot

root@sancho:~# Connection to 10.0.1.8 closed by remote host.
Connection to 10.0.1.8 closed.

debian@dulcinea:~$ ssh ubuntu@10.0.1.8
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-53-generic x86_64)

...

Last login: Sat Nov 14 18:41:41 2020 from 10.0.1.11

ubuntu@sancho:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc fq_codel state UP group default qlen 1000
    link/ether fa:16:3e:84:9b:94 brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.8/24 brd 10.0.1.255 scope global ens3
       valid_lft forever preferred_lft forever
    inet6 fe80::f816:3eff:fe84:9b94/64 scope link
       valid_lft forever preferred_lft forever

ubuntu@sancho:~$ ip r
default via 10.0.1.11 dev ens3 proto static
10.0.1.0/24 dev ens3 proto kernel scope link src 10.0.1.8

ubuntu@sancho:~$ ping www.google.es
PING www.google.es (172.217.168.163) 56(84) bytes of data.
64 bytes from mad07s10-in-f3.1e100.net (172.217.168.163): icmp_seq=1 ttl=112 time=43.2 ms
64 bytes from mad07s10-in-f3.1e100.net (172.217.168.163): icmp_seq=2 ttl=112 time=43.9 ms
64 bytes from mad07s10-in-f3.1e100.net (172.217.168.163): icmp_seq=3 ttl=112 time=43.2 ms
^C
--- www.google.es ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 43.166/43.438/43.925/0.345 ms
</pre>

Podemos ver como efectivamente nos ha aplicado la configuración, poseemos una IP estática y la puerta de enlace es la IP de *Dulcinea*, y además comprobamos que poseemos conectividad al exterior, y podemos disfrutar de una resolución de nombres satisfactoria.

**Quijote**

Para establecer el direccionamiento estático en **CentOS 7**, debemos editar el fichero `/etc/sysconfig/network-scripts/ifcfg-eth0`. En *CentOS* por defecto no viene instalado el editor de texto `nano`, que es el que suelo utilizar y el que más me gusta, por tanto tenemos que utilizar `vi`, de momento...

<pre>
[root@quijote ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0
</pre>

En este archivo nos encontramos con esta configuración predeterminada:

<pre>
BOOTPROTO=dhcp
DEVICE=eth0
HWADDR=fa:16:3e:5c:3d:c5
MTU=8950
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
</pre>

Debemos sustituirlo por este bloque, en el que indicamos que en el apartado **BOOTPROTO**, la IP ahora se establece como estática, y el **DHCP4** pasa a ser desactivado, que la IP estática que le estamos asignando es la **10.0.1.13**, cuya máscara de red es una **255.255.255.0**, que la puerta de enlace es la **10.0.1.11**, es decir, la IP de *Dulcinea*, y que utilice esos **DNS** indicados. Es importante establecer en el apartado **ONBOOT** el valor *yes*, ya que esto hará que esta configuración se active en cada inicio del sistema.

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
GATEWAY=10.0.1.11
DNS1=10.0.1.11
DNS2=8.8.8.8
</pre>

Reiniciamos y aplicamos los cambios en las interfaces de red:

<pre>
systemctl restart network.service
</pre>

También reinicio la máquina para verificar que en cada inicio se aplicará esta configuración:

<pre>
[root@quijote ~]# reboot
Connection to 10.0.1.13 closed by remote host.
Connection to 10.0.1.13 closed.

debian@dulcinea:~$ ssh centos@10.0.1.13

Last login: Sat Nov 14 18:43:37 2020 from gateway

[centos@quijote ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:5c:3d:c5 brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.13/24 brd 10.0.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::f816:3eff:fe5c:3dc5/64 scope link
       valid_lft forever preferred_lft forever

[centos@quijote ~]$ ip r
default via 10.0.1.11 dev eth0
10.0.1.0/24 dev eth0 proto kernel scope link src 10.0.1.13

[centos@quijote ~]$ ping www.google.es
PING www.google.es (216.58.209.67) 56(84) bytes of data.
64 bytes from mad07s22-in-f3.1e100.net (216.58.209.67): icmp_seq=1 ttl=112 time=42.9 ms
64 bytes from mad07s22-in-f3.1e100.net (216.58.209.67): icmp_seq=2 ttl=112 time=43.4 ms
64 bytes from mad07s22-in-f3.1e100.net (216.58.209.67): icmp_seq=3 ttl=112 time=57.3 ms
^C
--- www.google.es ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 42.978/47.944/57.388/6.680 ms
</pre>

Podemos ver como efectivamente nos ha aplicado la configuración, poseemos una IP estática y la puerta de enlace es la IP de *Dulcinea*, y además comprobamos que poseemos conectividad al exterior, y podemos disfrutar de una resolución de nombres satisfactoria.

**6. Modificación de la subred de la red interna, deshabilitando el servidor DHCP.**

Esta modificación, la podemos llevar a cabo en nuestro gestor de proyectos de *OpenStack* desde el navegador, pero como ya tenemos configurada el administrador de *OpenStack* desde la terminal, vamos a probar a hacerlo desde aquí.

Listamos todas nuestra redes:

<pre>
(openstack) javier@debian:~/openstack$ openstack network list
+--------------------------------------+------------------------------+----------------------------------------------------------------------------+
| ID                                   | Name                         | Subnets                                                                    |
+--------------------------------------+------------------------------+----------------------------------------------------------------------------+
| 446d94eb-183a-4f34-a05c-2dacc6cd3a54 | red de javier.perezh         | 98c0ae2f-d2ee-48a3-9122-f1369a6e99b3                                       |
| 49812d85-8e7a-4c31-baa2-d427692f6568 | ext-net                      | 158bbe3e-3c98-485e-8042-ba6402111ea6, 6218710b-aa05-46f7-b198-7639efe3da95 |
| 4fc06002-ccc1-4f22-af64-a5eb554d5e8b | red interna de javier.perezh | 87427d1a-bd9d-400a-935b-02c56aaf7748                                       |
+--------------------------------------+------------------------------+----------------------------------------------------------------------------+
</pre>

Si vemos los detalles de nuestra red interna obtenemos:

<pre>
(openstack) javier@debian:~/openstack$ openstack network show 4fc06002-ccc1-4f22-af64-a5eb554d5e8b
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | UP                                   |
| availability_zone_hints   |                                      |
| availability_zones        | nova                                 |
| created_at                | 2020-11-14T17:27:54Z                 |
| description               |                                      |
| dns_domain                | None                                 |
| id                        | 4fc06002-ccc1-4f22-af64-a5eb554d5e8b |
| ipv4_address_scope        | None                                 |
| ipv6_address_scope        | None                                 |
| is_default                | None                                 |
| is_vlan_transparent       | None                                 |
| mtu                       | 8950                                 |
| name                      | red interna de javier.perezh         |
| port_security_enabled     | True                                 |
| project_id                | 678e0304a62c445ba78d3b825cb4f1ab     |
| provider:network_type     | None                                 |
| provider:physical_network | None                                 |
| provider:segmentation_id  | None                                 |
| qos_policy_id             | None                                 |
| revision_number           | 5                                    |
| router:external           | Internal                             |
| segments                  | None                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   | 87427d1a-bd9d-400a-935b-02c56aaf7748 |
| tags                      |                                      |
| updated_at                | 2020-11-14T17:27:54Z                 |
+---------------------------+--------------------------------------+
</pre>

Pero nos encontramos con que no podemos apreciar ningún apartado que nos indique nada del servidor DHCP. He estado buscando un poco por internet pero no he conseguido averiguar nada. De hecho, ni siquiera sé si esta opción la podemos configurar desde aquí, aunque obviamente pienso que sí, por ello he intentado este proceso.

Dicho esto, nos dirigimos a nuestro proyecto de *OpenStack* en el navegador, a este apartado:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/redinternajavier.perezh.png" />

Seleccionamos la opción **Editar subred**, y se nos abrirá esta ventana en la que tendremos que desmarcar la opción llamada **Habilitar DHCP**.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/hlc_creacion_del_escenario_de_trabajo_en_OpenStack/dhcpdesactivado.png" />

Guardamos los cambios y ya tendríamos deshabilitado el servidor DHCP de nuestra red interna.

**7. Creación del usuario profesor en todas las instancias. Usuario que puede utilizar sudo sin contraseña.**

**Dulcinea:**

Para crear un usuario en *Debian*, tenemos que hacer uso del comando `useradd`, pero bien, si queremos que en el nuevo usuario se creen las carpetas automáticamente en el directorio `/home` debemos introducir la opción `-m`:

<pre>
root@dulcinea:~# useradd profesor -m -s /bin/bash

root@dulcinea:~# passwd profesor
New password:
Retype new password:
passwd: password updated successfully

root@dulcinea:~# ls /home/
debian	profesor
</pre>

También le he asignando una contraseña que es **profesor**, por si alguna vez nos es necesaria, aunque normalmente no nos hará falta ya que accederemos mediante claves públicas-privadas.

**Sancho:**

Para crear un usuario en *Ubuntu*, seguimos el mismo proceso que para *Debian*.

<pre>
root@sancho:~# useradd profesor -m -s /bin/bash

root@sancho:~# passwd profesor
New password:
Retype new password:
passwd: password updated successfully

root@sancho:~# ls /home/
profesor  ubuntu
</pre>

**Quijote:**

Para crear un usuario en *CentOS*, hacemos uso del comando `adduser`, que a diferencia de `useradd`, sí nos crea las carpetas automáticamente en el directorio `/home`:

<pre>
[root@quijote ~]# adduser profesor

[root@quijote ~]# passwd profesor
Changing password for user profesor.
New password:
BAD PASSWORD: The password contains the user name in some form
Retype new password:
passwd: all authentication tokens updated successfully.

[root@quijote ~]# ls /home/
centos  profesor
</pre>

Bien, ya habríamos creado todos los usuarios **profesor** en todas las instancias, y solo nos quedaría configurarlas para que este usuario pueda hacer uso de `sudo` sin tener que introducir la contraseña.

Este proceso va a ser el mismo en todos los sistemas.

Editamos el fichero `/etc/sudoers`:

<pre>
nano /etc/sudoers
</pre>

Recordemos que en *CentOS* no está instalado por defecto `nano`, por tanto o lo descargamos o utilizamos `vi`.

Debajo de la línea `root ALL=(ALL) ALL`, introducimos la siguiente línea:

<pre>
profesor ALL=(ALL) NOPASSWD: ALL
</pre>

Y fin, esto hará que cuando el usuario *profesor* haga uso de `sudo`, no le pida contraseña alguna.

**8. Copia las claves públicas de todos los profesores en las instancias para que puedan acceder con el usuario profesor.**

He copiado todas las claves públicas de los profesores al fichero `.ssh/authorized_keys` del usuario *profesor*.

**Importante:** hay que cambiar los permisos de la carpeta `.ssh` a *700*, y del fichero `authorized_keys` a *600*.

**9. Realiza una actualización completa de todos los servidores.**

Para realizar una actualización de todos los paquetes instalados en cada sistema, empleamos estos comandos:

**Dulcinea:**

<pre>
apt update && apt upgrade -y
</pre>

**Sancho:**

<pre>
apt update && apt upgrade -y
</pre>

**Quijote:**

Recordemos que en *CentOS* no se utiliza por defecto `apt`, sino que se sustituye por `yum`.

<pre>
yum update -y
</pre>

Cuando se ejecuta este comando, `yum` comenzará a comprobar en sus repositorios si existe una versión actualizada del software que el sistema tiene instalado actualmente. Una vez que revisa la lista de repositorios y nos informa de que paquetes se pueden actualizar, introducimos `y` y pulsando *intro* se nos actualizarán todos los paquetes.

**10. Configura el servidor con el nombre de dominio `(nombre-usuario).gonzalonazareno.org`.**

**Dulcinea:**

Me he dado cuenta de una cosa al reiniciar la máquina *Dulcinea*, y es que en cada inicio se restablece el fichero `/etc/hosts`. Para cambiar este funcionamiento, tenemos que dirigirnos al fichero `/etc/cloud/cloud.cfg` y buscar esta línea:

<pre>
manage_etc_hosts: true
</pre>

Le cambiamos el valor a *false*:

<pre>
manage_etc_hosts: false
</pre>

Hecho esto, ya podemos realizar las modificaciones necesarias en el fichero `/etc/hosts`. La línea editada tendría este aspecto:

<pre>
127.0.1.1 dulcinea.javierpzh.gonzalonazareno.org dulcinea dulcinea.novalocal  
</pre>

**Sancho:**

Añadimos al fichero `/etc/hosts` la siguiente línea:

<pre>
127.0.1.1 sancho.javierpzh.gonzalonazareno.org sancho
</pre>

**Quijote:**

En los sistemas **CentOS** de *OpenStack*, el *hostname* se asigna durante la creación es `(hostname).novalocal`, cosa que no nos interesa. Para llevar a cabo dicho cambio, vamos a modificar el fichero `/etc/hostname`. Quedando la línea de este fichero:

<pre>
quijote
</pre>

**11. Hasta que no esté configurado el servidor DNS, incluye resolución estática en las tres instancias tanto usando nombre completo como *hostname*.**

Para configurar la resolución estática de las instancias, debemos modificar el fichero `/etc/hosts` y añadir unas líneas con este aspecto:

<pre>
XXX.XXX.XXX.XXX nombre
</pre>

Esto lo que hace, es que cuando intentemos resolver un nombre, busca en este fichero si tiene su dirección IP guardada, por lo que nos facilita y nos acomoda mucho el trabajo.

**Dulcinea:**

Añadimos estas líneas:

<pre>
127.0.1.1 dulcinea.javierpzh.gonzalonazareno.org dulcinea dulcinea.novalocal
127.0.0.1 localhost

10.0.1.8 sancho.javierpzh.gonzalonazareno.org sancho
10.0.1.13 quijote.javierpzh.gonzalonazareno.org quijote
</pre>

Me he dado cuenta de una cosa al reiniciar la máquina *Dulcinea*, y es que en cada inicio se restablece el fichero `/etc/hosts`. Para cambiar este funcionamiento, tenemos que dirigirnos al fichero `/etc/cloud/cloud.cfg` y buscar esta línea:

<pre>
manage_etc_hosts: true
</pre>

Le cambiamos el valor a *false*:

<pre>
manage_etc_hosts: false
</pre>

Y ya habríamos configurado la resolución estática en *Dulcinea*.

**Sancho:**

Añadimos estas líneas:

<pre>
127.0.1.1 sancho.javierpzh.gonzalonazareno.org sancho
127.0.0.1 localhost

10.0.1.11 dulcinea.javierpzh.gonzalonazareno.org dulcinea
10.0.1.13 quijote.javierpzh.gonzalonazareno.org quijote
</pre>

**Quijote:**

Añadimos estas líneas:

<pre>
127.0.1.1 quijote.javierpzh.gonzalonazareno.org quijote
10.0.1.11 dulcinea.javierpzh.gonzalonazareno.org dulcinea
10.0.1.8 sancho.javierpzh.gonzalonazareno.org sancho
</pre>

**12. Asegúrate que el servidor tiene sincronizado su reloj utilizando un servidor NTP externo.**

**Dulcinea:**

Para configurar nuestro reloj utilizando un servidor **NTP** externo, introducimos el siguiente comando y seleccionamos la configuración que nos interese:

<pre>
dpkg-reconfigure tzdata
</pre>

Comprobamos que tenemos la hora correcta y el servidor **NTP** activo y sincronizado:

<pre>
root@dulcinea:~# timedatectl
               Local time: Sat 2020-11-14 21:51:13 CET
           Universal time: Sat 2020-11-14 20:51:13 UTC
                 RTC time: Sat 2020-11-14 20:51:14
                Time zone: Europe/Madrid (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
</pre>

**Sancho:**

Para configurar nuestro reloj utilizando un servidor **NTP** externo, introducimos el siguiente comando y seleccionamos la configuración que nos interese:

<pre>
dpkg-reconfigure tzdata
</pre>

Comprobamos que tenemos la hora correcta y el servidor **NTP** activo y sincronizado:

<pre>
root@sancho:~# timedatectl
               Local time: Sat 2020-11-14 21:53:48 CET
           Universal time: Sat 2020-11-14 20:53:48 UTC
                 RTC time: Sat 2020-11-14 20:53:49    
                Time zone: Europe/Madrid (CET, +0100)
System clock synchronized: yes                        
              NTP service: active                     
          RTC in local TZ: no
</pre>

**Quijote:**

Para configurar nuestro reloj utilizando un servidor **NTP** externo, introducimos el siguiente comando y seleccionamos la configuración que nos interese:

<pre>
tzselect
</pre>

Comprobamos que tenemos la hora correcta y el servidor **NTP** activo y sincronizado:

<pre>
[root@quijote ~]# timedatectl
      Local time: Sat 2020-11-14 21:56:25 CET
  Universal time: Sat 2020-11-14 20:56:25 UTC
        RTC time: Sat 2020-11-14 20:56:26
       Time zone: UTC (CET, +0100)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: no
 Last DST change: DST ended at
                  Sun 2020-10-25 02:59:59 CEST
                  Sun 2020-10-25 02:00:00 CET
 Next DST change: DST begins (the clock jumps one hour forward) at
                  Sun 2021-03-28 01:59:59 CET
                  Sun 2021-03-28 03:00:00 CEST
</pre>
