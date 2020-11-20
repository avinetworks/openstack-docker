set -x
set -e

export DEBIAN_FRONTEND=noninteractive
# install rabbitmq
apt-get update
apt-get -y install rabbitmq-server
set +e
service rabbitmq-server stop
service rabbitmq-server start
cat /var/log/rabbitmq/startup_err
set -e
service rabbitmq-server restart
rabbitmqctl add_user openstack avi123
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
