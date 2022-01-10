---
layout: post
---

## Cifrado asimétrico con gpg

En esta práctica vamos a cifrar ficheros utilizando cifrado asimétrico utilizando el programa gpg. Puedes encontrar el resumen de comando en esta [chuleta](https://elbauldelprogramador.com/chuleta-de-comandos-para-gpg/) o buscar información en internet.

### Tarea 1: Generación de claves.

Los algoritmos de cifrado asimétrico utilizan dos claves para el cifrado y descifrado de mensajes. Cada persona involucrada (receptor y emisor) debe disponer, por tanto, de una pareja de claves pública y privada. Para generar nuestra pareja de claves con gpg utilizamos la opción `--gen-key`:

Para esta práctica no es necesario que indiquemos frase de paso en la generación de las claves (al menos para la clave pública).

**1. Genera un par de claves (pública y privada). ¿En que directorio se guarda las claves de un usuario?**

Para generar un nuevo par de claves, utilizamos el siguiente comando:

<pre>
gpg --gen-key
</pre>

Aquí muestro como lo he realizado yo:

<pre>
javier@debian:~$ gpg --gen-key
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Nota: Usa "gpg --full-generate-key" para el diálogo completo de generación de clave.

GnuPG debe construir un ID de usuario para identificar su clave.

Nombre y apellidos: Javier Pérez Hidalgo
Dirección de correo electrónico: reyole111@gmail.com
Está usando el juego de caracteres 'utf-8'.
Ha seleccionado este ID de usuario:
    "Javier Pérez Hidalgo <reyole111@gmail.com>"

¿Cambia (N)ombre, (D)irección o (V)ale/(S)alir? v
Es necesario generar muchos bytes aleatorios. Es una buena idea realizar
alguna otra tarea (trabajar en otra ventana/consola, mover el ratón, usar
la red y los discos) durante la generación de números primos. Esto da al
generador de números aleatorios mayor oportunidad de recoger suficiente
entropía.
Es necesario generar muchos bytes aleatorios. Es una buena idea realizar
alguna otra tarea (trabajar en otra ventana/consola, mover el ratón, usar
la red y los discos) durante la generación de números primos. Esto da al
generador de números aleatorios mayor oportunidad de recoger suficiente
entropía.
gpg: clave E446ACC5CFC7D182 marcada como de confianza absoluta
gpg: creado el directorio '/home/javier/.gnupg/openpgp-revocs.d'
gpg: certificado de revocación guardado como '/home/javier/.gnupg/openpgp-revocs.d/17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182.rev'
claves pública y secreta creadas y firmadas.

pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
      17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182
uid                      Javier Pérez Hidalgo <reyole111@gmail.com>
sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]
</pre>

Antes de completar el proceso nos va a saltar una ventana donde vamos a tener que especificar nuestra contraseña.
Las claves y los datos que se crean se guardan en el directorio '.gnupg'.

**2. Lista las claves públicas que tienes en tu almacén de claves. Explica los distintos datos que nos muestra. ¿Cómo deberías haber generado las claves para indicar, por ejemplo, que tenga un 1 mes de validez?**

Para listar las claves de nuestro anillo de claves públicas:

<pre>
javier@debian:~/.gnupg$ gpg --list-keys
/home/javier/.gnupg/pubring.kbx
-------------------------------
pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
      17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182
uid        [  absoluta ] Javier Pérez Hidalgo <reyole111@gmail.com>
sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]
</pre>

Nos muestra la fecha de creación, la fecha de caducidad, el identificador, el nombre que le hemos puesto y el correo electrónico.

Para generar una clave pública-privada que tengan un mes de validez, debemos usar el siguiente comando, en el que podemos especificar además, más opciones y parámetros por si no queremos los predeterminados:

<pre>
javier@debian:~/.gnupg$ gpg --full-generate-key
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Por favor seleccione tipo de clave deseado:
   (1) RSA y RSA (por defecto)
   (2) DSA y ElGamal
   (3) DSA (sólo firmar)
   (4) RSA (sólo firmar)
Su elección: 1
las claves RSA pueden tener entre 1024 y 4096 bits de longitud.
¿De qué tamaño quiere la clave? (3072)
El tamaño requerido es de 3072 bits
Por favor, especifique el período de validez de la clave.
         0 = la clave nunca caduca
      <n>  = la clave caduca en n días
      <n>w = la clave caduca en n semanas
      <n>m = la clave caduca en n meses
      <n>y = la clave caduca en n años
