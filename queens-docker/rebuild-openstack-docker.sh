#!/usr/bin/env bash


set -x
docker stop queens-heat
docker rm queens-heat
docker rmi avinetworks/queens-heat
docker build -t avinetworks/queens-heat -f ./Dockerfile .
