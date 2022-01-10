---
layout: post
---

## Compilación de un kérnel linux a medida

Al ser *Linux* un *kérnel* libre, es posible descargar el código fuente, configurarlo y comprimirlo. Además, esta tarea a *priori* compleja, es más sencilla de lo que parece gracias a las herramientas disponibles.

En esta entrada voy a tratar de compilar un kérnel completamente funcional que reconozca todo el hardware básico de mi equipo y que sea a la vez lo más pequeño posible, es decir que incluya un *vmlinuz* lo más pequeño posible y que incorpore sólo los módulos imprescindibles.

El hardware básico incluye como mínimo el teclado, la interfaz de red y la consola gráfica en modo texto.

### Procedimiento a seguir

**1. Instalo el paquete `linux-source` correspondiente al núcleo que estoy usando en mi máquina.**

Voy a instalar el paquete `linux-source-4.19 (4.19.152-1)` que corresponde al *kérnel* **4.19**.

Lo he descargado desde la [página oficial de Debian](https://packages.debian.org/buster/linux-source-4.19), desde este [enlace](http://security.debian.org/debian-security/pool/updates/main/l/linux/linux_4.19.152.orig.tar.xz).

**2. Creo un directorio de trabajo.**

Creamos el directorio de trabajo.

**Importante:** hay que crear el directorio con nuestro usuario personal, es decir, no como *root*.

<pre>
mkdir ~/kernelLinux/
</pre>

**3. Descomprimo el código fuente del *kérnel* dentro del directorio de trabajo.**

Descargo y descomprimo el *kérnel* en el directorio de trabajo que he creado previamente:

<pre>
javier@debian:/usr/src# wget http://security.debian.org/debian-security/pool/updates/main/l/linux/linux_4.19.152.orig.tar.xz
--2020-11-06 10:26:31--  http://security.debian.org/debian-security/pool/updates/main/l/linux/linux_4.19.152.orig.tar.xz
Resolviendo security.debian.org (security.debian.org)... 151.101.128.204, 151.101.0.204, 151.101.64.204, ...
Conectando con security.debian.org (security.debian.org)[151.101.128.204]:80... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 107539124 (103M) [application/x-xz]
Grabando a: “linux_4.19.152.orig.tar.xz”

linux_4.19.152.orig.tar.x 100%[=====================================>] 102,56M  3,67MB/s    en 12s     

2020-11-06 10:26:44 (8,41 MB/s) - “linux_4.19.152.orig.tar.xz” guardado [107539124/107539124]

javier@debian:/usr/src# ls
linux_4.19.152.orig.tar.xz	linux-headers-4.19.0-12-amd64	vboxhost-6.0.24
linux-headers-4.19.0-11-amd64	linux-headers-4.19.0-12-common
linux-headers-4.19.0-11-common	linux-kbuild-4.19

javier@debian:/usr/src# tar xf /usr/src/linux_4.19.152.orig.tar.xz --directory ~/kernelLinux/
</pre>

Me muevo al directorio `~/kernelLinux`, que va a ser mi área de trabajo:

<pre>
javier@debian:/usr/src# cd ~/kernelLinux/

javier@debian:~/kernelLinux# ls
linux-4.19.152

javier@debian:~/kernelLinux# cd linux-4.19.152/

javier@debian:~/kernelLinux/linux-4.19.152# ls
arch   COPYING	Documentation  fs	ipc	 kernel    MAINTAINERS	net	 scripts   tools
block  CREDITS	drivers        include	Kbuild	 lib	   Makefile	README	 security  usr
certs  crypto	firmware       init	Kconfig  LICENSES  mm		samples  sound	   virt
</pre>


**4. Utilizo como punto de partida la configuración actual del núcleo.**

Para esto, es necesario revisar que tenemos instalado el paquete `build-essential` y todas sus dependencias. Este paquete incluye todo lo necesario a la hora de compilar. Para instalarlo:

<pre>
apt install build-essential -y
</pre>

Si ejecutamos este comando:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152# make oldconfig
  YACC    scripts/kconfig/zconf.tab.c
/bin/sh: 1: bison: not found
make[1]: *** [scripts/Makefile.lib:196: scripts/kconfig/zconf.tab.c] Error 127
make: *** [Makefile:554: oldconfig] Error 2
</pre>

Observamos como no nos realiza el `make oldconfig` deseado. Esto es debido a que el paquete `build-essential` en *Debian*, no incluye `bison` ni `flex`, que son necesarios para la compilación del *kérnel*. Por tanto, los instalamos:

<pre>
apt install bison flex -y
</pre>

Probamos de nuevo a ejecutar el comando `make oldconfig` y ahora sí realiza el proceso correctamente.

<pre>
javier@debian:~/kernelLinux/linux-4.19.152# make oldconfig
  YACC    scripts/kconfig/zconf.tab.c
  LEX     scripts/kconfig/zconf.lex.c
  HOSTCC  scripts/kconfig/zconf.tab.o
  HOSTLD  scripts/kconfig/conf
scripts/kconfig/conf  --oldconfig Kconfig
#
# using defaults found in /boot/config-4.19.0-12-amd64
#
/boot/config-4.19.0-12-amd64:6949:warning: symbol value 'm' invalid for ASHMEM
/boot/config-4.19.0-12-amd64:7577:warning: symbol value 'm' invalid for ANDROID_BINDER_IPC
*
* Restart config...
*
*
* Support for frame buffer devices
*
Support for frame buffer devices (FB) [Y/m/?] y
  Enable firmware EDID (FIRMWARE_EDID) [Y/n/?] y
  Enable Video Mode Handling Helpers (FB_MODE_HELPERS) [Y/?] y
  Enable Tile Blitting Support (FB_TILEBLITTING) [Y/?] y
  *
  * Frame buffer hardware drivers
  *
  Cirrus Logic support (FB_CIRRUS) [M/n/y/?] m
  Permedia2 support (FB_PM2) [M/n/y/?] m
    enable FIFO disconnect feature (FB_PM2_FIFO_DISCONNECT) [Y/n/?] y
  CyberPro 2000/2010/5000 support (FB_CYBER2000) [M/n/y/?] m
    DDC for CyberPro support (FB_CYBER2000_DDC) [Y/n/?] y
  Arc Monochrome LCD board support (FB_ARC) [M/n/y/?] m
  Asiliant (Chips) 69000 display support (FB_ASILIANT) [N/y/?] n
  IMS Twin Turbo display support (FB_IMSTT) [N/y/?] n
  VGA 16-color graphics support (FB_VGA16) [M/n/y/?] m
  Userspace VESA VGA graphics support (FB_UVESA) [M/n/y/?] m
  VESA VGA graphics support (FB_VESA) [Y/n/?] y
  EFI-based Framebuffer Support (FB_EFI) [Y/n/?] y
  N411 Apollo/Hecuba devkit support (FB_N411) [M/n/y/?] m
  Hercules mono graphics support (FB_HGA) [M/n/y/?] m
  OpenCores VGA/LCD core 2.0 framebuffer support (FB_OPENCORES) [N/m/y/?] n
  Epson S1D13XXX framebuffer support (FB_S1D13XXX) [N/m/y/?] n
  nVidia Framebuffer Support (FB_NVIDIA) [N/m/y/?] (NEW) n
  nVidia Riva support (FB_RIVA) [N/m/y/?] (NEW) n
  Intel740 support (FB_I740) [N/m/y/?] n
  Intel LE80578 (Vermilion) support (FB_LE80578) [M/n/y/?] m
    Intel Carillo Ranch support (FB_CARILLO_RANCH) [M/n/?] m
  Intel 830M/845G/852GM/855GM/865G/915G/945G/945GM/965G/965GM support (FB_INTEL) [N/m/?] n
  Matrox acceleration (FB_MATROX) [M/n/y/?] m
    Millennium I/II support (FB_MATROX_MILLENIUM) [Y/n/?] y
    Mystique support (FB_MATROX_MYSTIQUE) [Y/n/?] y
    G100/G200/G400/G450/G550 support (FB_MATROX_G) [Y/n/?] y
    Matrox I2C support (FB_MATROX_I2C) [M/n/?] m
      G400 second head support (FB_MATROX_MAVEN) [M/n/?] m
  ATI Radeon display support (FB_RADEON) [M/n/y/?] m
    DDC/I2C for ATI Radeon support (FB_RADEON_I2C) [Y/n/?] y
    Support for backlight control (FB_RADEON_BACKLIGHT) [Y/n/?] y
    Lots of debug output from Radeon driver (FB_RADEON_DEBUG) [N/y/?] n
  ATI Rage128 display support (FB_ATY128) [M/n/y/?] m
    Support for backlight control (FB_ATY128_BACKLIGHT) [Y/n/?] y
  ATI Mach64 display support (FB_ATY) [M/n/y/?] m
    Mach64 CT/VT/GT/LT (incl. 3D RAGE) support (FB_ATY_CT) [Y/n/?] y
      Mach64 generic LCD support (FB_ATY_GENERIC_LCD) [N/y/?] n
    Mach64 GX support (FB_ATY_GX) [Y/n/?] y
    Support for backlight control (FB_ATY_BACKLIGHT) [Y/n/?] y
  S3 Trio/Virge support (FB_S3) [M/n/y/?] m
    DDC for S3 support (FB_S3_DDC) [Y/n/?] y
  S3 Savage support (FB_SAVAGE) [M/n/y/?] m
    Enable DDC2 Support (FB_SAVAGE_I2C) [N/y/?] n
    Enable Console Acceleration (FB_SAVAGE_ACCEL) [N/y/?] n
  SiS/XGI display support (FB_SIS) [M/n/y/?] m
    SiS 300 series support (FB_SIS_300) [Y/n/?] y
    SiS 315/330/340 series and XGI support (FB_SIS_315) [Y/n/?] y
  VIA UniChrome (Pro) and Chrome9 display support (FB_VIA) [M/n/y/?] m
    direct hardware access via procfs (DEPRECATED)(DANGEROUS) (FB_VIA_DIRECT_PROCFS) [N/y/?] n
    X server compatibility (FB_VIA_X_COMPATIBILITY) [Y/n/?] y
  NeoMagic display support (FB_NEOMAGIC) [M/n/y/?] m
  IMG Kyro support (FB_KYRO) [M/n/y/?] m
  3Dfx Banshee/Voodoo3/Voodoo5 display support (FB_3DFX) [M/n/y/?] m
    3Dfx Acceleration functions (FB_3DFX_ACCEL) [N/y/?] n
    Enable DDC/I2C support (FB_3DFX_I2C) [Y/n/?] y
  3Dfx Voodoo Graphics (sst1) support (FB_VOODOO1) [M/n/y/?] m
  VIA VT8623 support (FB_VT8623) [M/n/y/?] m
  Trident/CyberXXX/CyberBlade support (FB_TRIDENT) [M/n/y/?] m
  ARK 2000PV support (FB_ARK) [M/n/y/?] m
  Permedia3 support (FB_PM3) [M/n/y/?] m
  Fujitsu carmine frame buffer support (FB_CARMINE) [N/m/y/?] n
  SMSC UFX6000/7000 USB Framebuffer support (FB_SMSCUFX) [M/n/?] m
  Displaylink USB Framebuffer support (FB_UDL) [M/n/?] m
  Framebuffer support for IBM GXT4000P/4500P/6000P/6500P adaptors (FB_IBM_GXT4500) [N/m/y/?] n
  Virtual Frame Buffer support (ONLY FOR TESTING!) (FB_VIRTUAL) [M/n/y/?] m
  Xen virtual frame buffer support (XEN_FBDEV_FRONTEND) [Y/n/m/?] y
  E-Ink Metronome/8track controller support (FB_METRONOME) [N/m/y/?] n
  Fujitsu MB862xx GDC support (FB_MB862XX) [M/n/y/?] m
    GDC variant
    > 1. Carmine/Coral-P(A) GDC (FB_MB862XX_PCI_GDC)
    choice[1]: 1
    Support I2C bus on MB862XX GDC (FB_MB862XX_I2C) [Y/n/?] y
  E-Ink Broadsheet/Epson S1D13521 controller support (FB_BROADSHEET) [N/m/y/?] n
  Microsoft Hyper-V Synthetic Video support (FB_HYPERV) [M/n/?] m
  Simple framebuffer support (FB_SIMPLE) [N/y/?] n
  Silicon Motion SM712 framebuffer support (FB_SM712) [N/m/y/?] n
*
* Android
*
Enable the Anonymous Shared Memory Subsystem (ASHMEM) [N/y/?] (NEW) n
Android Virtual SoC support (ANDROID_VSOC) [N/m/y/?] n
*
* Android
*
Android Drivers (ANDROID) [Y/n/?] y
  Android Binder IPC Driver (ANDROID_BINDER_IPC) [N/y/?] (NEW) n
*
* DOS/FAT/NT Filesystems
*
MSDOS fs support (MSDOS_FS) [M/n/y/?] m
VFAT (Windows-95) fs support (VFAT_FS) [M/n/y/?] m
  Default codepage for FAT (FAT_DEFAULT_CODEPAGE) [437] 437
  Default iocharset for FAT (FAT_DEFAULT_IOCHARSET) [ascii] ascii
  Enable FAT UTF-8 option by default (FAT_DEFAULT_UTF8) [Y/n/?] y
NTFS file system support (NTFS_FS) [N/m/y/?] (NEW) n
#
# configuration written to .config
#
</pre>


**5. Cuento el número de componentes que se han configurado para incluir en *vmlinuz* o como módulos.**

Voy a contar el número de componentes que se van a incluir como módulos en el proceso de compilación y el número de componentes que se van a incluir en la parte estática:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152# grep "=m" .config | wc -l
3378

javier@debian:~/kernelLinux/linux-4.19.152# grep "=y" .config | wc -l
2008
</pre>

Vemos que si realizara la compilación, incluiría 3378 módulos, y 2008 componentes enlazados estáticamente.

Son muchísimos componentes, por tanto voy a reducir el número de éstos al máximo, intentando dejar los imprescindibles para el arranque de mi máquina y la conexión a internet, esto es algo que lógicamente variará dependiendo del equipo y de los componentes del mismo.

**6. Configuro el núcleo en función de los módulos que está utilizando actualmente el equipo.**

Voy a realizar el primer proceso de eliminación de componentes, que me va a reducir en una enorme cantidad el número de componentes que se van a incluir en mi fichero `.config`, que es el fichero que luego voy a utilizar para realizar la compilación, ya que en él se indican todos los componentes que se van a incluir a la hora de compilar el núcleo.

Esta primera parte, sí es igual para todos ya que lo que vamos a hacer con este comando, es seleccionar la configuración que estamos utilizando actualmente en el equipo y copiarla al fichero `.config`, es decir vamos a copiar todos los módulos y enlaces estáticos que tengamos activos en el sistema, descartando los demás, pues se entiende que no están activos porque son prescindibles para nosotros. Esto lo realizaremos con el comando siguiente:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152# make localmodconfig
using config: '.config'
vboxnetadp config not found!!
vboxdrv config not found!!
vboxnetflt config not found!!
System keyring enabled but keys "debian/certs/debian-uefi-certs.pem" not found. Resetting keys to default value.
*
* Restart config...
*
*
* PCI GPIO expanders
*
AMD 8111 GPIO driver (GPIO_AMD8111) [N/m/y/?] n
BT8XX GPIO abuser (GPIO_BT8XX) [N/m/y/?] (NEW) n
OKI SEMICONDUCTOR ML7213 IOH GPIO support (GPIO_ML_IOH) [N/m/y/?] n
ACCES PCI-IDIO-16 GPIO support (GPIO_PCI_IDIO_16) [N/m/y/?] n
ACCES PCIe-IDIO-24 GPIO support (GPIO_PCIE_IDIO_24) [N/m/y/?] n
RDC R-321x GPIO support (GPIO_RDC321X) [N/m/y/?] n
*
* PCI sound devices
*
PCI sound devices (SND_PCI) [Y/n/?] y
  Analog Devices AD1889 (SND_AD1889) [N/m/?] n
  Avance Logic ALS300/ALS300+ (SND_ALS300) [N/m/?] n
  Avance Logic ALS4000 (SND_ALS4000) [N/m/?] n
  ALi M5451 PCI Audio Controller (SND_ALI5451) [N/m/?] n
  AudioScience ASIxxxx (SND_ASIHPI) [N/m/?] n
  ATI IXP AC97 Controller (SND_ATIIXP) [N/m/?] n
  ATI IXP Modem (SND_ATIIXP_MODEM) [N/m/?] n
  Aureal Advantage (SND_AU8810) [N/m/?] n
  Aureal Vortex (SND_AU8820) [N/m/?] n
  Aureal Vortex 2 (SND_AU8830) [N/m/?] n
  Emagic Audiowerk 2 (SND_AW2) [N/m/?] n
  Aztech AZF3328 / PCI168 (SND_AZT3328) [N/m/?] n
  Bt87x Audio Capture (SND_BT87X) [N/m/?] n
  SB Audigy LS / Live 24bit (SND_CA0106) [N/m/?] n
  C-Media 8338, 8738, 8768, 8770 (SND_CMIPCI) [N/m/?] n
  C-Media 8786, 8787, 8788 (Oxygen) (SND_OXYGEN) [N/m/?] n
  Cirrus Logic (Sound Fusion) CS4281 (SND_CS4281) [N/m/?] n
  Cirrus Logic (Sound Fusion) CS4280/CS461x/CS462x/CS463x (SND_CS46XX) [N/m/?] n
  Creative Sound Blaster X-Fi (SND_CTXFI) [N/m/?] n
  (Echoaudio) Darla20 (SND_DARLA20) [N/m/?] n
  (Echoaudio) Gina20 (SND_GINA20) [N/m/?] n
  (Echoaudio) Layla20 (SND_LAYLA20) [N/m/?] n
  (Echoaudio) Darla24 (SND_DARLA24) [N/m/?] n
  (Echoaudio) Gina24 (SND_GINA24) [N/m/?] n
  (Echoaudio) Layla24 (SND_LAYLA24) [N/m/?] n
  (Echoaudio) Mona (SND_MONA) [N/m/?] n
  (Echoaudio) Mia (SND_MIA) [N/m/?] n
  (Echoaudio) 3G cards (SND_ECHO3G) [N/m/?] n
  (Echoaudio) Indigo (SND_INDIGO) [N/m/?] n
  (Echoaudio) Indigo IO (SND_INDIGOIO) [N/m/?] n
  (Echoaudio) Indigo DJ (SND_INDIGODJ) [N/m/?] n
  (Echoaudio) Indigo IOx (SND_INDIGOIOX) [N/m/?] n
  (Echoaudio) Indigo DJx (SND_INDIGODJX) [N/m/?] n
  Emu10k1 (SB Live!, Audigy, E-mu APS) (SND_EMU10K1) [N/m/?] n
  Emu10k1X (Dell OEM Version) (SND_EMU10K1X) [N/m/?] n
  (Creative) Ensoniq AudioPCI 1370 (SND_ENS1370) [N/m/?] n
  (Creative) Ensoniq AudioPCI 1371/1373 (SND_ENS1371) [N/m/?] n
  ESS ES1938/1946/1969 (Solo-1) (SND_ES1938) [N/m/?] n
  ESS ES1968/1978 (Maestro-1/2/2E) (SND_ES1968) [N/m/?] n
  ForteMedia FM801 (SND_FM801) [N/m/?] n
  RME Hammerfall DSP Audio (SND_HDSP) [N/m/?] n
  RME Hammerfall DSP MADI/RayDAT/AIO (SND_HDSPM) [N/m/?] n
  ICEnsemble ICE1712 (Envy24) (SND_ICE1712) [N/m/?] n
  ICE/VT1724/1720 (Envy24HT/PT) (SND_ICE1724) [N/m/?] n
  Intel/SiS/nVidia/AMD/ALi AC97 Controller (SND_INTEL8X0) [N/m/?] n
  Intel/SiS/nVidia/AMD MC97 Modem (SND_INTEL8X0M) [N/m/?] n
  Korg 1212 IO (SND_KORG1212) [N/m/?] n
  Digigram Lola (SND_LOLA) [N/m/?] n
  Digigram LX6464ES (SND_LX6464ES) [N/m/?] n
  ESS Allegro/Maestro3 (SND_MAESTRO3) [N/m/?] n
  Digigram miXart (SND_MIXART) [N/m/?] n
  NeoMagic NM256AV/ZX (SND_NM256) [N/m/?] n
  Digigram PCXHR (SND_PCXHR) [N/m/?] n
  Conexant Riptide (SND_RIPTIDE) [N/m/?] n
  RME Digi32, 32/8, 32 PRO (SND_RME32) [N/m/?] n
  RME Digi96, 96/8, 96/8 PRO (SND_RME96) [N/m/?] n
  RME Digi9652 (Hammerfall) (SND_RME9652) [N/m/?] n
  Studio Evolution SE6X (SND_SE6X) [N/m/?] (NEW) n
  S3 SonicVibes (SND_SONICVIBES) [N/m/?] n
  Trident 4D-Wave DX/NX; SiS 7018 (SND_TRIDENT) [N/m/?] n
  VIA 82C686A/B, 8233/8235 AC97 Controller (SND_VIA82XX) [N/m/?] n
  VIA 82C686A/B, 8233 based Modems (SND_VIA82XX_MODEM) [N/m/?] n
  Asus Virtuoso 66/100/200 (Xonar) (SND_VIRTUOSO) [N/m/?] n
  Digigram VX222 (SND_VX222) [N/m/?] n
  Yamaha YMF724/740/744/754 (SND_YMFPCI) [N/m/?] n
#
# configuration written to .config
#
</pre>

**7. Vuelvo a contar el número de componentes que se han configurado para incluir en *vmlinuz* o como módulos.**

Si miro de nuevo cuantos módulos y componentes de *vmlinuz* se incluirían ahora en el fichero `.config`:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152# grep "=m" .config | wc -l
170

javier@debian:~/kernelLinux/linux-4.19.152# grep "=y" .config | wc -l
1423
</pre>

Observamos que he eliminado 3200 módulos y casi 600 componentes enlazados estáticamente.

**8. Realizo la primera compilación.**

Una vez tenemos el fichero `.config` reducido, vamos a realizar la compilación generando un paquete Debian (`.deb`), el cuál podremos instalar con la herramienta `dpkg -i`.

El comando para realizar esta compilación es `make bindep-pkg`, pero esto nos realizaría la compilación con un solo hilo. Es decir, utilizaría un hilo en vez de todos los posibles que podría utilizar en función de cada procesador. En mi caso poseo un **i7-9750H** que posee 6 núcleos y 12 hilos, por lo que estaría compilando con un solo hilo pudiendo realizar el proceso con 12 hilos, lo que disminuiría en una barbaridad el tiempo de compilación. Para establecer el número de hilos que van a llevar a cabo el proceso, introducimos la opción `-j` y el número de hilos.

Al final, introduzco *bindeb-pkg*, esto se encargará de, al terminar el proceso, generar un archivo `.deb` que posteriormente instalaremos con la utilidad `dpkg -i`.

Voy a realizar el primer intento de compilación con 11 hilos:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152# make -j 11 bindeb-pkg
  UPD     include/config/kernel.release
/bin/bash ./scripts/package/mkdebian
dpkg-buildpackage -r"fakeroot -u" -a$(cat debian/arch) -b -nc -uc
dpkg-buildpackage: información: paquete fuente linux-4.19.152
dpkg-buildpackage: información: versión de las fuentes 4.19.152-1
dpkg-buildpackage: información: distribución de las fuentes buster
dpkg-buildpackage: información: fuentes modificadas por root <root@debian>
dpkg-buildpackage: información: arquitectura del sistema amd64
dpkg-buildpackage: aviso: «debian/rules» no es un fichero ejecutable, reparando
 dpkg-source --before-build .
dpkg-checkbuilddeps: fallo: Unmet build dependencies: bc
dpkg-buildpackage: aviso: Las dependencias y conflictos de construcción no están satisfechas, interrumpiendo
dpkg-buildpackage: aviso: (Use la opción «-d» para anularlo.)
make[1]: *** [scripts/package/Makefile:80: bindeb-pkg] Error 3
make: *** [Makefile:1393: bindeb-pkg] Error 2
</pre>

Me ha devuelto un mensaje de error que indica que me falta una dependencia llamada `bc`. La instalo y realizo el segundo intento:

<pre>
apt install bc -y
</pre>

Segundo intento de compilación:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152# make -j 11 bindeb-pkg
/bin/bash ./scripts/package/mkdebian
dpkg-buildpackage -r"fakeroot -u" -a$(cat debian/arch) -b -nc -uc
dpkg-buildpackage: información: paquete fuente linux-4.19.152
dpkg-buildpackage: información: versión de las fuentes 4.19.152-1
dpkg-buildpackage: información: distribución de las fuentes buster
dpkg-buildpackage: información: fuentes modificadas por root <root@debian>
dpkg-buildpackage: información: arquitectura del sistema amd64
 dpkg-source --before-build .
 debian/rules build
make KERNELRELEASE=4.19.152 ARCH=x86 	KBUILD_BUILD_VERSION=1 KBUILD_SRC=
  SYSTBL  arch/x86/include/generated/asm/syscalls_32.h
  WRAP    arch/x86/include/generated/uapi/asm/bpf_perf_event.h
  SYSHDR  arch/x86/include/generated/asm/unistd_32_ia32.h
  UPD     include/generated/uapi/linux/version.h
  WRAP    arch/x86/include/generated/uapi/asm/poll.h
  SYSHDR  arch/x86/include/generated/asm/unistd_64_x32.h
error: Cannot generate ORC metadata for CONFIG_UNWINDER_ORC=y, please install libelf-dev, libelf-devel or elfutils-libelf-devel
  SYSTBL  arch/x86/include/generated/asm/syscalls_64.h
  HYPERCALLS arch/x86/include/generated/asm/xen-hypercalls.h
  SYSHDR  arch/x86/include/generated/uapi/asm/unistd_32.h
  SYSHDR  arch/x86/include/generated/uapi/asm/unistd_64.h
make[3]: *** [Makefile:1142: prepare-objtool] Error 1
make[3]: *** Se espera a que terminen otras tareas....
  SYSHDR  arch/x86/include/generated/uapi/asm/unistd_x32.h
make[2]: *** [debian/rules:4: build] Error 2
dpkg-buildpackage: fallo: debian/rules build subprocess returned exit status 2
make[1]: *** [scripts/package/Makefile:80: bindeb-pkg] Error 2
make: *** [Makefile:1393: bindeb-pkg] Error 2
</pre>

Me vuelve a reportar un fallo debido a falta de dependencias. Lo solucionaría instalando el paquete `libelf-dev`.

<pre>
apt install libelf-dev -y
</pre>

Tercer intento de compilación:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152# make -j 11 bindeb-pkg
/bin/bash ./scripts/package/mkdebian
dpkg-buildpackage -r"fakeroot -u" -a$(cat debian/arch) -b -nc -uc
dpkg-buildpackage: información: paquete fuente linux-4.19.152
dpkg-buildpackage: información: versión de las fuentes 4.19.152-1
dpkg-buildpackage: información: distribución de las fuentes buster
dpkg-buildpackage: información: fuentes modificadas por root <root@debian>
dpkg-buildpackage: información: arquitectura del sistema amd64
 dpkg-source --before-build .
 debian/rules build
make KERNELRELEASE=4.19.152 ARCH=x86 	KBUILD_BUILD_VERSION=1 KBUILD_SRC=
  DESCEND  objtool
  HOSTCC   /root/kernelLinux/linux-4.19.152/tools/objtool/fixdep.o
  HOSTCC  arch/x86/tools/relocs_32.o
  WRAP    arch/x86/include/generated/asm/dma-contiguous.h
  WRAP    arch/x86/include/generated/asm/early_ioremap.h
  WRAP    arch/x86/include/generated/asm/export.h
  UPD     include/generated/utsrelease.h
  WRAP    arch/x86/include/generated/asm/mcs_spinlock.h
  WRAP    arch/x86/include/generated/asm/mm-arch-hooks.h
  HOSTCC  arch/x86/tools/relocs_64.o
  HOSTCC  arch/x86/tools/relocs_common.o
  HOSTLD   /root/kernelLinux/linux-4.19.152/tools/objtool/fixdep-in.o
  HOSTCC  scripts/genksyms/genksyms.o
  LINK     /root/kernelLinux/linux-4.19.152/tools/objtool/fixdep
  CC      scripts/mod/empty.o
  HOSTCC  scripts/mod/mk_elfconfig
  YACC    scripts/genksyms/parse.tab.c
  LEX     scripts/genksyms/lex.lex.c
  YACC    scripts/genksyms/parse.tab.h
  HOSTCC  scripts/selinux/genheaders/genheaders
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/exec-cmd.o
  CC      scripts/mod/devicetable-offsets.s
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/help.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/pager.o
  MKELF   scripts/mod/elfconfig.h
  UPD     scripts/mod/devicetable-offsets.h
  HOSTCC  scripts/mod/sumversion.o
  HOSTCC  scripts/genksyms/parse.tab.o
  HOSTCC  scripts/genksyms/lex.lex.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/parse-options.o
  HOSTLD  arch/x86/tools/relocs
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/run-command.o
  HOSTCC  scripts/selinux/mdp/mdp
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/sigchain.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/subcmd-config.o
  CC      kernel/bounds.s
  UPD     include/generated/timeconst.h
  HOSTCC  scripts/bin2c
  HOSTCC  scripts/mod/modpost.o
  HOSTCC  scripts/mod/file2alias.o
  UPD     include/generated/bounds.h
  CC      arch/x86/kernel/asm-offsets.s
  GEN      /root/kernelLinux/linux-4.19.152/tools/objtool/arch/x86/lib/inat-tables.c
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/builtin-check.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/arch/x86/decode.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/builtin-orc.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/check.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/orc_gen.o
  HOSTCC  scripts/kallsyms
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/orc_dump.o
  HOSTCC  scripts/conmakehash
  HOSTCC  scripts/recordmcount
  LD       /root/kernelLinux/linux-4.19.152/tools/objtool/libsubcmd-in.o
  AR       /root/kernelLinux/linux-4.19.152/tools/objtool/libsubcmd.a
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/elf.o
  HOSTLD  scripts/genksyms/genksyms
  UPD     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  HOSTCC  scripts/sortextable
  HOSTCC  scripts/asn1_compiler
  LD       /root/kernelLinux/linux-4.19.152/tools/objtool/arch/x86/objtool-in.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/special.o
  HOSTCC  scripts/sign-file
scripts/sign-file.c:25:10: fatal error: openssl/opensslv.h: No existe el fichero o el directorio
 #include <openssl/opensslv.h>
          ^~~~~~~~~~~~~~~~~~~~
compilation terminated.
make[4]: *** [scripts/Makefile.host:90: scripts/sign-file] Error 1
make[4]: *** Se espera a que terminen otras tareas....
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/objtool.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/libstring.o
  CC       /root/kernelLinux/linux-4.19.152/tools/objtool/str_error_r.o
  HOSTLD  scripts/mod/modpost
make[3]: *** [Makefile:1089: scripts] Error 2
make[3]: *** Se espera a que terminen otras tareas....
  LD       /root/kernelLinux/linux-4.19.152/tools/objtool/objtool-in.o
  LINK     /root/kernelLinux/linux-4.19.152/tools/objtool/objtool
make[2]: *** [debian/rules:4: build] Error 2
dpkg-buildpackage: fallo: debian/rules build subprocess returned exit status 2
make[1]: *** [scripts/package/Makefile:80: bindeb-pkg] Error 2
make: *** [Makefile:1393: bindeb-pkg] Error 2
</pre>

¿Pensabais que iba a completar la compilación?

Pues no, me reportaría por tercera vez un error de dependencias, por lo tanto, voy a llevar a cabo la instalación del paquete necesario:

<pre>
apt install libssl-dev -y
</pre>

Esta vez ya sí completaría el proceso de compilación de los componentes que están incluidos en el fichero `.config`. Las últimas líneas tendrían este aspecto:

<pre>
dpkg-deb: construyendo el paquete `linux-headers-4.19.152' en `../linux-headers-4.19.152_4.19.152-1_amd64.deb'.
dpkg-deb: construyendo el paquete `linux-libc-dev' en `../linux-libc-dev_4.19.152-1_amd64.deb'.
dpkg-deb: construyendo el paquete `linux-image-4.19.152' en `../linux-image-4.19.152_4.19.152-1_amd64.deb'.
dpkg-deb: construyendo el paquete `linux-image-4.19.152-dbg' en `../linux-image-4.19.152-dbg_4.19.152-1_amd64.deb'.
 dpkg-genbuildinfo --build=binary
 dpkg-genchanges --build=binary >../linux-4.19.152_4.19.152-1_amd64.changes
dpkg-genchanges: información: binary-only upload (no source code included)
 dpkg-source --after-build .
dpkg-buildpackage: información: subida sólo de binarios (no se incluye ninguna fuente)
</pre>

Vemos como me ha creado correctamente una serie de archivos `.deb`, entre los cuáles se encuentra el llamado `linux-image-4.19.152_4.19.152-1_amd64.deb`, que es el que posteriormente voy a instalar con `dpkg -i`.

**9. Instalo el núcleo resultante de la compilación, reinicio el equipo y compruebo que funciona adecuadamente.**

Instalo el nuevo *kérnel*:

<pre>
dpkg -i linux-image-4.19.152_4.19.152-1_amd64.deb
</pre>

Reinicio el sistema arrancando con este nuevo *kérnel* y efectivamente, como era de esperar, el sistema corre perfectamente.

**10. Si ha funcionado adecuadamente, utilizamos la configuración del paso anterior como punto de partida y vamos a reducir de nuevo el tamaño del mismo, para ello vamos a seleccionar elemento a elemento.**

Copiamos la configuración del *kérnel* reducido ya una vez, de esta manera estaremos generando una copia de seguridad por si durante las pruebas tocamos algún módulo imprescindible y deseamos volver un paso atrás, ya que vamos a seguir reduciendo su tamaño. En mi caso simplemente cuando compruebo que he conseguido reducir un poco más el *kérnel*, copio el archivo `.config` a un directorio cualquiera, y si me es necesario, luego lo vuelvo a trasladar al área de trabajo.

<pre>
cp .config /home/javier/Documentos
</pre>

Instalamos los paquetes `pkg-config` y `qt4-dev-tools`, que son necesarios para ejecutar la herramienta gráfica (la cual utiliza las bibliotecas gráficas *Qt*) que vamos a utilizar para seguir con la configuración de nuestro núcleo. `pkg-config` es un sistema para gestionar las opciones de compilación y enlazado de las bibliotecas, funciona con *automake* y *autoconf*.

<pre>
apt install pkg-config qt4-dev-tools -y
</pre>

Cada vez que queramos realizar una nueva compilación, debemos limpiar el rastro del proceso anterior, para ello empleamos el comando:

<pre>
make clean
</pre>

Esta es una salida de un `make clean`:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152$ make clean
  CLEAN   .
  CLEAN   arch/x86/entry/vdso
  CLEAN   arch/x86/kernel/cpu
  CLEAN   arch/x86/kernel
  CLEAN   arch/x86/purgatory
  CLEAN   arch/x86/realmode/rm
  CLEAN   arch/x86/lib
  CLEAN   certs
  CLEAN   drivers/scsi
  CLEAN   drivers/tty/vt
  CLEAN   lib/raid6
  CLEAN   lib
  CLEAN   security/apparmor
  CLEAN   security/tomoyo
  CLEAN   usr
  CLEAN   arch/x86/boot/compressed
  CLEAN   arch/x86/boot
  CLEAN   arch/x86/tools
  CLEAN   .tmp_versions
</pre>

Ahora sí, podemos volver a iniciar el proceso de reducción del núcleo, y por tanto, abrimos la herramienta gráfica con el comando:  

<pre>
make xconfig
</pre>

Para empezar el proceso de compilación, ejecutamos el siguiente comando:

<pre>
make -j 12 bindeb-pkg
</pre>

Para instalar el paquete resultante `.deb`:

<pre>
sudo dpkg -i linux-image-4.19.152_4.19.152-1_amd64.deb
</pre>

En mi caso, esto es lo máximo que he podido reducir el *kérnel*. A continuación dejo una lista de todos los componentes eliminados. Si empieza por *m_* indica que se trata de un módulo:

##### General setup
- Support for paging of anonymous memory (swap)
- POSIX Message Queues
- Auditing support
- CPU isolation
- Kernel->user space relay support (formerly relayfs)
- m_Kernel .config support
- Automatic process group scheduling
- memory placement aware NUMA scheduler
- Checkpoint/restore support
- Enable bpf() system call
- Enable rseq() system call
- Enable VM event counters for /proc/vmstat
- Allow slab caches to be merged
- SLAB freelist randomization
- Harden slab freelist metadata
- profiling support
-   **Timers subsystem**
-   high resolution timer support
-   **CPU/Task time and stats accounting**
-   BSD process accounting
-   export task/process statistics through netlink
-   **Control Group support**
    - Swap controller
    - RDMA controller
    - Freezer controller
    - Cpuset controller
    - Support for eBPF programs attached to cgroups
- **Namespaces support** entero
- **Configure standard kernel features (expert users)**
    - BUG() support
    - Enable PC-Speaker suport
##### Processor type and features
- DMA memory allocation support
- Symmetric multi-processing support
- Avoid speculative indirect branches in kernel
- AMD ACPI2Platform devices support
- Intel SoC IOSF Sideband support for SoC platforms
- Single-depth WCHAN output
- Enable DMI scannning
- **Multi-core scheduler support** entero
- Reroute for broken boot IRQs
- Machine Check / overheating reporting
- old AMD GART IOMMU support
- IBM Calgary IOMMU support
- **Machine Check/overheating reporting**
    - AMD MCE features
- Enable vsyscall emulation
- **CPU microcode loading support** entero
- **Numa Memory Allocation and Scheduler Support**
- x86 architectural random number generator
- Supervisor Mode Access Prevention
- Intel User Mode Instruction Prevention
- Intel MPX (Memory Protection Extensions)
- Intel Memory Protection Keys
- Enable seccomp to safely compute untrusted bytecode
- kexec system call
- kexec file based system call
- Verify kernel signature during kexec_file_load() syscall
- kernel crash dumps
- **Build a relocatable kernel**
- Enable the LDT (local descriptor table)
    - **Linux guest support** entero
    - **Performance monitoring**
        - m_Intel uncore performance events
        - m_Intel rapl performance events
        - m_Intel cstate performance events
##### Power management and ACPI options
- suspend to RAM and standby
- hibernation
- device power management core functionality
- power management timer support
- **ACPI (Advanced Configuration and Power Interface) Support** entero
- **SFI (Simple Firmware Interface) Support**
- **CPU Frequency scaling**
    - **CPU Frequency scaling** entero
    - 'schedutil' cpufreq policy governor
    - Intel P state control
- **CPU Idle**
    - **CPU idle PM support** entero
##### Bus Options (PCI etc.)
- **PCI Express Port Bus support** entero
- Message Signaled Interrupts (MSI and MSI-X)
- Enable PCI quirk workarounds
- PCI IOV support
- PCI PRI support
- PCI PASID support
- ISA-style DMA support
  - **Support for PCI Hotplug**
  - **Binary Emulations**
      - **IA32 Emulation**
      - x32 ABI for 64-bit mode
##### Firmware Drivers
- Apple device properties
- virtualization
##### General architecture-dependent options
- kprobes
- optimize very unlikely/likely branches
- stack protector buffer overflow detection
- use a virtually-mapped stack
- perform full reference count validation at the expense of speed
- **Enable loadable modulo support**
    - Module versioning support
##### Enable the block layer
- Block layer SG support v4
- Block layer SG support v4 helper lib
- Block layer data integrity support
- Zoned block device support
- Block layer bio throttling support
- Enable support for block device writeback throttling
- Logic for interfacing with Opal enabled SEDs
- **Partition Types**
- acorn partition support
- alpha OSF partition support
- amiga partition table support
- atari partition table support
- macintosh partition map support
    - **PC BIOS (MSDOS partition tables) support**
    - Minix subpartition support
    - Solarix (x86) partition table support
    - Unixware slices support
    - **Windows Logical Disk Manager (Dynamic Disk) support**
- SGI partition support
- Ultrix partition table support
- sun partition tables support
- karma partition support
- **IO Schedulers**
- MQ deadline I/O scheduler
- **Executable file formats**
- Enable core dump support
- **Memory Management options**
- Sparse Memory virtual memmap
- Allow for memory hot-add
- Allow for memory compaction
    - **Transparent Hugepage Support** entero
- Low (Up to 2x) density storage for compressed pages
- Enable frontswap to cache swap pages if tmem is present
##### Networking support
- **Networking options**
    - Transformation sub policy support
    - Transformation migrate database
    - Security Marking
    - Data Center Bridging support
    - L3 Master device support
    - Network packet filtering framework
    - QoS and/or fair queueing
    - MultiProtocol Label Switching
    - Network priority cgroup
    - Network classid cgroup
    - enable BPF Just In Time compiler
    - enable BPF STREAM_PARSER
- Amateur Radio support
- Wireless
- m_Bluetooth subsystem support
- RF switch subsystem support
##### Device Drivers
- **Generic Driver Options**
    - Connector - unified userspace <-> kernelspace linker
    - **NVME Support**
    - NVMe multipath support
- **Misc devices**
- m_Intel Management Engine Interface
- m_ME Enabled Intel Chipsets
- **SCSI device support**
    - SCSI device support
    - Verbose SCSI error reporting (kernel size += 36K)
    - SCSI logging facility
    - Asynchronous SCSI sacnning
        - **SCSI Transports**
        - **SCSI low-level drivers**
        - **SCSI Device Handlers**
    - **Serial ATA and Parallel ATA drivers (libata)** entero
        - Verbose ATA error reporting
        - **ATA SFF support (for legacy IDE and PATA)**
    - **Multiple devices driver support (RAID and LVM)**
    - m_RAID support
    - Fusion MPT device support
    - Macintosh device drivers
- **Network device support**
    - **Network core driver support** entero
    - **FDDI driver support** entero
    - **HIPPI driver support** entero
    - **m_MDIO bus device drivers** entero
    - **m_PHY Device support and infrastructure** entero
    - Wireless LAN
    - Wan interfaces support
    - ISDN support
- **Input device support**
- m_Sparse keymap support library
- m_Mouse interface
- m_Joystick interface
- Joysticks/Gamepads
- Tablets
- Touchscreens
    - **Hardware I/O ports**
    - m_Raw accedd to serio ports
- **Character devices**
    - **Enable TTY**
        - **Virtual terminal**
            - Support for console on virtual terminal
            - Support for binding and unbinding console drivers
        - **Non-standard serial port support**
        - Automatically load TTY Line Disciplines
    - **I2C support** entero
    - **Serial drivers**
    - Support for sharing serial interrupts
    - Support RSA serial ports
    - Support for Synopsys DesignWare 8250 quirks
    - Support for serial ports in Intel MID platforms
    - m_Hardware Random Number Generator Core support
    - **m_IPMI top-level message handler** entero
    - **m_TPM Hardware Support** entero
- SPI support
- PPS support
    - **PTP clock support**
    - PTP clock support
- m_Hardware Monitoring support
- Generic Thermal sysfs driver
- Watchdog Timer Support
- Voltage and Current Regulator Support
- **GPIO Support**
    - **Multifunction device drivers**
        - m_Intel Low Power Subsystem support in PCI mode
- **Graphics support**
- VGA Arbitration
- Laptop Hybrid Graphics - GPU switching support
- Enable DisplayPort CEC-Tunneling-over-AUX- HDMI support
- /dev/agpgart (AGP support)
- m_Nouveau  (NVIDIA) cards
    - **Graphics support (Intel 8xx/9xx/G3x/G4x/HD Graphics)**
    - Enable capturing GPU state following a hang
    - Always enable userptr support
- m_Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)
    - **Frame buffer Devices**
    - Support for frame buffer devices
