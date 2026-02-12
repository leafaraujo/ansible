#!/bin/sh

# Permitir conexões HTTP apenas do CORE
iptables -A INPUT -s 172.31.0.154 -p tcp --dport 80 -j ACCEPT

# Permitir tráfego da UE (se estiver na rede ran ou tun0)
iptables -A INPUT -s 10.45.0.0/16 -p tcp --dport 80 -j ACCEPT

#iptables -A INPUT -s 172.31.0.0/24 -p tcp --dport 80 -j ACCEPT

# Bloquear qualquer outro acesso à porta 80
iptables -A INPUT -p tcp --dport 80 -j DROP

# Bloquear 443 (HTTPS)
iptables -A INPUT -p tcp --dport 443 -j DROP

