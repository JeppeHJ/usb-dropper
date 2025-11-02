sudo apt -y install mitmproxy  # pulls Python & binaries
sudo useradd -r -s /usr/sbin/nologin mitm   # non-priv user

# systemd unit
sudo tee /etc/systemd/system/mitmproxy.service >/dev/null <<'UNIT'
[Unit]
Description=mitmproxy transparent HTTP injector
After=network.target
Requires=network.target

[Service]
User=mitm
ExecStart=/usr/bin/mitmdump --mode transparent --listen-port 8081 \
          --set block_global=false --set showhost \
          --script /opt/mitm/inject.py
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

sudo mkdir -p /opt/mitm && sudo mv inject.py /opt/mitm
sudo chown -R mitm: /opt/mitm
sudo systemctl daemon-reload
sudo systemctl enable --now mitmproxy

# wipe old redirect if any
sudo iptables -t nat -D PREROUTING -i usb0 -p tcp --dport 80 -j REDIRECT --to-ports 8080 2>/dev/null || true

# new rule → mitmproxy:8081
sudo iptables -t nat -A PREROUTING -i usb0 -p tcp --dport 80 -j REDIRECT --to-ports 8081
sudo netfilter-persistent save