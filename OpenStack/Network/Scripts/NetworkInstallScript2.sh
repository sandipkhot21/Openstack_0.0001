#! /bin/sh

MYP=/home/sandip/Network;


echo "***********************************************Next is OpenStack Network Installation***********************************************";
echo $'auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet static\naddress 192.168.1.21\nnetmask 255.255.255.0\nbroadcast 192.168.1.255\n\nauto eth0:0\niface eth0:0 inet static\naddress 192.168.2.21\nnetmask 255.255.255.0\nbroadcast 192.168.2.255\n\nauto eth0:1\niface eth0:1 inet manual\n\tup ip link set dev $IFACE up\n\tdown ip link set dev $IFACE down' > /etc/network/interfaces;
service networking stop && service networking start;
route add default gw 192.168.1.1;
service networking stop && service networking start;
sync; sleep 5;


echo "**********************************************Next is Neutron Installation**********************************************";
echo "Come from controller, wait for #3 mssg....";
echo -n "Continue with Neutron-Network Installation?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

#echo "Edit /etc/neutron/sysctl.conf";
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;
cp $MYP/Neutron/sysctl.conf /etc/sysctl.conf;
sysctl -p;

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y neutron-plugin-openvswitch-agent openvswitch-datapath-dkms neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent;

#echo "Edit /etc/neutron/neutron.conf, l3_agent.ini, dhcp_agent.ini, dnsmasq-neutron.conf, and /etc/neutron/plugins/ml2/ml2_conf.ini, ";
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Neutron/neutron.conf /etc/neutron/neutron.conf;
cp $MYP/Neutron/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini;
cp $MYP/Neutron/l3_agent.ini /etc/neutron/l3_agent.ini;
cp $MYP/Neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini;
cp $MYP/Neutron/dnsmasq-neutron.conf /etc/neutron/dnsmasq-neutron.conf;
pkill dnsmasq;

#echo "Edit /etc/neutron/metadata_agent.ini";
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini;
sync;
sleep 5;
echo "4. Go to controller, wait for #5 mssg....";
echo -n "Changes on Nova-Controller Done?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

service openvswitch-switch restart;
sync;
sleep 5;

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y ethtool;

ethtool -K br-ex gro off;

sync;
sleep 5;
service neutron-plugin-openvswitch-agent restart;
service neutron-l3-agent restart;
service neutron-dhcp-agent restart;
service neutron-metadata-agent restart;

echo "**********************************************Neutron-Network Installation Done**********************************************";
echo "6. Go to Controller....";

echo "*******************************************Configurations for Network Node Complete*******************************************";
exit 0;