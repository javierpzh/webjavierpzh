---
layout: post
---

Vamos a construir un cortafuegos en **Dulcinea** que nos permita controlar el tráfico de nuestra red. El cortafuegos que vamos a construir debe funcionar tras un reinicio.

En primer lugar, me gustaría aclarar un poco cuál va a ser el entorno de trabajo, y es que el escenario sobre el que vamos a trabajar, ha sido construido en diferentes *posts* previamente elaborados. Los dejo ordenados a continuación por si te interesa:

- [Creación del escenario de trabajo en OpenStack](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html)
- [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html)
- [Servidores OpenStack: DNS, Web y Base de Datos](https://javierpzh.github.io/servidores-openstack-dns-web-y-base-de-datos.html)

Comprendido esto, empezaremos por instalar el paquete `nftables`:

<pre>
apt install nftables -y
</pre>

Una vez instalado, debemos habilitarlo para que se inicie en cada arranque:

<pre>
systemctl start nftables.service
systemctl enable nftables.service
</pre>

Al igual que pasa con `iptables`, `nftables` también permite guardar las reglas en un fichero para que así las configuraciones perduren a pesar de los reinicios del sistema. Para hacer esto empleamos el siguiente comando:

<pre>
nft list ruleset > /etc/nftables.conf
</pre>

Explicado esto, podemos empezar con las configuraciones de nuestro cortafuegos.


## Política por defecto

La política por defecto que vamos a configurar en nuestro cortafuegos será de tipo **DROP**, pero como estoy conectado por SSH, no voy a aplicar esta política de primeras, ya que sino perdería la conexión. Por tanto, empezaremos con añadir la regla para el acceso por el puerto 22, que es el que utiliza SSH:

Añadimos las reglas para SSH para poder acceder a *Dulcinea*:

<pre>
nft add rule inet filter input ip saddr 172.22.0.0/15 iifname "eth0" tcp dport 22 ct state new,established counter accept
nft add rule inet filter output ip daddr 172.22.0.0/15 oifname "eth0" tcp sport 22 ct state established counter accept
</pre>

En este punto, ya si podemos establecer la política por defecto a **DROP**, ya que poseemos la regla necesaria para tener acceso mediante SSH y no perderemos la conexión:

<pre>
nft add chain inet filter input { policy drop \;}

nft add chain inet filter output { policy drop \;}

nft add chain inet filter forward { policy drop \;}
</pre>

Miramos la lista de reglas:

<pre>
root@dulcinea:~# nft list ruleset
table inet filter {
	chain input {
		type filter hook input priority 0; policy drop;
		ip saddr 172.22.0.0/15 iifname "eth0" tcp dport ssh ct state established,new counter packets 65 bytes 4664 accept
	}

	chain forward {
		type filter hook forward priority 0; policy drop;
	}

	chain output {
		type filter hook output priority 0; policy drop;
		ip daddr 172.22.0.0/15 oifname "eth0" tcp sport ssh ct state established counter packets 37 bytes 8804 accept
	}
}
</pre>

Perfecto, ya poseemos una política por defecto **DROP**.


## NAT

Comenzaremos por crear una tabla llamada **NAT** y añadimos las siguientes cadenas:

<pre>
nft add table nat

nft add chain nat postrouting { type nat hook postrouting priority 100 \; }

nft add chain nat prerouting { type nat hook prerouting priority 0 \; }
</pre>

- **Configura de manera adecuada las reglas NAT para que todas las máquinas de nuestra red tenga acceso al exterior.**

Creamos las siguientes reglas:

<pre>
nft add rule ip nat postrouting oifname "eth0" ip saddr 10.0.1.0/24 counter snat to 10.0.0.8

nft add rule ip nat postrouting oifname "eth0" ip saddr 10.0.2.0/24 counter snat to 10.0.0.8
</pre>

Listo, ya las tendríamos.

- **Configura de manera adecuada todas las reglas NAT necesarias para que los servicios expuestos al exterior sean accesibles.**

Creamos las siguientes reglas:

<pre>
nft add rule ip nat prerouting iifname "eth0" udp dport 53 counter dnat to 10.0.1.6

nft add rule ip nat prerouting iifname "eth0" tcp dport 80 counter dnat to 10.0.2.6

nft add rule ip nat prerouting iifname "eth0" tcp dport 443 counter dnat to 10.0.2.6
</pre>

La primera hace referencia al servidor DNS ubicado en *Freston*, y las dos siguientes al servidor web ubicado en *Quijote*.

Listo, ya las tendríamos.


## Reglas

Para cada configuración, hay que mostrar las reglas que se han configurado y una prueba de funcionamiento de la misma.

#### SSH

- **Podemos acceder por SSH a todas las máquinas.**

Parte de este apartado lo vimos al principio del artículo, al crear las reglas necesarias para permitir el acceso por SSH a *Dulcinea*. Ahora haremos lo mismo pero para permitir el acceso mediante SSH a las máquinas de la red interna y de la DMZ.

Reglas para las máquinas de la red interna:

<pre>
nft add rule inet filter input ip saddr 10.0.1.0/24 iifname "eth1" tcp sport 22 ct state established counter accept
nft add rule inet filter output ip daddr 10.0.1.0/24 oifname "eth1" tcp dport 22 ct state new, established counter accept
</pre>

Reglas para las máquinas de la red DMZ:

<pre>
nft add rule inet filter output ip daddr 10.0.2.0/24 oifname "eth2" tcp dport 22 ct state new,established counter accept
nft add rule inet filter input ip saddr 10.0.2.0/24 iifname "eth2" tcp sport 22 ct state established counter accept
</pre>

Vamos a probar su funcionamiento:

<pre>
debian@dulcinea:~$ ssh freston
Linux freston 4.19.0-13-cloud-amd64 #1 SMP Debian 4.19.160-2 (2020-11-28) x86_64
...
Last login: Sun Jan 31 19:12:18 2021 from 10.0.1.11
debian@freston:~$

--------------------------------------------------------------------------------

debian@dulcinea:~$ ssh ubuntu@sancho
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-64-generic x86_64)
...
Last login: Fri Jan 29 08:45:37 2021 from 10.0.1.11
ubuntu@sancho:~$

