#!/bin/bash

sudo docker run  -p 8080:8080 -v /home/icreese/base_mapping/seeding:/home/icreese/base_mapping/seeding -v /home/icreese/data_store:/home/icreese/data_store -it mapproxy_mapnik:alpine

