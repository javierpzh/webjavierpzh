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