¿Validez de la clave (0)? 1m
La clave caduca jue 12 nov 2020 16:47:41 CET
¿Es correcto? (s/n) s

GnuPG debe construir un ID de usuario para identificar su clave.

Nombre y apellidos: Javier Pérez Hidalgo
Dirección de correo electrónico: reyole111@gmail.com
Comentario:
Está usando el juego de caracteres 'utf-8'.
Ha seleccionado este ID de usuario:
    "Javier Pérez Hidalgo <reyole111@gmail.com>"

¿Cambia (N)ombre, (C)omentario, (D)irección o (V)ale/(S)alir? s
gpg: Creación de claves cancelada.
</pre>

**3. Lista las claves privadas de tu almacén de claves.**

Si quisiéramos listar las claves privadas de muestro anillo de claves privadas:

<pre>
gpg --list-secret-keys
</pre>


### Tarea 2: Importar / exportar clave pública.

Para enviar archivos cifrados a otras personas, necesitamos disponer de sus claves públicas. De la misma manera, si queremos que cierta persona pueda enviarnos datos cifrados, ésta necesita conocer nuestra clave pública. Para ello, podemos hacérsela llegar por email por ejemplo. Cuando recibamos una clave pública de otra persona, ésta deberemos incluirla en nuestro keyring o anillo de claves, que es el lugar donde se almacenan todas las claves públicas de las que disponemos.

**1. Exporta tu clave pública en formato ASCII y guárdalo en un archivo nombre_apellido.asc y envíalo al compañero con el que vas a hacer esta práctica.**

Para exportar mi clave pública con formato ASCII, indicamos el parámetro `--armor`, le indicamos con el parámetro `--output` el nombre que va a recibir la clave y con `--export` indicamos la clave a exportar.

<pre>
gpg --armor --output javier_perez_hidalgo.asc --export "Javier Pérez Hidalgo"
</pre>

Ahora se la paso a mi compañero [Juanlu](https://www.instagram.com/juanlu_millan/).

**2. Importa las claves públicas recibidas de vuestro compañero.**

Juanlu me ha pasado su clave pública llamada `juanluis_millan.asc` y yo la importo a mi anillo de claves públicas.

<pre>
javier@debian:~/Descargas$ gpg --import juanluis_millan.asc
gpg: clave 15E1B16E8352B9BB: clave pública "Juan Luis Millan Hidalgo <juanluismillanhidalgo@gmail.com>" importada
gpg: Cantidad total procesada: 1
gpg:               importadas: 1
</pre>

Él también ha incluido mi pública en su anillo de claves públicas.

**3. Comprueba que las claves se han incluido correctamente en vuestro keyring.**

Compruebo que se ha importado de manera correcta:

<pre>
javier@debian:~/.gnupg$ gpg --list-keys
/home/javier/.gnupg/pubring.kbx
-------------------------------
pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
      17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182
uid        [  absoluta ] Javier Pérez Hidalgo <reyole111@gmail.com>
sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]

pub   rsa3072 2020-10-13 [SC] [caduca: 2022-10-13]
      B02B578465B0756DFD271C733E0DA17912B9A4F8
uid        [desconocida] Álvaro Vaca Ferreras <avacaferreras@gmail.com>
sub   rsa3072 2020-10-13 [E] [caduca: 2022-10-13]

pub   rsa3072 2020-10-07 [SC] [caduca: 2022-10-07]
      4C220919DD2364BED7D49C3215E1B16E8352B9BB
uid        [desconocida] Juan Luis Millan Hidalgo <juanluismillanhidalgo@gmail.com>
sub   rsa3072 2020-10-07 [E] [caduca: 2022-10-07]
</pre>

Vemos que la tenemos almacenada, por tanto ya podríamos enviarnos archivos encriptados.

### Tarea 3: Cifrado asimétrico con claves públicas.

Tras realizar el ejercicio anterior, podemos enviar ya documentos cifrados utilizando la clave pública de los destinatarios del mensaje.

**1. Cifraremos un archivo cualquiera y lo remitiremos por email a uno de nuestros compañeros que nos proporcionó su clave pública.**

He creado un archivo llamado `prueba_para_juanlu.txt` y lo encripto con la clave pública de Juanlu para que solo él con su clave privada pueda descifrarlo.

