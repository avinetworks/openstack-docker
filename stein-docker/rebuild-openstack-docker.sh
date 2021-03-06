#!/usr/bin/env bash

set -x
docker stop stein-heat
docker rm stein-heat
docker rmi avinetworks/stein-heat
docker build -t avinetworks/stein-heat -f ./Dockerfile .