--------------------------------------------------------------------------------

debian@dulcinea:~$ ssh centos@quijote
Last login: Fri Jan 29 10:08:13 2021 from 10.0.2.10
[centos@quijote ~]$
</pre>

Listo, ya las tendríamos.

- **Todas las máquinas pueden hacer SSH a máquinas del exterior.**

Creamos las siguientes reglas.

Reglas para *Dulcinea*:

<pre>
nft add rule inet filter output oifname "eth0" tcp dport 22 ct state new,established counter accept
nft add rule inet filter input iifname "eth0" tcp sport 22 ct state established counter accept
</pre>

Reglas para las máquinas de la red interna:

<pre>
nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" oifname "eth0" tcp dport 22 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.1.0/24 iifname "eth0" oifname "eth1" tcp sport 22 ct state established counter accept
</pre>

Reglas para las máquinas de la red DMZ:

<pre>
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" oifname "eth0" tcp dport 22 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.2.0/24 iifname "eth0" oifname "eth2" tcp sport 22 ct state established counter accept
</pre>

Vamos a probar su funcionamiento intentando acceder mediante SSH a la máquina de *OVH*, ya que aunque no poseamos acceso mediante el par de clave pública-privada, dicha máquina tiene habilitado el acceso mediante contraseña:

<pre>
root@dulcinea:~# ssh debian@51.210.105.17
The authenticity of host '51.210.105.17 (51.210.105.17)' can't be established.
ECDSA key fingerprint is SHA256:LDFXW0tFS0C4p8BBQTjDdyObkSnQmMTUZgfiVnCn9zk.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '51.210.105.17' (ECDSA) to the list of known hosts.
debian@51.210.105.17's password:
...
Last login: Sun Jan 31 20:32:56 2021 from 217.216.68.244
debian@vpsjavierpzh:~$

--------------------------------------------------------------------------------

