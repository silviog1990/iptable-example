#!/bin/bash
# Flushing all rules
iptables -F FORWARD
iptables -F INPUT
iptables -F OUTPUT
iptables -X
# Allow unlimited traffic on loopback
iptables -A INPUT -i wlan0 -j ACCEPT
iptables -A OUTPUT -o wlan0 -j ACCEPT