- Backlight & LCD device support
    - **Console display driver support**
- VGA text console
- m_Sound card support
- **HID Support**
    - **HID bus support** entero
    - **USB support** entero
    - **DMABUF options**
        - Explicit Syncrhonization Framework
    - X86 Platform Specific Device Drivers
- LED Support
- Accessibility support
- EDAC (Error Detection And Correction) reporting
- Real Time Clock
- DMA Engine support
- Virtualization drivers
- Virtio drivers
- Staging Drivers
- Platform support for Chrome hardware
- Mailbox Hardware Support
- IOMMU Hardware Support
- **SOC (System On Chip) specific Drivers**
    - **Generic Dynamic Voltage and Frequency Scaling (DVFS)**
        - Pulse-Width Modulation (PWM) Support
        - Generic powercap sysfs driver
    - **PHY Subsystem**
        - PHY Core
    - **Android**
        - **Android Drivers**
##### File systems
- m_Btrfs filesystems support
- Quota support
- Report quota messages through netlink interface
- m_Kernel automonter support (supports v3, v4 and v5)
- m_FUSE (Filesystem in Userspace) support
- **Pseudo filesystems**
    - Include /proc/<pid>/task/<tid>/children file
    - HugeTLB file system support
- **Miscellaneius filesystems**
- **Network File Systems**
- **Security options**
- Restrict unprivileged access to the kernel syslog
- Enable different security models
- NSA SELinux Support
    - **TOMOYO Linux Support**
    - **AppArmor support**
    - **Yama support**
