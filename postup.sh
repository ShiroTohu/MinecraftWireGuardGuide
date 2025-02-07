iptables -I FORWARD -i wg0 -d 192.168.0.0/24 -j REJECT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -I FORWARD -i wg0 -d 10.8.0.0/24 -j ACCEPT
iptables -I FORWARD -i wg0 -j REJECT
