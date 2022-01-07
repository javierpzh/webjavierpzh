---
layout: post
---
VPN con OpenVPN y certificados x509
Date: 2021/03/02
Category: Seguridad y Alta Disponibilidad
Header_Cover: theme/images/banner-vpn.jpg
Tags: VPN, OpenVPN, Site-to-Site

## ¿Qué es una VPN?

Una **VPN (Virtual Private Network)** es una tecnología que permite una conexión segura a otra red mediante una red pública. Permite, además, enviar y recibir datos como si se formase parte de la red local o privada, obteniendo así las funcionalidades que dicha red ofrece.

También se puede hacer referencia a una red privada virtual como un **túnel**, pues realmente lo que hace es crear un canal para el tráfico entre el cliente y el servidor VPN en el que su contenido corre independientemente del resto y de manera cifrada.

Existen cuatro tipos según su uso:

- *VPN de acceso remoto*
- *VPN Site to Site*
- *tunneling*
- *VPN over LAN*


## VPN de acceso remoto con OpenVPN y certificados x509

En el siguiente supuesto práctico vamos a interconectar dos máquinas que están en redes separadas, y para ello vamos a crear una VPN con el rango `10.99.99.0/32`. Dividiremos la configuración en dos partes: la configuración del servidor, que también se comportará como autoridad certificadora, y la configuración del cliente.

He creado los siguientes escenarios:

- **Fichero Vagrantfile Servidor:** [Vagrantfile](images/sad_VPN_con_OpenVPN_y_certificados_x509/Vagrantfileservidor.txt)
- **Fichero Vagrantfile Cliente:** [Vagrantfile](images/sad_VPN_con_OpenVPN_y_certificados_x509/Vagrantfilecliente.txt)

##### Escenario Servidor

En el escenario del **servidor** hay que realizar las siguientes modificaciones:

En la máquina **servidor**, instalar el siguiente paquete:

<pre>
apt install openvpn -y
</pre>

También debemos establecer el *bit de forward* a 1:

<pre>
sysctl -w net.ipv4.ip_forward=1
</pre>

En la máquina **cliente**, debemos borrar la puerta de enlace predeterminada y establecer como *gateway* la máquina *servidor*:

<pre>
ip r del default
ip r add default via 192.168.100.10 dev eth1
</pre>

Hecho.


##### Escenario Cliente

En el escenario del **cliente** hay que instalar el siguiente paquete:

<pre>
apt install openvpn -y
</pre>

Explicado esto, empezaremos con la propia configuración del ejercicio.

#### Configuración de OpenVPN

En primer lugar, voy a crear un nuevo fichero llamado `vars` a partir del fichero `vars.example`. Ambos se encuentran en la ruta `/usr/share/easy-rsa`.

<pre>
root@vpn:~# cd /usr/share/easy-rsa/

root@vpn:/usr/share/easy-rsa# cp vars.example vars

root@vpn:/usr/share/easy-rsa# nano vars
</pre>

Debemos modificar una serie de líneas en este fichero `vars`, que por defecto vienen comentadas. Su resultado final sería el siguiente:

<pre>
root@vpn:/usr/share/easy-rsa# cat vars
...
set_var EASYRSA_REQ_COUNTRY	  "ES"
set_var EASYRSA_REQ_PROVINCE  "Sevilla"
set_var EASYRSA_REQ_CITY	    "Dos Hermanas"
set_var EASYRSA_REQ_ORG		    "JAVIERPZH ORG"
set_var EASYRSA_REQ_EMAIL	    "javierperezhidalgo01@gmail.com"
set_var EASYRSA_REQ_OU		    "Ejercicio"
...
</pre>

Hecho esto, vamos a proceder con la creación de la **CA**, para ello, antes es necesario ejecutar algunos comandos.

En primer lugar, tenemos que crear el directorio de salida (`.../pki/`), donde se irán almacenando los distintos ficheros:

<pre>
root@vpn:/usr/share/easy-rsa# ./easyrsa init-pki

Note: using Easy-RSA configuration from: ./vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /usr/share/easy-rsa/pki
</pre>

Podemos apreciar como nos ha creado un nuevo directorio llamado `pki`. En este directorio se almacenarán los certificados firmados de los clientes, del servidor, de la propia CA, ...

Y por último, antes de crear la propia **CA**, debemos generar una clave **Diffie-Helman**. Para esta clave no nos pedirá ninguna frase de paso, ya que no requiere de la confianza de la CA. Esta clave consiste en un algoritmo criptográfico, cuyo fin es muy similar a los usados en otros protocolos como *HTTPs*, es decir, cifrar de forma asimétrica la conexión.

