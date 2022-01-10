---
layout: post
---

En este *post* vamos a instalar y configurar de manera adecuada un servidor de correos en una **VPS** alojada en **OVH**. Mi dominio es `iesgn15.es`. El nombre del servidor de correo será `mail.iesgn15.es` (este es el nombre que deberá aparecer en el registro MX).

#### Instalación

Para comenzar el artículo vamos a instalar las utilidades principales que necesitamos para crear nuestro servidor de correos. Empezaremos por instalar los paquetes `postfix` y `bsd-mailx` que corresponden al servidor y a las utilidades del cliente respectivamente.

<pre>
apt install postfix bsd-mailx -y
</pre>

Comencemos.


#### Gestión de correos desde el servidor

**1. Vamos a enviar un correo desde nuestro servidor local al exterior (Gmail).**

Antes de realizar este ejercicio, vamos a crear un registro de tipo **SPF** en nuestro DNS de OVH, esto le servirá a **Gmail** para identificar que nuestro correo no es **Spam**. He creado el siguiente registro:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/registrospf.png" />

Ahora vamos a probar a enviar un correo electrónico desde nuestro servidor local, para ello haremos uso de la herramienta `mail`:

<pre>
debian@vpsjavierpzh:~$ mail javierperezhidalgo01@gmail.com
Subject: Correo de prueba       
Este es el correo de prueba enviado desde mi servidor local
Cc:
</pre>

Parece que ya hemos enviado el correo, pero para asegurarnos vamos a visualizar los *logs* de nuestro servidor, que se encuentran en el fichero `/var/log/mail.log`:

<pre>
...
Jan 21 10:24:22 vpsjavierpzh postfix/pickup[24623]: A492F101017: uid=1000 from=<\debian\>
Jan 21 10:24:22 vpsjavierpzh postfix/cleanup[25286]: A492F101017: message-id=<\20210121092422.A492F101017@vpsjavierpzh.iesgn15.es\>
Jan 21 10:24:22 vpsjavierpzh postfix/qmgr[9341]: A492F101017: from=<\debian@iesgn15.es\>, size=488, nrcpt=1 (queue active)
Jan 21 10:24:30 vpsjavierpzh postfix/smtp[25289]: A492F101017: to=<\javierperezhidalgo01@gmail.com\>, relay=gmail-smtp-in.l.google.com[173.194.76.26]:25, delay=7.8, delays=0.05/0.01/0.26/7.5, dsn=2.0.0, status=sent (250 2.0.0 OK  1611221070 h17si4006834wmq.57 - gsmtp)
Jan 21 10:24:30 vpsjavierpzh postfix/qmgr[9341]: A492F101017: removed
...
</pre>

Podemos observar que nos muestra una serie de mensajes de los que podemos sacar que hemos enviado un correo desde `debian@iesgn15.es` hacia `javierperezhidalgo01@gmail.com` y que el estado es *sent*, por lo que en teoría el correo debería haber llegado correctamente. Si nos dirigimos a la bandeja de entrada del correo `javierperezhidalgo01@gmail.com`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correorecibidogmail.png" />

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correorecibidogmailinfo.png" />

Vemos que efectivamente hemos recibido el correo procedente de `debian@iesgn15.es`.

Antes de terminar, vamos a analizar más a fondo el código del correo, para ello hacemos *click* en *Mostrar original*:

<pre>
...
Received-SPF: pass (google.com: domain of debian@iesgn15.es designates 51.210.105.17 as permitted sender) client-ip=51.210.105.17;
...
</pre>

En estas líneas se aprecia como ha pasado correctamente y ha hecho uso del registro **SPF** y por tanto no nos muestra este mensaje como *Spam*.

**2. Vamos a enviar un correo desde el exterior (Gmail) a nuestro servidor local.**

Al igual que en la tarea anterior, antes de realizar este ejercicio, vamos a crear un registro de tipo **MX** en nuestro DNS de OVH. He creado el siguiente registro que apunta a su vez a un registro tipo *A*:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/registromx.png" />

