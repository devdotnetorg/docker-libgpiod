# Alpine image with [Libgpiod][1] library for control GPIO Developer boards such as Raspberry Pi, Banana Pi, Orange Pi, and etc. 

## Image Tags ##

### Linux arm64 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:libgpiod:1.6.3-aarch64` `:libgpiod:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

### Linux arm32 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:libgpiod:1.6.3-armhf` `:libgpiod:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

### Linux amd64 Tags ###

Tags  | Dockerfile  | OS Version  |  Libgpiod Version
------------- | --  | --  | --
`:libgpiod:1.6.3-amd64` `:libgpiod:1.6.3` `:latest` | [Dockerfile](https://github.com/devdotnetorg/docker-libgpiod/blob/master/Dockerfile.alpine) | `alpine:3.13.5` | Latest ([v1.6.3](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-1.6.3.tar.gz))

## Linux kernel GPIO interface

GPIO stands for General-Purpose Input/Output and is one of the most commonly used peripherals in an embedded Linux system.

Internally, the Linux kernel implements the access to GPIOs via a producer/consumer model. There are drivers that produce GPIO lines (GPIO controllers drivers) and drivers that consume GPIO lines (keyboard, touchscreen, sensors, etc).

To manage the GPIO registration and allocation there is a framework inside the Linux kernel called gpiolib. This framework provides an API to both device drivers running in kernel space and user space applications.

gpiolib.png

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

gpiodetect

root@bananapim64:~# gpiodetect
gpiochip0 [1f02c00.pinctrl] (32 lines)
gpiochip1 [1c20800.pinctrl] (256 lines)
gpiochip2 [axp20x-gpio] (2 lines)

 gpioinfo
 
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
		
		
		
		

 gpiomon
 
 root@bananapim64:~# gpiomon 1 38
event:  RISING EDGE offset: 38 timestamp: [     122.943878429]
event: FALLING EDGE offset: 38 timestamp: [     132.286218099]
event:  RISING EDGE offset: 38 timestamp: [     137.639045559]
event: FALLING EDGE offset: 38 timestamp: [     138.917400584]




## Run

За пускать контейнер небходимо на разработачной плате such as Raspberry Pi, Banana Pi, Orange Pi, and etc. Вы должны дать доступ к /dev/gpiochipX. Если используемый контакт находится в gpiochip1, то нет необходимости давать доступ к gpiochip0.

Запуск gpiodetect:

Включение светодиода LED на плате Banana Pi BPM  M 64:

Литуратура на русском языке

Литуература


 
 
 - L2TP/IPSec PSK + OpenVPN
 - SecureNAT enabled
 - Perfect Forward Secrecy (DHE-RSA-AES256-SHA)
 - make'd from [the official SoftEther VPN GitHub Stable Edition Repository][2].

`docker run -d --cap-add NET_ADMIN -p 500:500/udp -p 4500:4500/udp -p 1701:1701/tcp -p 1194:1194/udp -p 5555:5555/tcp devdotnetorg/softethervpn-alpine`

Connectivity tested on Android + iOS devices. It seems Android devices do not require L2TP server to have port 1701/tcp open.

The above example will accept connections from both L2TP/IPSec and OpenVPN clients at the same time.

Mix and match published ports: 
- `-p 500:500/udp -p 4500:4500/udp -p 1701:1701/tcp` for L2TP/IPSec
- `-p 1194:1194/udp` for OpenVPN.
- `-p 443:443/tcp` for OpenVPN over HTTPS.
- `-p 5555:5555/tcp` for SoftEther VPN (recommended by vendor).
- `-p 992:992/tcp` is also available as alternative.

Any protocol supported by SoftEther VPN server is accepted at any open/published port (if VPN client allows non-default ports).

## Credentials

All optional:

- `-e PSK`: Pre-Shared Key (PSK), if not set: "notasecret" (without quotes) by default.
- `-e USERS`: Multiple usernames and passwords may be set with the following pattern: `username:password;user2:pass2;user3:pass3`. Username and passwords are separated by `:`. Each pair of `username:password` should be separated by `;`. If not set a single user account with a random username ("user[nnnn]") and a random weak password is created.
- `-e SPW`: Server management password. :warning:
- `-e HPW`: "DEFAULT" hub management password. :warning:

Single-user mode (usage of `-e USERNAME` and `-e PASSWORD`) is still supported.

See the docker log for username and password (unless `-e USERS` is set), which *would look like*:

    # ========================
    # user6301
    # 2329.2890.3101.2451.9875
    # ========================
Dots (.) are part of the password. Password will not be logged if specified via `-e USERS`; use `docker inspect` in case you need to see it.

:warning: if not set a random password will be set but not displayed nor logged. If specifying read the notice below.

## Configurations ##

The vpn_server.config configuration file has been moved from the binaries folder to the `/usr/vpnserver/config` subfolder for mounting.
For the container to work, you need to create a file `vpn_server.config`, for this, start the container and specify the initial password for the server and the default hub:
```
$ docker run --name vpnconf -e SPW=<serverpw> -e HPW=<hubpw> -v softethervpn-config:/usr/vpnserver/config devdotnetorg/softethervpn-alpine echo
$ docker rm vpnconf
```
The `vpn_server.config` file will be located at VOLUME:` softethervpn-config`.
Now start the main container:
```
$ docker run ... -v softethervpn-config:/usr/vpnserver/config devdotnetorg/softethervpn-alpine
```
Refer to [SoftEther VPN Server Administration manual](https://www.softether.org/4-docs/1-manual/3._SoftEther_VPN_Server_Manual/3.3_VPN_Server_Administration) for more information.

## Logging ##

By default SoftEther has a very verbose logging system. For privacy or space constraints, this may not be desirable. The easiest way to solve this create a dummy volume to log to /dev/null. In your docker run you can use the following volume variables to remove logs entirely.
```
-v /dev/null:/usr/vpnserver/server_log \
-v /dev/null:/usr/vpnserver/packet_log \
-v /dev/null:/usr/vpnserver/security_log
```
If logs are needed, then logs will accumulate over time. Added cron job for regular cleaning of logs. The cron job runs every 15 minutes. The environment `LIFETIMELOGS` controls the lifetime of the logs in hours.
- (default) If `-e LIFETIMELOGS=0`, then the cron job does not start.
- if `-e LIFETIMELOGS=2`, logs older than 2 hours will be deleted. But you need to remember that a new log file is created at 00:00 every day and recorded until 23:59:59, name: vpn_20201104.log, vpn_20201105.log, etc. Thus, the vpn_20201104.log file will be deleted on 05 November 2020, at 02: 00-02: 15 minutes. There will be daily accumulation of information, if you have not switched to the hourly mode of creating log files.

Example: `docker run -d --cap-add NET_ADMIN -p 500:500/udp -p 4500:4500/udp -p 1701:1701/tcp -p 1194:1194/udp -p 5555:5555/tcp -e LIFETIMELOGS=2 devdotnetorg/softethervpn-alpine`

YAML:
```
#VPN
  softethervpn:
    image: devdotnetorg/softethervpn-alpine
    container_name: softethervpn_local
    restart: always
    ports:
      - 992:992/tcp
      - 1194:1194/udp
      - 5555:5555/tcp
      - 53:53/udp     
      - 1195:1195/udp      
    environment:
      - LIFETIMELOGS=2
    volumes:
      - softethervpn-config:/usr/vpnserver/config
      - softethervpn-logs-server:/usr/vpnserver/server_log      
      - softethervpn-logs-packet:/usr/vpnserver/packet_log
      - softethervpn-logs-security:/usr/vpnserver/security_log      
    cap_add:
      - NET_ADMIN    
```

## Server & Hub Management Commands ##

Management commands can be executed just before the server & hub admin passwords are set via:
- `-e VPNCMD_SERVER`: `;`-separated [Server management commands](https://www.softether.org/4-docs/1-manual/6._Command_Line_Management_Utility_Manual/6.3_VPN_Server_%2F%2F_VPN_Bridge_Management_Command_Reference_(For_Entire_Server)).
- `-e VPNCMD_HUB`: `;`-separated [Hub management commands](https://www.softether.org/4-docs/1-manual/6._Command_Line_Management_Utility_Manual/6.4_VPN_Server_%2F%2F_VPN_Bridge_Management_Command_Reference_(For_Virtual_Hub)) (currently only for `DEFAULT` hub).

Example: Set MTU via [`NatSet`](https://www.softether.org/4-docs/1-manual/6._Command_Line_Management_Utility_Manual/6.4_VPN_Server_%2F%2F_VPN_Bridge_Management_Command_Reference_(For_Virtual_Hub)#6.4.97_.22NatSet.22:_Change_Virtual_NAT_Function_Setting_of_SecureNAT_Function) Hub management command:
`-e VPNCMD_HUB='NatSet /MTU:1500'`

Note that commands run only if the config file is not mounted. Some commands (like `ServerPasswordSet`) will cause problems.

## OpenVPN ##

`docker run -d --cap-add NET_ADMIN -p 1194:1194/udp devdotnetorg/softethervpn-alpine`

The entire log can be saved and used as an `.ovpn` config file (change as needed).

Server CA certificate will be created automatically at runtime if it's not set. You can supply _a self-signed 1024-bit RSA certificate/key pair_ created locally OR use the `gencert` script described below. Feed the keypair contents via `-e CERT` and `-e KEY` ([use of `--env-file`][3] is recommended). X.509 markers (like `-----BEGIN CERTIFICATE-----`) and any non-BASE64 character (incl. newline) can be omitted and will be ignored.

Examples (assuming bash; note the double-quotes `"` and backticks `` ` ``):

* ``-e CERT="`cat server.crt`" -e KEY="`cat server.key`"``
* `-e CERT="MIIDp..b9xA=" -e KEY="MIIEv..x/A=="`
* `--env-file /path/to/envlist`

`env-file` template can be generated by:

`docker run --rm devdotnetorg/softethervpn-alpine gencert > /path/to/envlist`

The output will have `CERT` and `KEY` already filled in. Modify `PSK`/`USERS`.

Certificate volumes support (like `-v` or `--volumes-from`) will be added at some point...

## Assembly for ARM devices ##

The assembly for the aarch64 architecture (ARM64v8) was done on the [Banana Pi BPI-M64](http://wiki.banana-pi.org/Banana_Pi_BPI-M64) evaluation board.

The assembly for the armhf architecture (ARM32v7) was done on the [Cubietruck](https://habr.com/ru/post/186576/) evaluation board.

SoftEther VPN was compiled with musl option: `export USE_MUSL=YES`. [Build on musl-based linux](https://github.com/SoftEtherVPN/SoftEtherVPN/blob/master/src/BUILD_UNIX.md#build-on-musl-based-linux).

## License ##

[MIT License][4].

  [1]: https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/
  [2]: https://github.com/SoftEtherVPN/SoftEtherVPN_Stable
  [3]: https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables-e-env-env-file
  [4]: https://github.com/devdotnetorg/docker-softethervpn-alpine/raw/master/LICENSE
 
