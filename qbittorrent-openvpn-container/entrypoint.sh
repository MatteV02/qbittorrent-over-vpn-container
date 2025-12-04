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

# Start qBittorrent in the background
su - ${QBITTORRENT_USER} -c "qbittorrent-nox --webui-port=8080" &

# Function to handle NAT-PMP and port updates
setup_nat_and_qbittorrent() {
    while true; do
        date
        # Map UDP and TCP ports, capture the mapped port
        MAPPED_PORT_UDP=$(natpmpc -a 1 0 udp 3600 -g $VPN_GATEWAY | grep -oP 'Mapped public port \K\d+')
        MAPPED_PORT_TCP=$(natpmpc -a 1 0 tcp 3600 -g $VPN_GATEWAY | grep -oP 'Mapped public port \K\d+')

        if [ -z "$MAPPED_PORT_UDP" ] || [ -z "$MAPPED_PORT_TCP" ]; then
            echo "ERROR: Failed to retrieve mapped port from natpmpc"
            sleep 300
            continue
        fi

        # Update qBittorrent config with the mapped port
        QBIT_CONF="/home/${QBITTORRENT_USER}/.config/qBittorrent/qBittorrent.conf"
        sed -i "s/^Session\\Port=.*/Session\\Port=$MAPPED_PORT_UDP/" "$QBIT_CONF"

        # Restart qBittorrent to apply the new port
        pkill qbittorrent-nox
        su - ${QBITTORRENT_USER} -c "qbittorrent-nox --webui-port=8080" &

        sleep 300  # Refresh every 5 minutes
    done
}

# Run the function in the foreground to keep the container alive
setup_nat_and_qbittorrent
