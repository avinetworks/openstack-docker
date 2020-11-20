set -x
set -e

source /root/admin-openrc.sh
echo "127.0.0.1  openstack-controller" >> /etc/hosts
export DEBIAN_FRONTEND=noninteractive
service mysql restart
set +e
service rabbitmq-server stop
service rabbitmq-server start
set -e
service rabbitmq-server restart
service memcached restart
set +e
service apache2 stop
service apache2 start
set -e
service apache2 restart

# add neutron service
mysql -u root --password="avi123" -e "CREATE DATABASE neutron;"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'avi123';"

openstack user create --domain default --password avi123 neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://openstack-controller:9696
openstack endpoint create --region RegionOne network internal http://openstack-controller:9696
openstack endpoint create --region RegionOne network admin http://openstack-controller:9696
apt-get -y install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-dhcp-agent neutron-metadata-agent python-neutronclient conntrack
cp /root/install_scripts/neutron.conf /etc/neutron/
cp /root/install_scripts/ml2_conf.ini /etc/neutron/plugins/ml2/
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
service neutron-server restart