Para generar la clave, utilizaremos el parámetro `gen-dh`. Puede que tarde cierto tiempo, pero es normal, ya que **Diffie-Hellman** es un algoritmo de encriptación duro.

<pre>
root@vpn:/usr/share/easy-rsa# ./easyrsa gen-dh

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time

...

DH parameters of size 2048 created at /usr/share/easy-rsa/pki/dh.pem
</pre>

Ahora sí, vamos a crear mi **Autoridad Certificadora (CA)**, para ello empleamos el siguiente comando:

<pre>

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019

Enter New CA Key Passphrase:
Re-Enter New CA Key Passphrase:
Generating RSA private key, 2048 bit long modulus (2 primes)
........+++++
..........................+++++
e is 65537 (0x010001)
Can't load /usr/share/easy-rsa/pki/.rnd into RNG
140626734470272:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:98:Filename=/usr/share/easy-rsa/pki/.rnd
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:Javier Perez

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/usr/share/easy-rsa/pki/ca.crt
</pre>

Una vez disponemos de nuestra **Autoridad Certificadora**, es el momento de crear y firmar con nuestra nueva CA, el certificado que utilizará nuestro **servidor VPN**. El proceso es el siguiente:

<pre>
root@servidor:/usr/share/easy-rsa# ./easyrsa gen-req server

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019
Generating a RSA private key
.......................................+++++
....................................+++++
writing new private key to '/usr/share/easy-rsa/pki/private/server.key.K03xc5Q5bC'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [server]:Javier Perez

Keypair and certificate request completed. Your files are:
req: /usr/share/easy-rsa/pki/reqs/server.req
key: /usr/share/easy-rsa/pki/private/server.key

root@servidor:/usr/share/easy-rsa# ./easyrsa sign-req server server

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 1080 days:

subject=
    commonName                = Javier Perez


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /usr/share/easy-rsa/pki/safessl-easyrsa.cnf
Enter pass phrase for /usr/share/easy-rsa/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'Javier Perez'
Certificate is to be certified until Feb 14 19:03:04 2024 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /usr/share/easy-rsa/pki/issued/server.crt
</pre>

Hecho esto, tan sólo nos faltaría, crear el certificado que utilizará el **cliente externo** para conectarse a nuestro **servidor VPN** y así conectarse a la red privada. Creamos dicho certificado y lo firmamos con nuestra CA:

<pre>
root@servidor:/usr/share/easy-rsa# ./easyrsa gen-req vpncliente

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019
Generating a RSA private key
.......................................................................+++++
....................................................................+++++
writing new private key to '/usr/share/easy-rsa/pki/private/vpncliente.key.wTCsIvU2Wn'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [vpncliente]:Cliente

Keypair and certificate request completed. Your files are:
req: /usr/share/easy-rsa/pki/reqs/vpncliente.req
key: /usr/share/easy-rsa/pki/private/vpncliente.key

root@servidor:/usr/share/easy-rsa# ./easyrsa sign-req client vpncliente

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 1080 days:

subject=
    commonName                = Cliente


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /usr/share/easy-rsa/pki/safessl-easyrsa.cnf
Enter pass phrase for /usr/share/easy-rsa/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'Cliente'
Certificate is to be certified until Feb 14 19:04:45 2024 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /usr/share/easy-rsa/pki/issued/vpncliente.crt
</pre>

Bien, en este punto, habríamos terminado la parte de creación de los certificados, pero aún nos faltaría distribuir correctamente estos certificados y hacerle llegar al **cliente externo**, los que él va a necesitar.

Como comenté anteriormente, todos los archivos que hemos generado se almacenan dentro del directorio `pki`. En dicha ruta también nos encontramos con distintos subdirectorios, como los siguientes:

- **issued:** en él se almacenan los certificados firmados.

- **private:** en él se almacenan las claves privadas.

Estos certificados, deben estar en la ruta `/etc/openvpn`, por lo que creo una nueva carpeta en esta ruta, y los copio.

<pre>
root@servidor:/usr/share/easy-rsa/pki# mkdir /etc/openvpn/pki

root@servidor:/usr/share/easy-rsa/pki# cp ca.crt /etc/openvpn/pki/

root@servidor:/usr/share/easy-rsa/pki# cp dh.pem /etc/openvpn/pki/

root@servidor:/usr/share/easy-rsa/pki# cp issued/server.crt /etc/openvpn/pki/

root@servidor:/usr/share/easy-rsa/pki# cp private/server.key /etc/openvpn/pki/

root@servidor:/usr/share/easy-rsa/pki# ls /etc/openvpn/pki/
ca.crt	dh.pem	server.crt  server.key
</pre>

