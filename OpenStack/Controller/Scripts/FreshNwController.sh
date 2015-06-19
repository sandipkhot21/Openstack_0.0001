#! /bin/sh

ifconfig eth0 0;
service networking stop && service networking start;

ovs-vsctl add-br br-eth0;
ovs-vsctl add-port br-eth0 eth0;

ip addr add 192.168.1.11/24 broadcast 192.168.1.255 dev br-eth0;
ip link set br-eth0 up promisc on;

ip link add proxy-br-ex type veth peer name ex-br-proxy;

ovs-vsctl add-br br-ex;

ovs-vsctl add-port br-ex ex-br-proxy;
ovs-vsctl add-port br-eth0 proxy-br-ex;

ip link set ex-br-proxy up promisc on;
ip link set proxy-br-ex up promisc on;
ip link set br-ex up promisc on;
route add default gw 192.168.1.1;
