set -x
set -e

export DEBIAN_FRONTEND=noninteractive
# install rabbitmq
apt-get update
apt-get -y install rabbitmq-server
service rabbitmq-server start
rabbitmqctl add_user openstack avi123
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
