#!/bin/bash

sudo docker run  -p 8080:8080 -v /home/icreese/base_mapping/seeding:/home/icreese/base_mapping/seeding -v ${PWD}:${PWD} -it mapproxy_mapnik:ubuntu

