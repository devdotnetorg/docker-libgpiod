#!/bin/bash
# Remove libgpiod for ARM64, ARM32, x86_64
# Script version: 2.2
# C library and tools for interacting with the linux GPIO character device
# https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/
# $1 - library installation folder (default : /usr/share/libgpiod)
#=================================================================
# Run:  chmod +x remove-libgpiod.sh
# 		sudo ./remove-libgpiod.sh /usr/share/libgpiod
#=================================================================
# DevDotNet.ORG <anton@devdotnet.org> MIT License

set -e
#
INSTALLPATH="$1"
ARMBIT=$(uname -m) #aarch64, armv7l, or x86_64
#
if [ -z $INSTALLPATH ]; then
	INSTALLPATH=/usr/share/libgpiod
fi

echo "==============================================="
echo "Removing Libgpiod library" 
echo "Library installation path:" $INSTALLPATH
echo "==============================================="
echo ""
echo "=====================Remove====================="
#
rm -rfv ~/libgpiod-*

if [ -d $INSTALLPATH ]; then
	rm -rfv $INSTALLPATH    
fi
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
# Removing ln
echo "============Removing symbolic links============"
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
#all
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
#
echo "==============================================="
echo "Successfully"