Hecho esto, vamos a enviar un correo desde **Gmail** hacia `debian@iesgn15.es`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correoenviadogmail.png" />

Una vez enviado, vamos a comprobar que lo hayamos recibido en nuestro servidor local, para ello vamos a visualizar de nuevo los *logs* del fichero `/var/log/mail.log`:

<pre>
Jan 21 10:45:32 vpsjavierpzh postfix/smtpd[25717]: connect from mail-io1-f43.google.com[209.85.166.43]
Jan 21 10:45:33 vpsjavierpzh postfix/smtpd[25717]: 35244101016: client=mail-io1-f43.google.com[209.85.166.43]
Jan 21 10:45:33 vpsjavierpzh postfix/cleanup[25726]: 35244101016: message-id=<CAMu5ax_BkYemDjV=A1yf1wrDBZ6w_tHZ0Ws+tnPX+3k2TF5ghw@mail.gmail.com>
Jan 21 10:45:33 vpsjavierpzh postfix/qmgr[9341]: 35244101016: from=<javierperezhidalgo01@gmail.com>, size=2643, nrcpt=1 (queue active)
Jan 21 10:45:33 vpsjavierpzh postfix/local[25727]: 35244101016: to=<debian@iesgn15.es>, relay=local, delay=0.02, delays=0.01/0.01/0/0, dsn=2.0.0, status=sent (delivered to mailbox)
Jan 21 10:45:33 vpsjavierpzh postfix/qmgr[9341]: 35244101016: removed
Jan 21 10:45:33 vpsjavierpzh postfix/smtpd[25717]: disconnect from mail-io1-f43.google.com[209.85.166.43] ehlo=2 starttls=1 mail=1 rcpt=1 bdat=1 quit=1 commands=7
You have mail in /var/mail/debian
</pre>

Vaya, parece que tenemos un nuevo correo procedente de la dirección `javierperezhidalgo01@gmail.com` y lo ha almacenado en la ruta `/var/mail/debian`, así que vamos a verificarlo.

Para leer los nuevos correos, haremos uso de la herramienta `mail`.

<pre>
debian@vpsjavierpzh:~$ mail
Mail version 8.1.2 01/15/2001.  Type ? for help.
"/var/mail/debian": 1 message 1 new
\>N  1 javierperezhidalg  Thu Jan 21 10:45   54/2768  Correo de prueba
& 1
</pre>

Vemos que nos indica que tenemos un correo sin leer, si indicamos su número y lo leemos:

<pre>
Message 1:
From javierperezhidalgo01@gmail.com  Thu Jan 21 10:45:33 2021
X-Original-To: debian@iesgn15.es

...

Subject: Correo de prueba
To: debian@iesgn15.es
Content-Type:

...

Este es el correo de prueba enviado desde Gmail

...
</pre>

Efectivamente hemos recibido el correo.

Una vez leído, salimos del programa y vemos que guarda el correo en la dirección `/home/debian/mbox`:

<pre>
& q
Saved 1 message in /home/debian/mbox
</pre>

Explicado esto, vamos a pasar con el siguiente ejercicio.


#### Uso de alias y redirecciones

**3. Uso de alias y redirecciones.**

Vamos a comprobar como los procesos del servidor pueden mandar correos para informar sobre su estado. Por ejemplo cada vez que se ejecuta una tarea `cron` podemos enviar un correo informando del resultado. Normalmente estos correos se mandan al usuario **root** del servidor, para ello:

<pre>
crontab -e
</pre>

E indico donde se envía el correo:

<pre>
MAILTO = root
</pre>

Voy a añadir una nueva tarea en el *cron* para ver como se manda el correo cuando se lleve dicha tarea. Añado la siguiente línea a mi *crontab*:

<pre>
40 18 * * * apt update && apt upgrade -y
</pre>

