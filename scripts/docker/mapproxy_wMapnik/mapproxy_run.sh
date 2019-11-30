#!/bin/bash

docker run  -p 8080:8080 -v ${PWD}:${PWD} -it mapproxy_python_mapnik:ubuntu16.04


