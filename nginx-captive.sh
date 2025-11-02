sudo apt -y install nginx-light

sudo tee /etc/nginx/sites-enabled/redirect.conf <<'NG'
server {
    listen 80 default_server;
    return 302 https://your.webserver.com$request_uri;
}
NG
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# iptables: send usb0:80 -> local 80
sudo iptables -t nat -A PREROUTING -i usb0 -p tcp --dport 80 -j REDIRECT --to-ports 80
sudo netfilter-persistent save