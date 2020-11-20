#!/usr/bin/env bash

set -x
docker stop ocata-heat
docker rm ocata-heat
docker rmi ypraveen/ocata
docker rmi avinetworks/ocata-heat
docker build -t avinetworks/ocata-heat -f ./Dockerfile .
