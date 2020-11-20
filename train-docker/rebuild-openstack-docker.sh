#!/usr/bin/env bash

set -x
docker stop train-heat
docker rm train-heat
docker rmi avinetworks/train-heat
docker build -t avinetworks/train-heat -f ./Dockerfile .