Esta tarea lo que hará básicamente es una actualización de todos los paquetes que haya instalados en el sistema, y se llevará a cabo todos los días a las 18:40.

Al cerrar y guardar nuestro *crontab* apreciaremos la siguiente salida que indica que hemos realizado cambios en él:

<pre>
root@vpsjavierpzh:~# crontab -e
crontab: installing new crontab
</pre>

Aún queda algo de tiempo hasta las 18:40, lo que me da margen para configurar una serie de **alias** y **redirecciones** para hacer llegar esos correos a nuestro correo personal.

En primer lugar vamos a configurar un nuevo **alias**, para que los correos que tengan como destinatario al usuario **root**, también lleguen al buzón del usuario **debian**. Para ello vamos a editar el fichero `/etc/aliases` y añadiremos la siguiente línea:

<pre>
root: debian
</pre>

De manera que el contenido total del fichero `/etc/aliases` sería:

<pre>
# See man 5 aliases for format
postmaster:    root
root: debian
</pre>

Cuando se modifica este fichero, debemos ejecutar el siguiente comando para aplicar los cambios:

<pre>
newaliases
</pre>

Hecho esto, vamos a enviar un correo desde **Gmail** hacia `root@iesgn15.es`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correoenviadogmailparareenvioadebian.png" />

Una vez enviado, vamos a comprobar que lo hayamos recibido en nuestro servidor local, en el usuario **debian**. Para leer los nuevos correos, haremos uso de la herramienta `mail` en el usuario *debian*.

<pre>
debian@vpsjavierpzh:~$ mail
Mail version 8.1.2 01/15/2001.  Type ? for help.
"/var/mail/debian": 2 messages 2 new
...
\>N  2 javierperezhidalg  Tue Feb  2 13:53   54/2752  =?UTF-8?Q?prueba_de_reenv=C3=ADo?=
 & 2
</pre>

Vemos que nos indica que tenemos dos correos sin leer (el primero es una prueba), si indicamos su número, en este caso el 2, y lo leemos:

<pre>
Message 2:
From javierperezhidalgo01@gmail.com  Tue Feb  2 13:53:29 2021
X-Original-To: root@iesgn15.es

...

Subject: =?UTF-8?Q?prueba_de_reenv=C3=ADo?=
To: root@iesgn15.es
Content-Type:

...

hola, llega al usuario debian?

...
</pre>

Efectivamente hemos recibido el correo en el usuario *debian* y podemos apreciar que el destinatario del correo es **root**, por tanto el alias está bien configurado.

Pasamos a realizar una redirección. Las redirecciones se utilizan para enviar los correos que lleguen a un usuario, a una cuenta de correo externa. Para usuarios reales, las redirecciones se definen en el fichero `~/.forward` y el formato de este fichero es simplemente un listado de cuentas de correo a las que se quiere redirigir el correo.

En mi caso, creo dicho fichero en el usuario **debian** e introduzco una dirección de correo externa distinta de la que va a enviar el correo:

<pre>
reyole111@gmail.com
</pre>

Hecho esto, vamos a enviar un correo desde **Gmail** hacia `root@iesgn15.es`:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correoenviadogmailparareenvioadebianygmail.png" />

Supuestamente, lo que ahora debería ocurrir es lo siguiente. El correo cuyo destinatario es **root**, debe llegar a **debian**, lo cuál es señal de que el alias está actuando correctamente, y automáticamente después, el correo debe ser reenviado a la dirección **reyole111@gmail.com**.

Vamos a ver si hemos recibido el correo en la bandeja de entrada de **reyole111@gmail.com**.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correorecibidogmailreyole.png" />

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correorecibidogmailreyoleinfo.png" />

Efectivamente, también hemos recibido el correo en la dirección *reyole111@gmail.com*, por tanto la redirección está bien configurada.

¿Recordáis que teníamos programada una tarea en el *cron* para las 18:40? Bien, pues resulta que acabo de recibir en `reyole111@gmail.com` el siguiente correo:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correocron.png" />

