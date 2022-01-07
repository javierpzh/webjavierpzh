---
layout: post
---

**En este *post* voy a realizar un *script* el cuál, al introducirle como parámetro el nombre de un repositorio, mostrará como salida, los paquetes de ese repositorio que están instalados en la máquina.**

**El *script* acepta los siguientes formatos:**

<pre>
./script.sh security.debian.org
</pre>

<pre>
./script.sh http://security.debian.org
</pre>

El *script* es el siguiente:

<pre>
#!/bin/bash

# Script que introduciéndole como parámetro el nombre de un repositorio, muestra como salida los paquetes de ese repositorio que están instalados en la máquina.

repositorio=$1

for paquete in $(dpkg --get-selections | awk '{ print $1  }')
do
 salida=`apt-cache policy $paquete | grep -A 1 '[***]' | grep 'http:' | awk '{ print $2 }'`
 if [[ $salida == *$1* ]]
 then
        echo $paquete;
 fi
done
</pre>

Lo que hace este *script*, es que al recibir como parámetro una cadena, un **repositorio** en este caso, busca en todos los paquetes instalados, el repositorio del que provienen, y si es el mismo que el que hemos introducido, mostramos por pantalla el nombre de ese paquete.

La primera parte sería introducir el repositorio. Después identificaremos los repositorios de todos los paquetes instalados.

Ejecutamos un bucle *for* del comando `dpkg --get-selections | awk '{ print $1  }'`, que recorre todos los paquetes del equipo. Para identificar el repositorio de cada paquete lo hacemos con el comando `apt-cache policy`, que muestra la versión instalada mediante `***` y abajo identifica el repositorio desde donde se ha instalado. Por tanto lo que hace con el comando `grep -A 1 '[***]'` es quedarse con la línea de debajo de los tres asteriscos, y luego se queda con la cadena que contiene `http:`. Para omitir que imprima la propia línea `***`, y ahora que ya únicamente tenemos la línea del repositorio, con `awk` nos quedamos con la segunda columna que es el propio repositorio en sí.

Ahora lo único que falta es comparar si el repositorio que hemos introducido, es el mismo que el del paquete, si es el mismo muestra el nombre del paquete, y sino no hace nada.

Puedes descargar aquí el [script](images/aso_script_para_seleccionar_paquetes_por_respositorio/paquetesporrepositorio.sh).
