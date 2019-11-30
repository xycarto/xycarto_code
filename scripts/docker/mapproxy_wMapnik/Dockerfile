FROM ubuntu:16.04

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get install -y \
    libicu-dev \
    python-dev zlib1g-dev clang make pkg-config curl \
    libxml2 libxml2-dev \
    libfreetype6 libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libproj-dev \
    libtiff-dev \
    libcairo2 libcairo2-dev python-cairo python-cairo-dev \
    libcairomm-1.0 libcairomm-1.0-dev \
    ttf-unifont ttf-dejavu ttf-dejavu-core ttf-dejavu-extra \
    git build-essential python-nose \
    libgdal1-dev python-gdal \
    libsqlite3-dev libharfbuzz-dev libboost-dev libboost-filesystem-dev \
    libboost-program-options-dev libboost-python-dev \
    libboost-regex-dev libboost-system-dev libboost-thread-dev

RUN apt-get install -y git-core
RUN apt-get update

RUN git clone https://github.com/mapnik/mapnik --depth 10
RUN cd mapnik && \
  git fetch --all --tags --prune && \
  git checkout tags/v3.0.12 -b v3.0.12 && \
  git submodule update --init deps/mapbox/variant && \
  ./configure && \
  make && \
  make install

RUN apt-get install python-setuptools
RUN git clone https://github.com/mapnik/python-mapnik.git
RUN cd python-mapnik && \
  git checkout v3.0.x && \
  python setup.py install

RUN apt-get install -y python-imaging python-yaml
RUN git clone https://github.com/palmerj/mapproxy.git
RUN cd mapproxy && \
  git fetch origin mapnik_cachemapobj_multiproc && \
  git checkout mapnik_cachemapobj_multiproc && \
  python setup.py install

RUN apt-get install -y python-shapely