Se puede apreciar la salida de los comandos que indiqué en la tarea del *cron*, por lo que, además de ver como nuestro *cron* nos ha notificado por correo, podemos ver que una vez más han actuado tanto el alias como la redirección configurada.


#### Para luchar contra el SPAM

**4. Vamos a configurar `Postfix` para que tenga en cuenta el registro *SPF* de los correos que recibe.**

En primer lugar, necesitaremos instalar el paquete `postfix-policyd-spf-python`:

<pre>
apt install postfix-policyd-spf-python -y
</pre>

Una vez instalado, en el fichero `/etc/postfix/master.cf` debemos crear un *socket UNIX* que será el encargado de realizar la comprobación. Para ello introduciremos la siguiente línea:

<pre>
policyd-spf  unix  -       n       n       -       0       spawn     user=policyd-spf argv=/usr/bin/policyd-spf
</pre>

Para terminar, debemos editar el fichero `/etc/postfix/main.cf` y en él, indicaremos que haga uso de dicho *socket UNIX*. Añadimos esta línea:

<pre>
policyd-spf_time_limit = 3600
smtpd_recipient_restrictions = check_policy_service unix:private/policyd-spf
</pre>

Hecho esto, aplicaremos los cambios reiniciando el servicio:

<pre>
systemctl restart postfix
</pre>

Vamos a hacer la prueba visualizando los *logs* y enviando un nuevo correo desde *Gmail*:

<pre>
root@vpsjavierpzh:~# tail -f /var/log/mail.log
Feb 19 19:14:21 vpsjavierpzh postfix/smtpd[19227]: connect from mail-io1-f42.google.com[209.85.166.42]
Feb 19 19:14:22 vpsjavierpzh policyd-spf[19234]: prepend Received-SPF: Pass (mailfrom) identity=mailfrom; client-ip=209.85.166.42; helo=mail-io1-f42.google.com; envelope-from=javierperezhidalgo01@gmail.com; receiver=\<UNKNOWN\>
Feb 19 19:14:22 vpsjavierpzh postfix/smtpd[19227]: 7ED0310115E: client=mail-io1-f42.google.com[209.85.166.42]
Feb 19 19:14:22 vpsjavierpzh postfix/cleanup[19237]: 7ED0310115E: message-id=<CAMu5ax89DXzEtwWTeLm-OmDK18zXgXDocqiuk0XLn+9OnAu3cA@mail.gmail.com>
Feb 19 19:14:22 vpsjavierpzh postfix/qmgr[19197]: 7ED0310115E: from=<javierperezhidalgo01@gmail.com>, size=2710, nrcpt=1 (queue active)
Feb 19 19:14:22 vpsjavierpzh postfix/cleanup[19237]: 81C7710115F: message-id=<CAMu5ax89DXzEtwWTeLm-OmDK18zXgXDocqiuk0XLn+9OnAu3cA@mail.gmail.com>
Feb 19 19:14:22 vpsjavierpzh postfix/qmgr[19197]: 81C7710115F: from=<javierperezhidalgo01@gmail.com>, size=2845, nrcpt=1 (queue active)
Feb 19 19:14:22 vpsjavierpzh postfix/local[19238]: 7ED0310115E: to=<root@iesgn15.es>, relay=local, delay=0.36, delays=0.35/0.01/0/0, dsn=2.0.0, status=sent (forwarded as 81C7710115F)
Feb 19 19:14:22 vpsjavierpzh postfix/qmgr[19197]: 7ED0310115E: removed
Feb 19 19:14:22 vpsjavierpzh postfix/smtpd[19227]: disconnect from mail-io1-f42.google.com[209.85.166.42] ehlo=2 starttls=1 mail=1 rcpt=1 bdat=1 quit=1 commands=7
</pre>

Podemos ver como ahora si está llevando a cabo la comprobación del registro *SPF*.

**5. Vamos a configurar un sistema *antispam*.**