debian@freston:~$ ssh debian@51.210.105.17
The authenticity of host '51.210.105.17 (51.210.105.17)' can't be established.
ECDSA key fingerprint is SHA256:LDFXW0tFS0C4p8BBQTjDdyObkSnQmMTUZgfiVnCn9zk.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '51.210.105.17' (ECDSA) to the list of known hosts.
debian@51.210.105.17's password:
...
Last login: Sun Jan 31 20:33:39 2021 from 80.59.1.152
debian@vpsjavierpzh:~$

--------------------------------------------------------------------------------

[centos@quijote ~]$ ssh debian@51.210.105.17
The authenticity of host '51.210.105.17 (51.210.105.17)' can't be established.
ECDSA key fingerprint is SHA256:LDFXW0tFS0C4p8BBQTjDdyObkSnQmMTUZgfiVnCn9zk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '51.210.105.17' (ECDSA) to the list of known hosts.
debian@51.210.105.17's password:
...
Last login: Sun Jan 31 20:34:48 2021 from 80.59.1.152
debian@vpsjavierpzh:~$
</pre>

Listo, ya las tendríamos.


#### ping

- **Todas las máquinas de las dos redes pueden hacer *ping* entre ellas.**

Para permitir que todas las máquinas puedan hacer *ping* entre sí, debemos añadir las siguientes reglas que he ordenado de la siguiente manera para que quede más claro. En todos los bloques el orden es el siguiente, la primera regla permite el inicio de la conexión, es decir la petición, y la segunda la respuesta por parte del otro cliente.

*Dulcinea* a la red interna:

<pre>
nft add rule inet filter output ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-request counter accept
nft add rule inet filter input ip saddr 10.0.1.0/24 iifname "eth1" icmp type echo-reply counter accept
</pre>

*Dulcinea* a la red DMZ:

<pre>
nft add rule inet filter output ip daddr 10.0.2.0/24 oifname "eth2" icmp type echo-request counter accept
nft add rule inet filter input ip saddr 10.0.2.0/24 iifname "eth2" icmp type echo-reply counter accept
</pre>

Máquinas de la red interna a la red DMZ:

<pre>
nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" ip daddr 10.0.2.0/24 oifname "eth2" icmp type echo-request counter accept
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-reply counter accept
</pre>

Máquinas de la red DMZ a la red interna:

<pre>
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-request counter accept
nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" ip daddr 10.0.2.0/24 oifname "eth2" icmp type echo-reply counter accept
</pre>

En teoría ya tendríamos que poder hacer *ping* entre las diferentes máquinas, pero vamos a comprobarlo:

<pre>
debian@dulcinea:~$ ping 10.0.1.8
PING 10.0.1.8 (10.0.1.8) 56(84) bytes of data.
64 bytes from 10.0.1.8: icmp_seq=1 ttl=64 time=1.31 ms
64 bytes from 10.0.1.8: icmp_seq=2 ttl=64 time=1.20 ms
64 bytes from 10.0.1.8: icmp_seq=3 ttl=64 time=1.18 ms
^C
--- 10.0.1.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 1.181/1.232/1.314/0.070 ms

debian@dulcinea:~$ ping 10.0.2.6
PING 10.0.2.6 (10.0.2.6) 56(84) bytes of data.
64 bytes from 10.0.2.6: icmp_seq=1 ttl=64 time=1.18 ms
64 bytes from 10.0.2.6: icmp_seq=2 ttl=64 time=0.815 ms
64 bytes from 10.0.2.6: icmp_seq=3 ttl=64 time=0.671 ms
^C
--- 10.0.2.6 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 0.671/0.889/1.183/0.218 ms
debian@dulcinea:~$

--------------------------------------------------------------------------------

ubuntu@sancho:~$ ping 10.0.2.6
PING 10.0.2.6 (10.0.2.6) 56(84) bytes of data.
64 bytes from 10.0.2.6: icmp_seq=1 ttl=63 time=2.18 ms
64 bytes from 10.0.2.6: icmp_seq=2 ttl=63 time=1.87 ms
64 bytes from 10.0.2.6: icmp_seq=3 ttl=63 time=2.28 ms
^C
--- 10.0.2.6 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 1.870/2.109/2.278/0.173 ms

