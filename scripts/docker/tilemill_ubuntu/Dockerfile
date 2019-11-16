FROM ubuntu:18.04

RUN apt-get -y update

#build file for Tilemill on Ubuntu 18.04 Alpine

# NEED:
# Node.js: Ubuntu: v8.11.x
# Mapnik > v3.6.2 (but may work on earlier versions)

# install nodejs 
RUN apt-get install -y nodejs

RUN apt-get install -y wget

#install nvm for node version control
RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

RUN export NVM_DIR="$HOME/.nvm"

RUN [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

RUN [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

RUN nvm install 8.11.3

RUN nvm use 8.11.3

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
RUN git clone https://github.com/mapnik/mapnik mapnik --depth 10
RUN cd mapnik
RUN git submodule update --init
RUN apt-get install -y python zlib1g-dev clang make pkg-config curl
RUN source bootstrap.sh
RUN ./configure CUSTOM_CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" CXX=${CXX} CC=${CC}
RUN make
RUN make test
RUN make install


# install tilemill
RUN cd
RUN git clone https://github.com/tilemill-project/tilemill.git
RUN cd tilemill
RUN nvm use 8.11.3
RUN npm install

EXPOSE 20009
EXPOSE 20008
EXPOSE 5482