<pre>
javier@debian:~/Descargas$ gpg -r juanluismillanhidalgo@gmail.com --encrypt prueba_para_juanlu.txt
gpg: 988EDEB8C4FF299C: No hay seguridad de que esta clave pertenezca realmente
al usuario que se nombra

sub  rsa3072/988EDEB8C4FF299C 2020-10-07 Juan Luis Millan Hidalgo <juanluismillanhidalgo@gmail.com>
 Huella clave primaria: 4C22 0919 DD23 64BE D7D4  9C32 15E1 B16E 8352 B9BB
      Huella de subclave: 92ED 2E50 2319 E80D 5B0A  D728 988E DEB8 C4FF 299C

No es seguro que la clave pertenezca a la persona que se nombra en el
identificador de usuario. Si *realmente* sabe lo que está haciendo,
puede contestar sí a la siguiente pregunta.

¿Usar esta clave de todas formas? (s/N) s
</pre>

Una vez cifrado, se lo envío.

**2. Nuestro compañero, a su vez, nos remitirá un archivo cifrado para que nosotros lo descifremos.**

Mi compañero me ha pasado un archivo encriptado por él con mi clave pública, que se llama `hola.txt.gpg`.

<pre>
javier@debian:~/Descargas$ ls
hola.txt.gpg  juanluis_millan.asc     prueba_para_juanlu.txt.gpg
Imágenes      prueba_para_juanlu.txt
</pre>

**3. Tanto nosotros como nuestro compañero comprobaremos que hemos podido descifrar los mensajes recibidos respectivamente.**

Voy a descifrar el archivo con mi clave privada.

<pre>
javier@debian:~/Descargas$ gpg --decrypt hola.txt.gpg
gpg: cifrado con clave de 3072 bits RSA, ID 1A5336E5C764C497, creada el 2020-10-06
      "Javier Pérez Hidalgo <reyole111@gmail.com>"
hola compañero javier
</pre>

Vemos como lo hemos descifrado correctamente y que ya podemos leer el mensaje que Juanlu me quería hacer llegar.

**4. Por último, enviaremos el documento cifrado a alguien que no estaba en la lista de destinatarios y comprobaremos que este usuario no podrá descifrar este archivo.**

Voy a quitar la clave pública de Juanlu para ver como efectivamente, ya no podré descifrar el fichero que Juanlu me envíe encriptado con su clave privada.

<pre>
javier@debian:~/.gnupg$ gpg --list-keys
/home/javier/.gnupg/pubring.kbx
-------------------------------
pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
      17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182
uid        [  absoluta ] Javier Pérez Hidalgo <reyole111@gmail.com>
sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]

pub   rsa3072 2020-10-13 [SC] [caduca: 2022-10-13]
      B02B578465B0756DFD271C733E0DA17912B9A4F8
uid        [desconocida] Álvaro Vaca Ferreras <avacaferreras@gmail.com>
sub   rsa3072 2020-10-13 [E] [caduca: 2022-10-13]

pub   rsa3072 2020-10-07 [SC] [caduca: 2022-10-07]
      4C220919DD2364BED7D49C3215E1B16E8352B9BB
uid        [desconocida] Juan Luis Millan Hidalgo <juanluismillanhidalgo@gmail.com>
sub   rsa3072 2020-10-07 [E] [caduca: 2022-10-07]

javier@debian:~/.gnupg$ gpg --delete-key Juan Luis Millan Hidalgo
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.


pub  rsa3072/15E1B16E8352B9BB 2020-10-07 Juan Luis Millan Hidalgo <juanluismillanhidalgo@gmail.com>

¿Eliminar esta clave del anillo? (s/N) s
gpg: clave "Luis" no encontrada: Not found
gpg: Luis: delete key failed: Not found

javier@debian:~/.gnupg$ gpg --list-keys
/home/javier/.gnupg/pubring.kbx
-------------------------------
pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
      17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182
uid        [  absoluta ] Javier Pérez Hidalgo <reyole111@gmail.com>
sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]

pub   rsa3072 2020-10-13 [SC] [caduca: 2022-10-13]
      B02B578465B0756DFD271C733E0DA17912B9A4F8
uid        [desconocida] Álvaro Vaca Ferreras <avacaferreras@gmail.com>
sub   rsa3072 2020-10-13 [E] [caduca: 2022-10-13]
</pre>

