FROM ubuntu:18.04

#build file for Tilemill on Ubuntu 18.04 Alpine

# NEED:
# Node.js: Ubuntu: v8.11.x
# Mapnik > v3.6.2 (but may work on earlier versions)

# install nodejs 
apt-get install nodejs

apt-get install wget

#install nvm for node version control
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 8.11.3

nvm use 8.11.3

#install for Mapnik

apt-get install software-properties-common

# you might have to update your outdated clang
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get update -y
apt-get install -y gcc-6 g++-6 clang-3.9
export CXX="clang++-3.9" && export CC="clang-3.9"

# install mapnik
apt install git
git clone https://github.com/mapnik/mapnik mapnik --depth 10
cd mapnik
git submodule update --init
apt-get install python zlib1g-dev clang make pkg-config curl
source bootstrap.sh
./configure CUSTOM_CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" CXX=${CXX} CC=${CC}
make
make test
make install


# install tilemill
cd ..
git clone https://github.com/tilemill-project/tilemill.git
cd tilemill
nvm install lts/carbon
nvm use 8.11.3
npm install
npm start