--------------------------------------------------------------------------------

[centos@quijote ~]$ ping 10.0.1.6
PING 10.0.1.6 (10.0.1.6) 56(84) bytes of data.
64 bytes from 10.0.1.6: icmp_seq=1 ttl=63 time=2.96 ms
64 bytes from 10.0.1.6: icmp_seq=2 ttl=63 time=2.04 ms
64 bytes from 10.0.1.6: icmp_seq=3 ttl=63 time=1.80 ms
^C
--- 10.0.1.6 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 4ms
rtt min/avg/max/mdev = 1.796/2.266/2.963/0.502 ms
</pre>

Listo, ya las tendríamos.

- **Todas las máquinas pueden hacer *ping* a una máquina del exterior.**

*Dulcinea*:

<pre>
nft add rule inet filter output oifname "eth0" icmp type echo-request counter accept
nft add rule inet filter input iifname "eth0" icmp type echo-reply counter accept
</pre>

Máquinas de la red interna:

<pre>
nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" oifname "eth0" icmp type echo-request counter accept
nft add rule inet filter forward ip daddr 10.0.1.0/24 iifname "eth0" oifname "eth1" icmp type echo-reply counter accept
</pre>

Máquinas de la red DMZ:

<pre>
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" oifname "eth0" icmp type echo-request counter accept
nft add rule inet filter forward ip daddr 10.0.2.0/24 iifname "eth0" oifname "eth2" icmp type echo-reply counter accept
</pre>

Pruebas de funcionamiento:

<pre>
root@dulcinea:~# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=112 time=309 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=112 time=803 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=112 time=198 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 198.008/436.717/803.381/263.184 ms

--------------------------------------------------------------------------------

[centos@quijote ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=42.6 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=111 time=42.9 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=111 time=102 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 42.648/62.541/102.104/27.975 ms

--------------------------------------------------------------------------------

debian@freston:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=43.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=111 time=43.5 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=111 time=43.0 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 6ms
rtt min/avg/max/mdev = 43.019/43.247/43.492/0.193 ms
</pre>

Listo, ya las tendríamos.

- **Desde el exterior se puede hacer *ping* a *Dulcinea*.**

Reglas a añadir:

<pre>
nft add rule inet filter input iifname "eth0" icmp type echo-request counter accept
nft add rule inet filter output oifname "eth0" icmp type echo-reply counter accept
</pre>

Prueba de funcionamiento:

<pre>
javier@debian:~$ ping dulcinea
PING dulcinea (172.22.200.183) 56(84) bytes of data.
64 bytes from dulcinea (172.22.200.183): icmp_seq=1 ttl=61 time=88.3 ms
64 bytes from dulcinea (172.22.200.183): icmp_seq=2 ttl=61 time=87.8 ms
64 bytes from dulcinea (172.22.200.183): icmp_seq=3 ttl=61 time=88.2 ms
^C
--- dulcinea ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 87.803/88.115/88.308/0.222 ms
</pre>

Listo, ya las tendríamos.

- **A *Dulcinea* se le puede hacer *ping* desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT).**

Reglas para las máquinas de la red DMZ:

<pre>
nft add rule inet filter input ip saddr 10.0.2.0/24 iifname "eth2" icmp type echo-request counter accept
nft add rule inet filter output ip daddr 10.0.2.0/24 oifname "eth2" icmp type echo-reply counter accept
</pre>

Regla para las máquinas de la red interna:

<pre>
nft add rule inet filter input ip saddr 10.0.1.0/24 iifname "eth1" icmp type echo-request counter reject
</pre>

Pruebas de funcionamiento:

