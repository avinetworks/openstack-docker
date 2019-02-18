set -x
set -e

source /root/admin-openrc.sh
echo "127.0.0.1  openstack-controller" >> /etc/hosts
export DEBIAN_FRONTEND=noninteractive
service mysql restart
#service rabbitmq-server start
while [ -n $(service rabbitmq-server start) ];
do
    sleep 1
done
service memcached restart
service apache2 restart

# add glance
mysql -u root --password="avi123" -e "CREATE DATABASE glance;" 
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'avi123';"

openstack user create --domain default --password avi123 glance
openstack role add --project service --user glance admin

openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --region RegionOne image public http://openstack-controller:9292
openstack endpoint create --region RegionOne image internal http://openstack-controller:9292
openstack endpoint create --region RegionOne image admin http://openstack-controller:9292

apt-get -y install glance python-glanceclient
cp /root/install_scripts/glance-api.conf /etc/glance/
cp /root/install_scripts/glance-registry.conf /etc/glance/
su -s /bin/sh -c "glance-manage db_sync" glance