Para que el **cliente externo** pueda conectarse a la red privada, necesita poseer los ficheros `ca.crt`, `dh.pem`, `vpncliente.crt` y `vpncliente.key`. Por tanto, se los he pasado:

Es el momento de comenzar con las configuraciones. En primer lugar, veremos como actúo yo de servidor y mi compañero como cliente.

Para realizar la configuración del **servidor VPN**, he creado el fichero `/etc/openvpn/server.conf`. Su contenido es el siguiente:

<pre>
dev tun

server 10.99.99.0 255.255.255.0

push "route 192.168.100.0 255.255.255.0"

proto tcp

tls-server

dh /etc/openvpn/pki/dh.pem

ca /etc/openvpn/pki/ca.crt

cert /etc/openvpn/pki/server.crt

key /etc/openvpn/pki/server.key

comp-lzo

keepalive 10 60

log /var/log/openvpn/server.log

askpass pass1.txt

verb 3
</pre>

Podemos ver como hago referencia a un fichero `pass1.txt`. Este fichero también debe ser creado en la ruta `/etc/openvpn/` y dentro de él debemos introducir la contraseña que establecimos a la hora de crear la clave con la cual firmamos el certificado del servidor con nuestra CA.

Hecho esto, ya podríamos iniciar nuestro servidor:

<pre>
root@servidor:/etc/openvpn# systemctl start openvpn@server

root@servidor:/etc/openvpn# systemctl status openvpn@server
● openvpn@server.service - OpenVPN connection to server
   Loaded: loaded (/lib/systemd/system/openvpn@.service; enabled-runtime; vendor preset: enabled)
   Active: active (running) since Tue 2021-03-02 17:56:07 UTC; 4s ago
     Docs: man:openvpn(8)
           https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage
           https://community.openvpn.net/openvpn/wiki/HOWTO
 Main PID: 1523 (openvpn)
   Status: "Initialization Sequence Completed"
    Tasks: 1 (limit: 544)
   Memory: 1.1M
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─1523 /usr/sbin/openvpn --daemon ovpn-server --status /run/openvpn/server.status 10 --cd /et

Mar 02 17:56:07 servidor systemd[1]: Starting OpenVPN connection to server...
Mar 02 17:56:07 servidor systemd[1]: Started OpenVPN connection to server.

root@servidor:/etc/openvpn# ip a show tun0
4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.99.99.1 peer 10.99.99.2/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::8905:bd21:3450:bf22/64 scope link stable-privacy
       valid_lft forever preferred_lft forever

root@servidor:/etc/openvpn# ip r
default via 192.168.0.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
10.99.99.0/24 via 10.99.99.2 dev tun0
10.99.99.2 dev tun0 proto kernel scope link src 10.99.99.1
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.54
192.168.100.0/24 dev eth2 proto kernel scope link src 192.168.100.10
</pre>

Podemos ver como nos ha creado una nueva interfaz llamada **tun0** y una nueva ruta de encaminamiento. Si lo consultamos, podemos ver que efectivamente está escuchando en el puerto 1194:

<pre>
root@servidor:/etc/openvpn# lsof -i -P -n | grep openvpn
openvpn  1523    root    5u  IPv4  19271      0t0  TCP *:1194 (LISTEN)
</pre>

Por otro lado, vamos a realizar la configuración del **cliente VPN**. Para ello, he creado el fichero `/etc/openvpn/client.conf`. Su contenido es el siguiente:

<pre>
dev tun

ifconfig 10.99.99.0 255.255.255.0
pull

remote 192.168.0.54

proto tcp-client

tls-client

remote-cert-tls server

ca /etc/openvpn/pki/ca.crt

cert /etc/openvpn/pki/vpncliente.crt

key /etc/openvpn/pki/vpncliente.key

comp-lzo

keepalive 10 60

log /var/log/openvpn/cliente.log

askpass pass2.txt

verb 3
</pre>

Podemos ver como hago referencia a un fichero `pass2.txt`. Este fichero también debe ser creado en la ruta `/etc/openvpn/` y dentro de él debemos introducir la contraseña que se estableció a la hora de crear la clave con la cual se firmó el certificado del **cliente VPN** con nuestra CA.

Hecho esto, iniciamos el **cliente VPN**:

<pre>
root@clienteexterno:/etc/openvpn# systemctl start openvpn@client