<pre>
[centos@quijote ~]$ ping 10.0.2.10
PING 10.0.2.10 (10.0.2.10) 56(84) bytes of data.
64 bytes from 10.0.2.10: icmp_seq=1 ttl=64 time=0.530 ms
64 bytes from 10.0.2.10: icmp_seq=2 ttl=64 time=0.687 ms
64 bytes from 10.0.2.10: icmp_seq=3 ttl=64 time=0.568 ms
^C
--- 10.0.2.10 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 39ms
rtt min/avg/max/mdev = 0.530/0.595/0.687/0.066 ms

--------------------------------------------------------------------------------

ubuntu@sancho:~$ ping 10.0.1.11
PING 10.0.1.11 (10.0.1.11) 56(84) bytes of data.
^C
--- 10.0.1.11 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3064ms
</pre>

Listo, ya las tendríamos.


#### DNS

- **El único DNS que pueden usar los equipos de las dos redes es *Freston*, no pueden utilizar un DNS externo.**

Creamos las siguientes reglas para que el servidor DNS de *Freston* pueda hacer las preguntas recursivas en el caso de que sea necesario, es decir, pueda consultar a un DNS externo:

<pre>
nft add rule inet filter forward ip saddr 10.0.1.6 iifname "eth1" oifname "eth0" udp dport 53 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.1.6 iifname "eth0" oifname "eth1" udp sport 53 ct state established counter accept

nft add rule inet filter forward ip saddr 10.0.1.6 iifname "eth1" oifname "eth0" tcp dport 53 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.1.6 iifname "eth0" oifname "eth1" tcp sport 53 ct state established counter accept
</pre>

Creamos las siguientes reglas:

<pre>
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.6 oifname "eth1" udp dport 53 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.2.0/24 iifname "eth1" ip saddr 10.0.1.6 oifname "eth2" udp sport 53 ct state established counter accept
</pre>

Pruebas de funcionamiento:

<pre>
ubuntu@sancho:~$ dig www.javierpzh.gonzalonazareno.org

...

;; ANSWER SECTION:
www.javierpzh.gonzalonazareno.org. 86400 IN CNAME quijote.javierpzh.gonzalonazareno.org.
quijote.javierpzh.gonzalonazareno.org. 86400 IN	A 10.0.2.6

;; AUTHORITY SECTION:
javierpzh.gonzalonazareno.org. 86400 IN	NS	freston.javierpzh.gonzalonazareno.org.

;; ADDITIONAL SECTION:
freston.javierpzh.gonzalonazareno.org. 86400 IN	A 10.0.1.6

;; Query time: 4 msec
;; SERVER: 10.0.1.6#53(10.0.1.6)
;; WHEN: Mon Feb 01 21:05:59 CET 2021
;; MSG SIZE  rcvd: 166

--------------------------------------------------------------------------------

debian@freston:~$ dig www.javierpzh.gonzalonazareno.org

...

;; ANSWER SECTION:
www.javierpzh.gonzalonazareno.org. 86400 IN CNAME quijote.javierpzh.gonzalonazareno.org.
quijote.javierpzh.gonzalonazareno.org. 86400 IN	A 10.0.2.6

;; AUTHORITY SECTION:
javierpzh.gonzalonazareno.org. 86400 IN	NS	freston.javierpzh.gonzalonazareno.org.

;; ADDITIONAL SECTION:
freston.javierpzh.gonzalonazareno.org. 86400 IN	A 10.0.1.6

;; Query time: 0 msec
;; SERVER: 10.0.1.6#53(10.0.1.6)
;; WHEN: Mon Feb 01 21:05:13 CET 2021
;; MSG SIZE  rcvd: 166

--------------------------------------------------------------------------------

[centos@quijote ~]$ dig www.javierpzh.gonzalonazareno.org

...

;; ANSWER SECTION:
www.javierpzh.gonzalonazareno.org. 86400 IN CNAME quijote.javierpzh.gonzalonazareno.org.
quijote.javierpzh.gonzalonazareno.org. 86400 IN	A 10.0.2.6

;; AUTHORITY SECTION:
javierpzh.gonzalonazareno.org. 86400 IN	NS	freston.javierpzh.gonzalonazareno.org.

;; ADDITIONAL SECTION:
freston.javierpzh.gonzalonazareno.org. 86400 IN	A 10.0.1.6

