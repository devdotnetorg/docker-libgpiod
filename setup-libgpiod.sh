#!/bin/bash
# Setup libgpiod for ARM64, ARM32, x86_64
# Script version: 2.2
# C library and tools for interacting with the linux GPIO character device
# https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/
# $1 - library release number: 1.6.3
# $2 - library installation folder (default : /usr/share/libgpiod)
#=================================================================
# Run:	chmod +x setup-libgpiod.sh
# 		sudo ./setup-libgpiod.sh 1.6.3 /usr/share/libgpiod
# or
# Run:	chmod +x setup-libgpiod.sh
# 		sudo ./setup-libgpiod.sh 1.6.3
#=================================================================
# DevDotNet.ORG <anton@devdotnet.org> MIT License

set -e
#
LIBGPIOD_VERSION="$1"
INSTALLPATH="$2"
ARMBIT=$(uname -m) #aarch64, armv7l, or x86_64
#
if [ -z $LIBGPIOD_VERSION ]; then
	echo "Error: library version not specified"
	exit 1;
fi

if [ -z $INSTALLPATH ]; then
	INSTALLPATH=/usr/share/libgpiod
fi

echo "==============================================="
echo "Libgpiod library installation" 
echo "Installing the Libgpiod library version:" $LIBGPIOD_VERSION
echo "Library installation path:" $INSTALLPATH
echo "==============================================="
echo ""
echo "=====================Setup====================="
apt-get update
apt-get install -y curl autoconf automake autoconf-archive libtool pkg-config tar make
curl -SL --output libgpiod.tar.gz https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-$LIBGPIOD_VERSION.tar.gz
tar -ozxf libgpiod.tar.gz -C ~/
rm libgpiod.tar.gz
cd ~/libgpiod-$LIBGPIOD_VERSION
mkdir -p $INSTALLPATH
mkdir -p $INSTALLPATH/share
chmod +x autogen.sh
./autogen.sh --enable-tools=yes --prefix=$INSTALLPATH ac_cv_func_malloc_0_nonnull=yes
make
make install
#
LIB_FOLDER=""
case $LIB_FOLDER in

  aarch64)
    LIB_FOLDER="aarch64-linux-gnu"
    ;;

  armv7l)
    LIB_FOLDER="arm-linux-gnueabihf"
    ;;

  x86_64)
    LIB_FOLDER="x86_64-linux-gnu"
    ;;

  *)
    LIB_FOLDER=""
    ;;
esac
# create ln
echo "============Creating symbolic links============"
#
if [ -h /usr/bin/gpiodetect ]; then
	rm /usr/bin/gpiodetect    
fi
if [ -h /usr/bin/gpiofind ]; then
	rm /usr/bin/gpiofind    
fi
if [ -h /usr/bin/gpioget ]; then
	rm /usr/bin/gpioget    
fi
if [ -h /usr/bin/gpioinfo ]; then
	rm /usr/bin/gpioinfo    
fi
if [ -h /usr/bin/gpiomon ]; then
	rm /usr/bin/gpiomon    
fi
if [ -h /usr/bin/gpioset ]; then
	rm /usr/bin/gpioset    
fi
#/usr/lib
if [ -h /usr/lib/$LIB_FOLDER/libgpiod.a ]; then
	rm /usr/lib/$LIB_FOLDER/libgpiod.a    
fi
if [ -h /usr/lib/$LIB_FOLDER/libgpiod.la ]; then
	rm /usr/lib/$LIB_FOLDER/libgpiod.la    
fi
if [ -h /usr/lib/$LIB_FOLDER/libgpiod.so ]; then
	rm /usr/lib/$LIB_FOLDER/libgpiod.so    
fi
if [ -h /usr/lib/$LIB_FOLDER/libgpiod.so.2 ]; then
	rm /usr/lib/$LIB_FOLDER/libgpiod.so.2    
fi
if [ -h /usr/lib/$LIB_FOLDER/libgpiod.so.2.2.2 ]; then
	rm /usr/lib/$LIB_FOLDER/libgpiod.so.2.2.2    
fi
#set all
ln -s $INSTALLPATH/bin/gpiodetect /usr/bin/gpiodetect
ln -s $INSTALLPATH/bin/gpiofind /usr/bin/gpiofind
ln -s $INSTALLPATH/bin/gpioget /usr/bin/gpioget
ln -s $INSTALLPATH/bin/gpioinfo /usr/bin/gpioinfo
ln -s $INSTALLPATH/bin/gpiomon /usr/bin/gpiomon
ln -s $INSTALLPATH/bin/gpioset /usr/bin/gpioset
#set libs
ln -s $INSTALLPATH/lib/libgpiod.a /usr/lib/$LIB_FOLDER/libgpiod.a
ln -s $INSTALLPATH/lib/libgpiod.la /usr/lib/$LIB_FOLDER/libgpiod.la
ln -s $INSTALLPATH/lib/libgpiod.so.2.2.2 /usr/lib/$LIB_FOLDER/libgpiod.so
ln -s $INSTALLPATH/lib/libgpiod.so.2.2.2 /usr/lib/$LIB_FOLDER/libgpiod.so.2
ln -s $INSTALLPATH/lib/libgpiod.so.2.2.2 /usr/lib/$LIB_FOLDER/libgpiod.so.2.2.2
#
cp -R $INSTALLPATH/share/ /usr/lib/$LIB_FOLDER/
#
echo "==============================================="

echo "Successfully"