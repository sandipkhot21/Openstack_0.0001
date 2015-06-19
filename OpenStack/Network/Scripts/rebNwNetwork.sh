#! /bin/sh

ifconfig eth0 0;

ip addr add 192.168.1.21/24 broadcast 192.168.1.255 dev br-eth0;
ip link set br-eth0 up promisc on;
ip link add proxy-br-eth1 type veth peer name eth1-br-proxy;
ip link add proxy-br-ex type veth peer name ex-br-proxy;
ip link set eth1-br-proxy up promisc on;
ip link set proxy-br-eth1 up promisc on;
ip link set ex-br-proxy up promisc on;
ip link set proxy-br-ex up promisc on;
ip addr add 192.168.2.21/24 broadcast 192.168.2.255 dev br-eth1;
ip link set br-eth1 up promisc on;
ip link set br-ex up promisc on;

route add default gw 192.168.1.1;
sleep 5;
service openvswitch-switch restart;
service ntp restart;
service neutron-dhcp-agent restart
service neutron-l3-agent restart
service neutron-metadata-agent restart
service neutron-plugin-openvswitch-agent restart

exit 0;
