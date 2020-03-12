FROM ubuntu:18.04

RUN apt-get -y update

RUN apt -y install git

RUN apt -y install make

RUN apt -y install cmake

RUN apt -y install gawk

RUN git clone --recursive https://github.com/Melown/vts-registry.git

RUN cd vts-resitry/registry

RUN make

RUN cd

RUN apt-get update

RUN apt -y install g++

RUN git clone https://www.graphics.rwth-aachen.de:9000/OpenMesh/OpenMesh.git
RUN cd OpenMesh
RUN mkdir build
RUN cd build
RUN cmake ..
RUN make -j4
RUN sudo make install

RUN cd

RUN apt-get -y install software-properties-common