En este apartado vamos a ver como instalar un sistema *antispam* en nuestro servidor de correos. Para ello necesitaremos instalar los siguientes paquetes:

<pre>
apt install spamc spamassassin -y
</pre>

Una vez instalados, habilitaremos e iniciaremos el servicio:

<pre>
systemctl enable spamassassin && systemctl start spamassassin
</pre>

Posteriormente, nos dirigiremos al fichero `/etc/postfix/master.cf` y veremos que nos encontramos con las siguientes líneas:

<pre>
smtp      inet  n       -       y       -       -       smtpd
...
#submission inet n       -       y       -       -       smtpd
</pre>

Una vez localizadas, tendremos que hacer unas modificaciones en ellas para que *Postfix* tenga en cuenta el sistema *antispam*, además de añadir una nueva directiva. Realizadas las modificaciones, las líneas tendrían el siguiente aspecto:

<pre>
smtp      inet  n       -       y       -       -       smtpd
  -o content_filter=spamassassin
...
submission inet n       -       y       -       -       smtpd
  -o content_filter=spamassassin
...
spamassassin unix -     n       n       -       -       pipe
  user=debian-spamd argv=/usr/bin/spamc -f -e /usr/sbin/sendmail -oi -f ${sender} ${recipient}
</pre>

Por último, tendremos que configurar **Spamassassin**. Su configuración es bastante simple y se llevará a cabo en el fichero `/etc/spamassassin/local.cf`. En él necesitaremos descomentar la siguiente línea, ya que por defecto aparece comentada:

<pre>
rewrite_header Subject *****SPAM*****
</pre>

Realizados todas las modificaciones, aplicaremos los cambios reiniciando ambos servicios:

<pre>
systemctl restart postfix
systemctl restart spamassassin
</pre>

Llegó el momento de realizar la prueba, enviaremos un correo desde *Gmail*, y en el mensaje del correo, introduciré un mensaje de *spam*, que puedes encontrar [aquí](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correospam.txt).

Vamos a hacer la prueba visualizando los *logs*:

<pre>
Feb 19 19:43:56 vpsjavierpzh spamd[24888]: spamd: identified spam (999.9/5.0) for debian-spamd:112 in 0.2 seconds, 3818 bytes.
Feb 19 19:43:56 vpsjavierpzh spamd[24888]: spamd: result: Y 999 - DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FROM,GTUBE,HTML_MESSAGE,RCVD_IN_MSPIKE_H2,SPF_PASS,URIBL_BLOCKED scantime=0.2,size=3818,user=debian-spamd,uid=112,required_score=5.0,rhost=::1,raddr=::1,rport=38494,mid=<CA+kZvsg23JEMj32M6Frs1bc1UZ_2kSNeEpGKzP+wQ5wcdkQN-A@mail.gmail.com>,autolearn=no autolearn_force=no
Feb 19 19:43:56 vpsjavierpzh postfix/pipe[25543]: B6A05826C7: to=<debian@iesgn15.es>, relay=spamassassin, delay=0.61, delays=0.32/0.01/0/0.29, dsn=2.0.0, status=sent (delivered via spamassassin service)
</pre>

Vemos como nos muestra un mensaje **identified spam**.

**6. Vamos a configurar un sistema antivirus.**

En este apartado vamos a ver como instalar un sistema antivirus en nuestro servidor de correos. En mi caso, voy a utilizar un antivirus llamado **clamAV**, que se instala mediante los siguientes paquetes:

<pre>
apt install clamsmtp clamav-daemon arc arj bzip2 cabextract lzop nomarch p7zip pax tnef unrar-free unzip -y
</pre>

Una vez instalados, habilitaremos e iniciaremos el servicio:

<pre>
systemctl enable clamav-daemon && systemctl start clamav-daemon
</pre>

Posteriormente, nos dirigiremos al fichero `/etc/postfix/main.cf` y añadiremos las siguientes líneas:

<pre>
content_filter = scan:127.0.0.1:10026
</pre>

