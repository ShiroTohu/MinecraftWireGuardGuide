iptables -D FORWARD -i wg0 -d 192.168.0.0/24 -j REJECT
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
iptables -D FORWARD -i wg0 -d 10.8.0.0/24 -J ACCEPT
iptables -D FORWARD -i wg0 -j REJECT
