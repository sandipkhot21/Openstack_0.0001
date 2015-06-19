#! /bin/sh

ifconfig eth0 0;

ip addr add 192.168.1.11/24 broadcast 192.168.1.255 dev br-eth0;
ip link set br-eth0 up promisc on;
ip link add proxy-br-ex type veth peer name ex-br-proxy;
ip link set ex-br-proxy up promisc on;
ip link set proxy-br-ex up promisc on;
ip link set br-ex up promisc on;

route add default gw 192.168.1.1;
sleep 5;
service openvswitch-switch restart;
ervice ntp restart;
service mysql restart;
service keystone restart;
service rabbitmq-server restart;
service glance-api restart;
service glance-registry restart;
service neutron-server restart;
service nova-api restart;
service nova-conductor restart;
service nova-scheduler restart;
service neutron-server restart;
exit 0;
