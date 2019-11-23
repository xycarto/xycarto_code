FROM ubuntu:18.04

RUN apt-get -y update

#build for mapproxy using mapnik and python mapnik

# install nodejs 
RUN apt-get install -y nodejs

RUN apt-get install -y wget

#install nvm for node version control
ENV NODE_VERSION=8.11.3
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

#install for Mapnik

RUN apt-get install -y software-properties-common

# might have to update your outdated clang
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update -y
RUN apt-get install -y gcc-6 g++-6 clang-3.9
RUN export CXX="clang++-3.9" && export CC="clang-3.9"

# install mapnik
RUN cd
RUN apt install -y git
RUN apt-get install -y python zlib1g-dev make pkg-config
RUN git clone https://github.com/mapnik/mapnik mapnik --depth 10
RUN cd /mapnik && \
 git submodule update --init && \
 /bin/bash -c "source bootstrap.sh" && \
 export CXX="clang++-3.9" && export CC="clang-3.9" && \
 ./configure CUSTOM_CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" CXX=${CXX} CC=${CC} && \
 make && \
 make test && \
 make install

#install Mapproxy

RUN apt-get install -y python-pil python-yaml libproj12

RUN apt-get install -y libgeos-dev python-lxml libgdal-dev python-shapely

RUN apt-get install build-essential python-dev libjpeg-dev \
  zlib1g-dev libfreetype6-dev
RUN pip install Pillow

RUN pip install MapProxy

# install gdal
RUN apt-get install -y python3.6-dev

RUN add-apt-repository ppa:ubuntugis/ppa && sudo apt-get update

RUN apt-get update

RUN apt-get install -y gdal-bin


EXPOSE 8080