##### Cryptographic API
- FIPS 200 compilance
- m_ECDH algorithm
- m_GF(2^128) multiplication functions
- m_Null algorithms
- m_Software async crypto daemon
- m_CCM support
- m_GCM/GMAC support
- m_Sequence Number IV Generator
- m_CTR support
- m_ECB support
- m_CMAC support
- m_CRC32 INTEL hardware acceleration
- m_CRC32 PCLMULQDQ hardware acceleration
- m_CRCT10DIF PCLMULQDQ hardware acceleration
- m_GHASH digest algorithm
- m_GHASH digest algorithm (CLMNUL-NI accelerated)
- m_GHASH digest algorithm
- m_AES cipher algorithms (x86_64)
- m_AES cipher algorithms (AES-NI)
- m_ARC4 cipher algorithm
- Deflate compression algorithm
- LZO compression algorithm
- m_Pseudo Random Number Generation for Cryptographic modules
- Jitterentropy Non-Deterministic Random Number Generator
- m_NIST SP800-90A DRBG
- Hardware crypto devices (Support for AMD secure processor)
- **Asymmetric**
- Support for PE file signature verification
- **Certificates for signature checking**
- Provide a keyring to which extra trustable keys may be added
- Provide system-wide ring of blacklisted keys
- **Library routines**
- m_CRC16 functions
- m_CRC32c (Castagnoli, et al) Cyclic Redundancy-Check
    - **XZ decompression support**
    - x86 BCJ filter decoder
