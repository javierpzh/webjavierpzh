---
layout: post
---
Servidor DHCP con NAT
Date: 2020/10/19
Category: Servicios de Red e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: servidor, DHCP, NAT, SNAT

## Teoría

**Tarea 1: Lee el documento [Teoría: Servidor DHCP](https://fp.josedomingo.org/serviciosgs/u02/dhcp.html) y explica el funcionamiento del servidor DHCP resumido en este [gráfico](https://fp.josedomingo.org/serviciosgs/u02/img/dhcp.png).**

![.](images/sri_servidor_dhcp_con_nat/dhcp.png)

Voy a explicar este gráfico que define el funcionamiento de un servidor DHCP.

Primeramente se inicia el cliente DHCP, y se encuentra en su estado inicial (**INIT**), ya que aún no posee ningún tipo de información. Acto seguido envía un **DHCPDISCOVER** al puerto 67 del servidor, este mensaje usa la dirección IP de broadcast la red (255.255.255.255). Si no existe un servidor DHCP en la red local, el router deberá tener un agente **DHCP relay** para la retransmisión de esta petición hacia las otras subredes.
El mensaje DHCPDISCOVER, se envía tras esperar de 1 a 10 segundos para evitar una posible colisión con otros clientes DHCP.

Una vez enviado este mensaje, el cliente pasa a un estado llamado **SELECTING**, donde va a recibir los mensajes **DHCPOFFER** del servidor DHCP, configurados para atender a este cliente. En el caso de que el cliente reciba más de un mensaje DHCPOFFER, escogerá uno. Como respuesta, el cliente DHCP enviará un mensaje **DHCPREQUEST** para elegir un servidor DHCP, el que contestará con un **DHCPACK**, que contendrá la configuración de red para el cliente.
En este punto, como opción, el cliente envía una petición **ARP** con la dirección IP que le ha asignado el servidor, para comprobar que dicha dirección no esté duplicada. Si lo estuviera, el DHCPACK del servidor se ignora y se envía un **DHCPDECLINE** y el cliente regresaría al estado inicial. Si la dirección es únicamente utilizada por el cliente, éste pasaría a estado **BOUND**.

En dicho estado, se colocan tres valores de temporización, que pueden ser especificados en el servidor:

- **T1:** tiempo de renovación del alquiler. Si no se especifica su valor, se recurre esta fórmula, **T3 x 0'5**.

- **T2:** tiempo de reenganche. Si no se especifica su valor, se recurre esta fórmula, **T3 x 0'875**.

- **T3:** tiempo de duración del alquiler. Este valor se debe indicar en el servidor de manera indispensable.

Cuando **T1** expira, el cliente cambia de estado a **RENEWING**, y negocia con el servidor un nuevo alquiler. Si el servidor decide no renovarle el alquiler, le envía un mensaje **DHCPNACK** y el cliente pasará a estado **INIT**. Si por el contrario, el servidor decide renovarle el alquiler, le enviará un mensaje **DHCPACK** que contendrá la nueva duración del alquiler, y el cliente pasará a estado **BOUND**.

También existe la posibilidad de que al cliente, mientras está esperando la respuesta del servidor, le expire el **T2**, en este caso, se moverá al estado **REBINDING**.
Cuando ocurre esto, el cliente tiene que buscar otra alternativa, por tanto, se decide a intentar contactar con cualquier servidor DHCP que se encuentre en la red, a través de un **DHCPREQUEST**:

- Si un servidor le responde con un **DHCPACK**, el cliente renueva su alquiler, y vuelve al estado **BOUND**.

- Si ningún servidor le responde, y el **T3** expira, el alquiler caduca y pasa al estado **INIT**, eliminando toda la configuración de red.

Hay que decir que el cliente no siempre debe esperar a que termine su tiempo de concesión para devolver la IP que le han asignado, sino que también puede renunciar a esta dirección voluntariamente cuando ya no le sea necesaria.
Al hacer esto, el cliente le envía un mensaje **DHCPRELEASE** al servidor para cancelar el alquiler, y esta dirección IP volverá estar disponible para otro cliente.


## DHCPv4

####Preparación del escenario

**Crea un escenario usando Vagrant que defina las siguientes máquinas:**

- **Servidor:** Tiene dos tarjetas de red: una pública y una privada que se conectan a la red local.
- **nodo_lan1:** Un cliente conectado a la red local.

#### Servidor DHCP

**Instala un servidor dhcp en el ordenador “servidor” que de servicio a los ordenadores de red local, teniendo en cuenta que el tiempo de concesión sea 12 horas y que la red local tiene el direccionamiento `192.168.100.0/24`.**

**Tarea 2: Entrega el fichero `Vagrantfile` que define el escenario.**

He creado este fichero Vagrantfile para definir el escenario.

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :servidor do |servidor|
        servidor.vm.box="debian/buster64"
        servidor.vm.hostname="servidordhcp"
        servidor.vm.network :public_network, :bridge=>"wlo"
        servidor.vm.network :private_network, ip: "192.168.100.1", virtualbox__intnet: "red1"
  end

  config.vm.define :nodolan1 do |nodolan1|
        nodolan1.vm.box="debian/buster64"
        nodolan1.vm.hostname="nodolan1"
        nodolan1.vm.network :private_network, virtualbox__intnet: "red1", type: "dhcp"
  end

end
</pre>

En este fichero de configuración hemos especificado que cree una primera máquina, que actuará de servidor, la cual está conectada en modo puente a nuestra máquina física. También hemos creado una red privada.
La segunda máquina es la que actuará como cliente, a la que también le asignamos una red privada.

**Tarea 3: Muestra el fichero de configuración del servidor, la lista de concesiones, la modificación en la configuración que has hecho en el cliente para que tome la configuración de forma automática y muestra la salida del comando `ip address`.**

Una vez creado el Vagrantfile, ejecutamos estos comandos y nos conectamos a la máquina servidor para realizar las configuraciones necesarias.

<pre>
vagrant up servidor
vagrant ssh servidor
</pre>

Primeramente vamos a comprobar que tenemos las interfaces de red:

<pre>
vagrant@servidordhcp:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86376sec preferred_lft 86376sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:94:f6:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.36/24 brd 192.168.0.255 scope global dynamic eth1
       valid_lft 86382sec preferred_lft 86382sec
    inet6 fe80::a00:27ff:fe94:f6bc/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:d8:2f:9b brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.1/24 brd 192.168.100.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fed8:2f9b/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Vemos que efectivamente tenemos las interfaces que deseábamos:

- **eth0:** Se genera automáticamente por VirtualBox.

- **eth1:** Es la interfaz en la que hemos creado nuestra red pública en modo puente a nuestra máquina física, con la que poseemos una IP pública, **192.168.0.36**.

- **eth2:** Es la interfaz en la que hemos creado nuestra red privada, **192.168.100.1**.

<pre>
vagrant@servidordhcp:~$ ip r
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.36
192.168.100.0/24 dev eth2 proto kernel scope link src 192.168.100.1

vagrant@servidordhcp:~$ sudo ip r replace default via 192.168.0.1

vagrant@servidordhcp:~$ ip r
default via 192.168.0.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.36
192.168.100.0/24 dev eth2 proto kernel scope link src 192.168.100.1
</pre>

He cambiado la puerta de enlace y he especificado que utilice la puerta de enlace de mi **router físico**.

Ahora instalamos los paquetes necesarios para instalar el servidor dhcp. También es recomendable actualizar los paquetes instalados, ya que la box que estoy utilizando no es de la última versión de Debian.

<pre>
apt update && apt upgrade -y && apt autoremove -y && apt install isc-dhcp-server -y
</pre>

Una vez instalado, tenemos que editar estos dos ficheros:

Primero en el `/etc/default/isc-dhcp-server`, modificamos la línea `INTERFACESv4` para que quede así:

<pre>
INTERFACESv4="eth2"
</pre>

Y segundo, en el `/etc/dhcp/dhcpd.conf`, tenemos que realizar esta configuración, que por defecto viene comentada:

<pre>
# A slightly different configuration for an internal subnet.
subnet 192.168.100.0 netmask 255.255.255.0 {
  range 192.168.100.7 192.168.100.220;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  option routers 192.168.100.1;
  default-lease-time 43200;
  max-lease-time 43200;
}
</pre>

Le hemos especificado que nuestra red es la **192.168.100.0/24**, de ahí la máscara puesta, **/24**, el rango de direcciones va **desde la 7 hasta la 220**, le indicamos que la puerta de enlace sea la **192.168.100.1**. Le he puesto un tiempo de concesión por defecto y un tiempo de concesión máximo de **12 horas** (43200 segundos). Vamos a utilizar el **DNS de Google (8.8.8.8)** y el **8.8.4.4**.

Y una vez hecho esto, si realizamos un `systemctl restart isc-dhcp-server.service`, y reiniciamos el servidor dhcp, al arrancar la máquina cliente, debería recibir automáticamente una dirección IP dentro del rango que hemos puesto.

<pre>
root@servidordhcp:/home/vagrant# systemctl restart isc-dhcp-server.service
</pre>

Iniciamos el cliente y nos conectamos a él:

<pre>
javier@debian:~/Vagrant/Deb10-ServidorDHCP$ vagrant up nodolan1

javier@debian:~/Vagrant/Deb10-ServidorDHCP$ vagrant ssh nodolan1
Linux nodolan1 4.19.0-9-amd64 #1 SMP Debian 4.19.118-2 (2020-04-29) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

vagrant@nodolan1:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86311sec preferred_lft 86311sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:aa:c6:76 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.7/24 brd 192.168.100.255 scope global dynamic eth1
       valid_lft 43115sec preferred_lft 43115sec
    inet6 fe80::a00:27ff:feaa:c676/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Podemos ver que efectivamente nos ha asignado la primera dirección dentro del rango que hemos puesto.
Si nos vamos a la máquina servidor y miramos la lista de concesiones, podremos ver la concesión de esta dirección.

<pre>
root@servidordhcp:/home/vagrant# cat /var/lib/dhcp/dhcpd.leases
# The format of this file is documented in the dhcpd.leases(5) manual page.
# This lease file was written by isc-dhcp-4.4.1

# authoring-byte-order entry is generated, DO NOT DELETE
authoring-byte-order little-endian;

server-duid "\000\001\000\001'\037.\355\010\000'\330/\233";

lease 192.168.100.7 {
  starts 0 2020/10/18 16:51:43;
  ends 1 2020/10/19 04:51:43;
  cltt 0 2020/10/18 16:51:43;
  binding state active;
  next binding state free;
  rewind binding state free;
  hardware ethernet 08:00:27:aa:c6:76;
  uid "\377'\252\306v\000\001\000\001'\037/\034\010\000'\252\306v";
  client-hostname "nodolan1";
}
</pre>

Vemos que en la lista de concesiones del servidor, que es la `/var/lib/dhcp/dhcpd.leases` nos aparece como que ha dado la IP **192.168.100.7** al cliente **nodolan1**. Si nos fijamos, podemos apreciar que la concesión se inició a las **16:51** y terminará a las **04:51**, lo que serían doce horas, como hemos establecido en el tiempo de concesión máximo.

**Tarea 4: Configura el servidor para que funcione como router y NAT, de esta forma los clientes tengan internet. Muestra las rutas por defecto del servidor y el cliente. Realiza una prueba de funcionamiento para comprobar que el cliente tiene acceso a internet (utiliza nombres, para comprobar que tiene resolución DNS).**

Ahora lo que tenemos que hacer es cambiar la puerta de enlace para que el cliente tenga acceso a internet.

Al servidor anteriormente le hemos puesto la **192.168.0.1**, que es la ruta de enlace del router de mi casa. Ahora tendríamos que cambiar la puerta de enlace del cliente.

Al cliente le vamos a poner la **192.168.100.1**, que es la puerta de enlace que pertenece al servidor web, de esta manera el cliente se conecta al servidor dhcp (que está conectado con el equipo principal) y sale por su puerta de enlace hacia el equipo principal que es el que está conectado al router del proveedor de internet:

<pre>
vagrant@nodolan1:~$ ip r
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.100.0/24 dev eth1 proto kernel scope link src 192.168.100.7

vagrant@nodolan1:~$ sudo ip r replace default via 192.168.100.1

vagrant@nodolan1:~$ ip r
default via 192.168.100.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.100.0/24 dev eth1 proto kernel scope link src 192.168.100.7
</pre>

Llegados a este punto solo nos faltaría tener un router que soporte el protocolo **NAT** para que los equipos de la red interna, salgan al exterior mediante la IP pública (que realmente no es pública) del router.
Ahora debemos activar el `bit de forward` en la máquina que va a actuar como servidor. Esto va a permitir que funcione como router, o más concretamente en este caso como dispositivo de NAT.
Se puede activar con el siguiente comando:

<pre>
echo 1 > /proc/sys/net/ipv4/ip_forward
</pre>

Este comando lo que hace es poner a '1' el valor del bit de forward, por tanto lo activa.
Pero esta activación se borra cuando se apaga el equipo. Para que dicha activación permanezca debemos definirla en el fichero `/etc/sysctl.conf`, descomentando esta línea que por defecto viene desactivada:

<pre>
net.ipv4.ip_forward=1
</pre>

Y ejecutando el siguiente comando para guardar la configuración;

<pre>
sysctl -p /etc/sysctl.conf
</pre>

Es el momento de crear una nueva regla de `iptables`, que es el responsable de permitirnos hacer NAT.

<pre>
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o eth1 -j MASQUERADE
</pre>

Ahora sí, vamos a comprobar que el cliente posee realmente conexión haciéndole un ping al **servidor DNS de Google** `8.8.8.8.` y luego a `www.google.es`, para comprobar también que nos realiza la resolución de nombres:

<pre>
vagrant@nodolan1:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=17.4 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=116 time=17.7 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=116 time=19.7 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 6ms
rtt min/avg/max/mdev = 17.410/18.279/19.726/1.035 ms

vagrant@nodolan1:~$ ping www.google.com
PING www.google.com (172.217.168.164) 56(84) bytes of data.
64 bytes from mad07s10-in-f4.1e100.net (172.217.168.164): icmp_seq=1 ttl=116 time=17.4 ms
64 bytes from mad07s10-in-f4.1e100.net (172.217.168.164): icmp_seq=2 ttl=116 time=16.4 ms
64 bytes from mad07s10-in-f4.1e100.net (172.217.168.164): icmp_seq=3 ttl=116 time=19.8 ms
^C
--- www.google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 7ms
rtt min/avg/max/mdev = 16.366/17.853/19.820/1.458 ms
</pre>

Vemos que hace ping correctamente, por tanto ya tenemos conexión en nuestro cliente.

**Tarea 5: Realizar una captura, desde el servidor usando `tcpdump`, de los cuatro paquetes que corresponden a una concesión: `DISCOVER`, `OFFER`, `REQUEST`, `ACK`.**

Para realizar una captura con la utilidad `tcpdump`, antes debemos instalar el paquete:

<pre>
apt update && apt install tcpdump -y
</pre>

Antes de realizar la captura, obviamente debemos deshacernos de la dirección que ya tenemos concedida, para luego solicitar una nueva.

<pre>
vagrant@nodolan1:~$ sudo ip a del 192.168.100.7/24 dev eth1

vagrant@nodolan1:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 83577sec preferred_lft 83577sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:aa:c6:76 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a00:27ff:feaa:c676/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Ya hemos eliminado la dirección asignada anteriormente, es el momento de iniciar la captura de los paquetes. La opción `-vv` es para que nos muestre la información detallada, la opción `-i` para especificar la interfaz de red donde queremos realizar la captura del tráfico, y la opción `port` para capturar solamente el tráfico de los puertos **67** y **68** que son los que utiliza DHCP.

<pre>
tcpdump -vv -i eth2 port 67 and 68
</pre>

Desde el cliente vamos a pedirle la concesión de una dirección al servidor DHCP:

<pre>
sudo dhclient eth1
</pre>

Automáticamente el cliente recibe una dirección IP del servidor, en este caso la **192.168.100.8**:

<pre>
vagrant@nodolan1:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 82815sec preferred_lft 82815sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:aa:c6:76 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.8/24 brd 192.168.100.255 scope global dynamic eth1
       valid_lft 43072sec preferred_lft 43072sec
    inet6 fe80::a00:27ff:feaa:c676/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Vemos como efectivamente, `tcpdump` nos ha capturado el tráfico:

<pre>
root@servidordhcp:/home/vagrant# tcpdump -vv -i eth2 port 67 and 68
tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size 262144 bytes
17:49:15.650780 IP (tos 0x10, ttl 128, id 0, offset 0, flags [none], proto UDP (17), length 328)
    0.0.0.0.bootpc > 255.255.255.255.bootps: [udp sum ok] BOOTP/DHCP, Request from 08:00:27:aa:c6:76 (oui Unknown), length 300, xid 0x440e3325, Flags [none] (0x0000)
	  Client-Ethernet-Address 08:00:27:aa:c6:76 (oui Unknown)
	  Vendor-rfc1048 Extensions
	    Magic Cookie 0x63825363
	    DHCP-Message Option 53, length 1: Discover
	    Hostname Option 12, length 8: "nodolan1"
	    Parameter-Request Option 55, length 13:
	      Subnet-Mask, BR, Time-Zone, Default-Gateway
	      Domain-Name, Domain-Name-Server, Option 119, Hostname
	      Netbios-Name-Server, Netbios-Scope, MTU, Classless-Static-Route
	      NTP
17:49:16.652685 IP (tos 0x10, ttl 128, id 0, offset 0, flags [none], proto UDP (17), length 328)
    192.168.100.1.bootps > 192.168.100.8.bootpc: [udp sum ok] BOOTP/DHCP, Reply, length 300, xid 0x440e3325, Flags [none] (0x0000)
	  Your-IP 192.168.100.8
	  Client-Ethernet-Address 08:00:27:aa:c6:76 (oui Unknown)
	  Vendor-rfc1048 Extensions
	    Magic Cookie 0x63825363
	    DHCP-Message Option 53, length 1: Offer
	    Server-ID Option 54, length 4: 192.168.100.1
	    Lease-Time Option 51, length 4: 43200
	    Subnet-Mask Option 1, length 4: 255.255.255.0
	    Default-Gateway Option 3, length 4: 192.168.100.1
	    Domain-Name Option 15, length 11: "example.org"
	    Domain-Name-Server Option 6, length 8: dns.google,dns.google
17:49:16.654052 IP (tos 0x10, ttl 128, id 0, offset 0, flags [none], proto UDP (17), length 328)
    0.0.0.0.bootpc > 255.255.255.255.bootps: [udp sum ok] BOOTP/DHCP, Request from 08:00:27:aa:c6:76 (oui Unknown), length 300, xid 0x440e3325, Flags [none] (0x0000)
	  Client-Ethernet-Address 08:00:27:aa:c6:76 (oui Unknown)
	  Vendor-rfc1048 Extensions
	    Magic Cookie 0x63825363
	    DHCP-Message Option 53, length 1: Request
	    Server-ID Option 54, length 4: 192.168.100.1
	    Requested-IP Option 50, length 4: 192.168.100.8
	    Hostname Option 12, length 8: "nodolan1"
	    Parameter-Request Option 55, length 13:
	      Subnet-Mask, BR, Time-Zone, Default-Gateway
	      Domain-Name, Domain-Name-Server, Option 119, Hostname
	      Netbios-Name-Server, Netbios-Scope, MTU, Classless-Static-Route
	      NTP
17:49:16.656379 IP (tos 0x10, ttl 128, id 0, offset 0, flags [none], proto UDP (17), length 328)
    192.168.100.1.bootps > 192.168.100.8.bootpc: [udp sum ok] BOOTP/DHCP, Reply, length 300, xid 0x440e3325, Flags [none] (0x0000)
	  Your-IP 192.168.100.8
	  Client-Ethernet-Address 08:00:27:aa:c6:76 (oui Unknown)
	  Vendor-rfc1048 Extensions
	    Magic Cookie 0x63825363
	    DHCP-Message Option 53, length 1: ACK
	    Server-ID Option 54, length 4: 192.168.100.1
	    Lease-Time Option 51, length 4: 43200
	    Subnet-Mask Option 1, length 4: 255.255.255.0
	    Default-Gateway Option 3, length 4: 192.168.100.1
	    Domain-Name Option 15, length 11: "example.org"
	    Domain-Name-Server Option 6, length 8: dns.google,dns.google
^C
4 packets captured
4 packets received by filter
0 packets dropped by kernel
</pre>

En la captura podemos encontrar los paquetes: **DISCOVER, OFFER, REQUEST** y **ACK**.

#### Funcionamiento del DHCP

**Vamos a comprobar que ocurre con la configuración de los clientes en determinadas circunstancias, para ello vamos a poner un tiempo de concesión muy bajo.**

**Tarea 6: Los clientes toman una configuración, y a continuación apagamos el servidor dhcp. ¿qué ocurre con el cliente windows? ¿Y con el cliente linux?**

Puedes ver el vídeo [aquí](https://www.youtube.com/watch?v=FR5I2eHsJxc)

**Tarea 7: Los clientes toman una configuración, y a continuación cambiamos la configuración del servidor dhcp (por ejemplo el rango). ¿qué ocurriría con un cliente windows? ¿Y con el cliente linux?**

Puedes ver el vídeo [aquí](https://www.youtube.com/watch?v=b-qLm7r5uzw)

#### Reservas

**Crea una reserva para el que el cliente tome siempre la dirección `192.168.100.100`.**

**Tarea 8: Indica las modificaciones realizadas en los ficheros de configuración y entrega una comprobación de que el cliente ha tomado esa dirección.**

Para configurar una **reserva**, tendremos que especificarla en el fichero de configuración principal del servidor DHCP. Para editar este fichero:

<pre>
nano /etc/dhcp/dhcpd.conf
</pre>

En este archivo de configuración, antes, establecimos la red, sus parámetros, los tiempos, ...
Si nos situamos dos párrafos más abajo de esta configuración, nos encontramos con unas líneas que componen la **sección de host**, que vienen comentadas y vamos a descomentar y adaptar a nuestro gusto. En mi caso:

<pre>
host nodolan1 {
  hardware ethernet 08:00:27:aa:c6:76;
  fixed-address 192.168.100.100;
}
</pre>

Vemos que hemos establecido un nombre, en este caso **nodolan1**, su dirección MAC, **08:00:27:aa:c6:76**, y la IP estática que le deseámos reservar, la **192.168.100.100**.

Después de editar el fichero, reiniciamos el servicio `systemctl restart isc-dhcp-server.service`, y reiniciamos el cliente para que vuelva a hacer la petición DHCP al servidor, y en este caso, debería darle la dirección que acabamos de reservarle.

<pre>
vagrant@nodolan1:~$ ip a show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:aa:c6:76 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.10/24 brd 192.168.100.255 scope global dynamic eth1
       valid_lft 6sec preferred_lft 6sec
    inet6 fe80::a00:27ff:feaa:c676/64 scope link
       valid_lft forever preferred_lft forever

vagrant@nodolan1:~$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.

javier@debian:~/Vagrant/Deb10-ServidorDHCP$ vagrant ssh nodolan1
Linux nodolan1 4.19.0-9-amd64 #1 SMP Debian 4.19.118-2 (2020-04-29) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Oct 19 09:57:41 2020 from 10.0.2.2

vagrant@nodolan1:~$ ip a show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:aa:c6:76 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.100/24 brd 192.168.100.255 scope global dynamic eth1
       valid_lft 8sec preferred_lft 8sec
    inet6 fe80::a00:27ff:feaa:c676/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Vemos que el cliente **nodolan1**, que antes tenía la dirección 192.168.100.10, ha recibido ahora la dirección **192.168.100.100**.

#### Uso de varios ámbitos

**Modifica el escenario Vagrant para añadir una nueva red local y un nuevo nodo:**

- **Servidor:** En el servidor hay que crear una nueva interfaz.
- **nodo_lan2:** Un cliente conectado a la segunda red local.

**Configura el servidor dhcp en el ordenador “servidor” para que de servicio a los ordenadores de la nueva red local, teniendo en cuenta que el tiempo de concesión sea 24 horas y que la red local tiene el direccionamiento 192.168.200.0/24.**

**Tarea 9: Entrega el nuevo fichero Vagrantfile que define el escenario.**

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :servidor do |servidor|
        servidor.vm.box="debian/buster64"
        servidor.vm.hostname="servidordhcp"
        servidor.vm.network :public_network, :bridge=>"wlo"
        servidor.vm.network :private_network, ip: "192.168.100.1", virtualbox__intnet: "red1"
        servidor.vm.network :private_network, ip: "192.168.200.1", virtualbox__intnet: "red2"
  end

  config.vm.define :nodolan1 do |nodolan1|
        nodolan1.vm.box="debian/buster64"
        nodolan1.vm.hostname="nodolan1"
        nodolan1.vm.network :private_network, virtualbox__intnet: "red1", type: "dhcp"
  end

  config.vm.define :nodolan2 do |nodolan2|
        nodolan2.vm.box="debian/buster64"
        nodolan2.vm.hostname="nodolan2"
        nodolan2.vm.network :private_network, virtualbox__intnet: "red2", type: "dhcp"
  end

end
</pre>

**Tarea 10: Explica las modificaciones que has hecho en los distintos ficheros de configuración. Entrega las comprobaciones necesarias de que los dos ámbitos están funcionando.**

Este proceso es el mismo que hemos seguido al principio de la práctica con la **red1**, pero en este caso lo haremos con la **red2**.
Primeramente, en la máquina servidor vamos a verificar que nos ha asignado de manera correcta la nueva interfaz de red:

<pre>
vagrant@servidordhcp:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 85781sec preferred_lft 85781sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:94:f6:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.36/24 brd 192.168.0.255 scope global dynamic eth1
       valid_lft 85802sec preferred_lft 85802sec
    inet6 fe80::a00:27ff:fe94:f6bc/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:d8:2f:9b brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.1/24 brd 192.168.100.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fed8:2f9b/64 scope link
       valid_lft forever preferred_lft forever
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:99:f1:0b brd ff:ff:ff:ff:ff:ff
    inet 192.168.200.1/24 brd 192.168.200.255 scope global eth3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe99:f10b/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Vemos como nos ha creado una nueva interfaz, **eth3** que contiene la dirección **192.168.200.1**.

Tenemos que cambiar la puerta de enlace ya que si nos fijamos, nos ha añadido la regla de la nueva interfaz, pero como pasaba al crear la primera red, tenemos que reemplazar la ruta de enlace predeterminada:

<pre>
vagrant@servidordhcp:~$ ip r
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.36
192.168.100.0/24 dev eth2 proto kernel scope link src 192.168.100.1
192.168.200.0/24 dev eth3 proto kernel scope link src 192.168.200.1

vagrant@servidordhcp:~$ sudo ip r replace default via 192.168.0.1

vagrant@servidordhcp:~$ ip r
default via 192.168.0.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.36
192.168.100.0/24 dev eth2 proto kernel scope link src 192.168.100.1
192.168.200.0/24 dev eth3 proto kernel scope link src 192.168.200.1
</pre>

Volvemos a asignar como predeterminada, la ruta de enlace de nuestro router doméstico.

Ahora nos dirigimos a editar el fichero `/etc/default/isc-dhcp-server`, en el que tenemos que cambiar la línea `INTERFACESv4` y asignarle el valor `eth3`, de manera que quede así:

<pre>
INTERFACESv4="eth2 eth3"
</pre>

Es **importante** no quitar la interfaz **eth2** ya que es la que pertenece a la **red1**, y si la quitamos estaríamos perdiendo esta configuración DHCP.

Es el momento de modificar el archivo principal de configuración del servidor DHCP, el `/etc/dhcp/dhcpd.conf`. Quedaría de esta forma:

<pre>
# A slightly different configuration for an internal subnet.
subnet 192.168.200.0 netmask 255.255.255.0 {
  range 192.168.200.10 192.168.200.220;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  option routers 192.168.200.1;
  default-lease-time 86400;
  max-lease-time 86400;
}
</pre>

Le hemos especificado que nuestra red es la **192.168.200.0/24**, de ahí la máscara puesta, **/24**, el rango de direcciones va **desde la 10 hasta la 220**, le indicamos que la puerta de enlace sea la **192.168.200.1**. Le he puesto un tiempo de concesión por defecto y un tiempo de concesión máximo de **24 horas** (86400 segundos). Vamos a utilizar el **DNS de Google (8.8.8.8)** y el **8.8.4.4**.

Al igual que antes, es **importante** que no quitemos la configuración de la **red1**. Simplemente esta configuración la podemos realizar debajo.

Ya hemos realizado todos los cambios necesarios en el servidor, por tanto reiniciamos el servicio, `systemctl restart isc-dhcp-server.service`.

En la máquina servidor solo nos quedaría activar el `bit de forward` y crear de nuevo la regla de `iptables`:

<pre>
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o eth1 -j MASQUERADE
</pre>

Iniciamos los clientes, y vamos a comprobar que tanto el cliente **nodolan1**, tanto el cliente **nodolan2**, poseen una dirección IP correspondiente a su red.

Cliente **nodolan1**:

<pre>
javier@debian:~/Vagrant/Deb10-ServidorDHCP$ vagrant ssh nodolan1
Linux nodolan1 4.19.0-9-amd64 #1 SMP Debian 4.19.118-2 (2020-04-29) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Oct 19 11:03:41 2020 from 10.0.2.2

vagrant@nodolan1:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86254sec preferred_lft 86254sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:aa:c6:76 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.100/24 brd 192.168.100.255 scope global dynamic eth1
       valid_lft 43055sec preferred_lft 43055sec
    inet6 fe80::a00:27ff:feaa:c676/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Vemos como este cliente posee la dirección **192.168.100.100**, la que le asignamos antes mediante una reserva.
Le cambiamos la puerta de enlace:

<pre>
vagrant@nodolan1:~$ sudo ip r replace default via 192.168.100.1

vagrant@nodolan1:~$ ip r
default via 192.168.100.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.100.0/24 dev eth1 proto kernel scope link src 192.168.100.100
</pre>

Y hacemos un ping a `www.google.es`:

<pre>
vagrant@nodolan1:~$ ping www.google.es
PING www.google.es (216.58.209.67) 56(84) bytes of data.
64 bytes from waw02s06-in-f67.1e100.net (216.58.209.67): icmp_seq=1 ttl=117 time=17.3 ms
64 bytes from waw02s06-in-f67.1e100.net (216.58.209.67): icmp_seq=2 ttl=117 time=43.3 ms
64 bytes from waw02s06-in-f67.1e100.net (216.58.209.67): icmp_seq=3 ttl=117 time=100 ms
^C
--- www.google.es ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 152ms
rtt min/avg/max/mdev = 17.294/53.574/100.180/34.617 ms
</pre>

Y ya tendríamos conexión hacia el exterior en el primer cliente.

Cliente **nodolan2**:

<pre>
javier@debian:~/Vagrant/Deb10-ServidorDHCP$ vagrant ssh nodolan2
Linux nodolan2 4.19.0-9-amd64 #1 SMP Debian 4.19.118-2 (2020-04-29) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Oct 19 11:03:50 2020 from 10.0.2.2

vagrant@nodolan2:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86247sec preferred_lft 86247sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:13:18:76 brd ff:ff:ff:ff:ff:ff
    inet 192.168.200.10/24 brd 192.168.200.255 scope global dynamic eth1
       valid_lft 86248sec preferred_lft 86248sec
    inet6 fe80::a00:27ff:fe13:1876/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Vemos como a este cliente se le ha asignado la dirección **192.168.200.10**, la primera del rango que le hemos asignado a esta red.

**Tarea 11: Realiza las modificaciones necesarias para que los clientes de la segunda red local tengan acceso a internet. Entrega las comprobaciones necesarias.**

Por último, vamos a configurar el servidor y el cliente **nodolan2**, para que éste tenga conectividad.

Para ello, al igual que para el cliente 1, debemos añadir en el servidor una nueva regla de `iptables`.

<pre>
iptables -t nat -A POSTROUTING -s 192.168.200.0/24 -o eth1 -j MASQUERADE
</pre>

Ya solo nos quedaría cambiar la puerta de enlace del cliente:

<pre>
vagrant@nodolan2:~$ sudo ip r replace default via 192.168.200.1

vagrant@nodolan2:~$ ip r
default via 192.168.200.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.200.0/24 dev eth1 proto kernel scope link src 192.168.200.10
</pre>

Y hacemos un ping a `www.google.es`:

<pre>
vagrant@nodolan2:~$ ping www.google.es
PING www.google.es (216.58.209.67) 56(84) bytes of data.
64 bytes from waw02s06-in-f67.1e100.net (216.58.209.67): icmp_seq=1 ttl=117 time=16.9 ms
64 bytes from waw02s06-in-f67.1e100.net (216.58.209.67): icmp_seq=2 ttl=117 time=22.1 ms
64 bytes from waw02s06-in-f67.1e100.net (216.58.209.67): icmp_seq=3 ttl=117 time=18.2 ms
^C
--- www.google.es ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 169ms
rtt min/avg/max/mdev = 16.862/19.061/22.079/2.212 ms
vagrant@nodolan2:~$
</pre>

Observamos como también tenemos conexión en este segundo cliente.
