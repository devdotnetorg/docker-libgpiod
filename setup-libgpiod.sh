#!/bin/bash
# Setup libgpiod for ARM64, ARM32, x86_64, RISC-V
# C library and tools for interacting with the linux GPIO character device
# Site: https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
# Script version: 3.0
# arguments:
# 1) -t|--type: installation type  (default: source);
#		binary - installation from binaries, no questions asked installation (hidden installation),
#        all default settings;
#		find_ver - find out the version in the repository;
#		repo - installation from the repository;
#		source - installation from source.
# 2) -p|--path: library installation folder (default: /usr/share/libgpiod).
# 3) -v|--version: library release number (default: 2.0.1).
# 4) -o|--options: argument string to build the library, only if "--type source" (default: --enable-tools=yes --enable-bindings-cxx --enable-bindings-python ac_cv_func_malloc_0_nonnull=yes).
# 5) -a|--artifact: save artifact after build from source, values: yes, no (default: no).
#=================================================================
# Run:	chmod +x setup-libgpiod.sh
# 		sudo ./setup-libgpiod.sh --type source --path /usr/share/libgpiod --version 2.0.1 --options "--enable-tools=yes --enable-bindings-cxx --enable-bindings-python ac_cv_func_malloc_0_nonnull=yes"
# or
# Run:	chmod +x setup-libgpiod.sh
# 		sudo ./setup-libgpiod.sh
#=================================================================
# DevDotNet.ORG <anton@devdotnet.org> MIT License

set -e

# definition of variables
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

# reading arguments from CLI
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--type)
      TYPE_SETUP="$2"
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

# func
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
# find_ver
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

# if not hidden library installation, then showing selection menu
if [ -z $TYPE_SETUP ]; then
	echo "==============================================="
	echo "Libgpiod library installation"
	echo -e "The latest version of the Libgpiod library is \033[1;32m 2.0.1 \033[0m"
	echo "==============================================="
	NUMBER_STEPS=4
	# TYPE_SETUP
	PS3="1/${NUMBER_STEPS}. Choose the type of Libgpiod library installation. Please enter your choice (recommended: 4): "
	options=("Check the version in the repository" "Installation from repository" "Install from source" "Installation from binaries" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Check the version in the repository")
				TYPE_SETUP="find_ver"
				funcUpdate
				funcFindVer
				echo "Successfully"	
				exit 0;
				;;
			"Installation from repository")
				TYPE_SETUP="repo"
				funcUpdate
				funcRepo
				funcCheckVer
				echo "Successfully"	
				exit 0;
				;;
			"Install from source")
				TYPE_SETUP="source"
				break;
				;;
			"Installation from binaries")
				TYPE_SETUP="binary"
				NUMBER_STEPS=3
				break;
				;;
			"Quit")
				exit 0;
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
	echo "You choosed: $TYPE_SETUP" 
	
	# LIB_VERSION
	PS3="2/${NUMBER_STEPS}. Select version of Libgpiod library. Please enter your choice (recommended: 1): "
	options=('2.0.2' '2.0.1' '2.0' '1.6.4' '1.6.3' 'Quit')
	select opt in "${options[@]}"
	do
		case $opt in
			'2.0.2')
				LIB_VERSION="2.0.2"
				break;
				;;		
			'2.0.1')
				LIB_VERSION="2.0.1"
				break;
				;;
			'2.0')
				LIB_VERSION="2.0"
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
	if [ $TYPE_SETUP == "source" ]; then
		# INSTALL_PATH
		read -e -p "3/${NUMBER_STEPS}. Set installation path [/usr/share/libgpiod]: " -i "/usr/share/libgpiod" INSTALL_PATH
		if [ -z $INSTALL_PATH ]; then
			INSTALL_PATH=/usr/share/libgpiod
		fi
		echo "You choosed: ${INSTALL_PATH}"
		# BUILD_ARG
		read -e -p "4/${NUMBER_STEPS}. Specify build arguments [--enable-tools=yes --enable-bindings-cxx --enable-bindings-python ac_cv_func_malloc_0_nonnull=yes]: " -i "--enable-tools=yes --enable-bindings-cxx --enable-bindings-python ac_cv_func_malloc_0_nonnull=yes" BUILD_ARG
		echo "You choosed: ${BUILD_ARG}"
	fi
