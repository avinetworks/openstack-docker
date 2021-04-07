#!/usr/bin/env bash

set -x
docker stop victoria-heat
docker rm victoria-heat
docker rmi avinetworks/victoria-heat
docker build -t avinetworks/victoria-heat -f ./Dockerfile .
