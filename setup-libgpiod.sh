#!/bin/bash
# Setup libgpiod for ARM64, ARM32, x86_64, RISC-V
# C library and tools for interacting with the linux GPIO character device
# Site: https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
# Script version: 4.5
# arguments:
# 1) -t|--type: installation type;
#		binary - installation from binaries;
#		source - installation from source;
#		findver - find out the version in the repository;
#		repo - installation from the repository.
# 2) -v|--version: library release number. Only for types 'binary' and 'source'. Options available: '2.1.2' '2.0.2' '1.6.4' '1.6.3'.
# 3) -f|--file: name of the binary file to install. Only for type 'binary'. Source: https://github.com/devdotnetorg/docker-libgpiod/blob/dev/out/list.txt
# 4) -c|--canselect: selection of build, values: yes, no (default: yes). Only for type 'binary'. 
# 5) -o|--options: argument string to build the library. Only for type 'source' (default: --enable-tools=yes --enable-bindings-cxx --enable-bindings-python ac_cv_func_malloc_0_nonnull=yes).
# 6) -p|--path: library installation folder (default: /usr/share/libgpiod). Only for type 'source'.
# The project is compiled in this folder, then the binary files are transferred to the Linux system folders.
# 7) -a|--artifact: save artifact after build from source, values: yes, no (default: no). Only for type 'source'.
#=================================================================
# Run:	chmod +x setup-libgpiod.sh
# 		sudo ./setup-libgpiod.sh --type source --path /usr/share/libgpiod --version 2.1.2 --options "--enable-tools=yes --enable-bindings-cxx --enable-bindings-python ac_cv_func_malloc_0_nonnull=yes"
# or
# Run:	chmod +x setup-libgpiod.sh
# 		sudo ./setup-libgpiod.sh
#=================================================================
# DevDotNet.ORG <anton@devdotnet.org> MIT License

set -e

# **************** definition of variables ****************
declare ARCH_OS=$(uname -m) #aarch64, armv7l, x86_64 or riscv64
declare ID_OS=("$(cat /etc/*release | grep '^ID=' | sed 's/.*=\s*//')") # ubuntu, debian, alpine
declare VERSION_OS=("$(cat /etc/*release | grep '^VERSION_ID=' | sed 's/.*=\s*//')")
VERSION_OS=("$(echo ${VERSION_OS} | sed 's/\"//g')")
# get only type XX.YY
VERSION_OS=("$(cut -d '.' -f 1 <<< "$VERSION_OS")"."$(cut -d '.' -f 2 <<< "$VERSION_OS")")

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

# Folders
declare LIB_FOLDER=""
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
# *********************************************************
# *************** reading arguments from CLI **************
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--type)
      TYPE_SETUP="$2"
      shift # past argument
      shift # past value
      ;;
	-f|--file)
      FILENAME_BIN="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--path)
      INSTALL_PATH="$2"
      shift # past argument
      shift # past value
      ;;
    -v|--version)
      LIB_VERSION="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--options)
      BUILD_ARG="$2"
      shift # past argument
      shift # past value
      ;; 
    -c|--canselect)
      CAN_SELECT="$2"
      shift # past argument
      shift # past value
      ;;
    -a|--artifact)
      ARTIFACT="$2"
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
# *********************************************************
# ************************** func *************************
# update
funcUpdate() {
echo "Updating package information"
if [ $ID_OS != "alpine" ]; then
	# ubuntu, debian
	sudo apt-get update
else
	# alpine
	sudo apk update
fi
}
# findver
funcFindVer() {
echo "Check the version of Libgpiod in the repository"
if [ $ID_OS != "alpine" ]; then
	# ubuntu, debian
	declare VER_LIB_REPO=$(apt list libgpiod-dev | grep '^libgpiod-dev')
else
	# alpine
	declare VER_LIB_REPO=$(apk list libgpiod-dev | grep '^libgpiod-dev')
fi
echo "Latest available version in the repository: ${VER_LIB_REPO}"
}

