#! /bin/sh

MYP=/home/sandip/OpenStack/Controller;


echo "***********************************************Next is OpenStack Network Installation***********************************************";
echo $'auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet static\naddress 192.168.1.11\nnetmask 255.255.255.0\nbroadcast 192.168.1.255\n\nauto eth0:1\niface eth0:1 inet manual\n\tup ip link set dev $IFACE up\n\tdown ip link set dev $IFACE down' > /etc/network/interfaces;
service networking stop && service networking start;
route add default gw 192.168.1.1;
service networking stop && service networking start;
sync; sleep 5;



echo "***********************************************Next is MySQL Server Installation***********************************************";
MYSQL_PASSWORD=123;
echo "mysql-server-5.5 mysql-server/root_password password ${MYSQL_PASSWORD}
mysql-server-5.5 mysql-server/root_password seen true
mysql-server-5.5 mysql-server/root_password_again password ${MYSQL_PASSWORD}
mysql-server-5.5 mysql-server/root_password_again seen true
" | debconf-set-selections;

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y mysql-server python-mysqldb;

#edit the bind-address=controller ip address; default-storage-engine = innodb; innodb_file_per_table; collation-server = utf8_general_ci; 
#init-connect = 'SET NAMES utf8'; character-set-server = utf8;
cp $MYP/MySQL/my.cnf /etc/mysql/my.cnf;
service mysql restart;
echo "Securing MySQL";
#mysql_install_db and mysql_secure_installation 
mysql -u root --password=123 -e "UPDATE mysql.user SET Password=password('123') WHERE User='root'";
mysql -u root --password=123 -e "DROP USER ''@'localhost'";
mysql -u root --password=123 -e "DROP USER ''@'%'";
mysql -u root --password=123 -e "DROP DATABASE test";
mysql -u root --password=123 -e "FLUSH PRIVILEGES";
echo "MySQL Server Installation Done";
sleep 5;
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;


echo "**********************************************Next is Rabbit Server Installation**********************************************";
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y rabbitmq-server;
rabbitmqctl change_password guest 123;
echo "Password for guest user changed.";
#echo "Edit /etc/rabbitmq/rabbitmq-env.conf"
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Rabbit/rabbitmq-env.conf /etc/rabbitmq/rabbitmq-env.conf;
sync; sleep 5;
service rabbitmq-server restart;
echo "RabbitMq Server Installation Done";


echo "*************************************************Next is Keystone Installation*************************************************";
#Creating database for keystone
mysql -u root --password=123 -e "CREATE DATABASE keystonedb";
mysql -u root --password=123 -e "GRANT ALL PRIVILEGES ON keystonedb.* TO 'keystone'@'localhost' IDENTIFIED BY '123'";
mysql -u root --password=123 -e "GRANT ALL PRIVILEGES ON keystonedb.* TO 'keystone'@'%' IDENTIFIED BY '123'";
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y keystone python-keystoneclient;
#edit the connection=http://keystone:123@controller/keystonedb line and also the admin_token=123456789abcdef
#echo "Edit /etc/Keystone/keystone.conf"
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Keystone/keystone.conf /etc/keystone/keystone.conf;
sync;
su -s /bin/sh -c "keystone-manage db_sync" keystone;
service keystone restart;
echo "Keystone Installation Done";

export OS_SERVICE_TOKEN=123456789abcdef;
export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0;
echo "OS_SERVICE_TOKEN and ENDPOINT Exported";
sync; sleep 5;

keystone tenant-create --name admin --description "Admin Tenant";
echo "Keystone Tenant-admin Created";
sleep 5;

keystone tenant-create --name service --description "Service Tenant";
echo "Keystone Tenant-service Created";

keystone user-create --name admin --pass 123 --email root@localhost.com;
echo "Keystone User-admin Created";

keystone role-create --name admin;
echo "Keystone Role-admin Created";

keystone user-role-add --user admin --tenant admin --role admin;
echo "Keystone User-admin Added to Role-admin";

#Create a demo tenant and user for typical operations in your environment.
keystone tenant-create --name demo --description "Demo Tenant";
keystone user-create --name demo --tenant demo --pass 123 --email root@localhost.com


ID=$(keystone service-create --name=keystone --type=identity --description="Keystone Identity Service" | grep -m 1 id | awk '{print $4}');
echo "Keystone Service-keystone Created";