También tendremos que editar el fichero `/etc/postfix/master.cf` y añadir las líneas siguientes. Estas líneas nos servirán para indicarle a nuestro servidor de correos, donde debe llevar a cabo las consultas referentes sobre si los diferentes correos llevan algún virus o no.

<pre>
scan unix -       -       n       -       16       smtp
  -o smtp_data_done_timeout=1200
  -o smtp_send_xforward_command=yes
  -o disable_dns_lookups=yes

127.0.0.1:10025 inet n       -       n       -       16       smtpd
  -o content_filter=
  -o local_recipient_maps=
  -o relay_recipient_maps=
  -o smtpd_restriction_classes=
  -o smtpd_client_restrictions=
  -o smtpd_helo_restrictions=
  -o smtpd_sender_restrictions=
  -o smtpd_recipient_restrictions=permit_mynetworks,reject
  -o mynetworks_style=host
  -o smtpd_authorized_xforward_hosts=127.0.0.0/8
</pre>

Realizados todas las modificaciones, aplicaremos los cambios reiniciando el servicio:

<pre>
systemctl restart postfix
</pre>

Llegó el momento de realizar la prueba, enviaremos un correo desde *Gmail*, y en el mensaje del correo, introduciré un mensaje que es detectado como *virus*. El mensaje de virus es el siguiente: `X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*`.

Vamos a hacer la prueba visualizando los *logs*:

<pre>
Feb 19 19:43:56 vpsjavierpzh spamd[24888]: spamd: clean message (-0.1/5.0) for debian-spamd:112 in 0.2 seconds, 2794 bytes.
Feb 19 19:43:56 vpsjavierpzha spamd[24888]: spamd: result: . 0 - DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FROM,HTML_MESSAGE,RCVD_IN_MSPIKE_H2,SPF_PASS,TVD_SPACE_RATIO scantime=0.2,size=2794,user=debian-spamd,uid=112,required_score=5.0,rhost=::1,raddr=::1,rport=38584,mid=<CA+kZvsjbkMPbcUYhSfzzbGYCtVTZ07bVNT1+YvB=Ce2Ln9J_fQ@mail.gmail.com>,autolearn=ham autolearn_force=no
Feb 19 19:43:56 vpsjavierpzh postfix/pipe[17795]: 9C5A0826CE: to=<debian@iesgn15.es>, relay=spamassassin, delay=0.51, delays=0.27/0.01/0/0.23, dsn=2.0.0, status=sent (delivered via spamassassin service)
Feb 19 19:43:56 vpsjavierpzh postfix/qmgr[17773]: 9C5A0826CE: removed
...
Feb 19 20:32:15 vpsjavierpzh clamsmtpd: 100002: accepted connection from: 127.0.0.1
Feb 19 19:32:15 vpsjavierpzh spamd[24887]: prefork: child states: II
Feb 19 19:32:15 vpsjavierpzh postfix/smtpd[17803]: connect from localhost[127.0.0.1]
Feb 19 19:32:15 vpsjavierpzh postfix/smtpd[17803]: ECB66826CE: client=localhost[127.0.0.1]
Feb 19 19:32:15 vpsjavierpzh postfix/smtp[17801]: D79E0826D0: to=<debian@iesgn15.es>, relay=127.0.0.1[127.0.0.1]:10025, delay=0.09, delays=0.01/0.02/0.07/0.01, dsn=2.0.0, status=sent (250 Virus Detected; Discarded Email)
Feb 19 19:32:15 vpsjavierpzh postfix/qmgr[17773]: D79E0826D0: removed
</pre>

Vemos como nos muestra un mensaje **250 Virus Detected**.


#### Gestión de correos desde un cliente

**7. Vamos a configurar el buzón de los usuarios de tipo `Maildir`. Envía un correo a tu usuario y comprueba que el correo se ha guardado en el buzón `Maildir` del usuario del sistema correspondiente. Recuerda que ese tipo de buzón no se puede leer con la utilidad `mail`.**

