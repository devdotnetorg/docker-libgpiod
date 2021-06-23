# Alpine image with [Libgpiod][1] library for control GPIO Developer boards such as Raspberry Pi, Banana Pi, Orange Pi, and etc. 

#### Upstream Links

* Docker Registry @ [devdotnetorg/libgpiod](https://hub.docker.com/r/devdotnetorg/libgpiod)
* GitHub @ [devdotnetorg/docker-libgpiod](https://github.com/devdotnetorg/docker-libgpiod)

## Image Tags ##

### Linux arm64 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:1.6.3-aarch64` `:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

### Linux arm32 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:1.6.3-armhf` `:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

### Linux amd64 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:1.6.3-amd64` `:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

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

`docker run --rm --name test-libgpiod -v /dev/gpiochip0:/dev/gpiochip0 -v /dev/gpiochip1:/dev/gpiochip1 -v /dev/gpiochip2:/dev/gpiochip2 devdotnetorg/libgpiod gpiodetect`

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

## Links in Russian

- [Работа с GPIO в Linux. Часть 6. Библиотека Libgpiod](https://devdotnet.org/post/rabota-s-gpio-v-linux-chast-6-biblioteka-libgpiod/)

## Links

- [Linux kernel GPIO user space interface — Sergio Prado embeddedbits.org](https://embeddedbits.org/new-linux-kernel-gpio-user-space-interface/)

- [An Introduction to chardev GPIO and Libgpiod on the Raspberry PI — Craig Peacock BeyondLogic](https://www.beyondlogic.org/an-introduction-to-chardev-gpio-and-libgpiod-on-the-raspberry-pi/)

- [Manage GPIO lines with gpiod — Sergio Tanzilli acmesystems.it](https://devdotnet.org/post/rabota-s-gpio-v-linux-chast-6-biblioteka-libgpiod/)

## License ##

[MIT License][2].

  [1]: https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/
  [2]: https://github.com/devdotnetorg/docker-libgpiod/raw/master/LICENSE