Aquí muestro como he borrado su clave de mi anillo. A su vez, él también ha borrado mi clave de su anillo, y ahora voy a cifrar un archivo con mi privada que él no podrá descifrar.

<pre>
javier@debian:~/Descargas$ touch prueba_para_juanlu_2.txt

javier@debian:~/Descargas$ nano prueba_para_juanlu_2.txt

javier@debian:~/Descargas$ gpg -r reyole111@gmail.com --encrypt prueba_para_juanlu_2.txt
</pre>

Juanlu me envía un elemento cifrado llamado `hola1.txt.gpg`, voy a intentar descifrarlo.

<pre>
javier@debian:~/Descargas$ ls
hola1.txt.gpg  Imágenes             prueba_para_juanlu_2.txt      prueba_para_juanlu.txt
hola.txt.gpg   juanluis_millan.asc  prueba_para_juanlu_2.txt.gpg  prueba_para_juanlu.txt.gpg

javier@debian:~/Descargas$ gpg --decrypt hola1.txt.gpg
gpg: cifrado con clave RSA, ID 988EDEB8C4FF299C
gpg: descifrado fallido: No secret key
</pre>

Aquí vemos como me da error y me dice que no puedo descifrarlo porque no poseo la clave correcta.

**5. Para terminar, indica los comandos necesarios para borrar las claves públicas y privadas que posees.**

Para borrar cualquier clave pública:

<pre>
gpg --delete-key "(identificador)"
</pre>

Para borrar cualquier clave privada:

<pre>
gpg --delete-secret-key "(identificador)"
</pre>


### Tarea 4: Exportar clave a un servidor público de claves PGP.

Para distribuir las claves públicas es mucho más habitual utilizar un servidor específico para distribuirlas, que permite a los clientes añadir las claves públicas a sus anillos de forma mucho más sencilla.

**1. Genera la clave de revocación de tu clave pública para utilizarla en caso de que haya problemas.**

Voy a generar la clave de revocación de mi clave pública.

<pre>
javier@debian:~/.gnupg$ gpg -k
/home/javier/.gnupg/pubring.kbx
-------------------------------
pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
      17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182
uid        [  absoluta ] Javier Pérez Hidalgo <reyole111@gmail.com>
sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]

pub   rsa3072 2020-10-13 [SC] [caduca: 2022-10-13]
      B02B578465B0756DFD271C733E0DA17912B9A4F8
uid        [desconocida] Álvaro Vaca Ferreras <avacaferreras@gmail.com>
sub   rsa3072 2020-10-13 [E] [caduca: 2022-10-13]

javier@debian:~/.gnupg$ gpg --output javier_perez_hidalgo_revocacion.asc --gen-revoke 17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182

sec  rsa3072/E446ACC5CFC7D182 2020-10-06 Javier Pérez Hidalgo <reyole111@gmail.com>

¿Crear un certificado de revocación para esta clave? (s/N) s
Por favor elija una razón para la revocación:
  0 = No se dio ninguna razón
  1 = La clave ha sido comprometida
  2 = La clave ha sido reemplazada
  3 = La clave ya no está en uso
  Q = Cancelar
(Probablemente quería seleccionar 1 aquí)
¿Su decisión? 1
Introduzca una descripción opcional; acábela con una línea vacía:

Razón para la revocación: La clave ha sido comprometida
(No se dió descripción)
¿Es correcto? (s/N) s
se fuerza salida con armadura ASCII.
Certificado de revocación creado.

Por favor consérvelo en un medio que pueda esconder; si alguien consigue
acceso a este certificado puede usarlo para inutilizar su clave.
Es inteligente imprimir este certificado y guardarlo en otro lugar, por
si acaso su medio resulta imposible de leer. Pero precaución: ¡el sistema
de impresión de su máquina podría almacenar los datos y hacerlos accesibles
a otras personas!
</pre>

**2. Exporta tu clave pública al servidor `pgp.rediris.es` .**

El servidor `pgp.rediris.es` no funcionaba correctamente en este momento por tanto la he enviado a este otro servidor: `keys.gnupg.net`.

<pre>
javier@debian:~/.gnupg$ gpg --keyserver keys.gnupg.net --send-key 17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182
gpg: enviando clave E446ACC5CFC7D182 a hkp://hkps.pool.sks-keyservers.net
</pre>

