#! /bin/bash
echo "jalankan firewall"

IPTABLES=/sbin/iptables

$IPTABLES -F
$IPTABLES -X

#Set default policies
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P INPUT DROP

#Accept localhost
$IPTABLES -A INPUT -i lo -j ACCEPT

$IPTABLES -I INPUT 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

echo
echo "iptables firewall is up `date`"