# repo
funcRepo() {
echo "Install Libgpiod from repository"
if [ $ID_OS != "alpine" ]; then
	# ubuntu, debian
	sudo apt-get install -y -f libgpiod-dev gpiod python3-libgpiod libgpiod-doc
else
	# alpine
	sudo apk add --no-cache --upgrade libgpiod-dev libgpiod py3-libgpiod libgpiod-doc
fi
}

# check version
funcCheckVer() {
echo "Check:"
gpiodetect --version
}
# *********************************************************
# ************************** show *************************
echo "==============================================="
echo "Libgpiod library installation"
echo -e "The latest version of the Libgpiod library is \033[1;32m 2.1.2 \033[0m"
echo "==============================================="
# *********************************************************
# *************** checking input parameters ***************
# TYPE_SETUP
# LIB_VERSION
# CAN_SELECT
# INSTALL_PATH
# BUILD_ARG
# ARTIFACT
# *********
# TYPE_SETUP
if [ -z $TYPE_SETUP ]; then
	PS3="Choose the type of Libgpiod library installation. Please enter your choice (recommended: 4): "
	options=("Check the version in the repository" "Installation from repository" "Install from source" "Installation from binaries" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Check the version in the repository")
				TYPE_SETUP="findver"
				break;
				;;
			"Installation from repository")
				TYPE_SETUP="repo"
				break;
				;;
			"Install from source")
				TYPE_SETUP="source"
				break;
				;;
			"Installation from binaries")
				TYPE_SETUP="binary"
				break;
				;;
			"Quit")
				exit 0;
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
	echo "You choosed: $TYPE_SETUP" 
fi
# LIB_VERSION
if [ -z $LIB_VERSION ]; then
	if [ $TYPE_SETUP == "binary" ] || [ $TYPE_SETUP == "source" ]; then
		if [ -z $FILENAME_BIN ]; then
			PS3="Select version of Libgpiod library. Please enter your choice (recommended: 1): "
			options=('2.1.2' '2.0.2' '1.6.4' '1.6.3' 'Quit')
			select opt in "${options[@]}"
			do
				case $opt in
					'2.1.2')
						LIB_VERSION="2.1.2"
						break;
						;;
					'2.0.2')
						LIB_VERSION="2.0.2"
						break;
						;;
					'1.6.4')
						LIB_VERSION="1.6.4"
						break;
						;;
					'1.6.3')
						LIB_VERSION="1.6.3"
						break;
						;;
					'Quit')
						exit 0;
						;;
					*) echo "invalid option $REPLY";;
				esac
			done
			echo "You choosed: ${LIB_VERSION}"
		fi
	fi
fi
# CAN_SELECT
if [ -z $CAN_SELECT ]; then
	if [ $TYPE_SETUP == "binary" ]; then
		CAN_SELECT="yes"
	fi
fi
# INSTALL_PATH
if [ -z $INSTALL_PATH ]; then
	if [ $TYPE_SETUP == "source" ]; then
		INSTALL_PATH=/usr/share/libgpiod
	fi
