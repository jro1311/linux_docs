## Codecs

sudo zypper in -y opi && opi codecs

# Update grub

sudo grub2-mkconfig

# Adds firewall exceptions

sudo firewall-cmd --add-interface=wlp8s0 --zone=home --permanent
sudo firewall-cmd --set-default-zone=home --permanent
sudo firewall-cmd --zone=home --add-service=bittorrent-lsd --permanent
sudo firewall-cmd --zone=home --add-service=dhcp --permanent
sudo firewall-cmd --zone=home --add-service=dhcpv6 --permanent
sudo firewall-cmd --zone=home --add-service=dhcpv6-client --permanent
sudo firewall-cmd --zone=home --add-service=dns --permanent
sudo firewall-cmd --zone=home --add-service=dns-over-quic --permanent
sudo firewall-cmd --zone=home --add-service=dns-over-tls --permanent
sudo firewall-cmd --zone=home --add-service=http --permanent
sudo firewall-cmd --zone=home --add-service=http3 --permanent
sudo firewall-cmd --zone=home --add-service=mdns --permanent
sudo firewall-cmd --zone=home --add-service=samba-client --permanent
sudo firewall-cmd --zone=home --add-service=slp --permanent
sudo firewall-cmd --zone=home --add-service=spotify-sync --permanent
sudo firewall-cmd --zone=home --add-service=ssh --permanent
sudo firewall-cmd --zone=home --add-service=terraria --permanent
sudo firewall-cmd --zone=home --add-service=transmission-client --permanent
sudo firewall-cmd --zone=home --add-port=161-162/tcp --permanent
sudo firewall-cmd --zone=home --add-port=9100/tcp --permanent
sudo firewall-cmd --zone=home --add-port=161-162/udp --permanent
sudo firewall-cmd --zone=home --add-port=9100/udp --permanent
sudo firewall-cmd --reload
