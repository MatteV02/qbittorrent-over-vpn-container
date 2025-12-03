#!/bin/bash

iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Allow DNS
iptables -A OUTPUT -p udp -d 1.1.1.1 --dport 53 -j ACCEPT
iptables -A INPUT -p udp -s 1.1.1.1 --sport 53 -j ACCEPT

# Allow traffic on VPN
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp -d $VPN_SERVER_IP --dport 1194 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p udp -s $VPN_SERVER_IP --sport 1194 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow WebUI
iptables -A INPUT -p tcp -i eth0 --dport 8080 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -o eth0 --sport 8080 -m conntrack --ctstate ESTABLISHED -j ACCEPT
