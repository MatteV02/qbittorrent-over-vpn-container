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
        procps \
        curl \
        jq \
        cron \
        && rm -rf /var/lib/apt/lists/*

# Create qBittorrent unprivileged user
RUN groupadd ${QBITTORRENT_USER} && \
    useradd --create-home -g ${QBITTORRENT_USER} ${QBITTORRENT_USER}

RUN mkdir -p /home/${QBITTORRENT_USER}/.config/qBittorrent && \
    mkdir -p /home/${QBITTORRENT_USER}/Downloads && \
    chown -R ${QBITTORRENT_USER}:${QBITTORRENT_USER} /home/${QBITTORRENT_USER}/Downloads && \
    chown -R ${QBITTORRENT_USER}:${QBITTORRENT_USER} /home/${QBITTORRENT_USER}/.config/qBittorrent && \
    mkdir -p /root/torrents

COPY crontab.txt /etc/cron.d/qbittorrent-cron
RUN chmod 0644 /etc/cron.d/qbittorrent-cron && \
    touch /var/log/cron.log

COPY qBittorrent.conf /home/${QBITTORRENT_USER}/.config/
COPY export_torrents.sh /root
COPY entrypoint.sh /root
COPY firewall.sh /root

RUN chmod u+x /root/entrypoint.sh && \
    chmod u+x /root/firewall.sh && \
    chmod u+x /root/export_torrents.sh

EXPOSE 8080

CMD [ "/root/entrypoint.sh" ]