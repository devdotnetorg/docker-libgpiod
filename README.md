# Docker images with [Libgpiod][1] library for control GPIO Developer boards such as Raspberry Pi, Banana Pi, Orange Pi, and etc. And bash scripts to install the library for Armbian/Ubuntu.

#### Upstream Links

* Docker Registry @ [devdotnetorg/libgpiod](https://hub.docker.com/r/devdotnetorg/libgpiod)
* GitHub @ [devdotnetorg/docker-libgpiod](https://github.com/devdotnetorg/docker-libgpiod)

## Image Tags ##

### Linux arm64 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:1.6.3-aarch64` `:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))
`:1.6.3-focal-aarch64` `:1.6.3-focal` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.focal) | `ubuntu:20.04` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

### Linux arm32 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:1.6.3-armhf` `:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))
`:1.6.3-focal-armhf` `:1.6.3-focal` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.focal) | `ubuntu:20.04` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

### Linux amd64 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:1.6.3-amd64` `:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))
`:1.6.3-focal-amd64` `:1.6.3-focal` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.focal) | `ubuntu:20.04` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

## Linux kernel GPIO interface

GPIO stands for General-Purpose Input/Output and is one of the most commonly used peripherals in an embedded Linux system.

Internally, the Linux kernel implements the access to GPIOs via a producer/consumer model. There are drivers that produce GPIO lines (GPIO controllers drivers) and drivers that consume GPIO lines (keyboard, touchscreen, sensors, etc).

To manage the GPIO registration and allocation there is a framework inside the Linux kernel called gpiolib. This framework provides an API to both device drivers running in kernel space and user space applications.

