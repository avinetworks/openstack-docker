FROM ubuntu:18.04
MAINTAINER Rishabh Baranwal <rishabh.baranwal@avinetworks.com>
#ADD files /root/files
#RUN /bin/bash /root/files/installer.sh
#CMD /root/files/startup

ADD install_scripts/base.sh /root/install_scripts/base.sh
RUN /bin/bash /root/install_scripts/base.sh

ADD install_scripts/mysql.sh /root/install_scripts/mysql.sh
ADD install_scripts/mysqld_openstack.cnf /root/install_scripts/mysqld_openstack.cnf
RUN /bin/bash /root/install_scripts/mysql.sh

ADD install_scripts/rabbitmq.sh /root/install_scripts/rabbitmq.sh
RUN /bin/bash /root/install_scripts/rabbitmq.sh

ADD install_scripts/admin-openrc.sh /root/
ADD install_scripts/demo-openrc.sh /root/

# keystone
ADD install_scripts/keystone.conf /root/install_scripts/keystone.conf
ADD install_scripts/keystone.sh /root/install_scripts/keystone.sh
RUN /bin/bash /root/install_scripts/keystone.sh

# nova
ADD install_scripts/nova.conf /root/install_scripts/nova.conf
ADD install_scripts/nova.sh /root/install_scripts/nova.sh
RUN /bin/bash /root/install_scripts/nova.sh

# neutron
ADD install_scripts/neutron.conf /root/install_scripts/neutron.conf
ADD install_scripts//ml2_conf.ini /root/install_scripts/ml2_conf.ini
ADD install_scripts/neutron.sh /root/install_scripts/neutron.sh
RUN /bin/bash /root/install_scripts/neutron.sh

# glance
ADD install_scripts/glance-api.conf /root/install_scripts/glance-api.conf
ADD install_scripts/glance-registry.conf /root/install_scripts/glance-registry.conf
ADD install_scripts/glance.sh /root/install_scripts/glance.sh
RUN /bin/bash /root/install_scripts/glance.sh

# heat
ADD install_scripts/heat.conf /root/install_scripts/heat.conf
ADD install_scripts/heat.sh /root/install_scripts/heat.sh
RUN /bin/bash /root/install_scripts/heat.sh

# setup and startup files
ADD install_scripts/setup-avi-heat /root/install_scripts/setup-avi-heat
ADD install_scripts/startup /root/install_scripts/startup

