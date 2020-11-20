#!/usr/bin/env bash

set -x
docker stop pike-heat
docker rm pike-heat
docker rmi ypraveen/pike
docker rmi avinetworks/pike-heat
docker build -t avinetworks/pike-heat -f ./Dockerfile .
