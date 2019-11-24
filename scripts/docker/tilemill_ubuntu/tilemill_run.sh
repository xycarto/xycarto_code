#!/bin/bash

sudo docker run \
    -p 20009:20009 \
    -p 20008:20008 \
    -p 5482:5482 \
    -v ${HOME}:/home/${USER} \
    -v ${HOME}/Documents/MapBox:/root/Documents/MapBox \
    -it tilemill:ubuntu18.04

