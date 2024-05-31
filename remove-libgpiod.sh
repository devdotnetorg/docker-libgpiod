#!/bin/bash
# Remove libgpiod for for ARM64, ARM32, x86_64, RISC-V
# C library and tools for interacting with the linux GPIO character device
# Site: https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
# Script version: 3.0
# arguments:
# -p|--path: library installation folder (default: /usr/share/libgpiod).
#=================================================================
# Run:	chmod +x remove-libgpiod.sh
# 		sudo ./remove-libgpiod.sh -p /usr/share/libgpiod
# or
# Run:	chmod +x remove-libgpiod.sh
# 		sudo ./remove-libgpiod.sh
#=================================================================
# DevDotNet.ORG <anton@devdotnet.org> MIT License

set -e

# definition of variables
declare ARCH_OS=$(uname -m) #aarch64, armv7l, x86_64 or riscv64
declare ID_OS=("$(cat /etc/*release | grep '^ID=' | sed 's/.*=\s*//')") # ubuntu, debian, alpine

# requirements check
if [ $ARCH_OS != "aarch64" ] && [ $ARCH_OS != "armv7l" ] \
 && [ $ARCH_OS != "x86_64" ]&& [ $ARCH_OS != "riscv64" ]; then
	echo "ERROR. Current OS architecture ${ARCH_OS} is not supported."
	exit 1;
fi

if [ $ID_OS != "ubuntu" ] && [ $ID_OS != "debian" ] && [ $ID_OS != "alpine" ]; then
	echo "ERROR. Current OS ${ID_OS} not supported."
	exit 1;
fi

# reading arguments from CLI
wPOSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--path)
      INSTALL_PATH="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

# defining default values
if [ -z $INSTALL_PATH ]; then
	INSTALL_PATH="/usr/share/libgpiod"
fi

echo "==============================================="
echo "Removing Libgpiod library" 
echo "Library installation path:" $INSTALL_PATH
echo "==============================================="
echo ""
echo "===================== Remove ====================="
echo "Please wait for the end ..."

# Package removal
if [ $ID_OS != "alpine" ]; then
	# ubuntu, debian
	export DEBIAN_FRONTEND="noninteractive"
	sudo apt-get remove -y libgpiod-doc &>/dev/null || echo "Package libgpiod-doc has been removed"
	sudo apt-get remove -y python3-libgpiod &>/dev/null || echo "Package python3-libgpiod has been removed"
	sudo apt-get remove -y gpiod &>/dev/null || echo "Package gpiod has been removed"
	sudo apt-get remove -y libgpiod-dev &>/dev/null || echo "Package libgpiod-dev has been removed"
	# Clear
	sudo apt-get clean autoclean -y
	sudo apt-get autoremove -y
else
	# alpine
	apk delete libgpiod-doc &>/dev/null || echo "Package libgpiod-doc has been removed"
	apk delete py3-libgpiod &>/dev/null || echo "Package py3-libgpiod has been removed"
	apk delete libgpiod &>/dev/null || echo "Package libgpiod has been removed"
	apk delete libgpiod-dev &>/dev/null || echo "Package libgpiod-dev has been removed"
fi

# INSTALL_PATH
if [ -d $INSTALL_PATH ]; then
	sudo rm -rfv $INSTALL_PATH  
	echo "${INSTALL_PATH} has been removed"
fi

# Clear
sudo rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/* $HOME/.cache

# Folders
LIB_FOLDER=""
case $ARCH_OS in

  aarch64)
    LIB_FOLDER="aarch64-linux-gnu"
    ;;

  armv7l)
    LIB_FOLDER="arm-linux-gnueabihf"
    ;;

  x86_64)
    LIB_FOLDER="x86_64-linux-gnu"
    ;;

  riscv64)
    LIB_FOLDER="riscv64-linux-gnu"
    ;; 

  *)
    LIB_FOLDER=""
    ;;
esac

# Removing ln
echo "============ Deleting binary files ============"
# /usr/bin
# ubuntu, debian, alpine
sudo rm /usr/bin/gpio* &>/dev/null || echo "bin/gpio* has been removed"
# /usr/include
# ubuntu, debian, alpine
sudo rm -r /usr/include/gpiod* &>/dev/null || echo "include/gpiod* has been removed"
# /usr/lib
# ubuntu, debian
sudo rm /usr/lib/$LIB_FOLDER/libgpiod* &>/dev/null || echo "libgpiod* has been removed"
sudo rm /usr/lib/$LIB_FOLDER/pkgconfig/libgpiod* &>/dev/null || echo "pkgconfig/libgpiod* has been removed"
# alpine
sudo rm /usr/lib/libgpiod* &>/dev/null || echo "libgpiod* has been removed"
sudo rm /usr/lib/pkgconfig/libgpiod* &>/dev/null || echo "pkgconfig/libgpiod* has been removed"
# /usr/share/
# ubuntu, debian, alpine
sudo rm /var/lib/dpkg/info/libgpiod* &>/dev/null || echo "dpkg/info libgpiod* has been removed"
sudo rm -r /usr/share/doc/libgpiod* &>/dev/null || echo "doc/libgpiod* has been removed"
# /usr/share/man
# ubuntu, debian, alpine
sudo rm -r /usr/share/man/man1/gpio* &>/dev/null || echo "share/man/man1/gpio* has been removed"

echo "==============================================="
echo "Successfully"
exit 0;