fi
# BUILD_ARG
if [ -z $BUILD_ARG ]; then
	if [ $TYPE_SETUP == "source" ]; then
		BUILD_ARG="--enable-tools=yes --enable-bindings-cxx \
		--enable-bindings-python ac_cv_func_malloc_0_nonnull=yes"
		# lib 2.1.2 2.1.1 2.1 2.0.2 2.0.1 2.0 in ubuntu 20.04, 18.04 - not support python
		if [ "${LIB_VERSION}" == "2.1.2" ] || [ "${LIB_VERSION}" == "2.1.1" ] \
		 || [ "${LIB_VERSION}" == "2.1" ] ||  [ "${LIB_VERSION}" == "2.0.2" ] \
		 || [ "${LIB_VERSION}" == "2.0.1" ] || [ "${LIB_VERSION}" == "2.0" ]; then
			if [ $ID_OS == "ubuntu" ]; then
				if [ "${VERSION_OS}" == "20.04" ]; then
					#
					BUILD_ARG="--enable-tools=yes --enable-bindings-cxx ac_cv_func_malloc_0_nonnull=yes"
					END_NAME_ARTIFACT="-without_support_python"
					echo "WARNING! $ID_OS ${VERSION_OS} builds libgpiod without PYTHON support."
					#
				fi
				if [ "${VERSION_OS}" == "18.04" ]; then
					#
					BUILD_ARG="--enable-tools=yes ac_cv_func_malloc_0_nonnull=yes"
					END_NAME_ARTIFACT="-without_support_python_and_cxx"
					echo "WARNING! $ID_OS ${VERSION_OS} builds libgpiod without PYTHON and C++ support."
					#
				fi
			fi
		fi
		# lib 2.1.2 2.1.1 2.1 in debian 11 - not support python
		if [ "${LIB_VERSION}" == "2.1.2" ] || [ "${LIB_VERSION}" == "2.1.1" ] \
		 || [ "${LIB_VERSION}" == "2.1" ]; then
			if [ $ID_OS == "debian" ]; then
				if [ "${VERSION_OS}" == "11.11" ]; then
					#
					BUILD_ARG="--enable-tools=yes --enable-bindings-cxx ac_cv_func_malloc_0_nonnull=yes"
					END_NAME_ARTIFACT="-without_support_python"
					echo "WARNING! $ID_OS ${VERSION_OS} builds libgpiod without PYTHON support."
					#
				fi
			fi
		fi
	fi
fi
# ARTIFACT
if [ -z $ARTIFACT ]; then
	if [ $TYPE_SETUP == "source" ]; then
		ARTIFACT="no"
	fi
fi
# *********************************************************
# ************************** show *************************
echo "==============================================="
echo "Libgpiod library installation"
echo "==============================================="
echo "Options:"
echo "Processor architecture: ${ARCH_OS}"
echo "OS name: ${ID_OS}"
echo "OS version: ${VERSION_OS}"
echo "Type of instalation: ${TYPE_SETUP}"
if [ "${LIB_VERSION}" != "" ]; then
	echo "Installing the Libgpiod library version: ${LIB_VERSION}"
fi
if [ "${CAN_SELECT}" != "" ]; then
	echo "Can select: ${CAN_SELECT}"
fi
if [ "${INSTALL_PATH}" != "" ]; then
	echo "Library installation path: ${INSTALL_PATH}"
	echo "Libgpiod library build arguments: ${BUILD_ARG}"
	echo "Save artifact: ${ARTIFACT}"
fi
echo "==============================================="
echo ""
echo "==================== Setup ===================="
# *********************************************************
# ************************* Install ***********************
# TYPE_SETUP = "findver", "repo", "source", "binary"
if [ "${TYPE_SETUP}" == "findver" ]; then
	funcUpdate
	funcFindVer
	echo "==============================================="
	echo "Successfully"
	exit 0;
fi
# **********
if [ "${TYPE_SETUP}" == "repo" ]; then
	funcUpdate
	funcRepo
