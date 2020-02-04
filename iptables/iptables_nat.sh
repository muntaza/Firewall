#! /bin/bash
echo "jalankan firewall"

IPTABLES=/sbin/iptables
INT_IF=tap11
EXT_IF=wlp1s0

$IPTABLES -F
$IPTABLES -X

#Aturan default
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P INPUT DROP

#Izin localhost
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -i $INT_IF -j ACCEPT

#Izin Packet dengan tanda ESTABLISHED
$IPTABLES -I INPUT 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT


#Izin Packet Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward


#Table NAT
/sbin/iptables -t nat -A POSTROUTING -o $EXT_IF -j MASQUERADE
/sbin/iptables -A FORWARD -i $EXT_IF -o $INT_IF -m conntrack \
   --ctstate RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i $INT_IF -o $EXT_IF -j ACCEPT

echo
echo "iptables firewall is up `date`"