root@clienteexterno:/etc/openvpn# systemctl status openvpn@client
● openvpn@client.service - OpenVPN connection to client
   Loaded: loaded (/lib/systemd/system/openvpn@.service; enabled-runtime; vendor preset: enabled)
   Active: active (running) since Tue 2021-03-02 17:57:21 UTC; 1s ago
     Docs: man:openvpn(8)
           https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage
           https://community.openvpn.net/openvpn/wiki/HOWTO
 Main PID: 1375 (openvpn)
   Status: "Pre-connection initialization successful"
    Tasks: 1 (limit: 544)
   Memory: 1.1M
   CGroup: /system.slice/system-openvpn.slice/openvpn@client.service
           └─1375 /usr/sbin/openvpn --daemon ovpn-client --status /run/openvpn/client.status 10 --cd /et

Mar 02 17:57:21 clienteexterno systemd[1]: Starting OpenVPN connection to client...
Mar 02 17:57:21 clienteexterno systemd[1]: Started OpenVPN connection to client.

root@clienteexterno:/etc/openvpn# ip a show tun0
4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.99.99.6 peer 10.99.99.5/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::3968:e84e:5015:575d/64 scope link stable-privacy
       valid_lft forever preferred_lft forever

root@clienteexterno:/etc/openvpn# ip r
default via 192.168.0.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
10.99.99.1 via 10.99.99.5 dev tun0
10.99.99.5 dev tun0 proto kernel scope link src 10.99.99.6
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.56
192.168.100.0/24 via 10.99.99.5 dev tun0
</pre>

Podemos ver como me ha creado una nueva interfaz llamada **tun0** y una nueva ruta de encaminamiento hacia la red `192.168.100.0/24`. En este punto ya debo tener accesible las máquinas de la red privada.

Al iniciar el **servidor VPN** vimos que se encontraba escuchando en el puerto 1194, vamos a realizar de nuevo la misma consulta:

<pre>
root@servidor:/etc/openvpn# lsof -i -P -n | grep openvpn
openvpn  1523    root    5u  IPv4  19271      0t0  TCP *:1194 (LISTEN)
openvpn  1523    root    7u  IPv4  20654      0t0  TCP 192.168.0.54:1194->192.168.0.56:54350 (ESTABLISHED)
</pre>

¡Vaya! Vemos como ahora aparecen dos resultados, ya que el **cliente VPN** se ha conectado correctamente.

En teoría ya habríamos terminado pero vamos a comprobarlo. Voy a realizar los siguientes *pings* a la máquina *servidor* y al cliente interno, respectivamente:

<pre>
root@clienteexterno:/etc/openvpn# ping 192.168.100.10
PING 192.168.100.10 (192.168.100.10) 56(84) bytes of data.
64 bytes from 192.168.100.10: icmp_seq=1 ttl=64 time=0.613 ms
64 bytes from 192.168.100.10: icmp_seq=2 ttl=64 time=1.42 ms
64 bytes from 192.168.100.10: icmp_seq=3 ttl=64 time=1.46 ms
^C
--- 192.168.100.10 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 72ms
rtt min/avg/max/mdev = 0.613/1.161/1.457/0.390 ms

root@clienteexterno:/etc/openvpn# ping 192.168.100.20
PING 192.168.100.20 (192.168.100.20) 56(84) bytes of data.
64 bytes from 192.168.100.20: icmp_seq=1 ttl=63 time=2.37 ms
64 bytes from 192.168.100.20: icmp_seq=2 ttl=63 time=1.03 ms
64 bytes from 192.168.100.20: icmp_seq=3 ttl=63 time=2.23 ms
^C
--- 192.168.100.20 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 34ms
rtt min/avg/max/mdev = 1.028/1.876/2.373/0.603 ms
</pre>

Vemos como puedo hacer *ping* a la máquina que está actuando como **servidor VPN**, y también al cliente interno que únicamente está conectado a la red privada.


## Site to site

Ahora, vamos a ver como realizar una **VPN Site to Site**, aunque antes vamos a ver qué es este tipo de VPN.

Se basa en un concepto algo distinto, ya que ahora no vamos a conectar una máquina a una red remota, sino que vamos a conectar dos redes remotas, por lo que estaremos fusionando las dos redes.

#### Javier servidor - Álvaro cliente

En este apartado vamos a ver el proceso desde el lado del servidor. Es algo más complejo que en el lado del cliente, ya que también necesitaremos crear una **Autoridad Certificadora (CA)** y firmar los certificados de nuestros clientes.

Esta vez, tendremos un escenario como el siguiente.

- **Red de Javier `10.0.5.0/24`:** poseo dos máquinas distintas conectadas a esta red privada. La primera de éstas actuará como **servidor**, y es alcanzable por la máquina **servidor** de Álvaro. Mi segunda máquina sólo posee una dirección IP de mi red privada, por lo que no es accesible desde la red de Álvaro.