#Note the service-id below is received from the output of the above command
keystone endpoint-create --service-id=$ID --publicurl=http://controller:5000/v2.0 --internalurl=http://controller:5000/v2.0 --adminurl=http://controller:35357/v2.0 --region regionOne;
echo "Keystone Enpoint for Service-keystone Created";
sleep 5;

#verify keystone installation
unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT;
echo "Keystone OS_SERVICE_TOKEN and ENDPOINT Unset";
sleep 5;

export OS_USERNAME=admin;
export OS_PASSWORD=123;
export OS_TENANT_NAME=admin;
export OS_AUTH_URL="http://controller:35357/v2.0";
echo "Exported OS_USERNAME, PASSWORD, TENANT_NAME, AUTH_URL...."
sleep 5;

keystone token-get;
echo "verified token-get";

keystone tenant-list;
echo "verified tenant-list";

keystone user-list;
echo "verified user-list";

keystone role-list;
echo "verified role-list";
sleep 5;

echo "*******************************************Next is Glance Installation*******************************************";
mysql -u root --password=123 -e "CREATE DATABASE glancedb";
mysql -u root --password=123 -e "GRANT ALL PRIVILEGES ON glancedb.* TO 'glance'@'localhost' IDENTIFIED BY '123'";
mysql -u root --password=123 -e "GRANT ALL PRIVILEGES ON glancedb.* TO 'glance'@'%' IDENTIFIED BY '123'";

export OS_USERNAME=admin;
export OS_PASSWORD=123;
export OS_TENANT_NAME=admin;
export OS_AUTH_URL="http://controller:35357/v2.0";

keystone user-create --name glance --pass 123 --email root@localhost.com;
keystone user-role-add --user glance --tenant service --role admin;
ID=$(keystone service-create --name glance --type image --description "Openstack Image Service" | grep -m 1 id | awk '{print $4}');
keystone endpoint-create --service-id $ID --publicurl http://controller:9292 --internalurl http://controller:9292 --adminurl http://controller:9292 --region regionOne;

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y glance python-glanceclient;

#echo "Edit /etc/glance/glance-api.conf and glance-registry.conf"
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Glance/glance-api.conf /etc/glance/glance-api.conf;
cp $MYP/Glance/glance-registry.conf /etc/glance/glance-registry.conf;
su -s /bin/sh -c "glance-manage db_sync" glance;
sync; sleep 5;
service glance-registry restart;
service glance-api restart;
#Glance Installation Done

#copy the image for test purpose
echo "Verifying Glance Installation";
mkdir -p /tmp/images;
cp $MYP/Images/cirros-0.3.1-x86_64-disk.img /tmp/images/;
sync;
glance image-create --name "cirros-0.3.1-x86_64" --file /tmp/images/cirros-0.3.1-x86_64-disk.img --disk-format qcow2 --container-format bare --is-public True --progress;
glance image-list;
echo "Verification of Glance Installation Done";
rm -r /tmp/images;
sync;

echo "**************************************************Next is Nova Installation**************************************************";
mysql -u root --password=123 -e "CREATE DATABASE novadb";
mysql -u root --password=123 -e "GRANT ALL PRIVILEGES ON novadb.* TO 'nova'@'localhost' IDENTIFIED BY '123'";
mysql -u root --password=123 -e "GRANT ALL PRIVILEGES ON novadb.* TO 'nova'@'%' IDENTIFIED BY '123'";

export OS_USERNAME=admin;
export OS_PASSWORD=123;
export OS_TENANT_NAME=admin;
export OS_AUTH_URL="http://controller:35357/v2.0";

keystone user-create --name nova --pass 123 --email root@localhost.com;
keystone user-role-add --user nova --tenant service --role admin;
ID=$(keystone service-create --name nova --type compute --description "Openstack Compute" | grep -m 1 id | awk '{print $4}');
keystone endpoint-create --service-id $ID --publicurl http://controller:8774/v2/%\(tenant_id\)s --internalurl http://controller:8774/v2/%\(tenant_id\)s --adminurl http://controller:8774/v2/%\(tenant_id\)s --region regionOne;

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient;

echo "Edit /etc/nova/nova.conf"
echo -n "Continue?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

