set -x
set -e

export DEBIAN_FRONTEND=noninteractive

# install mysql

##### OLD REPOS ####
# apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
# add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://ftp.utexas.edu/mariadb/repo/10.3/ubuntu bionic main'

# apt-get -y install systemd
apt-get --yes install software-properties-common
#apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
#add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirror.vpsfree.cz/mariadb/repo/10.4/ubuntu bionic main'
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirror.ihost.md/mariadb/repo/10.5/ubuntu bionic main'
apt-get -y update
apt-get -y install mariadb-server 
apt-get -y install python3-pymysql
service mariadb restart
mysqladmin -u root password avi123
cp /root/install_scripts/mysqld_openstack.cnf /etc/mysql/mariadb.conf.d/99-openstack.cnf
#service mysql restart
service mariadb restart
