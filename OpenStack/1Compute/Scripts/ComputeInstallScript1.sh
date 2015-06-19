#! /bin/sh

MYP=/home/sandip/1Compute;

echo 'auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet static\naddress 192.168.1.31\nnetmask 255.255.255.0\ngateway 192.168.1.1' > /etc/network/interfaces;
echo 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolv.conf;
sync;
service networking stop && service networking start;
sleep 5;
scp -r sandip@192.168.1.11:/home/sandip/OpenStack/1Compute /home/sandip/1Compute;
sync; sleep 5;

echo "**********************************************Next is Networking Configuration**********************************************";
#cp $MYP/Networks/apt.conf.wired /etc/apt/apt.conf;
cp $MYP/Networks/sources.list /etc/apt/sources.list;
cp $MYP/Networks/hosts /etc/hosts;
cp $MYP/Networks/hostname /etc/hostname;
cp -r $MYP/UpdateLists/* /var/lib/apt/lists/;
cp -r $MYP/Packages/* /var/cache/apt/archives/;
sync;
service networking stop && service networking start;
sleep 5;

echo "**********************************************Next is System Utilities Installation**********************************************";
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y less locate vim dbconfig-common debconf-utils openssh-server;
dpkg-reconfigure --frontend=noninteractive --priority=critical debconf;
#Reconfiguring to default bash
echo "dash dash/sh boolean false" | debconf-set-selections;
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash;


echo "***************************************************Next is NTP Installation***************************************************";
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y ntp;
#configure the ntp server for broadcasting time within subnetwork
cp $MYP/NTP/ntp.conf /etc/ntp.conf;
sync;
service ntp restart;
sleep 5;

echo "********************************************Next is OpenStack Packages Installation********************************************";
echo "OpenStack Packages archive-keyring, python-argparse and dist-upgrade Started";
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y gplhost-archive-keyring;
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y python-argparse
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y openstack-deploy;
DEBIAN_FRONTEND=noninteractive apt-get --force-yes -y dist-upgrade;
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y linux-headers-$(uname -r);
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y linux-image-$(uname -r);
DEBIAN_FRONTEND=noninteractive apt-get --force-yes -y dist-upgrade;
sync; sleep 5;

echo "Reboot the System, Since New Kernel Image Installed";
echo -n "Continue With Reboot?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

reboot;
