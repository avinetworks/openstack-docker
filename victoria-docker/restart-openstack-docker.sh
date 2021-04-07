#!/usr/bin/env bash

set -x
docker stop victoria-heat
docker rm victoria-heat

ETH0=`ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`
docker run --name=victoria-heat -p 9292:9292 -p 35357:35357 \
    -p 8774:8774 -p 5000:5000 -p 8004:8004 -p 9696:9696 \
    -e OSC_IP=$ETH0 -e AVI_IP=10.79.109.32 \
    -e HEAT_REPO='https://github.com/avinetworks/avi-heat' \
    -e HEAT_BRANCH=master -d -t -i avinetworks/victoria-heat \
    /bin/bash -c "/root/install_scripts/startup"

docker logs -f victoria-heat