cp $MYP/Nova/nova.conf /etc/nova/nova.conf;
su -s /bin/sh -c "nova-manage db sync" nova;
sync; sleep 5;
service nova-api restart;
service nova-cert restart;
service nova-consoleauth restart;
service nova-scheduler restart;
service nova-conductor restart;
service nova-novncproxy restart;

echo "1. Go to Compute, wait till #2 mssg on Compute....";
echo -n "Nova-Compute Installation Done?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

#This step to be executed only after Nova installation on Compute Node
echo "Verifying Entire Nova Image Service Installation...";
nova service-list;
nova image-list;

echo "Neutron Installation about to start. Please enter 'n' to exit the script";
echo -n "Continue?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

echo "************************************************Next is Neutron Installation************************************************";
mysql -u root --password=123 -e "CREATE DATABASE neutrondb";
mysql -u root --password=123 -e "GRANT ALL PRIVILEGES ON neutrondb.* TO 'neutron'@'localhost' IDENTIFIED BY '123'";
mysql -u root --password=123 -e "GRANT ALL PRIVILEGES ON neutrondb.* TO 'neutron'@'%' IDENTIFIED BY '123'";

export OS_USERNAME=admin;
export OS_PASSWORD=123;
export OS_TENANT_NAME=admin;
export OS_AUTH_URL="http://controller:35357/v2.0";
keystone user-create --name neutron --pass 123 --email root@localhost.com;
keystone user-role-add --user neutron --tenant service --role admin;
keystone service-create --name neutron --type network --description "OpenStack Networking";
keystone endpoint-create --service-id $(keystone service-list | awk '/ network / {print $2}') --publicurl http://controller:9696 --adminurl http://controller:9696 --internalurl http://controller:9696 --region regionOne;

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y neutron-server;
#echo "Edit /etc/neutron/neutron.conf"
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Neutron/neutron.conf /etc/neutron/neutron.conf;
ID=$(keystone tenant-get service | grep -m 1 id | awk '{print $4}');
sed -i 's/.*nova_admin_tenant_id =.*/nova_admin_tenant_id = '$ID'/' /etc/neutron/neutron.conf;

#echo "Edit /etc/neutron/plugins/ml2/ml2_conf.ini"
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Neutron/ml2_conf.ini /etc/neutron/plugins/ml2/

#echo "Edit /etc/nova/nova.conf"
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Neutron/nova1.conf /etc/nova/nova.conf
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno" neutron;

service nova-api restart;
service nova-scheduler restart;
service nova-conductor restart;
service neutron-server restart;

export OS_USERNAME=admin;
export OS_PASSWORD=123;
export OS_TENANT_NAME=admin;
export OS_AUTH_URL="http://controller:35357/v2.0";
neutron ext-list;

echo "*********************************************Neutron-Controller Installation Done*********************************************";

DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y linux-headers-$(uname -r);

echo "3. Go to Network, wait till #4 mssg on Network....";
echo -n "Continue with Neutron-Network Installation?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

#This step to be executed only after neutron installation on Network Node


#echo "Edit /etc/nova/nova.conf"
#echo -n "Continue?y/n > ";
#read var;
#if [ "$var" = "n" ];
#	then exit 0;
#fi;

cp $MYP/Neutron/nova2.conf /etc/nova/nova.conf;
service nova-api restart;

echo "Edit /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini"
echo -n "Continue?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

#cp $MYP/Neutron/ovs_neutron_plugin.ini /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini;

echo "5. Go to Network, wait till #6 mssg on Network....";
echo -n "Neutron-Network Installation Done?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;

#This step to be executed only after neutron installation on Compute Node
export OS_USERNAME=admin;
export OS_PASSWORD=123;
export OS_TENANT_NAME=admin;
export OS_AUTH_URL="http://controller:35357/v2.0";
neutron agent-list;

echo "7. Go to Compute, wait till #8 mssg on Compute....";
echo -n "Neutron-Compute Installation Done?y/n > ";
read var;
if [ "$var" = "n" ];
	then exit 0;
fi;
neutron agent-list;

echo "*********************************************Creating Intial Networks*********************************************";
#export OS_USERNAME=demo;
#export OS_PASSWORD=123;
#export OS_TENANT_NAME=demo;
#export OS_AUTH_URL="http://controller:35357/v2.0";

#neutron net-create demo-net;
#neutron subnet-create demo-net --name demo-subnet --gateway 192.168.1.1 192.168.1.0/24;
#neutron router-create demo-router;

