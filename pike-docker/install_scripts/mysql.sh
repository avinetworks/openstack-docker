set -x
set -e

export DEBIAN_FRONTEND=noninteractive
# install mysql
apt-get -y install mariadb-server python-pymysql && service mysql restart
mysqladmin -u root password avi123
cp /root/install_scripts/mysqld_openstack.cnf /etc/mysql/mariadb.conf.d/99-openstack.cnf
service mysql restart
