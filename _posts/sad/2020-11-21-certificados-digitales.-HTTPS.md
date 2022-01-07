---
layout: post
---
Certificados digitales. HTTPS
Date: 2020/11/21
Category: Seguridad y Alta Disponibilidad
Header_Cover: theme/images/banner-seguridad.jpg
Tags: Criptografía, Certificado digital, HTTPS, SSL, Apache, Nginx

## Certificado digital de persona física

#### Tarea 1: Instalación del certificado

**1. Una vez que hayas obtenido tu certificado, explica brevemente como se instala en tu navegador favorito.**

Una vez hemos solicitado y descargado nuestro certificado digital, se nos guardará en forma de una especie de carpeta/fichero que son los que tendremos que utilizar.

En mi caso utilizo **Mozilla Firefox**, por tanto lo voy a instalar en este navegador.

Nos dirigimos al menú de **Preferencias** del navegador, y en el apartado de **Privacidad & Seguridad**, nos desplazamos hasta la último opción, llamada **Certificados**. Aquí haremos *click* en **Ver certificados** y se nos abrirá una pequeña ventana en la que tendremos distintas secciones. Nos interesa la sección **Sus certificados**, y aquí haremos *click* en **Importar** y se nos abrirá una ventana donde tendremos que seleccionar el certificado que hemos descargado antes, y con esto, ya tendremos instalado nuestro certificado en nuestro navegador.

**2. Muestra una captura de pantalla donde se vea las preferencias del navegador donde se ve instalado tu certificado.**

![.](images/sad_certificados_digitales_HTTPS/certinstalado.png)

**3. ¿Cómo puedes hacer una copia de tu certificado? ¿Como vas a realizar la copia de seguridad de tu certificado? Razona la respuesta.**

El proceso para crear una copia de un certificado en bastante sencilla.

En la ventana de la imagen anterior, seleccionamos nuestro certificado, y seleccionamos la opción **Hacer copia...**, se nos abrirá una ventana donde debemos especificar en que ruta de nuestro PC queremos guardar esta copia, hecho esto, nos pedirá introducir una contraseña para poder restaurar esta copia en otro navegador/dispositivo. Con esto ya habremos hecho una copia del certificado instalado.

**4. Investiga como exportar la clave pública de tu certificado.**

Para exportar nuestra clave pública, debemos hacer doble *click* en nuestro certificado, y se nos abrirá una nueva pestaña con la información del certificado. Nos dirigimos hasta el apartado **Información de clave pública** y aquí encontraremos nuestra clave pública y ya podremos exportarla y compartirla:

![.](images/sad_certificados_digitales_HTTPS/infoclavepublica.png)


#### Tarea 2: Validación del certificado