;; Query time: 2 msec
;; SERVER: 10.0.1.6#53(10.0.1.6)
;; WHEN: Mon Feb 01 21:06:46 CET 2021
;; MSG SIZE  rcvd: 166
</pre>

Listo, ya las tendríamos.

- **Dulcinea puede usar cualquier servidor DNS.**

Creamos las siguientes reglas:

<pre>
nft add rule inet filter output udp dport 53 ct state new,established counter accept
nft add rule inet filter input udp sport 53 ct state established counter accept
</pre>

Prueba de funcionamiento:

<pre>
debian@dulcinea:~$ dig @8.8.8.8 www.google.es

...

;; ANSWER SECTION:
www.google.es.		53	IN	A	216.58.201.131

;; Query time: 65 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Mon Feb 01 21:07:44 CET 2021
;; MSG SIZE  rcvd: 58
</pre>

Listo, ya las tendríamos.

- **Tenemos que permitir consultas DNS desde el exterior a *Freston*, para que, por ejemplo, papion-dns pueda preguntar.**

Creamos las siguientes reglas:

<pre>
nft add rule inet filter forward ip daddr 10.0.1.6 iifname "eth0" oifname "eth1" udp dport 53 ct state new,established counter accept
nft add rule inet filter forward ip saddr 10.0.1.6 iifname "eth1" oifname "eth0" udp sport 53 ct state established counter accept
</pre>

Prueba de funcionamiento:

<pre>
javier@debian:~$ dig www.javierpzh.gonzalonazareno.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.javierpzh.gonzalonazareno.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2373
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 0730df91c1792814964dae846018fef15b7db48cb2c29bbf (good)
;; QUESTION SECTION:
;www.javierpzh.gonzalonazareno.org. IN	A

;; ANSWER SECTION:
www.javierpzh.gonzalonazareno.org. 86400 IN CNAME dulcinea.javierpzh.gonzalonazareno.org.
dulcinea.javierpzh.gonzalonazareno.org.	86400 IN A 172.22.200.183

;; AUTHORITY SECTION:
javierpzh.gonzalonazareno.org. 86400 IN	NS	dulcinea.javierpzh.gonzalonazareno.org.

;; Query time: 10 msec
;; SERVER: 192.168.202.2#53(192.168.202.2)
;; WHEN: mar feb 02 08:27:45 CET 2021
;; MSG SIZE  rcvd: 143
</pre>

Listo, ya las tendríamos.


#### Base de datos

- **A la base de datos de sancho sólo pueden acceder las máquinas de la DMZ.**

Creamos las siguientes reglas:

<pre>
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.8 oifname "eth1" tcp dport 3306 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.2.0/24 iifname "eth1" ip saddr 10.0.1.8 oifname "eth2" tcp sport 3306 ct state established counter accept
</pre>

Prueba de funcionamiento:

<pre>
[centos@quijote ~]$ mysql -h sancho -u javierquijote -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 36
Server version: 10.3.25-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
</pre>

Listo, ya las tendríamos.


#### Web

- **Las páginas web de *Quijote* (80, 443) pueden ser accedidas desde todas las máquinas de nuestra red y desde el exterior.**

Creamos las siguientes reglas para *Dulcinea*:

<pre>
nft add rule inet filter output ip daddr 10.0.2.6 oifname "eth2" tcp dport 80 ct state new,established counter accept
nft add rule inet filter input ip saddr 10.0.2.6 iifname "eth2" tcp sport 80 ct state established counter accept

nft add rule inet filter output ip daddr 10.0.2.6 oifname "eth2" tcp dport 443 ct state new,established counter accept
nft add rule inet filter input ip saddr 10.0.2.6 iifname "eth2" tcp sport 443 ct state established counter accept
</pre>

Creamos las siguientes reglas para las demás máquinas:

<pre>
nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" ip daddr 10.0.2.6 oifname "eth2" tcp dport 80 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.1.0/24 iifname "eth2" ip saddr 10.0.2.6 oifname "eth1" tcp sport 80 ct state established counter accept

nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" ip daddr 10.0.2.6 oifname "eth2" tcp dport 443 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.1.0/24 iifname "eth2" ip saddr 10.0.2.6 oifname "eth1" tcp sport 443 ct state established counter accept

--------------------------------------------------------------------------------

nft add rule inet filter forward ip daddr 10.0.2.6 iifname "eth0" oifname "eth2" tcp dport 80 ct state new,established counter accept
nft add rule inet filter forward ip saddr 10.0.2.6 iifname "eth2" oifname "eth0" tcp sport 80 ct state established counter accept

nft add rule inet filter forward ip daddr 10.0.2.6 iifname "eth0" oifname "eth2" tcp dport 443 ct state new,established counter accept
nft add rule inet filter forward ip saddr 10.0.2.6 iifname "eth2" oifname "eth0" tcp sport 443 ct state established counter accept
</pre>

Listo, ya las tendríamos.


#### Más servicios

- **Webs exteriores**

Al terminar el cortafuegos me dí cuenta que no podía conectar con ninguna web del exterior, ya que no poseía ninguna regla con la que pudiera conectar con ellas, ni por el puerto 80, ni por el 443, por tanto vamos a crearlas:

Reglas para *Dulcinea*:

<pre>
nft add rule inet filter output oifname "eth0" tcp dport 80 ct state new,established counter accept
nft add rule inet filter input iifname "eth0" tcp sport 80 ct state established counter accept

nft add rule inet filter output oifname "eth0" tcp dport 443 ct state new,established counter accept
nft add rule inet filter input iifname "eth0" tcp sport 443 ct state established counter accept
</pre>

Reglas para las máquinas de la red interna:

<pre>
nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" oifname "eth0" tcp dport 80 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.1.0/24 iifname "eth0" oifname "eth1" tcp sport 80 ct state established counter accept

nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" oifname "eth0" tcp dport 443 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.1.0/24 iifname "eth0" oifname "eth1" tcp sport 443 ct state established counter accept
</pre>

Reglas para las máquinas de la red DMZ:

<pre>
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" oifname "eth0" tcp dport 80 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.2.0/24 iifname "eth0" oifname "eth2" tcp sport 80 ct state established counter accept

nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" oifname "eth0" tcp dport 443 ct state new,established counter accept
nft add rule inet filter forward ip daddr 10.0.2.0/24 iifname "eth0" oifname "eth2" tcp sport 443 ct state established counter accept
</pre>

Listo, ya las tendríamos.


#### Zona en pruebas

- **Bacula**

Creamos las siguientes reglas para *Bacula*.

--------------------------------------------------------------------------------

Para conectar con la máquina de OVH:

<pre>
nft add rule inet filter output oifname "eth0" tcp dport 9101 ct state new,established counter accept
nft add rule inet filter input iifname "eth0" tcp sport 9101 ct state established counter accept
</pre>



nft add chain inet filter input { policy accept \;}

nft add chain inet filter output { policy accept \;}

nft add chain inet filter forward { policy accept \;}





-A INPUT -i eth1 -s 0.0.0.0/0 -p tcp --dport 9101 --ctstate new,established
-A OUTPUT -o eth0 -d 0.0.0.0/0 -p tcp --sport 9101 state established

-A OUTPUT -o eth0 -d 0.0.0.0/0 --dport 9102 new,established
-A INPUT -i eth0 -s 0.0.0.0/0 --sport 9102 established

nft add rule inet filter input ip saddr 0.0.0.0/0 iifname "eth1" tcp dport 9101 ct state new,established counter accept
nft add rule inet filter output ip daddr 0.0.0.0/0 oifname "eth0" tcp sport 9101 ct state established counter accept

nft add rule inet filter output ip daddr 0.0.0.0/0 oifname "eth0" tcp dport 9102 ct state new,established counter accept
nft add rule inet filter input ip saddr 0.0.0.0/0 iifname "eth0" tcp sport 9102 ct state established counter accept















--------------------------------------------------------------------------------

Listo, ya las tendríamos, y ahora sí, habríamos terminado con este *firewall*.