Como ya sabemos, por defecto al instalar *Postfix*, estaremos utilizando el formato **mbox** para almacenar los correos electrónicos, pero, ¿cómo hacemos para cambiar al formato **Maildir**?

Primeramente vamos a ver que diferencias encontramos entre los dos.

- **mbox:** guarda todos los mensajes en un solo archivo.

- **Maildir:** utiliza un directorio, con subdirectorios, para guardar los mensajes en ficheros individuales.

Explicado esto, vamos a proceder a configurar *Postfix* para que empiece a utilizar el formato *Maildir*.

En primer lugar, nos dirigimos al fichero `/etc/postfix/main.cf` e introduciremos la siguiente línea en él:

<pre>
home_mailbox = Maildir/
</pre>

(Es importante la `/` final.)

Hecho esto, ya habremos configurado *Postfix* para que utilice *Maildir*, por tanto vamos a reiniciar el servicio y a hacer una prueba para comprobar el cambio.

<pre>
systemctl restart postfix
</pre>

Desde este momento, no podremos ver los correos con la herramienta `mail`. Para solucionarlo, instalaremos un nuevo cliente llamado `mutt`:

<pre>
apt install mutt -y
</pre>

Instalado, debemos crear en el directorio del usuario un fichero `.muttrc` que posea el siguiente contenido:

<pre>
set mbox_type=Maildir
set folder="/Maildir"
set mask="!^\.[^.]"
set mbox="/Maildir"
set record="+.Sent"
set postponed="+.Drafts"
set spoolfile="~/Maildir"
</pre>

Hecho esto, voy a enviar un correo desde *Gmail* y posteriormente utilizaré el comando `mutt` para abrir el nuevo cliente.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/mutt1.png" />

Abrimos el nuevo correo:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/mutt2.png" />

Podemos ver como ya estamos utilizando un nuevo cliente de correos.

**8. Vamos a instalar y configurar `dovecot` para ofrecer el protocolo `IMAP`. También vamos a configurar `dovecot` para ofrecer autentificación y cifrado.**

En primer lugar, para realizar el cifrado de la comunicación tendremos que crear un certificado en *LetsEncrypt* para el dominio `mail.iesgn15.es`. Recordemos que para el ofrecer el cifrado poseemos varias opciones:

- **IMAP con STARTTLS:** *STARTTLS* transforma una conexión insegura en una segura mediante el uso de *SSL/TLS*. Por lo tanto usando el mismo puerto, *143/tcp*, tenemos cifrada la comunicación.

- **IMAPS:** Versión segura del protocolo *IMAP* que usa el puerto *993/tcp*.

En mi caso, voy a utilzar el protocolo **IMAPS**, por lo que me será necesario solicitar un certificado, lo haré a través de *LetsEncrypt*.

Para generar este certificado, voy a utilizar **Certbot**.

<pre>
apt install certbot -y
</pre>

Una vez instalado, procederemos a generar el certificado necesario.

Es importante parar el servicio en caso de que dispongamos de algún servidor web, para que *Certbot* pueda realizar el *challenge*. Utilizaremos el siguiente comando para generar el certificado:

<pre>
certbot certonly --standalone -d mail.iesgn15.es
</pre>

Veamos el proceso:

<pre>
root@vpsjavierpzh:~# certbot certonly --standalone -d mail.iesgn15.es
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator standalone, Installer None
Obtaining a new certificate

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/mail.iesgn15.es/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/mail.iesgn15.es/privkey.pem
   Your cert will expire on 2021-05-22. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
</pre>

Una vez hemos generado y poseemos nuestro certificado, vamos a seguir con la instalación de *dovecot*. Para ello instalaremos los siguientes paquetes:

<pre>
apt install dovecot-imapd dovecot-pop3d dovecot-common -y
</pre>

Ahora vamos a proceder a configurar *dovecot* para que haga uso del protocolo *IMAPS*.

