#!/bin/bash

VPN_SERVER_IP=${VPN_SERVER_IP:-$(grep -E '^remote\s+[^ ]+' /root/vpn-config/*.ovpn | awk '{print $2}' | head -n 1)}
export VPN_SERVER_IP

echo "nameserver 1.1.1.1" > /etc/resolv.conf

/root/firewall.sh

openvpn --config /root/vpn-config/*.ovpn \
    --auth-user-pass /root/vpn-config/*.txt \
    --route-nopull --route $VPN_SERVER_IP 255.255.255.255 net_gateway \
    --daemon

# Wait for tun0 interface to be up and have an IP
while true; do
    if ip -4 addr show tun0 &>/dev/null; then
        VPN_GATEWAY=$(ip -4 addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | cut -d. -f1-3).1
        if [ -n "$VPN_GATEWAY" ]; then
            break
        fi
    fi
    sleep 1
done

VPN_GATEWAY=${VPN_GATEWAY:-$(ip -4 addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | cut -d. -f1-3).1}

# Start qBittorrent in the background
su - ${QBITTORRENT_USER} -c "qbittorrent-nox --webui-port=8080" &

# Wait for the WebUI to be ready
while ! curl -s http://localhost:8080 >/dev/null; do
    sleep 1
done

# Function to handle NAT-PMP and port updates
setup_nat_and_qbittorrent() {
    while true; do
        date
        # Map UDP and TCP ports, capture the mapped port
        MAPPED_PORT_UDP=$(natpmpc -a 1 0 udp 60 -g $VPN_GATEWAY | grep -oP 'Mapped public port \K\d+')
        echo "natpmpc retrieved udp $MAPPED_PORT_UDP port"
        MAPPED_PORT_TCP=$(natpmpc -a 1 0 tcp 60 -g $VPN_GATEWAY | grep -oP 'Mapped public port \K\d+')
        echo "natpmpc retrieved udp $MAPPED_PORT_TCP port"

        if [ -z "$MAPPED_PORT_UDP" ] || [ -z "$MAPPED_PORT_TCP" ]; then
            echo "ERROR: Failed to retrieve mapped port from natpmpc"
            sleep 300
            continue
        fi

        # Set the listening port via qBittorrent's Web API
        curl -X POST \
             --data "json={\"listen_port\": $MAPPED_PORT_UDP}" \
             http://localhost:8080/api/v2/app/setPreferences > /dev/null 2>&1

        sleep 45  # Refresh every 45 seconds
    done
}

# Run the function in the foreground to keep the container alive
setup_nat_and_qbittorrent
