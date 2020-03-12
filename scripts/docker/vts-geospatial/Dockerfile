FROM ubuntu:18.04

RUN apt-get -y update

#build file for vts-geospatial-backend on Ubuntu 18.04

RUN apt-get -y install wget 

RUN apt-get -y install apt-transport-https

RUN apt-get -y install gnupg

RUN cd /etc/apt/sources.list.d/ && wget http://cdn.melown.com/packages/conf/melown-bionic.list

RUN  wget -O - http://cdn.melown.com/packages/keys/oss.packages%40melown.com.key | apt-key add -

RUN cd

RUN apt-get update

RUN apt-get -y --fix-missing install vts-backend

EXPOSE 8070