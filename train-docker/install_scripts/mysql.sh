set -x
set -e

export DEBIAN_FRONTEND=noninteractive
# install mysql
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://ftp.utexas.edu/mariadb/repo/10.3/ubuntu bionic main'
apt-get update && apt-get -y install mariadb-server
apt-get -y install python-pymysql && service mysql restart
mysqladmin -u root password avi123
cp /root/install_scripts/mysqld_openstack.cnf /etc/mysql/mariadb.conf.d/99-openstack.cnf
service mysql restart