fi
# **********
if [ "${TYPE_SETUP}" == "source" ]; then
	echo "Install Libgpiod from source"
	funcUpdate
	# remove
	if [ -d $INSTALL_PATH ]; then
		sudo rm -rfv $INSTALL_PATH  
		echo "${INSTALL_PATH} has been removed"
	fi
	# only for ubuntu
	if [ $ID_OS == "ubuntu" ]; then
		# for python3
		sudo apt-get install -y --install-recommends ubuntu-drivers-common
	fi
	
	if [ $ID_OS != "alpine" ]; then
		# ubuntu, debian
		sudo apt-get install -y curl wget ca-certificates autoconf automake autoconf-archive libtool pkg-config tar zip gzip
		sudo update-ca-certificates
		sudo apt-get install -y gawk mawk gcc make g++ libclang-dev doxygen help2man linux-headers-generic
		# python3
		sudo apt-get install -y --install-recommends python3 python3-dev python3-setuptools python3-venv
		# Python3-distutils removed in Ubuntu Noble Numbat 24.04
		if [ $ID_OS == "ubuntu" ]; then
			if [ "${VERSION_OS}" == "24.04" ]; then
				#
				sudo apt-get install -y --install-recommends python3-setuptools
				#
			else
				#
				sudo apt-get install -y --install-recommends python3-distutils
				#
			fi
		fi
		# fix python3 path
		alias python='python3'
		sudo ln -sf /usr/bin/python3 /usr/bin/python
		sudo ln -sf /usr/bin/python3-config /usr/bin/python-config
		# for Rust: cargo
		sudo mkdir -p $INSTALL_PATH/source
		cd $INSTALL_PATH/source
		sudo wget --no-check-certificate -O libgpiod.tar.gz  "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-${LIB_VERSION}.tar.gz"
		file libgpiod.tar.gz
		sudo mkdir -p $INSTALL_PATH/share
		sudo tar -xvzf libgpiod.tar.gz -C $INSTALL_PATH/source
		sudo rm libgpiod.tar.gz
		cd $INSTALL_PATH/source/libgpiod-${LIB_VERSION}
		sudo chmod +x autogen.sh
		sudo ./autogen.sh --prefix=$INSTALL_PATH $BUILD_ARG
		sudo make
		sudo make install
		# copy
		# bin
		sudo cp $INSTALL_PATH/bin/gpio* /usr/bin/ &>/dev/null || echo "Nothing to copy from /bin"
		# include
		sudo cp -r $INSTALL_PATH/include/gpiod* /usr/include/ &>/dev/null || echo "Nothing to copy from /include"
		# lib
		sudo cp -r $INSTALL_PATH/lib/* /usr/lib/$LIB_FOLDER/ &>/dev/null || echo "Nothing to copy from /lib"
		# doc
		sudo cp $INSTALL_PATH/share/* /usr/share/ &>/dev/null || echo "Nothing to copy from /share"
	else
		# alpine
		apk update
		apk add --no-cache --upgrade ca-certificates
		update-ca-certificates
		apk add --no-cache --upgrade curl wget autoconf automake autoconf-archive libtool pkgconfig tar zip gzip
		apk add --no-cache --upgrade gawk mawk build-base gcc make g++ zlib-dev python3 python3-dev \
		  py3-setuptools doxygen help2man linux-headers
		# ubuntu: libclang-dev
		# fix python3 path
		ln -sf /usr/bin/python3-config /usr/bin/python-config
		#
		mkdir -p $INSTALL_PATH/source
		cd $INSTALL_PATH/source
		wget -O libgpiod.tar.gz  "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-${LIB_VERSION}.tar.gz"
		file libgpiod.tar.gz
		mkdir -p $INSTALL_PATH/share
		tar -xvzf libgpiod.tar.gz -C $INSTALL_PATH/source
		rm libgpiod.tar.gz
		cd $INSTALL_PATH/source/libgpiod-${LIB_VERSION}
		chmod +x autogen.sh
		./autogen.sh --prefix=$INSTALL_PATH $BUILD_ARG
		make
		make install
		# copy
		# bin
		cp $INSTALL_PATH/bin/gpio* /usr/bin/ &>/dev/null || echo "Nothing to copy from /bin"
		# include
		cp -r $INSTALL_PATH/include/gpiod* /usr/include/ &>/dev/null || echo "Nothing to copy from /include"
		# lib
		cp -r $INSTALL_PATH/lib/* /usr/lib/  &>/dev/null || echo "Nothing to copy from /lib"
		# doc
		cp $INSTALL_PATH/share/* /usr/share/ &>/dev/null || echo "Nothing to copy from /share"
	fi
	
	# create artifacts
	if [ $ARTIFACT == "yes" ]; then
		if [ $ID_OS != "alpine" ]; then
			# ubuntu, debian
			mkdir -p $INSTALL_PATH/tmp/
			cd $INSTALL_PATH/lib/
			mv * $INSTALL_PATH/tmp/
			mkdir -p $INSTALL_PATH/lib/$LIB_FOLDER/
			cd $INSTALL_PATH/tmp/
			mv * $INSTALL_PATH/lib/$LIB_FOLDER/
			cd $INSTALL_PATH
			rm -r $INSTALL_PATH/tmp
		fi
		cd $INSTALL_PATH
		zip -r9 artifact.zip bin include lib share
		FILENAME_ZIP=libgpiod-bin-${LIB_VERSION}-${ID_OS}-${VERSION_OS}-${ARCH_OS}${END_NAME_ARTIFACT}.zip
		echo "FILENAME_ZIP=${FILENAME_ZIP}"
		mkdir /out
		cp artifact.zip /out/${FILENAME_ZIP}
	fi
	#end block	
fi
# **********
if [ "${TYPE_SETUP}" == "binary" ]; then
	#wget
	wget --version &>/dev/null || (echo "Updating package information" && sudo apt-get update \
 && sudo apt-get install -y wget)
	echo "Package search ..."
	# get list
	wget -O list.txt "https://raw.githubusercontent.com/devdotnetorg/docker-libgpiod/dev/out/list.txt"
	# select - ARCH_OS, ID_OS, VERSION_OS, LIB_VERSION
	declare LIST_BIN=$(cat list.txt | grep ${ARCH_OS} | grep ${ID_OS} | \
 grep ${VERSION_OS} | grep "${LIB_VERSION}")
	LIST_BIN=$(echo "$LIST_BIN" | tr '\n' ' ')
	IFS=' ' read -r -a options <<< "$LIST_BIN"
	echo "==============================================="
	echo "Your OS ${ID_OS} ${VERSION_OS} architecture ${ARCH_OS}"
	echo "==============================================="
	if [ -z $FILENAME_BIN ]; then
		echo "WARNING. The required version of the library was not found for your OS. Options will be offered ..."
		# no option
		# select - ARCH_OS, LIB_VERSION, ID_OS
		if [ ${#options[@]} == 0 ]; then
			LIST_BIN=$(cat list.txt | grep ${ARCH_OS} | grep ${LIB_VERSION} | grep ${ID_OS})
			LIST_BIN=$(echo "$LIST_BIN" | tr '\n' ' ')
			IFS=' ' read -r -a options <<< "$LIST_BIN"
		fi
		# select - ARCH_OS, LIB_VERSION
		if [ ${#options[@]} == 0 ]; then
			LIST_BIN=$(cat list.txt | grep ${ARCH_OS} | grep ${LIB_VERSION})
			LIST_BIN=$(echo "$LIST_BIN" | tr '\n' ' ')
			IFS=' ' read -r -a options <<< "$LIST_BIN"
		fi
		# select - ARCH_OS
		if [ ${#options[@]} == 0 ]; then
			LIST_BIN=$(cat list.txt | grep ${ARCH_OS})
			LIST_BIN=$(echo "$LIST_BIN" | tr '\n' ' ')
			IFS=' ' read -r -a options <<< "$LIST_BIN"
		fi
		if [ "${CAN_SELECT}" == "yes" ]; then
			# SELECT
			PS3="Select version of Libgpiod library. Please enter your choice: "
			echo "Library versions:"
			select opt in "${options[@]}"
				do
					FILENAME_BIN=$opt
					break;
				done
		else
			# "no"
			# select - last item
			if [ ${#options[@]} != 0 ]; then
				FILENAME_BIN=${options[-1]}
			fi	
		fi
	fi
	# defining  value
	if [ -z $FILENAME_BIN ]; then
		echo "ERROR. No binary package found for your OS"
		exit 1;
	fi
	echo "Choosed: ${FILENAME_BIN}"
	# unzip
	unzip --help &>/dev/null || (echo "Updating package information" && sudo apt-get update \
 && sudo apt-get install -y unzip)
	echo "Package download ..."
	# download bin
	wget -O libgpiod-bin.zip "https://raw.githubusercontent.com/devdotnetorg/docker-libgpiod/dev/out/${FILENAME_BIN}.zip"
	# install
	sudo unzip -o libgpiod-bin.zip -d /usr/
	# removing artifacts
	rm libgpiod-bin.zip &>/dev/null || (echo "The libgpiod-bin.zip file cannot be deleted. Remove it manually.")
	rm list.txt &>/dev/null || (echo "The list.txt file cannot be deleted. Remove it manually.")
	#
fi
# *********************************************************
#
funcCheckVer
echo "==============================================="
echo "Successfully"
exit 0;