![Image of gpiolib](https://raw.githubusercontent.com/devdotnetorg/docker-libgpiod/master/Images/gpiolib.png)

## Libgpiod

Since Linux version 4.8 the GPIO sysfs interface is deprecated, and now we have a new API based on character devices to access GPIO lines from user space.

Every GPIO controller (gpiochip) will have a character device in /dev and we can use file operations (open(), read(), write(), ioctl(), poll(), close()) to manage and interact with GPIO lines:

	root@bananapim64:~# ls /dev/gpiochip*
	/dev/gpiochip0  /dev/gpiochip1  /dev/gpiochip2

Although this new char device interface prevents manipulating GPIO with standard command-line tools like echo and cat, it has some advantages when compared to the sysfs interface, including:

The allocation of the GPIO is tied to the process that it is using it, improving control over which GPIO lines are been used by user space processes.
It is possible to read or write to multiple GPIO lines at once.
It is possible to find GPIO controllers and GPIO lines by name.
It is possible to configure the state of the pin (open-source, open-drain, etc).
The polling process to catch events (interrupts from GPIO lines) is reliable.



Libgpiod (Library General Purpose Input/Output device)  provides both API calls for use in your own programs and the following six user-mode applications to manipulate GPIO lines:

- gpiodetect – list all gpiochips present on the system, their names, labels and number of GPIO lines
- gpioinfo – list all lines of specified gpiochips, their names, consumers, direction, active state and additional flags
- gpioget – read values of specified GPIO lines
- gpioset – set values of specified GPIO lines, potentially keep the lines exported and wait until timeout, user input or signal
- gpiofind – find the gpiochip name and line offset given the line name
- gpiomon – wait for events on GPIO lines, specify which events to watch, how many events to process before exiting or if the events should be reported to the console

**gpiodetect**

	root@bananapim64:~# gpiodetect
	gpiochip0 [1f02c00.pinctrl] (32 lines)
	gpiochip1 [1c20800.pinctrl] (256 lines)
	gpiochip2 [axp20x-gpio] (2 lines)

 **gpioinfo**
 
	root@bananapim64:~# gpioinfo 1
	gpiochip1 - 256 lines:
	        line   0:      unnamed       unused   input  active-high
	...
	        line  64:      unnamed         "dc"  output  active-high [used]
	...
	        line  68:      unnamed "backlightlcdtft" output active-high [used]
	...
	        line  96:      unnamed   "spi0 CS0"  output   active-low [used]
	        line  97:      unnamed       unused   input  active-high
	        line  98:      unnamed       unused   input  active-high
	        line  99:      unnamed       unused   input  active-high
	        line 100:      unnamed      "reset"  output   active-low [used]
	...
	        line 120:      unnamed "bananapi-m64:red:pwr" output active-high [used]
	...
	        line 254:      unnamed       unused   input  active-high
	        line 255:      unnamed       unused   input  active-high

**gpiomon**

	root@bananapim64:~# gpiomon 1 38
	event:  RISING EDGE offset: 38 timestamp: [     122.943878429]
	event: FALLING EDGE offset: 38 timestamp: [     132.286218099]
	event:  RISING EDGE offset: 38 timestamp: [     137.639045559]
	event: FALLING EDGE offset: 38 timestamp: [     138.917400584]

## Quick Start

The container needs to be run on a development board such as Raspberry Pi, Banana Pi, Orange Pi, and etc. You must give access to `/dev/gpiochipX`. If the pin you are using is in `gpiochip1`, then there is no need to give access to `gpiochip0`. 

Running **gpiodetect** on Banana Pi M64 (ARM64):

`docker run --rm --name test-libgpiod --device /dev/gpiochip1 devdotnetorg/libgpiod gpiodetect`

Output:

	gpiochip1 [1c20800.pinctrl] (256 lines)

`docker run --rm --name test-libgpiod --device /dev/gpiochip0 --device /dev/gpiochip1 --device /dev/gpiochip2 devdotnetorg/libgpiod gpiodetect`

output:

	gpiochip0 [1f02c00.pinctrl] (32 lines)
	gpiochip1 [1c20800.pinctrl] (256 lines)
	gpiochip2 [axp20x-gpio] (2 lines)

`docker run --rm --name test-libgpiod --device /dev/gpiochip1 devdotnetorg/libgpiod gpiodetect -v`

output:

	gpiodetect (libgpiod) v1.6.3
	Copyright (C) 2017-2018 Bartosz Golaszewski
	License: LGPLv2.1
	This is free software: you are free to change and redistribute it.
	There is NO WARRANTY, to the extent permitted by law.

Running **gpioset**. Turning on LED on Banana Pi M64 (ARM64):

`docker run --rm --name alpine-test-libgpiod --device /dev/gpiochip1 devdotnetorg/libgpiod gpioset 1 36=1`

## Using Libgpiod .so files in containers with a .NET application 

To control GPIO from .NET code, the `LibGpiodDriver` class is used, the `System.Device.Gpio.Drivers` namespace. The `LibGpiodDriver` class is a wrapper around the Libgpiod library.

Sample C # source code:

```csharp
GpioController controller;
var drvGpio = new LibGpiodDriver(int_gpiochip.Value);
controller = new GpioController(PinNumberingScheme.Logical, drvGpio);
```

For the `LibGpiodDriver` class to function, the * .so library files must be added to the container.

The container under the path `/ artifacts.zip` contains all the necessary libraries and test programs (gpiodetect, etc.). All you need to do is unpack this archive.

An example Dockerfile with a C # application using the Libgpiod library:

```
FROM devdotnetorg/libgpiod:1.6.3 AS sourcelibgpiod

FROM mcr.microsoft.com/dotnet/runtime:5.0-alpine AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
WORKDIR /src
COPY ["src/dotnet-gpioset.csproj", "."]
RUN dotnet restore "./dotnet-gpioset.csproj"
COPY /src/. .
WORKDIR "/src/."
RUN dotnet build "dotnet-gpioset.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "dotnet-gpioset.csproj" -c Release -o /app/publish

FROM base AS final
MAINTAINER DevDotNet.Org <anton@devdotnet.org>
LABEL maintainer="DevDotNet.Org <anton@devdotnet.org>"
WORKDIR /app
COPY --from=publish /app/publish .
# Get libgpiod
COPY --from=sourcelibgpiod /artifacts.zip /

# Add Libgpiod
RUN apk update \
	&& apk add --no-cache --upgrade zip \
	&& unzip -o /artifacts.zip -d / \
	&& apk del zip \
	&& rm /artifacts.zip

ENTRYPOINT ["dotnet", "dotnet-gpioset.dll"]
```

## Bash scripts to install the library for Armbian/Ubuntu

To install the latest current version, you need to run the installation script, which will take the latest version of the library from the source repository. In the line for calling the setup script [setup-libgpiod-arm64.sh](https://raw.githubusercontent.com/devdotnetorg/docker-libgpiod/master/setup-libgpiod-armv7-and-arm64.sh), specify the library version number as the first parameter (for example: 1.6.3), the second parameter (optional) is the script installation folder. By default, the library will be installed in the path: /usr/share/libgpiod.

Installation script from the source code of libgpiod library and utilities for ARM32 / ARM64:

```bash
cd ~/
sudo apt-get update
sudo apt-get install -y curl
curl -SL --output setup-libgpiod-armv7-and-arm64.sh https://raw.githubusercontent.com/devdotnetorg/docker-libgpiod/master/setup-libgpiod-armv7-and-arm64.sh
chmod +x setup-libgpiod-armv7-and-arm64.sh
sudo ./setup-libgpiod-armv7-and-arm64.sh 1.6.3
```

To remove the library, execute the script: [remove-libgpiod-armv7-and-arm64.sh](https://raw.githubusercontent.com/devdotnetorg/docker-libgpiod/master/remove-libgpiod-armv7-and-arm64.sh).

If, as a result of the script execution, the inscription "Successfully" appears, then the library and utilities have been successfully installed.

## Links
- [Managing GPIO pins in Linux from a Docker container using the Libgpiod library (RU)](https://devdotnet.org/post/upravlyaem-gpio-v-linux-iz-docker-bibliotekoi-libgpiod/)

- [Working with GPIO in Linux. Part 6. Libgpiod Library (RU)](https://devdotnet.org/post/rabota-s-gpio-v-linux-chast-6-biblioteka-libgpiod/)

- [Weather station on Banana Pi M64 (Linux, C#, Docker, RabbitMQ, AvaloniaUI)(RU)](https://habr.com/ru/company/timeweb/blog/569748/)

- [Linux kernel GPIO user space interface — Sergio Prado embeddedbits.org](https://embeddedbits.org/new-linux-kernel-gpio-user-space-interface/)

- [An Introduction to chardev GPIO and Libgpiod on the Raspberry PI — Craig Peacock BeyondLogic](https://www.beyondlogic.org/an-introduction-to-chardev-gpio-and-libgpiod-on-the-raspberry-pi/)

- [Manage GPIO lines with gpiod — Sergio Tanzilli acmesystems.it](https://devdotnet.org/post/rabota-s-gpio-v-linux-chast-6-biblioteka-libgpiod/)

## License ##

[MIT License][2].

  [1]: https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/
  [2]: https://github.com/devdotnetorg/docker-libgpiod/raw/master/LICENSE