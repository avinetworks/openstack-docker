set -x
set -e

cp /root/files/demo-openrc.sh /root/
cp /root/files/admin-openrc.sh /root/
source /root/admin-openrc.sh

apt-get update
apt-get --yes install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get update && apt-get -y dist-upgrade
apt-get install -y python-openstackclient  python-pip git
apt-get install -y ssh-client

# install mysql
export DEBIAN_FRONTEND=noninteractive
apt-get -y install mariadb-server python-pymysql && service mysql restart
mysqladmin -u root password avi123
cp /root/files/mysqld_openstack.cnf /etc/mysql/conf.d/
service mysql restart

# install rabbitmq
apt-get -y install rabbitmq-server
set +e
service rabbitmq-server stop
service rabbitmq-server start
set -e
service rabbitmq-server restart
rabbitmqctl add_user openstack avi123
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
mysql -u root --password="avi123" -e "CREATE DATABASE keystone;"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'avi123';"

# install keystone
echo "manual" > /etc/init/keystone.override
apt-get -y install keystone apache2 libapache2-mod-wsgi memcached python-memcache
cp /root/files/keystone.conf /etc/keystone/
su -s /bin/sh -c "keystone-manage db_sync" keystone

cp /root/files/wsgi-keystone.conf /etc/apache2/sites-available/
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
service memcached restart
service apache2 restart
rm -f /var/lib/keystone/keystone.db

OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack service create --name keystone --description "OpenStack Identity" identity
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack endpoint create --region RegionOne identity public http://openstack-controller:5000/v2.0
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack endpoint create --region RegionOne identity internal http://openstack-controller:5000/v2.0
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack endpoint create --region RegionOne identity admin http://openstack-controller:35357/v2.0

OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack project create --domain default --description "Admin Project" admin
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack user create --domain default --password avi123 admin
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack role create admin
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack role add --project admin --user admin admin
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack project create --domain default   --description "Service Project" service
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack project create --domain default   --description "Demo Project" demo
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack user create --domain default   --password avi123 demo
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack role create user
OS_TOKEN=avi123 OS_URL=http://localhost:35357/v3 OS_IDENTITY_API_VERSION=3 openstack role add --project demo --user demo user

mysql -u root --password="avi123" -e "CREATE DATABASE heat;" 
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY 'avi123';"

echo "127.0.0.1  openstack-controller" >> /etc/hosts
openstack user create --domain default --password avi123 heat
openstack role add --project service --user heat admin
openstack service create --name heat   --description "Orchestration" orchestration
openstack service create --name heat-cfn   --description "Orchestration"  cloudformation
openstack endpoint create --region RegionOne   orchestration public http://openstack-controller:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne   orchestration internal http://openstack-controller:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne   orchestration admin http://openstack-controller:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne   cloudformation public http://openstack-controller:8000/v1
openstack endpoint create --region RegionOne   cloudformation internal http://openstack-controller:8000/v1
openstack endpoint create --region RegionOne   cloudformation admin http://openstack-controller:8000/v1
openstack domain create --description "Stack projects and users" heat
openstack user create --domain heat --password avi123 heat_domain_admin
openstack role add --domain heat --user heat_domain_admin admin
openstack role create heat_stack_owner
openstack role add --project demo --user demo heat_stack_owner
openstack role create heat_stack_user
apt-get install heat-api heat-api-cfn heat-engine   python-heatclient -y
cp /root/files/heat.conf /etc/heat/
su -s /bin/sh -c "heat-manage db_sync" heat

service heat-api restart
service heat-api-cfn restart
service heat-engine restart

# add neutron service
mysql -u root --password="avi123" -e "CREATE DATABASE neutron;"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'avi123';"

source /root/admin-openrc.sh
echo "127.0.0.1  openstack-controller" >> /etc/hosts
openstack user create --domain default --password avi123 neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://openstack-controller:9696
openstack endpoint create --region RegionOne network internal http://openstack-controller:9696
openstack endpoint create --region RegionOne network admin http://openstack-controller:9696
apt-get -y install neutron-server neutron-plugin-ml2 neutron-plugin-linuxbridge-agent neutron-dhcp-agent neutron-metadata-agent python-neutronclient conntrack
cp /root/files/neutron.conf /etc/neutron/
cp /root/files/ml2_conf.ini /etc/neutron/plugins/ml2/
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
service neutron-server restart


#add nova for cloud connector to work
mysql -u root --password="avi123" -e "CREATE DATABASE nova;" 
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'avi123';"

source /root/admin-openrc.sh
openstack user create --domain default --password avi123 nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://openstack-controller:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://openstack-controller:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://openstack-controller:8774/v2/%\(tenant_id\)s

apt-get -y install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient
cp /root/files/nova.conf /etc/nova/
su -s /bin/sh -c "nova-manage db sync" nova


# add glance
mysql -u root --password="avi123" -e "CREATE DATABASE glance;" 
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'avi123';"

source /root/admin-openrc.sh
openstack user create --domain default --password avi123 glance
openstack role add --project service --user glance admin

openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --region RegionOne image public http://openstack-controller:9292
openstack endpoint create --region RegionOne image internal http://openstack-controller:9292
openstack endpoint create --region RegionOne image admin http://openstack-controller:9292

apt-get -y install glance python-glanceclient
cp /root/files/glance-api.conf /etc/glance/
cp /root/files/glance-registry.conf /etc/glance/
su -s /bin/sh -c "glance-manage db_sync" glance

