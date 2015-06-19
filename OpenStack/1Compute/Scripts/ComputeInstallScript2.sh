#! /bin/sh

MYP=/home/sandip/1Compute;


echo "***********************************************Next is OpenStack Network Installation***********************************************";
echo $'auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet static\naddress 192.168.1.31\nnetmask 255.255.255.0\nbroadcast 192.168.1.255\n\nauto eth0:0\niface eth0:0 inet static\naddress 192.168.2.31\nnetmask 255.255.255.0\nbroadcast 192.168.2.255' > /etc/network/interfaces;
service networking stop && service networking start;
route add default gw 192.168.1.1;
service networking stop && service networking start;
sync; sleep 5;

echo "***********************************************Next is Nova Installation***********************************************";
echo "Come from Controller, wait for #1 mssg from compute.....";
echo -n "Continue with Nova-Compute Installation?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y nova-compute sysfsutils;

#echo "Edit /etc/nova/nova.cnf";
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Nova/nova1.conf /etc/nova/nova.conf;

sync;
service nova-compute restart;
sleep 5;

echo "********************************************Done with Nova-Compute Installation********************************************";


echo "***********************************************Next is Neutron Installation***********************************************";
echo "2. Go to Controller, wait for #7 mssg from controller....";
echo "Don't Continue Install in neutron debug phase......";
echo -n "Neutron-Network & Neutron-Controller Installation Done?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

#This step to be done only after Neutron installation on Network node
#echo "Edit /etc/sysctl.cnf";
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;
cp $MYP/Neutron/sysctl.conf /etc/sysctl.conf;
sysctl -p;

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y neutron-plugin-openvswitch-agent openvswitch-datapath-dkms;

#echo "Edit /etc/neutron/neutron.cnf and /etc/neutron/plugins/ml2/ml2_conf.ini";
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Neutron/neutron.conf /etc/neutron/neutron.conf;
cp $MYP/Neutron/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini;

sync;
service openvswitch-switch restart;
sleep 5;

#echo "Edit /etc/nova/nova.cnf";
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Neutron/nova.conf /etc/nova/nova.conf;
sync;
service nova-compute restart;
service neutron-plugin-openvswitch-agent restart;


echo "*******************************************Configurations for Compute Node Complete*******************************************";
echo "8. Go to Controller....";


exit 0;
