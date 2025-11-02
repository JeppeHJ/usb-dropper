This is a `Raspberry Pi Zero 2 W` project I developed to learn about Linux internals, and to explore what an adversary could potentially accomplish if they could leave a very small USB-device sitting in the USB-port of a Linux workstation.

## Overview
A single-plug demo tool that turns a Pi Zero 2 W into a USB Ethernet gadget. When plugged into a Linux workstation, it enumerates as a NIC, assigns the host an IP via DHCP/DNS, advertises classless routes so the host prefers the USB link, and NATs traffic out the Pi’s Wi-Fi. You can point DNS to a specific webserver and (optionally) redirect HTTP to a local service or pass it through an mitmproxy script for controlled, lab-only response modification.

## Pre-requisites
- A Raspberry Pi Zero 2 W (older models can also do this but setup will differ slightly)
- A SD card
- USB-A to USB-B cable
- A mobile hotspot/WiFi for the Pi to connect to
- A Linux machine to try it on

## Setup
- Alter `setup.sh` lines where `YOUR.WEBSERVER.IP` appears to point to your webserver
- Transfer `setup.sh` to your Raspberry Pi
- Run it with `sudo`
- Your USB-dropper is now ready to be plugged into Linux workstations
