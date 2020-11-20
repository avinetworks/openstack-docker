#!/usr/bin/env bash

set -x
docker stop liberty-heat
docker rm liberty-heat
docker rmi avinetworks/liberty-heat
docker build -t avinetworks/liberty-heat -f ./Dockerfile .
