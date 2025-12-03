#!/bin/bash

VPN_SERVER_IP=${VPN_SERVER_IP:-$(grep -E '^remote\s+[^ ]+' /root/vpn-config/*.ovpn | awk '{print $2}' | head -n 1)}
export VPN_SERVER_IP

echo "nameserver 1.1.1.1" > /etc/resolv.conf

/root/firewall.sh

openvpn --config /root/vpn-config/*.ovpn \
    --auth-user-pass /root/vpn-config/*.txt \
    --route-nopull --route $VPN_SERVER_IP 255.255.255.255 net_gateway \
    --daemon

sleep 5

VPN_GATEWAY=${VPN_GATEWAY:-$(ip -4 addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | cut -d. -f1-3).1}

while true; do
  date
  natpmpc -a 1 0 udp 3600 -g $VPN_GATEWAY && natpmpc -a 1 0 tcp 3600 -g $VPN_GATEWAY || { echo -e "ERROR with natpmpc command \a"; break; }
  sleep 300  # Refresh every 5 minutes
done > /proc/1/fd/1 2>/proc/1/fd/2 &

# Start qBittorrent-nox as the non-root user
su - ${QBITTORRENT_USER} -c "qbittorrent-nox --webui-port=8080"
