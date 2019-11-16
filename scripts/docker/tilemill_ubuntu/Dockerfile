FROM ubuntu:18.04

RUN apt-get -y update

#build file for Tilemill on Ubuntu 18.04

# NEED:
# Node.js: Ubuntu: v8.11.x
# Mapnik > v3.6.2 (but may work on earlier versions)

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


# install tilemill
RUN cd
RUN git clone https://github.com/tilemill-project/tilemill.git && \
 cd tilemill && \
 npm install

EXPOSE 20009
EXPOSE 20008
EXPOSE 5482

