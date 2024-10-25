sudo brctl addbr br0
sudo ip link set br0 up
sudo ifconfig br0 192.168.57.1/24
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