- **Red de Álvaro `10.0.4.0/24`:** misma situación anterior. Álvaro posee dos máquinas distintas conectadas a esta red privada. La primera de éstas actuará como **servidor**, y es alcanzable por mi máquina **servidor**. La segunda máquina sólo posee una dirección IP de esta red privada, por lo que no es accesible desde mi red.

En primer lugar, vamos a crear un nuevo fichero llamado `vars` a partir del fichero `vars.example`. Ambos se encuentran en la ruta `/usr/share/easy-rsa`.

<pre>
root@vpn:~# cd /usr/share/easy-rsa/

root@vpn:/usr/share/easy-rsa# cp vars.example vars

root@vpn:/usr/share/easy-rsa# nano vars
</pre>

Debemos modificar una serie de líneas en este fichero `vars`, que por defecto vienen comentadas. Su resultado final sería el siguiente:

<pre>
root@vpn:/usr/share/easy-rsa# cat vars
...
set_var EASYRSA_REQ_COUNTRY	  "ES"
set_var EASYRSA_REQ_PROVINCE  "Sevilla"
set_var EASYRSA_REQ_CITY	    "Dos Hermanas"
set_var EASYRSA_REQ_ORG		    "JAVIERPZH ORG"
set_var EASYRSA_REQ_EMAIL	    "javierperezhidalgo01@gmail.com"
set_var EASYRSA_REQ_OU		    "Ejercicio"
...
</pre>

Hecho esto, vamos a proceder con la creación de nuestra **CA**, para ello, antes es necesario ejecutar algunos comandos.

En primer lugar, tenemos que crear el directorio de salida (`.../pki/`), donde se irán almacenando los distintos ficheros:

<pre>
root@vpn:/usr/share/easy-rsa# ./easyrsa init-pki

Note: using Easy-RSA configuration from: ./vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /usr/share/easy-rsa/pki
</pre>

Podemos apreciar como nos ha creado un nuevo directorio llamado `pki`. En este directorio se almacenarán los certificados firmados de los clientes, del servidor, de la propia CA, ...

Y por último, antes de crear la propia **CA**, debemos generar una clave **Diffie-Helman**. Puede que tarde cierto tiempo, pero es normal, ya que **Diffie-Hellman** es un algoritmo de encriptación duro.

<pre>
root@vpn:/usr/share/easy-rsa# ./easyrsa gen-dh

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time

...

DH parameters of size 2048 created at /usr/share/easy-rsa/pki/dh.pem
</pre>

Ahora sí, vamos a crear nuestra **Autoridad Certificadora (CA)**, para ello empleamos el siguiente comando:

<pre>
root@vpn:/usr/share/easy-rsa# ./easyrsa build-ca

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019

