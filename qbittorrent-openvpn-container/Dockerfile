# Use Debian Trixie as the base image
FROM debian:trixie-slim

ENV QBITTORRENT_USER='qbittorrent'

RUN apt update && \
    apt install -y \
        qbittorrent-nox \
        openvpn \
        iptables \
        natpmpc \
        iproute2 \
        && rm -rf /var/lib/apt/lists/*

# Create qBittorrent unprivileged user
RUN groupadd ${QBITTORRENT_USER} && \
    useradd --create-home -g ${QBITTORRENT_USER} ${QBITTORRENT_USER}

# Create the qBittorrent config directory and pre-accept the legal notice
RUN mkdir -p /home/${QBITTORRENT_USER}/.config/qBittorrent && \
    echo "[LegalNotice]" > /home/${QBITTORRENT_USER}/.config/qBittorrent/qBittorrent.conf && \
    echo "Accepted=true" >> /home/${QBITTORRENT_USER}/.config/qBittorrent/qBittorrent.conf && \
    # set OpenVPN interface as default
    echo "\n[BitTorrent]" >> /home/${QBITTORRENT_USER}/.config/qBittorrent/qBittorrent.conf && \
    echo "Session\Interface=tun0" >> /home/${QBITTORRENT_USER}/.config/qBittorrent/qBittorrent.conf && \
    echo "Session\InterfaceName=tun0" >> /home/${QBITTORRENT_USER}/.config/qBittorrent/qBittorrent.conf && \
    echo "\n[Preferences]" >> /home/${QBITTORRENT_USER}/.config/qBittorrent/qBittorrent.conf && \
    # Password: adminadmin
    echo 'WebUI\Password_PBKDF2="@ByteArray(GzJPf38x/Fkwt5mmG2Gw4A==:YNf9UUd+hAD27T1S1MNwLLqVT41BYKYI9cFa+Kv/gWtKRLcgLwZkYVhd9tDN8a/cYcEAdZ6jah6Ki3lRgUwaUg==)"' >> /home/${QBITTORRENT_USER}/.config/qBittorrent/qBittorrent.conf && \
    chown -R ${QBITTORRENT_USER}:${QBITTORRENT_USER} /home/${QBITTORRENT_USER}/.config/qBittorrent

RUN mkdir -p /home/${QBITTORRENT_USER}/Downloads && \
    chown -R ${QBITTORRENT_USER}:${QBITTORRENT_USER} /home/${QBITTORRENT_USER}/Downloads

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod u+x /root/entrypoint.sh

COPY firewall.sh /root/firewall.sh
RUN chmod u+x /root/firewall.sh

EXPOSE 8080

CMD [ "/root/entrypoint.sh" ]