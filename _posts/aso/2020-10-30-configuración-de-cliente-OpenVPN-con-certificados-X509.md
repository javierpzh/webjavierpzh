---
layout: post
---

## Configuración de cliente OpenVPN con certificados X.509

### Descripción

**Para poder acceder a la red local desde el exterior, existe una red privada configurada con OpenVPN que utiliza certificados x509 para autenticar los usuarios y el servidor.**

- **Genera una clave privada RSA 4096**
- **Genera una solicitud de firma de certificado (fichero CSR) y súbelo a gestiona**
- **Descarga el certificado firmado cuando esté disponible**
- **Instala y configura apropiadamente el cliente openvpn y muestra los registros (logs) del sistema que demuestren que se ha establecido una conexión.**
- **Cuando hayas establecido la conexión VPN tendrás acceso a la red 172.22.0.0/16 a través de un túnel SSL. Compruébalo haciendo ping a 172.22.0.1**

En este post voy a tratar el tema de como crear una **VPN** utilizando **OpenVPN** con certificados **X.509**.

Lo primero sería crear nuestra clave privada de **4096 bits**, para ello vamos a utilizar **openssl**. Vamos a guardar esta clave en el directorio `/etc/ssl/private/`. Para crear esta clave privada empleamos el siguiente comando:

<pre>
root@debian:~# openssl genrsa 4096 > /etc/ssl/private/msi-debian-javierperezhidalgo.key
Generating RSA private key, 4096 bit long modulus (2 primes)
................................................................................++++
.................++++
e is 65537 (0x010001)
</pre>

Lo siguiente sería generar una solicitud de firma de certificado, es decir, un fichero **csr**, que posteriormente enviaremos a la entidad del [Gonzalo Nazareno](https://blogsaverroes.juntadeandalucia.es/iesgonzalonazareno/) para que nos lo firmen.

Para generar nuestro archivo *.csr*:

<pre>
root@debian:~# openssl req -new -key /etc/ssl/private/msi-debian-javierperezhidalgo.key -out /root/msi-debian-javierperezhidalgo.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:ES
State or Province Name (full name) [Some-State]:Sevilla
Locality Name (eg, city) []:Dos Hermanas
Organization Name (eg, company) [Internet Widgits Pty Ltd]:IES Gonzalo Nazareno
Organizational Unit Name (eg, section) []:Informatica
Common Name (e.g. server FQDN or YOUR name) []:msi-debian-javierperezhidalgo
Email Address []:javierperezhidalgo01@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

root@debian:~# ls
msi-debian-javierperezhidalgo.csr
</pre>

Vemos que ya hemos generado nuestro certificado, así que ahora tenemos que enviárselo al *Gonzalo Nazareno* para que nos lo firme. Lo enviamos desde este [enlace](https://dit.gonzalonazareno.org/gestiona/cert/).

Una vez tenemos descargado el certificado firmado, normalmente lo habremos descargado en *Descargas*, por tanto lo vamos a mover a la carpeta `/etc/openvpn` de nuestro usuario *root*.

<pre>
root@debian:~# mv ../home/javier/Descargas/msi-debian-javierperezhidalgo.crt /etc/openvpn/
</pre>

También hemos tenido que descargar el certificado de la entidad *Gonzalo Nazareno*. Por tanto lo vamos a mover a la ruta `/etc/ssl/certs/`:

<pre>
root@debian:~# mv ../home/javier/Descargas/gonzalonazareno.csr /etc/ssl/certs/
</pre>

Solo nos quedaría crear un fichero que configure **OpenVPN**. Este fichero tiene que tener una extensión `.conf`, y tiene que encontrarse en el directorio `/etc/openvpn`.

<pre>
root@debian:/etc/openvpn# nano vpniesgn.conf
</pre>

Dentro de él copiamos y pegamos las siguientes líneas:

<pre>
dev tun
remote sputnik.gonzalonazareno.org
ifconfig 172.23.0.0 255.255.255.0
pull
proto tcp-client
tls-client
remote-cert-tls server
ca /etc/ssl/certs/gonzalonazareno.crt <- Cambiar por la ruta al certificado de la CA Gonzalo Nazareno (el mismo que utilizamos para la moodle, redmine, etc.)
cert /etc/openvpn/msi-debian-javierperezhidalgo.crt <- Cambiar por la ruta al certificado CRT firmado que nos han devuelto
key /etc/ssl/private/msi-debian-javierperezhidalgo.key <- Cambiar por la ruta a la clave privada, aunque en ese directorio es donde debe estar y con permisos 600
comp-lzo
keepalive 10 60
log /var/log/openvpn-sputnik.log
verb 1
</pre>

Reiniciamos el servicio y lo iniciamos:

<pre>
systemctl restart openvpn.service
systemctl start openvpn.service
</pre>

Comprobamos que nos ha creado el túnel y que se nos ha añadido una IP y una regla de encaminamiento para acceder a la red `172.22.0.0/16`:

<pre>
root@debian:~# ip a show tun0
10: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 172.23.0.46 peer 172.23.0.45/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::3ed2:aec4:b737:ab2c/64 scope link stable-privacy
       valid_lft forever preferred_lft forever

root@debian:/etc/ssl/certs# ip r
...
172.22.0.0/16 via 172.23.0.45 dev tun0
...
</pre>

Comprobamos los mensajes del fichero `/var/log/openvpn-sputnik.log`:

<pre>
root@debian:/etc/ssl/certs# cat /var/log/openvpn-sputnik.log
Fri Oct 30 17:14:33 2020 OpenVPN 2.4.7 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Feb 20 2019
Fri Oct 30 17:14:33 2020 library versions: OpenSSL 1.1.1d  10 Sep 2019, LZO 2.10
Fri Oct 30 17:14:33 2020 WARNING: using --pull/--client and --ifconfig together is probably not what you want
Fri Oct 30 17:14:33 2020 TCP/UDP: Preserving recently used remote address: [AF_INET]92.222.86.77:1194
Fri Oct 30 17:14:33 2020 Attempting to establish TCP connection with [AF_INET]92.222.86.77:1194 [nonblock]
Fri Oct 30 17:14:34 2020 TCP connection established with [AF_INET]92.222.86.77:1194
Fri Oct 30 17:14:34 2020 TCP_CLIENT link local: (not bound)
Fri Oct 30 17:14:34 2020 TCP_CLIENT link remote: [AF_INET]92.222.86.77:1194
Fri Oct 30 17:14:34 2020 [sputnik.gonzalonazareno.org] Peer Connection Initiated with [AF_INET]92.222.86.77:1194
Fri Oct 30 17:14:36 2020 TUN/TAP device tun0 opened
Fri Oct 30 17:14:36 2020 /sbin/ip link set dev tun0 up mtu 1500
Fri Oct 30 17:14:36 2020 /sbin/ip addr add dev tun0 local 172.23.0.46 peer 172.23.0.45
Fri Oct 30 17:14:36 2020 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
Fri Oct 30 17:14:36 2020 Initialization Sequence Completed
</pre>

**Importante:** Si no queremos que se levante el túnel VPN cada vez que encendemos el ordenador deshabilitamos el servicio:

<pre>
systemctl disable openvpn.service
</pre>

Para habilitar el túnel VPN cuando lo necesitemos:

<pre>
systemctl start openvpn.service
</pre>

Si queremos utilizar resolución estática de nombres de las máquinas del centro, **jupiter** y **macaco**, añadimos en nuestro fichero `/etc/hosts` las siguientes líneas:

<pre>
172.22.222.1    jupiter
172.22.0.1      macaco
</pre>

Ya hemos terminado la configuración de nuestra VPN.