fi

# binary
if [ $TYPE_SETUP == "binary" ]; then
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
	# no option
	# select - ARCH_OS, ID_OS
	if [ ${#options[@]} == 0 ]; then
		LIST_BIN=$(cat list.txt | grep ${ARCH_OS} | grep ${ID_OS})
		LIST_BIN=$(echo "$LIST_BIN" | tr '\n' ' ')
		IFS=' ' read -r -a options <<< "$LIST_BIN"
	fi
	# select - ARCH_OS
	if [ ${#options[@]} == 0 ]; then
		LIST_BIN=$(cat list.txt | grep ${ARCH_OS})
		LIST_BIN=$(echo "$LIST_BIN" | tr '\n' ' ')
		IFS=' ' read -r -a options <<< "$LIST_BIN"
	fi
	# SELECT
	PS3="3/${NUMBER_STEPS}. Select version of Libgpiod library. Please enter your choice: "
	echo "Library versions:"
	select opt in "${options[@]}"
		do
			FILENAME_BIN=$opt
			echo "You choosed: ${FILENAME_BIN}"
			break;
		done
fi

# defining default values
if [ -z $TYPE_SETUP ]; then
	TYPE_SETUP="source"
fi

if [ -z $INSTALL_PATH ]; then
	INSTALL_PATH="/usr/share/libgpiod"
fi

if [ -z $LIB_VERSION ]; then
	LIB_VERSION="2.0.2"
fi

if [ "${BUILD_ARG}" == "" ]; then
	BUILD_ARG="--enable-tools=yes --enable-bindings-cxx \
--enable-bindings-python ac_cv_func_malloc_0_nonnull=yes"
	# lib 2.0.2 2.0.1 2.0 in ubuntu 20.04, 18.04 - not support python
	if [ "${LIB_VERSION}" == "2.0.2" ] || [ "${LIB_VERSION}" == "2.0.1" ] || [ "${LIB_VERSION}" == "2.0" ]; then
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
fi

if [ -z $ARTIFACT ]; then
	ARTIFACT="no"
fi

# show
echo "==============================================="
echo "Libgpiod library installation"
echo "==============================================="
echo "Options:"
echo "Type of instalation: ${TYPE_SETUP}"
echo "Library installation path: ${INSTALL_PATH}"
echo "Installing the Libgpiod library version: ${LIB_VERSION}"
echo "Libgpiod library build arguments: ${BUILD_ARG}"
echo "Save artifact: ${ARTIFACT}"
echo "Processor architecture: ${ARCH_OS}"
echo "OS name: ${ID_OS}"
echo "OS version: ${VERSION_OS}"
echo "==============================================="
echo ""
echo "==================== Setup ===================="

# Install from source
if [ $TYPE_SETUP == "source" ]; then
	echo "Install Libgpiod from source"
	funcUpdate
	# remove
	if [ -d $INSTALL_PATH ]; then
		sudo rm -rfv $INSTALL_PATH  
		echo "${INSTALL_PATH} has been removed"
	fi
	if [ $ID_OS != "alpine" ]; then
		# ubuntu, debian
		sudo apt-get install -y curl wget ca-certificates autoconf automake autoconf-archive libtool pkg-config tar zip gzip
		sudo update-ca-certificates
		sudo apt-get install -y gawk mawk gcc make g++ libclang-dev doxygen help2man linux-headers-generic
		# python3
		sudo apt-get install -y --install-recommends python3 python3-dev python3-distutils python3-setuptools python3-venv
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

# Installation from binaries
if [ $TYPE_SETUP == "binary" ]; then
	# defining  value
	if [ -z $FILENAME_BIN ]; then
		echo "ERROR. No binary package found for your OS"
		exit 1;
	fi
	# unzip
	unzip --help &>/dev/null || (echo "Updating package information" && sudo apt-get update \
 && sudo apt-get install -y unzip)
	echo "Package download ..."
	# download bin
	wget -O libgpiod-bin.zip "https://raw.githubusercontent.com/devdotnetorg/docker-libgpiod/dev/out/${FILENAME_BIN}.zip"
	# install
	sudo unzip -o libgpiod-bin.zip -d /usr/
	rm libgpiod-bin.zip
	#
fi

#
funcCheckVer
echo "==============================================="
echo "Successfully"
exit 0;