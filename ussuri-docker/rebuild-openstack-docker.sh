#!/usr/bin/env bash

set -x
docker stop ussuri-heat
docker rm ussuri-heat
docker rmi avinetworks/ussuri-heat
docker build -t avinetworks/ussuri-heat -f ./Dockerfile .
