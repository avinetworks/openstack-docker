set -x
set -e

export DEBIAN_FRONTEND=noninteractive
service mysql restart

# install keystone
mysql -u root --password="avi123" -e "CREATE DATABASE keystone;"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'avi123';"
echo "manual" > /etc/init/keystone.override
apt-get -y install keystone apache2 libapache2-mod-wsgi memcached python-memcache
cp /root/install_scripts/keystone.conf /etc/keystone/
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password avi123 \
  --bootstrap-admin-url http://openstack-controller:35357/v3/ \
  --bootstrap-internal-url http://openstack-controller:5000/v3/ \
  --bootstrap-public-url http://openstack-controller:5000/v3/ \
  --bootstrap-region-id RegionOne

service memcached restart
service apache2 restart
rm -f /var/lib/keystone/keystone.db

echo "127.0.0.1  openstack-controller" >> /etc/hosts
source /root/admin-openrc.sh
openstack project create --domain default   --description "Service Project" service
openstack project create --domain default   --description "Demo Project" demo
openstack user create --domain default   --password avi123 demo
openstack role create user
openstack role add --project demo --user demo user

