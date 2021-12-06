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
rm -rfv ~/libgpiod-* &>/dev/null || echo "libgpiod-* has been removed" 

if [ -d $INSTALLPATH ]; then
	rm -rfv $INSTALLPATH    
fi
#
LIB_FOLDER=""
case $ARMBIT in

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
#bin
rm /usr/bin/gpiodetect &>/dev/null || echo "gpiodetect has been removed"
rm /usr/bin/gpiofind &>/dev/null || echo "gpiofind has been removed"
rm /usr/bin/gpioget &>/dev/null || echo "gpioget has been removed"
rm /usr/bin/gpioinfo &>/dev/null || echo "gpioinfo has been removed"
rm /usr/bin/gpiomon &>/dev/null || echo "gpiomon has been removed"
rm /usr/bin/gpioset &>/dev/null || echo "gpioset has been removed"
#/usr/lib
rm /usr/lib/$LIB_FOLDER/libgpiod.a &>/dev/null || echo "libgpiod.a has been removed"
rm /usr/lib/$LIB_FOLDER/libgpiod.la &>/dev/null || echo "libgpiod.la has been removed"
rm /usr/lib/$LIB_FOLDER/libgpiod.so &>/dev/null || echo "libgpiod.so has been removed"
rm /usr/lib/$LIB_FOLDER/libgpiod.so.2 &>/dev/null || echo "libgpiod.so.2 has been removed"
rm /usr/lib/$LIB_FOLDER/libgpiod.so.2.2.2 &>/dev/null || echo "libgpiod.so.2.2.2 has been removed"
#
echo "==============================================="
echo "Successfully"