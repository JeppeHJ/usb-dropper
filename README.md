This is a `Raspberry Pi Zero 2 W` project I developed to learn about Linux internals, and to explore what an adversary could potentially accomplish if they could leave a very small USB-device sitting in the USB-port of a Linux workstation. Conclusion is you can do a lot of really cool stuff if any browsed websites don’t use HTTPS or don’t enforce HSTS :) 

## Overview
A single-plug demo tool that turns a `Raspberry Pi Zero 2` W into a **USB Ethernet gadget**. When plugged into a Linux workstation, it enumerates as a NIC, assigns the host an IP via DHCP/DNS, advertises classless routes so the host prefers the USB link, and NATs traffic out the Pi’s Wi-Fi. You can point DNS to a specific webserver and (optionally) redirect HTTP to a local service or pass it through an mitmproxy script for controlled, lab-only response modification.

This can be leveraged in a lot of really cool ways, but this tool is simply a proof of concept that routes ALL traffic (through either DNS-poisoning, NAT-steering, response-injection or captive-portal style 302 redirection) to an attacker-controlled server. In a real engagement you would obviously do this in a more stealthy and sophisticated way.

## Pre-requisites
- A Raspberry Pi Zero 2 W (older models can also do this but setup will differ slightly)
- A SD card
- USB-A to USB-B cable
- A mobile hotspot/WiFi for the Pi to connect to
- A Linux machine to test your cool hacker-tool on

## Setup
### DNS-poisoning and NAT-steering
- Alter `setup.sh` lines where `YOUR.WEBSERVER.IP` appears to point to your webserver
- Transfer `setup.sh` to your Raspberry Pi
- Run it with `sudo`

### Response injection
- If you want to play around with response content injection, you will have to set up a `inject.py`-script and run `mitmproxy.sh`.

### Captive Portal style redirection
- If you want to play around with 302-redirection using nginx, you will have to replace the old DNAT:80 if you ran `setup.py` and run `captive.sh`.