Empezaremos modificando el fichero `/etc/dovecot/conf.d/10-auth.conf`, y en él, debemos buscar la siguiente línea:

<pre>
#disable_plaintext_auth = yes
</pre>

Encontrada, vamos a descomentarla y a cambiarle su valor a **no**, de manera que quedaría de esta forma:

<pre>
disable_plaintext_auth = no
</pre>

Bien, seguiremos configurando *dovecot* editando el fichero `/etc/dovecot/conf.d/10-ssl.conf`. Dentro de él, buscaremos las siguientes directivas, en las que tendremos que indicar las rutas en las que se encuentran tanto el certificado firmado por *LetsEncrypt*, como la clave privada asociada al certificado.

<pre>
ssl = yes
...
ssl_cert = /etc/letsencrypt/live/mail.iesgn15.es/fullchain.pem
ssl_key = /etc/letsencrypt/live/mail.iesgn15.es/privkey.pem
</pre>

**Atención:** al principio de los valores de los parámetros **ssl_cert** y **ssl_key**, debemos introducir el carácter `<`. Yo lo he omitido por una cuestión de formato. Ejemplo: `ssl_cert = </etc/letsencrypt/live/mail.iesgn15.es/fullchain.pem`.

Hecho esto, debemos comprobar que en el fichero `/etc/dovecot/conf.d/10-mail.conf`, el siguiente parámetro posea el siguiente valor:

<pre>
mail_location = maildir:~/Maildir
</pre>

Por último, para terminar de configurar *dovecot*, nos situamos en el archivo `/etc/dovecot/conf.d/10-master.conf`. Buscaremos el siguiente bloque que se encuentra por defecto:

<pre>
service imap-login {
  inet_listener imap {
    #port = 143
  }
  inet_listener imaps {
    #port = 993
    #ssl = yes
</pre>

En él, debemos descomentar todas las líneas para que *dovecot* pueda hacer uso del protocolo *IMAPS*, quedando el bloque así:

<pre>
service imap-login {
  inet_listener imap {
    port = 143
  }
  inet_listener imaps {
    port = 993
    ssl = yes
  }
</pre>

Si nos desplazamos un poco más abajo, nos encontraremos con el siguiente bloque totalmente comentado:

<pre>
#unix_listener /var/spool/postfix/private/auth {
  #  mode = 0666
  #}
</pre>

Debemos modificarlo para que quede igual que éste:

<pre>
unix_listener /var/spool/postfix/private/auth {
  mode = 0666
  user = postfix
  group = postfix
}
</pre>

Nuestra configuración de *dovecot* para que haga uso del protocolo *IMAPS* ha finalizado, de manera que es momento de reiniciar dicho servicio:

<pre>
systemctl restart dovecot
</pre>

Ya podríamos entrar a nuestro cliente de correos. Para ello he instalado en mi máquina anfitriona el cliente **Thunderbird**.

<pre>
apt install thunderbird -y
</pre>

Inicio sesión:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/thunderbird.png" />

Abrimos el nuevo correo:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/correothunderbird.png" />

Podemos apreciar como el correo ha sido recibido correctamente en nuestro cliente *Thunderbird*.

**9. Vamos a configurar `postfix` para que podamos mandar un correo desde un cliente remoto. La conexión entre cliente y servidor estará autentificada con *SASL* usando `dovecot` y además estará cifrada.**

No he conseguido configurarlo.


#### Comprobación final

**En [www.mail-tester.com/](https://www.mail-tester.com/) tenemos una herramienta completa y fácil de usar a la que podemos enviar un correo para que verifique y puntúe el correo que enviamos.**

Voy a enviar un correo como el siguiente para que esta herramienta me lo examine.

<pre>
echo "Esto es una prueba" | mutt  -s 'Test' test-6noihtep7@srv1.mail-tester.com
</pre>

Veamos el resultado:

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/sri_servidor_de_correos/puntos.png" />

¡Genial, me ha dado un **9/10**!