- IRQ polling library
##### Kernel hacking
- Collect scheduler debbuging info
- Collect scheduler statistics
- Detect stack corruption on calls to schedule
- Stack backtrace support
- Verbose BUG() reporting (addds 70K)
- Debug linked list manipulation
- Memtest
- Tigger a BUG when data corruption is detected
- **Early printk**
- Warn on W+X mappings at boot
- Enable doublefault exception handler
- Allow gcc to uninline functions marked 'inline'
- Debug the x86 FPU code
- **printk and dmesg options**
    - Show timing information on printks
    - Delay each boot printk message by N milliseconds
    - Enable dynamic printk() support
- **Compile-time checks and compiler options**
    - Compile the kernel with debug info
    - Enable __must_check logic
    - Strip assembler-generated symbols during link
    - Debug Filesystems
    - Make section mismatch errors non-fatal
- **Memory Debugging**
    - Extend memmap on extra space for more information on page
    - Poison pages after freeing
    - Debug memory initialisation
- **Debug Lockups and Hangs**
    - Detect Soft Lockups
    - Detect Hard Lockups
    - Detect Hung Tasks
- Tracers
- Runtime Testing

Si cuento cuántos módulos y cuántos enlaces estáticos forman ahora el núcleo:

<pre>
javier@debian:~/kernelLinux/linux-4.19.152$ grep "=m" .config | wc -l
16

javier@debian:~/kernelLinux/linux-4.19.152$ grep "=y" .config | wc -l
615
</pre>

Si observamos cuanto ocupa ahora el paquete *.deb*:

<pre>
javier@debian:~/kernelLinux$ du -hs * | grep 'linux-image'
3,0M	linux-image-4.19.152_4.19.152-103_amd64.deb
</pre>

Podemos observar que he conseguido reducir el número de componentes en una gran cantidad. Los módulos se han reducido de 170 hasta 16, es decir, más de 10 veces menos y he eliminado más de 800 enlaces que se incluirán en *vmlinuz*. A consecuencia de esto, el peso del paquete *.deb* resultante es de 3.0 MB.

Puedes descargar el paquete *.deb* [aquí](https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/aso_compilacion_de_un_kernel_linux_a_medida/linux-image-4.19.152_4.19.152-103_amd64.deb).
