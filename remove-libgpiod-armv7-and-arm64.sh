#!/bin/bash
# Remove libgpiod for ARM64 and ARM32
# Script version: 2.1
# C library and tools for interacting with the linux GPIO character device
# https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/
# $1 - library release number: 1.6.3
# $2 - library installation folder (default : /usr/share/libgpiod)
#=================================================================
# Run: sudo ./remove-libgpiod-armv7-and-arm64 1.6.3 /usr/share/libgpiod
# or
# Run: sudo ./remove-libgpiod-armv7-and-arm64 1.6.3
#=================================================================
# DevDotNet.ORG <anton@devdotnet.org> MIT License

set -e
#
LIBGPIOD_VERSION="$1"
INSTALLPATH="$2"
ARMBIT=$(uname -m) #aarch64 or armv7l
#
if [ -z $LIBGPIOD_VERSION ]; then
	echo "Error: library version not specified"
	exit 1;
fi

if [ -z $INSTALLPATH ]; then
	INSTALLPATH=/usr/share/libgpiod
fi

echo "==============================================="
echo "Removing Libgpiod library" 
echo "Removing the Libgpiod library version:" $LIBGPIOD_VERSION
echo "Library installation path:" $INSTALLPATH
echo "==============================================="
echo ""
echo "=====================Remove====================="
#
if [ -d ~/libgpiod-$LIBGPIOD_VERSION ]; then
	rm -rfv ~/libgpiod-$LIBGPIOD_VERSION    
fi
if [ -d $INSTALLPATH ]; then
	rm -rfv $INSTALLPATH    
fi
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
#aarch64
if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.a ]; then
	rm /usr/lib/aarch64-linux-gnu/libgpiod.a    
fi
if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.la ]; then
	rm /usr/lib/aarch64-linux-gnu/libgpiod.la    
fi
if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.so ]; then
	rm /usr/lib/aarch64-linux-gnu/libgpiod.so    
fi
if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.so.2 ]; then
	rm /usr/lib/aarch64-linux-gnu/libgpiod.so.2    
fi
if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.so.2.2.2 ]; then
	rm /usr/lib/aarch64-linux-gnu/libgpiod.so.2.2.2    
fi
#armv7l
if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.a ]; then
	rm /usr/lib/arm-linux-gnueabihf/libgpiod.a    
fi
if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.la ]; then
	rm /usr/lib/arm-linux-gnueabihf/libgpiod.la    
fi
if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.so ]; then
	rm /usr/lib/arm-linux-gnueabihf/libgpiod.so    
fi
if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.so.2 ]; then
	rm /usr/lib/arm-linux-gnueabihf/libgpiod.so.2    
fi
if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.so.2.2.2 ]; then
	rm /usr/lib/arm-linux-gnueabihf/libgpiod.so.2.2.2    
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
if [ $ARMBIT == "aarch64" ]; then
	#aarch64	
	if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.a ]; then
		rm /usr/lib/aarch64-linux-gnu/libgpiod.a    
	fi
	
	if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.la ]; then
		rm /usr/lib/aarch64-linux-gnu/libgpiod.la   
	fi
	
	if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.so ]; then
		rm /usr/lib/aarch64-linux-gnu/libgpiod.so    
	fi
	
	if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.so.2 ]; then
		rm /usr/lib/aarch64-linux-gnu/libgpiod.so.2    
	fi
	
	if [ -h /usr/lib/aarch64-linux-gnu/libgpiod.so.2.2.2 ]; then
		rm /usr/lib/aarch64-linux-gnu/libgpiod.so.2.2.2    
	fi	
else
	#armv7l
	if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.a ]; then
		rm /usr/lib/arm-linux-gnueabihf/libgpiod.a    
	fi
	
	if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.la ]; then
		rm /usr/lib/arm-linux-gnueabihf/libgpiod.la   
	fi
	
	if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.so ]; then
		rm /usr/lib/arm-linux-gnueabihf/libgpiod.so    
	fi
	
	if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.so.2 ]; then
		rm /usr/lib/arm-linux-gnueabihf/libgpiod.so.2    
	fi
	
	if [ -h /usr/lib/arm-linux-gnueabihf/libgpiod.so.2.2.2 ]; then
		rm /usr/lib/arm-linux-gnueabihf/libgpiod.so.2.2.2    
	fi
fi
echo "==============================================="
echo "Successfully"