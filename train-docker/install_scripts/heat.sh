set -x
set -e

source /root/admin-openrc.sh
echo "127.0.0.1  openstack-controller" >> /etc/hosts
export DEBIAN_FRONTEND=noninteractive
service mysql restart
service rabbitmq-server start
service memcached restart
service apache2 restart

# install heat
mysql -u root --password="avi123" -e "CREATE DATABASE heat;" 
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY 'avi123';"

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
apt-get install heat-api heat-api-cfn heat-engine -y
cp /root/install_scripts/heat.conf /etc/heat/
su -s /bin/sh -c "heat-manage db_sync" heat

service heat-api restart
service heat-api-cfn restart
service heat-engine restart