**3. Borra la clave pública de alguno de tus compañeros de clase e impórtala ahora del servidor público de rediris.**

Voy a intentar importar la clave de Juanlu que previamente ha subido a este servidor:

<pre>
javier@debian:~/.gnupg$ gpg --recv-keys --keyserver keys.gnupg.net 4C220919DD2364BED7D49C3215E1B16E8352B9BB
gpg: clave 15E1B16E8352B9BB: clave pública "Juan Luis Millan Hidalgo <juanluismillanhidalgo@gmail.com>" importada
gpg: Cantidad total procesada: 1
gpg:               importadas: 1
</pre>

Vemos como la hemos importado correctamente a nuestro anillo de claves.

### Tarea 5: Cifrado asimétrico con openssl.

En esta ocasión vamos a cifrar nuestros ficheros de forma asimétrica utilizando la herramienta openssl.

**1. Genera un par de claves (pública y privada).**

Para generar un par de claves openssl:

<pre>
javier@debian:~$ openssl genrsa -aes128 -out javier_perez_hidalgo_key.pem 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
...........+++++
.................................+++++
e is 65537 (0x010001)
Enter pass phrase for javier_perez_hidalgo_key.pem:
Verifying - Enter pass phrase for javier_perez_hidalgo_key.pem:

javier@debian:~$ ls
 Descargas    Escritorio                     Música       Vagrant           virtualenv
 Documentos   Imágenes                       Plantillas   Vídeos
 Dropbox      javier_perez_hidalgo_key.pem   Público     'VirtualBox VMs'
</pre>

<pre>
javier@debian:~$ openssl rsa -in javier_perez_hidalgo_key.pem -out javier_perez_hidalgo_key.pub.pem -outform PEM -pubout
Enter pass phrase for javier_perez_hidalgo_key.pem:
writing RSA key
</pre>

Podemos ver como las hemos creado correctamente.

**2. Envía tu clave pública a un compañero.**

Le he enviado mi clave pública `javier_perez_hidalgo_key.pub.pem` a Juanlu, y él me ha pasado la suya `key.pub.pem`.

**3. Utilizando la clave pública cifra un fichero de texto y envíalo a tu compañero.**

Voy a crear un fichero de texto, lo voy a cifrar con la pública de Juanlu y se lo voy a enviar.

<pre>
javier@debian:~/Descargas$ touch prueba_juanlu_openssl.txt

javier@debian:~/Descargas$ nano prueba_juanlu_openssl.txt

javier@debian:~/Descargas$ openssl rsautl -pubin -encrypt -in prueba_juanlu_openssl.txt -out prueba_juanlu_openssl.enc -inkey key.pub.pem

javier@debian:~/Descargas$ ls
hola1.txt.gpg        key.pub.pem                prueba_para_juanlu_2.txt.gpg
hola.txt.gpg         prueba_juanlu_openssl.enc  prueba_para_juanlu.txt
Imágenes             prueba_juanlu_openssl.txt  prueba_para_juanlu.txt.gpg
juanluis_millan.asc  prueba_para_juanlu_2.txt
</pre>

**4. Tu compañero te ha mandado un fichero cifrado, muestra el proceso para el descifrado.**

Juanlu me acaba de enviar un fichero cifrado supuestamente con mi clave pública, por tanto yo no tendría que tener ningún problema a la hora de descifrarlo. El archivo se llama `holaejemplo.enc`.

<pre>
javier@debian:~/Descargas$ ls
hola1.txt.gpg    Imágenes             prueba_juanlu_openssl.enc  prueba_para_juanlu_2.txt.gpg
holaejemplo.enc  juanluis_millan.asc  prueba_juanlu_openssl.txt  prueba_para_juanlu.txt
hola.txt.gpg     key.pub.pem          prueba_para_juanlu_2.txt   prueba_para_juanlu.txt.gpg

javier@debian:~/Descargas$ openssl rsautl -decrypt -inkey ../javier_perez_hidalgo_key.pem -in holaejemplo.enc -out holaejemplo.dec
Enter pass phrase for ../javier_perez_hidalgo_key.pem:

javier@debian:~/Descargas$ cat holaejemplo.dec
hola compañero javier
</pre>

Vemos como lo he descifrado y he podido leer su mensaje.
