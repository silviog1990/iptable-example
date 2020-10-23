#!/bin/bash

# REMEMBER: Run this as a single bash script or you'll lock yourself out of your machine.

# Flushing all rules
iptables -F FORWARD
iptables -F INPUT
iptables -F OUTPUT
iptables -t nat -D POSTROUTING
iptables -X
# Setting default filter policy
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
# Allow unlimited traffic on loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Accept outbound on the primary interface
iptables -I OUTPUT -o wlan0 -d 0.0.0.0/0 -j ACCEPT
# Accept inbound TCP packets
iptables -I INPUT -i wlan0 -m state --state ESTABLISHED,RELATED -j ACCEPT
# Allow incoming SSH
iptables -A INPUT -p tcp --dport 22789 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
# Allow incoming OpenVPN
iptables -A INPUT -p udp --dport 1194 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
# Enable NAT for the VPN
iptables -t nat -A POSTROUTING -s 192.168.25.0/24 -o wlan0 -j MASQUERADE
# Allow TUN interface connections to OpenVPN server
iptables -A INPUT -i tun0 -j ACCEPT
# Allow TUN interface connections to be forwarded through other interfaces
iptables -A FORWARD -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
# Allow outbound access to all networks on the Internet from the VPN
iptables -A FORWARD -i tun0 -s 192.168.25.0/24 -d 0.0.0.0/0 -j ACCEPT
# Block client-to-client routing on the VPN
#iptables -A FORWARD -i tun0 -s 192.168.25.0/24 -d 192.168.25.0/24 -j DROP

iptables -A INPUT -s 192.168.1.0/24 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.0/24 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.0/24 -p tcp -m multiport --dports 8008:8009 -j ACCEPT
iptables -A OUTPUT -d 239.255.255.250/32 -p udp --dport 1900 -j ACCEPT

iptables -A INPUT -s 192.168.25.0/24 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -j ACCEPT
iptables -A OUTPUT -d 192.168.25.0/24 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -j ACCEPT
iptables -A OUTPUT -d 192.168.25.0/24 -p tcp -m multiport --dports 8008:8009 -j ACCEPT

iptables -I INPUT -p udp -m udp --sport 5353 -j ACCEPT
iptables -I OUTPUT -p udp -m udp --dport 5353 -j ACCEPT

# porta frontend homeassistant
iptables -A INPUT -p tcp --dport 8123 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT

# abilita mdns per discovery dispositivi google
iptables -I INPUT -p udp -m udp --sport 5353 -j ACCEPT
iptables -I OUTPUT -p udp -m udp --dport 5353 -j ACCEPT