Enter New CA Key Passphrase:
Re-Enter New CA Key Passphrase:
Generating RSA private key, 2048 bit long modulus (2 primes)
.............................................+++++
.........+++++
e is 65537 (0x010001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:Javier Pérez

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/usr/share/easy-rsa/pki/ca.crt
</pre>

Ya dispondríamos de nuestra **Autoridad Certificadora**, por lo que, es el momento de crear y firmar con nuestra nueva CA, el certificado que utilizará nuestro **servidor VPN**. El proceso es el siguiente:

<pre>
root@vpn:/usr/share/easy-rsa# ./easyrsa gen-req server

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019
Generating a RSA private key
...............................................................................+++++
....................+++++
writing new private key to '/usr/share/easy-rsa/pki/private/server.key.nx2TAMpMy5'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [server]:Javier Perez

Keypair and certificate request completed. Your files are:
req: /usr/share/easy-rsa/pki/reqs/server.req
key: /usr/share/easy-rsa/pki/private/server.key

root@vpn:/usr/share/easy-rsa# ./easyrsa sign-req server server

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 1080 days:

subject=
    commonName                = Javier Perez


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /usr/share/easy-rsa/pki/safessl-easyrsa.cnf
Enter pass phrase for /usr/share/easy-rsa/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'Javier Perez'
Certificate is to be certified until Feb 14 15:48:45 2024 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /usr/share/easy-rsa/pki/issued/server.crt
</pre>

Hecho esto, tan sólo nos faltaría, crear los certificados que utilizarán nuestros clientes. En mi caso, voy a crear y firmar el certificado que utilizará Álvaro para conectarse a mi máquina **servidor** y así conectarse a mi red privada. Creo dicho certificado y lo firmo con mi CA:

<pre>
root@vpn:/usr/share/easy-rsa# ./easyrsa gen-req vpnAlvaro

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019
Generating a RSA private key
........+++++
...........+++++
writing new private key to '/usr/share/easy-rsa/pki/private/vpnAlvaro.key.BbyZVkhsTn'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [vpnAlvaro]:Alvaro Vaca

Keypair and certificate request completed. Your files are:
req: /usr/share/easy-rsa/pki/reqs/vpnAlvaro.req
key: /usr/share/easy-rsa/pki/private/vpnAlvaro.key

root@vpn:/usr/share/easy-rsa# ./easyrsa sign-req client vpnAlvaro

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.1.1d  10 Sep 2019


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 1080 days:

subject=
    commonName                = Alvaro Vaca


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /usr/share/easy-rsa/pki/safessl-easyrsa.cnf
Enter pass phrase for /usr/share/easy-rsa/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'Alvaro Vaca'
Certificate is to be certified until Feb 14 15:49:58 2024 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /usr/share/easy-rsa/pki/issued/vpnAlvaro.crt
</pre>

Bien, en este punto, habríamos terminado la parte de creación de los certificados, pero aún nos faltaría distribuir correctamente estos certificados y hacerle llegar a nuestros clientes (Álvaro), los que necesitarán.

Como comenté anteriormente, todos los archivos que hemos generado se almacenan dentro del directorio `pki`. En dicha ruta también nos encontramos con distintos subdirectorios, como los siguientes:

- **issued:** en él se almacenan los certificados firmados.

- **private:** en él se almacenan las claves privadas.

Estos certificados, deben estar en la ruta `/etc/openvpn`, por lo que creo una nueva carpeta en esta ruta, y los copio.

<pre>
root@vpn:/usr/share/easy-rsa/pki# mkdir /etc/openvpn/pki

root@vpn:/usr/share/easy-rsa/pki# cp ca.crt /etc/openvpn/pki/caJavier.crt

root@vpn:/usr/share/easy-rsa/pki# cp dh.pem /etc/openvpn/pki/dhJavier.pem

root@vpn:/usr/share/easy-rsa/pki# cp issued/server.crt /etc/openvpn/pki/serverJavier.crt

root@vpn:/usr/share/easy-rsa/pki# cp private/server.key /etc/openvpn/pki/serverJavier.key

root@vpn:/usr/share/easy-rsa/pki# ls /etc/openvpn/pki/
caJavier.crt  dhJavier.pem  serverJavier.crt  serverJavier.key
</pre>

Para que Álvaro pueda conectarse a mi red privada, necesita poseer los ficheros `caJavier.crt`, `dhJavier.pem`, `vpnAlvaro.crt` y `vpnAlvaro.key`. Por tanto, se los paso:

<pre>
root@vpn:~# scp /etc/openvpn/pki/caJavier.crt debian@172.22.200.186:
debian@172.22.200.186's password:
caJavier.crt                                                          100% 1212   568.1KB/s   00:00    

root@vpn:~# scp /etc/openvpn/pki/dhJavier.pem debian@172.22.200.186:
debian@172.22.200.186's password:
dhJavier.pem                                                          100%  424   237.6KB/s   00:00    

root@vpn:~# scp /usr/share/easy-rsa/pki/issued/vpnAlvaro.crt debian@172.22.200.186:
debian@172.22.200.186's password:
vpnAlvaro.crt                                                         100% 4526     1.7MB/s   00:00    

root@vpn:~# scp /usr/share/easy-rsa/pki/private/vpnAlvaro.key debian@172.22.200.186:
debian@172.22.200.186's password:
vpnAlvaro.key                                                         100% 1854   938.3KB/s   00:00
</pre>

Es el momento de realizar la configuración del **servidor VPN**, para ello, he creado el fichero `/etc/openvpn/server.conf`. Su contenido es el siguiente:

<pre>
dev tun

ifconfig 10.99.99.1 10.99.99.2

route 10.0.4.0 255.255.255.0

tls-server

dh /etc/openvpn/pki/dhJavier.pem

ca /etc/openvpn/pki/caJavier.crt

cert /etc/openvpn/pki/serverJavier.crt

key /etc/openvpn/pki/serverJavier.key

comp-lzo

keepalive 10 60

log /var/log/openvpn/server.log

askpass pass1.txt

verb 3
</pre>

Podemos ver como hago referencia a un fichero `pass1.txt`. Este fichero también debe ser creado en la ruta `/etc/openvpn/` y dentro de él debemos introducir la contraseña que establecimos a la hora de crear la clave con la cual firmamos el certificado del servidor con nuestra CA.

Hecho esto, ya podríamos iniciar nuestro servidor y Álvaro podrá conectarse a mi red privada.

<pre>
root@vpn:/etc/openvpn# systemctl start openvpn@server

root@vpn:/etc/openvpn# systemctl status openvpn@server
● openvpn@server.service - OpenVPN connection to server
   Loaded: loaded (/lib/systemd/system/openvpn@.service; disabled; vendor preset: enabled)
   Active: active (running) since Tue 2021-03-02 11:15:03 UTC; 24min ago
     Docs: man:openvpn(8)
           https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage
           https://community.openvpn.net/openvpn/wiki/HOWTO
 Main PID: 17505 (openvpn)
   Status: "Pre-connection initialization successful"
    Tasks: 1 (limit: 562)
   Memory: 1.2M
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─17505 /usr/sbin/openvpn --daemon ovpn-server --status /run/openvpn/server.status 10 --cd /et

Mar 02 11:15:03 vpn systemd[1]: Starting OpenVPN connection to server...
Mar 02 11:15:03 vpn systemd[1]: Started OpenVPN connection to server.

root@vpn:/etc/openvpn# ip a show tun0
4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.99.99.1 peer 10.99.99.2/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::9bb3:c109:1018:9699/64 scope link stable-privacy
       valid_lft forever preferred_lft forever

root@vpn:/etc/openvpn# ip r
default via 10.0.0.1 dev eth0
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.14
10.0.4.0/24 via 10.99.99.2 dev tun0
10.0.5.0/24 dev eth1 proto kernel scope link src 10.0.5.10
10.99.99.2 dev tun0 proto kernel scope link src 10.99.99.1
169.254.169.254 via 10.0.5.1 dev eth1
</pre>

Podemos ver como me ha creado una nueva interfaz llamada **tun0** y una nueva ruta de encaminamiento hacia la red `10.0.4.0/24`. Efectivamente mi compañero inició su cliente VPN, y ya tiene accesible mis máquinas, al igual que yo las suyas. Para demostrarlo he realizado los siguientes *pings* desde mi máquina interna hacia las máquinas de Álvaro:

<pre>
root@vpn:~# ping 10.0.4.4
PING 10.0.4.4 (10.0.4.4) 56(84) bytes of data.
64 bytes from 10.0.4.4: icmp_seq=1 ttl=64 time=1.94 ms
64 bytes from 10.0.4.4: icmp_seq=2 ttl=64 time=2.36 ms
64 bytes from 10.0.4.4: icmp_seq=3 ttl=64 time=2.16 ms
^C
--- 10.0.4.4 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 1.941/2.154/2.362/0.180 ms

root@vpn:~# ping 10.0.4.5
PING 10.0.4.5 (10.0.4.5) 56(84) bytes of data.
64 bytes from 10.0.4.5: icmp_seq=1 ttl=63 time=5.03 ms
64 bytes from 10.0.4.5: icmp_seq=2 ttl=63 time=3.06 ms
64 bytes from 10.0.4.5: icmp_seq=3 ttl=63 time=2.63 ms
^C
--- 10.0.4.5 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 2.633/3.572/5.025/1.042 ms
</pre>

Vemos como puedo hacer *ping* a ambas máquinas de Álvaro, por lo que tanto él como yo, tendremos accesibles ambas redes, y el proceso habría terminado.


#### Javier cliente - Álvaro servidor

Hemos visto el proceso desde el lado del servidor, pero no desde el lado del cliente, así que vamos a ver también como sería el proceso de configuración desde el cliente, para lo cuál, actuaré yo de cliente y mi compañero como servidor.

Álvaro me ha hecho llegar los siguientes ficheros que ha generado con su CA y yo necesito:

<pre>
root@vpn:/etc/openvpn/pki# mv /home/debian/* ./

root@vpn:/etc/openvpn/pki# ls
caalvaro.crt  dhalvaro.pem  vpnjavier.crt  vpnjavier.key
</pre>

Perfecto, ya podríamos realizar la configuración del cliente VPN. Para ello, he creado el fichero `/etc/openvpn/client.conf`. Su contenido es el siguiente:

<pre>
dev tun

remote 172.22.200.186

ifconfig 10.99.99.2 10.99.99.1

route 10.0.4.0 255.255.255.0

tls-client

ca /etc/openvpn/pki/caalvaro.crt

cert /etc/openvpn/pki/vpnjavier.crt

key /etc/openvpn/pki/vpnjavier.key

comp-lzo

keepalive 10 60

verb 3

askpass pass2.txt
</pre>

Podemos ver como hago referencia a un fichero `pass2.txt`. Este fichero también debe ser creado en la ruta `/etc/openvpn/` y dentro de él debemos introducir la contraseña que Álvaro estableció a la hora de crear la clave con la cual firmó el certificado de mi cliente VPN con su CA.

Hecho esto, mi compañero ha iniciado su servidor VPN, y en teoría, una vez inicie mi cliente, podré conectarme a la red privada de Álvaro.

<pre>
root@vpn:/etc/openvpn# systemctl start openvpn@client

root@vpn:/etc/openvpn# systemctl status openvpn@client
● openvpn@client.service - OpenVPN connection to client
   Loaded: loaded (/lib/systemd/system/openvpn@.service; disabled; vendor preset: enabled)
   Active: active (running) since Tue 2021-03-02 11:43:21 UTC; 5s ago
     Docs: man:openvpn(8)
           https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage
           https://community.openvpn.net/openvpn/wiki/HOWTO
 Main PID: 18090 (openvpn)
   Status: "Initialization Sequence Completed"
    Tasks: 1 (limit: 562)
   Memory: 1.2M
   CGroup: /system.slice/system-openvpn.slice/openvpn@client.service
           └─18090 /usr/sbin/openvpn --daemon ovpn-client --status /run/openvpn/client.status 10 --cd /et

Mar 02 11:43:21 vpn ovpn-client[18090]: Outgoing Data Channel: Cipher 'BF-CBC' initialized with 128 bit k
Mar 02 11:43:21 vpn ovpn-client[18090]: WARNING: INSECURE cipher with block size less than 128 bit (64 bi
Mar 02 11:43:21 vpn ovpn-client[18090]: Outgoing Data Channel: Using 160 bit message hash 'SHA1' for HMAC
Mar 02 11:43:21 vpn ovpn-client[18090]: Incoming Data Channel: Cipher 'BF-CBC' initialized with 128 bit k
Mar 02 11:43:21 vpn ovpn-client[18090]: WARNING: INSECURE cipher with block size less than 128 bit (64 bi
Mar 02 11:43:21 vpn ovpn-client[18090]: Incoming Data Channel: Using 160 bit message hash 'SHA1' for HMAC
Mar 02 11:43:21 vpn ovpn-client[18090]: WARNING: cipher with small block size in use, reducing reneg-byte
Mar 02 11:43:21 vpn ovpn-client[18090]: Control Channel: TLSv1.3, cipher TLSv1.3 TLS_AES_256_GCM_SHA384,
Mar 02 11:43:21 vpn ovpn-client[18090]: [server] Peer Connection Initiated with [AF_INET]172.22.200.186:1
Mar 02 11:43:22 vpn ovpn-client[18090]: Initialization Sequence Completed

root@vpn:/etc/openvpn# ip a show tun0
4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.99.99.2 peer 10.99.99.1/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::f261:f23f:5d1a:1d79/64 scope link stable-privacy
       valid_lft forever preferred_lft forever

root@vpn:/etc/openvpn# ip r
default via 10.0.0.1 dev eth0
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.14
10.0.4.0/24 via 10.99.99.1 dev tun0
10.0.5.0/24 dev eth1 proto kernel scope link src 10.0.5.10
10.99.99.1 dev tun0 proto kernel scope link src 10.99.99.2
169.254.169.254 via 10.0.5.1 dev eth1
</pre>

Podemos ver como me ha creado una nueva interfaz llamada **tun0** y una nueva ruta de encaminamiento hacia la red `10.0.4.0/24`. En este punto ya debo tener accesible las máquinas de la red de Álvaro, al igual que él debe tener accesibles las mías. Para comprobarlo voy a hacer los siguientes *pings* desde mi máquina interna hacia el servidor VPN de Álvaro, y también hacia su máquina interna:

<pre>
root@vpn:~# ping 10.0.4.4
PING 10.0.4.4 (10.0.4.4) 56(84) bytes of data.
64 bytes from 10.0.4.4: icmp_seq=1 ttl=64 time=1.82 ms
64 bytes from 10.0.4.4: icmp_seq=2 ttl=64 time=2.07 ms
64 bytes from 10.0.4.4: icmp_seq=3 ttl=64 time=2.21 ms
^C
--- 10.0.4.4 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 1.816/2.030/2.208/0.166 ms

root@vpn:~# ping 10.0.4.5
PING 10.0.4.5 (10.0.4.5) 56(84) bytes of data.
64 bytes from 10.0.4.5: icmp_seq=1 ttl=63 time=2.74 ms
64 bytes from 10.0.4.5: icmp_seq=2 ttl=63 time=2.57 ms
64 bytes from 10.0.4.5: icmp_seq=3 ttl=63 time=2.96 ms
^C
--- 10.0.4.5 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 4ms
rtt min/avg/max/mdev = 2.574/2.757/2.956/0.162 ms
</pre>

Vemos como puedo hacer *ping* a la máquina servidor de Álvaro, y también a su máquina cliente que únicamente está conectada a su red privada. Mi compañero también tiene accesible mis dos máquinas, por lo que, el proceso habría terminado correctamente.

Con esto, el contenido del *post* habría finalizado.
