set -x
set -e

source /root/admin-openrc.sh
echo "127.0.0.1  openstack-controller" >> /etc/hosts
export DEBIAN_FRONTEND=noninteractive
service mysql restart
service rabbitmq-server start
service memcached restart
service apache2 restart

#add nova for cloud connector to work
mysql -u root --password="avi123" -e "CREATE DATABASE nova;" 
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'avi123';"

mysql -u root --password="avi123" -e "CREATE DATABASE nova_api;" 
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'avi123';"


mysql -u root --password="avi123" -e "CREATE DATABASE nova_cell0;" 
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'avi123';"

openstack user create --domain default --password avi123 nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://openstack-controller:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://openstack-controller:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://openstack-controller:8774/v2.1

openstack user create --domain default --password avi123 placement
openstack role add --project service --user placement admin
openstack service create --name placement --description "Placement API" placement
openstack endpoint create --region RegionOne placement public http://openstack-controller:8778
openstack endpoint create --region RegionOne placement internal http://openstack-controller:8778
openstack endpoint create --region RegionOne placement admin http://openstack-controller:8778


apt-get -y install nova-api nova-conductor nova-consoleauth \
  nova-novncproxy nova-scheduler nova-placement-api python-novaclient
cp /root/install_scripts/nova.conf /etc/nova/
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