**1. Instala en tu ordenador el software [autofirma](https://firmaelectronica.gob.es/Home/Descargas.html) y desde la página de *VALIDe*, valida tu certificado. Muestra capturas de pantalla donde se comprueba la validación.**

Para instalar **Autofirma** sobre *Debian*, tenemos que tener en cuenta que necesitamos tener instalado **Java**. Para instalar *Java* ejecutamos:

<pre>
sudo apt install default-jdk openjdk-11-jdk libnss3-tools -y
</pre>

Verificamos la versión instalada:

<pre>
javier@debian:~/Descargas/AutoFirma_Linux$ java -version
openjdk version "11.0.9" 2020-10-20
OpenJDK Runtime Environment (build 11.0.9+11-post-Debian-1deb10u1)
OpenJDK 64-Bit Server VM (build 11.0.9+11-post-Debian-1deb10u1, mixed mode, sharing)
</pre>

Ahora nos descargamos el programa de instalación de *Autofirma* desde este [enlace](https://firmaelectronica.gob.es/Home/Descargas.html).

Una vez descargado y descomprimido, instalamos el paquete `.deb`:

<pre>
sudo dpkg -i AutoFirma_1_6_5.deb
</pre>

Y ya tendríamos instalado **Autofirma**. Comprobamos que lo podemos abrir:

![.](images/sad_certificados_digitales_HTTPS/autofirma.png)

Para validar nuestro certificado, nos dirigimos a la página de **VALIDe** y al apartado **[Validar Certificado](https://valide.redsara.es/valide/validarCertificado/ejecutar.html)**. Seleccionamos el certificado mediante el software de *Autofirma*:

 ![.](images/sad_certificados_digitales_HTTPS/certautofirma.png)

Seleccionamos nuestro certificado y hacemos *click* en **Validar**, y obtendremos una respuesta sobre sí el certificado es válido o no. En mi caso:

![.](images/sad_certificados_digitales_HTTPS/certvalido.png)


#### Tarea 3: Firma electrónica

**1. Utilizando la página *VALIDe* y el programa *Autofirma*, firma un documento con tu certificado y envíalo por correo a un compañero.**

Con **Autofirma**:

Para firmar un documento con nuestro certificado y el programa *Autofirma*, seleccionamos **Seleccionar ficheros a firmar**:

![.](images/sad_certificados_digitales_HTTPS/autofirma.png)

Seleccionamos el documento que deseamos firmar:

![.](images/sad_certificados_digitales_HTTPS/autofirmaseleccfichero.png)

Seleccionamos con que certificado queremos firmar el documento:

![.](images/sad_certificados_digitales_HTTPS/autofirmaselecccert.png)

Guardamos el fichero ya firmado con nuestro certificado:

![.](images/sad_certificados_digitales_HTTPS/autofirmaguardarficherofirm.png)

Vemos que ya hemos firmado y guardado el documento firmado:

![.](images/sad_certificados_digitales_HTTPS/autofirmaficherofirm.png)

Con **Valide**:

Para firmar un documento con mi certificado y el programa *Valide*, nos dirigimos a la página de *VALIDe* y al apartado **[Realizar Firma](https://valide.redsara.es/valide/firmar/ejecutar.html)**.

![.](images/sad_certificados_digitales_HTTPS/validepagfirmar.png)

Seleccionamos el documento que deseamos firmar:

![.](images/sad_certificados_digitales_HTTPS/valideseleccfichero.png)

Seleccionamos con que certificado queremos firmar el documento:

![.](images/sad_certificados_digitales_HTTPS/valideselecccert.png)

Vemos que ya hemos firmado el documento pero aún no lo hemos guardado en nuestro equipo:

![.](images/sad_certificados_digitales_HTTPS/valideficherofirm.png)

Guardamos el fichero ya firmado con nuestro certificado:

![.](images/sad_certificados_digitales_HTTPS/valideguardarficherofirm.png)

Vemos que ya hemos firmado y guardado el documento firmado:

![.](images/sad_certificados_digitales_HTTPS/valideficherofirmyguardado.png)

Ya dispongo de los documentos firmados, llamados `documentofirmadoautofirma.txt_signed.csig` y `documentofirmadovalide.txt.csig`, y se lo envío a mi compañero [Álvaro](https://www.instagram.com/whosalvr/).

**2. Tu debes recibir otro documento firmado por un compañero y utilizando las herramientas anteriores debes visualizar la firma (Visualizar Firma) y (Verificar Firma). ¿Puedes verificar la firma aunque no tengas la clave pública de tu compañero? ¿Es necesario estar conectado a internet para hacer la validación de la firma? Razona tus respuestas.**

He recibido de Álvaro los documentos `ficheroautofirma.txt_signed.csig` y `ficherovalide.txt_signed.csig`.

Con **Autofirma**:

En el programa *Autofirma* seleccionamos la opción **Ver firma**:

![.](images/sad_certificados_digitales_HTTPS/autofirmaverificarfirma.png)

Seleccionamos el fichero del cuál queremos ver la firma:

![.](images/sad_certificados_digitales_HTTPS/autofirmaverificarfirmaseleccfichero.png)

Nos sale que está firmado por Álvaro:

![.](images/sad_certificados_digitales_HTTPS/autofirmafirmaverificada.png)

Con **Valide**:

Para verificar la firma de un documento y el programa *Valide*, nos dirigimos a la página de *VALIDe* y al apartado **[Validar Firma](https://valide.redsara.es/valide/validarFirma/ejecutar.html)**.

Seleccionamos el fichero del cuál queremos ver la firma:

![.](images/sad_certificados_digitales_HTTPS/valideverificarfirma.png)

Nos sale que también está firmado por Álvaro:

![.](images/sad_certificados_digitales_HTTPS/validefirmaverificada.png)

**3. Entre dos compañeros, firmar los dos un documento, verificar la firma para comprobar que está firmado por los dos.**

Tanto yo como Álvaro hemos firmado el mismo documento, por tanto si verificamos la firma de éste:

![.](images/sad_certificados_digitales_HTTPS/autofirmafirmadelosdosverificada.png)

Vemos que sale firmado por ambos.


#### Tarea 4: Autentificación

**1. Utilizando tu certificado accede a alguna página de la administración pública (cita médica, becas, puntos del carnet,…). Entrega capturas de pantalla donde se demuestre el acceso a ellas.**

Voy a intentar consultar mis trámites abiertos en el Ministerio de Educación, utilizando mi certificado digital.

Me dirijo a la web llamada **[Sede Electrónica](https://sede.educacion.gob.es/portada.html)**, y aquí indico que deseo acceder a mis trámites:

![.](images/sad_certificados_digitales_HTTPS/sedeelectronica.png)

Vemos que tenemos distintas posibilidades para identificarnos, yo selecciono **Clave**:

![.](images/sad_certificados_digitales_HTTPS/sedeelectronicaacceso.png)

En esta ventana selecciono **Certificado Electrónico**.

![.](images/sad_certificados_digitales_HTTPS/sedeelectronicacertdigital.png)

Como tengo instalado mi certificado en este navegador, me lo reconoce automáticamente y me pregunta si quiero acceder:

![.](images/sad_certificados_digitales_HTTPS/sedeelectronicaverificacion.png)

Le digo que sí y automáticamente nos hemos identificado con nuestra certificado digital y nos proporciona la siguiente información:

![.](images/sad_certificados_digitales_HTTPS/sedeelectronicapag.png)

Podemos ver que hemos accedido correctamente y podemos ver la solicitud de mi beca por ejemplo, y que en la parte inferior nos sale un mensaje que nos indica que he accedido mediante clave (certificado digital).


## HTTPS / SSL

**Antes de hacer esta práctica vamos a crear una página web (puedes usar una página estática o instalar una aplicación web) en un servidor web apache2 que se acceda con el nombre `tunombre.iesgn.org`.**

#### Tarea 1: Certificado autofirmado

**Esta práctica la vamos a realizar con un compañero. En un primer momento un alumno creará una Autoridad Certificadora y firmará un certificado para la página del otro alumno. Posteriormente se volverá a realizar la práctica con los roles cambiados.**

**Para hacer esta práctica puedes buscar información en internet, algunos enlaces interesantes:**

- [Phil’s X509/SSL Guide](https://www.phildev.net/ssl/)
- [How to setup your own CA with OpenSSL](https://gist.github.com/Soarez/9688998)
- [Crear autoridad certificadora (CA) y certificados autofirmados en Linux](https://blog.guillen.io/2018/09/29/crear-autoridad-certificadora-ca-y-certificados-autofirmados-en-linux/)

**El alumno que hace de Autoridad Certificadora deberá entregar una documentación donde explique los siguientes puntos:**

**1. Crear su autoridad certificadora (generar el certificado digital de la CA). Mostrar el fichero de configuración de la AC.**

Para crear una **Autoridad Certificadora** debemos crear esta estructura de directorios con esta serie de permisos y ficheros:

<pre>
root@https:~# mkdir CA

root@https:~# cd CA/

root@https:~/CA# mkdir ./{certsdb,certreqs,crl,private}

root@https:~/CA# chmod 700 ./private

root@https:~/CA# touch ./index.txt

root@https:~/CA# cp /usr/lib/ssl/openssl.cnf ./

root@https:~/CA# nano openssl.cnf
</pre>

Los directorios que hemos creado:

- **certsdb:** En él se almacenarán los certificados firmados.

- **certreqs:** En él se almacenarán los ficheros *.csr*.

- **crl:** En él se almacenarán los certificados revocados.

- **private:** En él se almacenará la clave privada de la CA. Por eso mismo, le hemos establecido permisos 700, para que solo pueda acceder el propietario.

El fichero `index.txt` actuará como base de datos.

Vemos que también hemos copiado el fichero `openssl.cnf`, y en él tendremos que editar las siguientes líneas y corregir las rutas, para que se use el directorio creado previamente para la Autoridad Certificadora.

En este bloque indicamos que el directorio se encuentra en `/root/CA`, que los certificados se van a guardar en `$dir/certsdb`,  la variable `$dir` ha referencia si nos fijamos a `/root/CA`, el certificado de la autoridad certificadora se va a encontrar en el directorio con el nombre `cacert.pem`, ...

<pre>
[ CA_default ]

dir             = /root/CA              # Where everything is kept
certs           = $dir/certsdb          # Where the issued certs are kept
crl_dir         = $dir/crl              # Where the issued crl are kept
database        = $dir/index.txt        # database index file.

                                        # several certs with same subject.
new_certs_dir   = $certs                # default place for new certs.

certificate     = $dir/cacert.pem       # The CA certificate
serial          = $dir/serial           # The current serial number
crlnumber       = $dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = $dir/crl.pem          # The current CRL
private_key     = $dir/private/cakey.pem# The private key
</pre>

El siguiente bloque a tener en cuenta en el fichero `openssl.cnf` es el siguiente, y en él vamos a introducir los datos básicos de la autoridad certificadora.

<pre>
[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = ES
countryName_min                 = 2
countryName_max                 = 2

stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = Sevilla

localityName                    = Locality Name (eg, city)
localityName_default            = Dos Hermanas

0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = JavierPerez Corp

organizationalUnitName          = Organizational Unit Name (eg, section)
organizationalUnitName_default  = Informatica

commonName                      = Common Name (e.g. server FQDN or YOUR name)
commonName_max                  = 64

emailAddress                    = Email Address
emailAddress_max                = 64
</pre>

Ya nos encontramos frente al último bloque a editar en este fichero `openssl.cnf`, y simplemente se trata de buscar las siguientes líneas y comentarlas, ya que a mí no me interesan, esto es según las necesidades y lo que busque cada uno:

<pre>
[ req_attributes ]
#challengePassword              = A challenge password
#challengePassword_min          = 4
#challengePassword_max          = 20

#unstructuredName               = An optional company name
</pre>

Una vez tenemos creada nuestra autoridad certificadora, vamos a generar un par de claves, y un fichero *.csr* que luego vamos a firmar con nuestra propia CA:

<pre>
root@https:~/CA# openssl req -new -newkey rsa:2048 -keyout private/cakey.pem -out careq.pem -config ./openssl.cnf
Generating a RSA private key
............................................+++++
..............................................................................+++++
writing new private key to 'private/cakey.pem'
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
Country Name (2 letter code) [ES]:
State or Province Name (full name) [Sevilla]:
Locality Name (eg, city) [Dos Hermanas]:
Organization Name (eg, company) [JavierPerez Corp]:
Organizational Unit Name (eg, section) [Informatica]:
Common Name (e.g. server FQDN or YOUR name) []:javier.debian
Email Address []:javierperezhidalgo01@gmail.com

root@https:~/CA#
</pre>

Firmamos nuestro propio fichero *.csr* con nuestra propia entidad certificadora. Esto lo hacemos para generar un fichero *.crt* que es el que vamos a enviar a nuestros clientes como certificado de la CA.

<pre>
root@https:~/CA# openssl ca -create_serial -out cacert.pem -days 365 -keyfile private/cakey.pem -selfsign -extensions v3_ca -config ./openssl.cnf -infiles careq.pem
Using configuration from ./openssl.cnf
Enter pass phrase for private/cakey.pem:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number:
            0a:7b:37:65:ef:20:c3:8c:e9:00:00:d2:54:7c:35:69:7c:0b:29:3d
        Validity
            Not Before: Nov 17 18:43:27 2020 GMT
            Not After : Nov 17 18:43:27 2021 GMT
        Subject:
            countryName               = ES
            stateOrProvinceName       = Sevilla
            organizationName          = JavierPerez Corp
            organizationalUnitName    = Informatica
            commonName                = javier.debian
            emailAddress              = javierperezhidalgo01@gmail.com
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                92:F5:19:9E:24:0D:30:B0:83:14:FA:D5:74:BC:25:79:0F:9F:19:CD
            X509v3 Authority Key Identifier:
                keyid:92:F5:19:9E:24:0D:30:B0:83:14:FA:D5:74:BC:25:79:0F:9F:19:CD

            X509v3 Basic Constraints: critical
                CA:TRUE
Certificate is to be certified until Nov 17 18:43:27 2021 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

root@https:~/CA#
</pre>

Nos ha generado un fichero `cacert.pem` que es el certificado de la autoridad certificadora.

**2. Debe recibir el fichero CSR (Solicitud de Firmar un Certificado) de su compañero, debe firmarlo y enviar el certificado generado a su compañero.**

He creado en mi máquina un usuario llamado `alvaro`, al que tiene acceso mi compañero para que me traslade su fichero *.csr*.

Una vez tenemos a nuestra disposición el fichero que queremos firmar, debemos moverlo a la carpeta `certreqs` creada anteriormente.

Ahora procedemos a firmar el documento y a generar el *.crt*.

<pre>
root@https:~/CA# openssl ca -config openssl.cnf -out certsdb/alvaro.crt -infiles certreqs/alvaro.csr
Using configuration from openssl.cnf
Enter pass phrase for /root/CA/private/cakey.pem:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number:
            0a:7b:37:65:ef:20:c3:8c:e9:00:00:d2:54:7c:35:69:7c:0b:29:3e
        Validity
            Not Before: Nov 17 18:48:00 2020 GMT
            Not After : Nov 17 18:48:00 2021 GMT
        Subject:
            countryName               = ES
            stateOrProvinceName       = Sevilla
            organizationName          = JavierPerez Corp
            organizationalUnitName    = Informatica
            commonName                = alvaro.iesgn.org
            emailAddress              = avacaferreras@gmail.com
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                6C:6E:4C:23:03:A7:E9:64:DC:0B:F3:5B:79:97:9A:2C:BE:FB:3D:22
            X509v3 Authority Key Identifier:
                keyid:92:F5:19:9E:24:0D:30:B0:83:14:FA:D5:74:BC:25:79:0F:9F:19:CD

Certificate is to be certified until Nov 17 18:48:00 2021 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

root@https:~/CA#
</pre>

El fichero *.crt* obtenido, que es el fichero firmado por mi autoridad certificadora, se lo copio a Álvaro al usuario que he creado para él.

**3. ¿Qué otra información debes aportar a tu compañero para que éste configure de forma adecuada su servidor web con el certificado generado?**

Como yo estoy actuando como Autoridad Certificadora, le tengo que enviar a mi compañero el certificado de la entidad certificadora. Al igual que su *.crt*, se lo dejo en el usuario de mi máquina que he creado para que acceda él.

Por tanto, una vez hecho esto, Álvaro ya podría visualizar su página con *https*.

**El alumno que hace de administrador del servidor web, debe entregar una documentación que describa los siguientes puntos:**

**1. Crea una clave privada RSA de 4096 bits para identificar el servidor.**

Lo primero que hay que hacer es generar una clave privada:

<pre>
root@https:~# openssl genrsa 4096 > /etc/ssl/private/javi.key
Generating RSA private key, 4096 bit long modulus (2 primes)
................................................................................................................................................++++
............................++++
e is 65537 (0x010001)

root@https:~#
</pre>

**2. Utiliza la clave anterior para generar un CSR, considerando que deseas acceder al servidor tanto con el FQDN (`tunombre.iesgn.org`) como con el nombre de host (implica el uso de las extensiones `Alt Name`).**

Con la clave generada anteriormente, voy a generar un fichero `.csr` que tendré que enviar a Álvaro para que él me devuelva un fichero `.crt` firmado por su Autoridad Certificadora, con el cuál yo podré disponer de **https** en mi sitio web.

A la hora de generar el fichero `.csr` nos pedirá unos valores que debemos rellenar para identificar el certificado, respetando los apartados, **County Name**, **Locality Name**, **Organization Name** y **Organizational Unit Name**, que debo poner los valores que Álvaro haya especificado en el fichero *openssl.cnf* de su Autoridad Certificadora. En los apartados **Common Name** y **Email Address** debemos introducir nuestros datos personales, ya que eso es lo que diferenciara los distintos certificados.

<pre>
root@https:~# openssl req -new -key /etc/ssl/private/javi.key -out ./javi.csr
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
Organization Name (eg, company) [Internet Widgits Pty Ltd]:AlvaroVaca Corp
Organizational Unit Name (eg, section) []:Informatica
Common Name (e.g. server FQDN or YOUR name) []:javierpzh.iesgn.org
Email Address []:javierperezhidalgo01@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

root@https:~#
</pre>

**3. Envía la solicitud de firma a la entidad certificadora (su compañero).**

Álvaro también me ha creado un usuario en su máquina, al cuál yo tengo acceso, para que le envíe mi fichero *.csr*, y próximamente pueda copiarme, el fichero *.crt* que me devuelva junto con el certificado de su CA, a mi máquina.

Le envío mi *.csr*:

<pre>
root@https:~# scp javi.csr javi@172.22.200.186:/home/javi/
javi@172.22.200.186's password:
javi.csr                                                              100% 1801   980.4KB/s   00:00
</pre>

**4. Recibe como respuesta un certificado X.509 para el servidor firmado y el certificado de la autoridad certificadora.**

Copio de la máquina de Álvaro el fichero *.crt* y el llamado *cacert.pem* que es el certificado de su autoridad certificadora.

<pre>
root@https:~# scp javi@172.22.200.186:/home/javi/javier.crt ./
javi@172.22.200.186's password:
javier.crt                                                            100% 6284     1.9MB/s   00:00

root@https:~/CA# scp javi@172.22.200.186:/home/javi/cacert.pem ./
javi@172.22.200.186's password:
cacert.pem                                                            100% 4658     1.7MB/s   00:00
</pre>

**5. Configura tu servidor web con *https* en el puerto 443, haciendo que las peticiones *http* se redireccionen a *https* (forzar *https*).**

Lo primero que debemos hacer, como estamos trabajando en el *cloud*, es decir, en *OpenStack*, sería abrir el puerto **443**, que corresponde a **https**.

Lo abro:

![.](images/sad_certificados_digitales_HTTPS/puerto443.png)

Hecho esto, tenemos que almacenar los ficheros *.crt* y *.pem* en la ruta `/etc/ssl/certs/`, por tanto los movemos:

<pre>
root@https:~# ls
CA  javi.csr  javier.crt  cacert.pem

root@https:~# mv cacert.pem /etc/ssl/certs/

root@https:~# mv javier.crt /etc/ssl/certs/
</pre>

Tenemos que configurar *Apache* para que utilice los ficheros necesarios y verifique y fuerce el *https*. Primero vamos a editar el fichero de configuración del *virtualhost* de la página que hemos creado, y vamos a crear una redirección a *https* para que siempre accedamos por aquí. Introduzco esta línea:

<pre>
Redirect / https://javierpzh.iesgn.org/
</pre>

El fichero de configuración de mi *virtualhost* quedaría así:

<pre>
<\VirtualHost *:80>

        ServerName javierpzh.iesgn.org

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        Redirect / https://javierpzh.iesgn.org/

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

<\/VirtualHost>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres \, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Si nos fijamos en la ruta del **DocumentRoot**, vemos que he almacenado la página en `/var/www/html`, esto no es lo adecuado pero como solo estoy haciendo estas pruebas y realmente esta estructura no va a tener ninguna funcionalidad en un futuro, lo hago así por comodidad y rapidez. Recomiendo usar la ruta `/srv/www/...` para almacenar datos de sitios webs.

Ahora, en el fichero de configuración de la página con *https*, debemos introducir una serie de líneas como estas:

- **SSLCertificateFile:** indica donde se encuentra nuestro fichero *.crt* firmado por la autoridad.

- **SSLCertificateKeyFile:** indica donde se encuentra nuestra clave privada mediante la cuál generamos el archivo *.csr*.

- **SSLCACertificateFile:** indica donde se encuentra el certificado de la autoridad certificadora.

<pre>
...

		ServerAdmin webmaster@localhost

		ServerName javierpzh.iesgn.org

		DocumentRoot /var/www/html

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined

		SSLEngine on

		SSLCertificateFile	/etc/ssl/certs/javier.crt
		SSLCertificateKeyFile /etc/ssl/private/javi.key

    SSLCACertificateFile /etc/ssl/private/cacert.pem

...
</pre>

Una vez configurado, debemos habilitar la página e iniciar el **módulo SSL** de *Apache*:

<pre>
root@https:/etc/apache2/sites-available# a2ensite default-ssl.conf

root@https:/etc/apache2/sites-available# a2enmod ssl

root@https:/etc/apache2/sites-available# systemctl restart apache2
</pre>

Ya tendríamos nuestro sitio web configurado para que utilice *https* pero en nuestro navegador no poseemos el certificado de la autoridad certificadora que nos ha firmado, por tanto debemos añadir su certificado.

Para instalar el certificado en nuestro navegador, *Firefox* en mi caso, nos dirigimos a **Preferencias**, a la sección **Privacidad & Seguridad**, y al apartado **Certificados**, *clickamos* en **Ver certificados** y nos sale una ventana como esta:

![.](images/sad_certificados_digitales_HTTPS/importar.png)

Seleccionamos **Importar ...**, e importamos el fichero *cacert.pem*:

![.](images/sad_certificados_digitales_HTTPS/caalvaroconfiar.png)

Ya hemos importado el certificado de la entidad de Álvaro:

![.](images/sad_certificados_digitales_HTTPS/caalvaroinstalado.png)

Si ahora nos dirigimos a la dirección `javierpzh.iesgn.org`:

![.](images/sad_certificados_digitales_HTTPS/httpsapache.png)

Vemos que nos ha redirigido automáticamente por *https* y además podemos ver como tenemos la confianza de la entidad de Álvaro.

**6. Instala ahora un servidor Nginx, y realiza la misma configuración que anteriormente para que se sirva la página con *HTTPS*.**

Vamos realizar el mismo proceso pero con un servidor web **Nginx**. En este proceso, voy a ser más directo y voy a utilizar los mismos ficheros que en el apartado anterior, por tanto únicamente nos hace falta configurar *Nginx*.

En primer lugar vamos a parar el servicio de *Apache*:

<pre>
systemctl stop apache2
</pre>

Instalamos *Nginx*:

<pre>
apt install nginx -y
</pre>

Editamos el fichero *virtualhost* por defecto (aunque lo recomendable es crear un *virtualhost* diferente) y le forzamos a que utilice *https* y queda con este aspecto:

<pre>
server {
	listen 80;
	server_name javierpzh.iesgn.org;
	return 301 https://$host$request_uri;
}

server {
	 listen 443;

	server_name javierpzh.iesgn.org;

	root /var/www/html;

	index index.html index.htm index.nginx-debian.html;

	ssl on;
	ssl_certificate /etc/ssl/certs/javier.crt;
	ssl_certificate_key /etc/ssl/private/javi.key;

	location / {
		try_files $uri $uri/ =404;
	}

}
</pre>

Nos aseguramos que esté habilitado para *Nginx*:

<pre>
root@https:/etc/nginx/sites-available# ls -l /etc/nginx/sites-enabled/
total 0
lrwxrwxrwx 1 root root 34 Nov 21 12:32 default -> /etc/nginx/sites-available/default
</pre>

Si no lo está, lo habilitamos:

<pre>
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
</pre>

Reiniciamos el servicio:

<pre>
systemctl restart nginx.service
</pre>

En el navegador nos introducimos la dirección `javierpzh.iesgn.org`:

![.](images/sad_certificados_digitales_HTTPS/httpsnginx.png)

Vemos que nos ha redirigido automáticamente por *https* y además podemos ver como tenemos la confianza de la entidad de Álvaro, esta vez utilizando un servidor web *Nginx*.
