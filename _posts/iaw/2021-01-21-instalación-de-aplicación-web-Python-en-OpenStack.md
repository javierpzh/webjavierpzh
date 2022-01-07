---
layout: post
---

**En este *post* vamos a realizar la instalación de un *CMS Python* basado en *Django*. Puedes encontrar varios en el siguiente [enlace](https://djangopackages.org/grids/g/cms/).**

En primer lugar, me gustaría aclarar un poco cuál va a ser el entorno de trabajo, y es que el escenario sobre el que vamos a trabajar, ha sido construido en diferentes *posts* previamente elaborados. Los dejo ordenados a continuación por si te interesa:

- [Creación del escenario de trabajo en OpenStack](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html)
- [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html)
- [Servidores OpenStack: DNS, Web y Base de Datos](https://javierpzh.github.io/servidores-openstack-dns-web-y-base-de-datos.html)

Comprendido esto, voy a realizar la instalación/configuración en un entorno de desarrollo, que será mi propio equipo, donde utilizaré una base de datos **sqlite3** como veremos posteriormente, y una vez que todo se encuentre completamente listo lo trasladaré a mi entorno de producción, es decir, al escenario de OpenStack, donde como ya sabemos, se encuentra una base de datos **MySQL**.

Utilizaremos un repositorio de *GitHub* en el que se van a ir guardando los ficheros que se generen durante la instalación del *CMS*. He creado un nuevo repositorio y lo voy a clonar en la dirección `entornos_virtuales`:

Para clonar dicho repositorio, obviamente necesitamos tener instalado el paquete `git`:

<pre>
apt install git -y
</pre>

Ahora sí, lo clonamos:

<pre>
javier@debian:~/entornos_virtuales$ git clone git@github.com:javierpzh/Web-Python-OpenStack.git
</pre>

En segundo lugar, vamos a crear el entorno virtual donde trabajaremos en el entorno de desarrollo, en mi caso, se encontrará en `entornos_virtuales/Web_Python_OpenStack`. Para crear un entorno virtual necesitamos tener instalado este paquete:

<pre>
apt install python3-venv -y
</pre>

Ya instalado, podemos crear el entorno virtual, y para ello, empleamos el siguiente comando:

<pre>
javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ python3 -m venv desarrollo
</pre>

Una vez creado, vamos a activarlo mediante el siguiente comando:

<pre>
javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ source desarrollo/bin/activate
</pre>

Si nos fijamos, vemos como el aspecto del *prompt* ha cambiado y ahora aparece el entorno virtual como activo:

<pre>
(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack$
</pre>

Para actualizar `pip`:

<pre>
pip install --upgrade pip
</pre>

Ya tendríamos el entorno virtual listo para trabajar con él.

Llegó el momento de decidir qué CMS instalaremos. En mi caso, he decidido instalar **Mezzanine**.

<pre>
(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ pip install mezzanine
</pre>

Una vez instalado, vamos a crear nuestra web/proyecto con el siguiente comando:

<pre>
(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ mezzanine-project appmezzanine
</pre>

Hecho esto, podremos ver como nos ha creado una carpeta con el nombre que hayamos decidido establecerle a nuestro proyecto. Dentro de esta carpeta podremos encontrar varios directorios/ficheros, pero el que nos interesa en este punto es el llamado `appmezzanine/local_settings.py`, ya que, en él se encuentra la configuración básica de la base de datos.

<pre>
(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine/appmezzanine$ ls
__init__.py  local_settings.py  settings.py  urls.py  wsgi.py
</pre>

Si lo observamos, podremos apreciar como nos muestra los detalles de la base de datos que utilizará por defecto, que es una **sqlite3**:

<pre>
DATABASES = {
    "default": {
        # Ends with "postgresql_psycopg2", "mysql", "sqlite3" or "oracle".
        "ENGINE": "django.db.backends.sqlite3",
        # DB name or path to database file if using sqlite3.
        "NAME": "dev.db",
        # Not used with sqlite3.
        "USER": "",
        # Not used with sqlite3.
        "PASSWORD": "",
        # Set to empty string for localhost. Not used with sqlite3.
        "HOST": "",
        # Set to empty string for default. Not used with sqlite3.
        "PORT": "",
    }
}
</pre>

Vamos a utilizar esta, ya que nos viene por defecto, pero en el entorno de producción hay que recordar que estamos utilizando una *MySQL*, por tanto, habría que migrarla a este gestor.

Comentado estos detalles, vamos a proceder a crear la propia aplicación, y para ello nos vamos a situar en el primer directorio y haremos uso del siguiente comando:

<pre>
(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine$ ls
appmezzanine  deploy  fabfile.py  manage.py  requirements.txt

(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine$ python manage.py createdb
Operations to perform:

...

Running migrations:

...

A site record is required.
Please enter the domain and optional port in the format 'domain:port'.
For example 'localhost:8000' or 'www.example.com'.
Hit enter to use the default (127.0.0.1:8000):

Creating default site record: 127.0.0.1:8000 ...


Creating default account ...

Username (leave blank to use 'javier'): javierpzh
Email address: javierperezhidalgo01@gmail.com
Password:
Password (again):
Superuser created successfully.

...
</pre>

Veremos como tras introducir nuestra información de administrador, se ejecutarán una serie de procesos que desembocarán en la creación de la nueva aplicación.

Probaremos a acceder a ella desde nuestro navegador, para ello, antes necesitaremos ejecutar un proceso para servirla localmente:

<pre>
(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine$ python manage.py runserver
              .....
          _d^^^^^^^^^b_
       .d''           ''b.
     .p'                'q.
    .d'                   'b.
   .d'                     'b.   * Mezzanine 4.3.1
   ::                       ::   * Django 1.11.29
  ::    M E Z Z A N I N E    ::  * Python 3.7.3
   ::                       ::   * SQLite 3.27.2
   'p.                     .q'   * Linux 4.19.0-13-amd64
    'p.                   .q'
     'b.                 .d'
       'q..          ..p'
          ^q........p^
              ''''

Performing system checks...

System check identified no issues (0 silenced).
January 21, 2021 - 12:47:34
Django version 1.11.29, using settings 'appmezzanine.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
</pre>

Si accedemos a la dirección `127.0.0.1:8000`:

![.](images/iaw_instalación_de_aplicación_web_Python/localhost.png)

Nuestra aplicación ya se está ejecutando. Ahora vamos a crear nuestro blog y vamos a personalizar un poco la web, para ello, nos *logueamos*:

![.](images/iaw_instalación_de_aplicación_web_Python/localhostlogin.png)

Y así accederemos al panel de administración:

![.](images/iaw_instalación_de_aplicación_web_Python/localhostadmin.png)

Una vez aquí, lo configuramos a nuestro gusto y una vez finalizado, podemos ver el resultado:

![.](images/iaw_instalación_de_aplicación_web_Python/localhostblog.png)

Es la hora de pasar esta aplicación al entorno de producción, para ello tendremos que realizar la copia de seguridad adecuada para restaurarla en este entorno. Como he comentado anteriormente, vamos a utilizar gestores de bases de datos distintos, por lo que, tendremos que buscar una solución para solventar esto.

Es por ello que existe el comando:

<pre>
python manage.py dumpdata
</pre>

Este comando lo que hace es imprimirnos por pantalla toda la información almacenada en la base de datos en formato **.json**, es decir, información que se puede restaurar en **MySQL**. Genial, ya tendríamos el "problema" solventado, ya que con guardar la salida de dicho comando en un fichero tendríamos la copia de seguridad. Pues eso es lo que vamos a hacer con el siguiente comando:

<pre>
(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine$ python manage.py dumpdata> copiadeseguridad.json

(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine$ ls
appmezzanine  copiadeseguridad.json  deploy  dev.db  fabfile.py  manage.py  requirements.txt  static
</pre>

En el entorno de desarrollo ya hemos terminado nuestro trabajo, y si recordamos, íbamos a utilizar un repositorio de GitHub para almacenar esta información y descargarla en el entorno de desarrollo.

Almacenamos todos los nuevos ficheros, entre los que se encuentra la copia de seguridad:

<pre>
(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine$ git add * -f

...

(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine$ git commit -am "aplicación mezzanine"

...

(desarrollo) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/appmezzanine$ git push
Enumerando objetos: 18, listo.
Contando objetos: 100% (18/18), listo.
Compresión delta usando hasta 12 hilos
Comprimiendo objetos: 100% (15/15), listo.
Escribiendo objetos: 100% (18/18), 18.35 KiB | 9.18 MiB/s, listo.
Total 18 (delta 0), reusado 0 (delta 0)
To github.com:javierpzh/Web-Python-OpenStack.git
 * [new branch]      master -> master
</pre>

Ya en el entorno de producción, en **Quijote**, que es donde se encuentra el servidor web *Apache*, vamos a dirigirnos a la ruta `/var/www/` y clonaremos el repositorio, por lo que tenemos que tener instalado el paquete `git`:

<pre>
[root@quijote www]# dnf install git -y

[root@quijote www]# git clone https://github.com/javierpzh/Web-Python-OpenStack.git
Cloning into 'Web-Python-OpenStack'...
remote: Enumerating objects: 12105, done.
remote: Counting objects: 100% (12105/12105), done.
remote: Compressing objects: 100% (7711/7711), done.
remote: Total 12105 (delta 2845), reused 12102 (delta 2845), pack-reused 0
Receiving objects: 100% (12105/12105), 22.34 MiB | 6.47 MiB/s, done.
Resolving deltas: 100% (2845/2845), done.
Updating files: 100% (8886/8886), done.

[root@quijote www]# ls
cgi-bin  html  iesgn  Web-Python-OpenStack
</pre>

Vamos a crear un nuevo entorno virtual:

<pre>
[root@quijote Web-Python-OpenStack]# dnf install virtualenv -y

[root@quijote Web-Python-OpenStack]# python3 -m venv produccion

[root@quijote Web-Python-OpenStack]# source produccion/bin/activate

(produccion) [root@quijote Web-Python-OpenStack]# pip install --upgrade pip

(produccion) [root@quijote Web-Python-OpenStack]# pip install mezzanine
</pre>

Una vez tenemos nuestro entorno virtual en producción, vamos a crear el usuario **javiermezzanine** en el servidor *MariaDB* de *Sancho*, y posteriormente, la base de datos **mezzanine**, para almacenar los datos de la copia de seguridad:

<pre>
root@sancho:~# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 67
Server version: 10.3.25-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'javiermezzanine'@'10.0.2.6' IDENTIFIED BY 'contraseña';
Query OK, 0 rows affected (0.099 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'javiermezzanine'@'10.0.2.6';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> exit
Bye
</pre>

Una vez creado el usuario, vamos a probar a acceder a él desde *Quijote*, y crearemos la base de datos necesaria:

<pre>
[root@quijote ~]# mysql -h sancho -u javiermezzanine -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 69
Server version: 10.3.25-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE mezzanine;
Query OK, 1 row affected (0.003 sec)

MariaDB [(none)]> exit
Bye
</pre>

En este punto, nos faltaría por configurar la conexión entre nuestro servidor web, y nuestra aplicación *Python*, por lo que necesitamos un servidor de aplicaciones, en mi caso, he elegido **uWSGI**.

Lo instalamos en nuestro sistema *CentOS* con el siguiente comando:

<pre>
[root@quijote Web-Python-OpenStack]# dnf install python3-mod_wsgi -y
</pre>

En nuestro entorno virtual, debemos instalar el conector necesario para que nuestra aplicación pueda conectar con la base de datos *MySQL*, para ello:

<pre>
(produccion) [root@quijote Web-Python-OpenStack]# pip install mysql-connector-python
</pre>

De la misma manera que hicimos en nuestro sistema, debemos instalar en nuestro entorno de trabajo el servidor **uWSGI**:

<pre>
(produccion) [root@quijote Web-Python-OpenStack]# pip install uwsgi
</pre>

Seguramente nos reporte un error, para solventarlo, debemos asegurarnos que tenemos instalado en nuestro sistema los siguientes paquetes:

<pre>
dnf install gcc python3-devel -y
</pre>

En teoría, ya tendríamos disponible nuestro servidor de aplicaciones *uWSGI*, pero vamos a asegurarnos probando su funcionamiento:

<pre>
(produccion) [root@quijote Web-Python-OpenStack]# uwsgi --http :8080 --plugin python35 --chdir /var/www/Web-Python-OpenStack/appmezzanine/ --wsgi-file /var/www/Web-Python-OpenStack/appmezzanine/appmezzanine/wsgi.py --process 4 --threads 2 --master
</pre>

Una vez tenemos nuestro servidor de aplicaciones listo, tan sólo nos quedaría, restaurar la copia de seguridad en nuestra base de datos *MySQL*. Hay que decir, que para acceder a nuestra aplicación, debe estar ejecutándose el comando anterior.

Antes de realizar la restauración, vamos a configurar *Mezzanine* para que utilice dicha base de datos. Esta configuración se encuentra dentro del fichero `appmezzanine/settings.py`, en el siguiente bloque:

<pre>
DATABASES = {
    "default": {
        # Add "postgresql_psycopg2", "mysql", "sqlite3" or "oracle".
        "ENGINE": "django.db.backends.mysql",
        # DB name or path to database file if using sqlite3.
        "NAME": "mezzanine",
        # Not used with sqlite3.
        "USER": "javiermezzanine",
        # Not used with sqlite3.
        "PASSWORD": "contraseña",
        # Set to empty string for localhost. Not used with sqlite3.
        "HOST": "10.0.1.8",
        # Set to empty string for default. Not used with sqlite3.
        "PORT": "3306",
    }
}
</pre>

En este fichero, también tenemos que establecer en la directiva **ALLOWED_HOSTS**, el valor **"*"**, ya que en mi caso deseo que pueda acceder quien quiera, de manera que quedaría así:

<pre>
ALLOWED_HOSTS = ["*"]
</pre>

Es importante asegurarnos que no poseemos el fichero llamado `local_settings.py`, ya que sino, la configuración realizada en el fichero `settings.py` la ignorará, y buscara los recursos de manera local.

Debemos realizar una modificación en un fichero que se encuentra dentro del directorio de nuestro entorno virtual, en mi caso, en la ruta `/produccion/lib64/python3.6/site-packages/django/conf/__init__.py`. En él debemos comentar el siguiente bloque:

<pre>
if not self.SECRET_KEY:
 ImproperlyConfigured("The SECRET_KEY setting must not be empty.")
</pre>

Hecho esto, es hora de crear las tablas en nuestra base de datos mediante el comando `python manage.py migrate`:

<pre>
(produccion) [root@quijote appmezzanine]# python manage.py migrate
/var/www/Web-Python-OpenStack/produccion/lib64/python3.6/site-packages/mezzanine/utils/conf.py:65: UserWarning: You haven't defined the ALLOWED_HOSTS settings, which Django requires. Will fall back to the domains configured as sites.
  warn("You haven't defined the ALLOWED_HOSTS settings, which "
Operations to perform:
  Apply all migrations: admin, auth, blog, conf, contenttypes, core, django_comments, forms, galleries, generic, pages, redirects, sessions, sites, twitter
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying contenttypes.0002_remove_content_type_name... OK
  Applying auth.0002_alter_permission_name_max_length... OK
  Applying auth.0003_alter_user_email_max_length... OK
  Applying auth.0004_alter_user_username_opts... OK
  Applying auth.0005_alter_user_last_login_null... OK
  Applying auth.0006_require_contenttypes_0002... OK
  Applying auth.0007_alter_validators_add_error_messages... OK
  Applying auth.0008_alter_user_username_max_length... OK
  Applying sites.0001_initial... OK
  Applying blog.0001_initial... OK
  Applying blog.0002_auto_20150527_1555... OK
  Applying blog.0003_auto_20170411_0504... OK
  Applying conf.0001_initial... OK
  Applying core.0001_initial... OK
  Applying core.0002_auto_20150414_2140... OK
  Applying django_comments.0001_initial... OK
  Applying django_comments.0002_update_user_email_field_length... OK
  Applying django_comments.0003_add_submit_date_index... OK
  Applying pages.0001_initial... OK
  Applying forms.0001_initial... OK
  Applying forms.0002_auto_20141227_0224... OK
  Applying forms.0003_emailfield... OK
  Applying forms.0004_auto_20150517_0510... OK
  Applying forms.0005_auto_20151026_1600... OK
  Applying forms.0006_auto_20170425_2225... OK
  Applying galleries.0001_initial... OK
  Applying galleries.0002_auto_20141227_0224... OK
  Applying generic.0001_initial... OK
  Applying generic.0002_auto_20141227_0224... OK
  Applying generic.0003_auto_20170411_0504... OK
  Applying pages.0002_auto_20141227_0224... OK
  Applying pages.0003_auto_20150527_1555... OK
  Applying pages.0004_auto_20170411_0504... OK
  Applying redirects.0001_initial... OK
  Applying sessions.0001_initial... OK
  Applying sites.0002_alter_domain_unique... OK
  Applying twitter.0001_initial... OK
</pre>

Creadas las tablas, podremos restaurar los datos de nuestra copia de seguridad. Para ello empleamos el siguiente comando:

<pre>
(produccion) [root@quijote appmezzanine]# python manage.py loaddata copiadeseguridad.json
Installed 126 object(s) from 1 fixture(s)
</pre>

Bien, ya tenemos restaurada la copia de seguridad en nuestra base de datos de producción, por lo que nos tocaría crear los ficheros *virtualhost*, que recordemos que se almacenan en el directorio `/etc/httpd/sites-availables`, tanto para el protocolo *HTTP* (puerto 80), como para *HTTPs* (puerto 443). Veremos primero el fichero para el puerto 80, que recibirá el nombre de `python.javierpzh.gonzalonazareno.conf` y tendrá este aspecto:

<pre>
<\VirtualHost *:80\>

    ServerName python.javierpzh.gonzalonazareno.org
    DocumentRoot /var/www/Web-Python-OpenStack/appmezzanine

    ErrorLog /var/www/iesgn/log/error.log
    CustomLog /var/www/iesgn/log/requests.log combined

    Redirect / https://python.javierpzh.gonzalonazareno.org

<\/VirtualHost\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

El fichero para el protocolo *HTTPs* se identifica como `python.javierpzh.gonzalonazareno.https.conf` e incluye estas líneas:

<pre>
<\VirtualHost *:443\>

    ServerName python.javierpzh.gonzalonazareno.org
    DocumentRoot /var/www/Web-Python-OpenStack/appmezzanine

    ErrorLog /var/www/iesgn/log/error.log
    CustomLog /var/www/iesgn/log/requests.log combined

    <\Directory /var/www/Web-Python-OpenStack/appmezzanine/static\>
      Require all granted
      Options FollowSymlinks
    <\/Directory\>

    ProxyPass / http://127.0.0.1:8080/

    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/wildcard.crt
    SSLCertificateKeyFile /etc/pki/tls/private/freston.key

<\/VirtualHost\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Como ya sabemos, una vez creados los *virtualhost*, para que el servidor web los sirva, debemos habilitarlos almacenándolos en el directorio `/etc/httpd/sites-enabled`, para ello crearemos dos enlaces simbólicos:

<pre>
[root@quijote sites-availables]# ln -s /etc/httpd/sites-availables/python.javierpzh.gonzalonazareno.conf /etc/httpd/sites-enabled/

[root@quijote sites-availables]# ln -s /etc/httpd/sites-availables/python.javierpzh.gonzalonazareno.https.conf /etc/httpd/sites-enabled/

[root@quijote sites-availables]# ls -l /etc/httpd/sites-enabled/
total 0
lrwxrwxrwx 1 root root 58 Jan 25 17:26 javierpzh.gonzalonazareno.conf -> /etc/httpd/sites-availables/javierpzh.gonzalonazareno.conf
lrwxrwxrwx 1 root root 64 Jan 25 17:25 javierpzh.gonzalonazareno.https.conf -> /etc/httpd/sites-availables/javierpzh.gonzalonazareno.https.conf
lrwxrwxrwx 1 root root 65 Jan 25 17:24 python.javierpzh.gonzalonazareno.conf -> /etc/httpd/sites-availables/python.javierpzh.gonzalonazareno.conf
lrwxrwxrwx 1 root root 71 Jan 25 17:24 python.javierpzh.gonzalonazareno.https.conf -> /etc/httpd/sites-availables/python.javierpzh.gonzalonazareno.https.conf
</pre>

Una vez terminados todos los cambios y configuraciones, reiniciamos el servidor web:

<pre>
systemctl restart httpd
</pre>

En este momento nuestro servidor *Apache* debería estar sirviendo *Mezzanine*, pero recordemos que *Quijote*, máquina donde se encuentra *Apache*, pertenece a la red DMZ de nuestro escenario, y accederemos a ella mediante *Dulcinea*. Esto quiere decir, que necesitaremos añadir un nuevo registro en la zona externa de nuestro DNS, instalado en *Freston*. De manera que ahora, el fichero de nuestra zona externa quedaría de tal manera:

<pre>
$TTL    86400
@       IN      SOA     dulcinea.javierpzh.gonzalonazareno.org. root.localhost. (
                        21012501        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      dulcinea.javierpzh.gonzalonazareno.org.

$ORIGIN javierpzh.gonzalonazareno.org.

dulcinea        IN      A       172.22.200.183
www             IN      CNAME   dulcinea
python          IN      CNAME   dulcinea

@       IN      MX 10   dulcinea.javierpzh.gonzalonazareno.org.
</pre>

Reiniciamos el servidor DNS:

<pre>
systemctl restart bind9
</pre>

Y ahora sí, llegó la hora de la verdad, vamos a probar a acceder a la dirección `python.javierpzh.gonzalonazareno.org` en nuestro navegador:

![.](images/iaw_instalación_de_aplicación_web_Python/produccionsinhojadeestilo.png)

Parece que nos sirve la aplicación pero podemos apreciar que no hace uso de las hojas de estilos. Eso es porque estamos utilizando el servidor *uWSGI* que solo ejecuta el código *Python*. De manera que tendríamos que realizar un **proxy inverso**, además, como aún no hemos importado las hojas de estilos de nuestra aplicación, vamos a ello:

<pre>
(produccion) [root@quijote appmezzanine]# python manage.py collectstatic
</pre>

Terminaremos añadiendo a nuestro *virtualhost* la siguiente línea para que haga uso del nuevo *proxy*:

<pre>
ProxyPass /static !
</pre>

Reiniciamos el servidor web para que vuelva a cargar la nueva configuración:

<pre>
systemctl restart httpd
</pre>

Volvemos a acceder a `python.javierpzh.gonzalonazareno.org`:

![.](images/iaw_instalación_de_aplicación_web_Python/produccionhojadeestilo.png)

Ahora sí parece estar funcionando totalmente. Vamos a dirigirnos al blog creado en el entorno de desarrollo para comprobar que todo está correcto:

![.](images/iaw_instalación_de_aplicación_web_Python/produccionhojadeestiloblog.png)

Efectivamente, el resultado es el esperado y por tanto damos por finalizado este *post*.
