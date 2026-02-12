#!/bin/sh
iptables -A INPUT -s 10.45.1.0/16 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -s 10.53.1.0/24 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j DROP

