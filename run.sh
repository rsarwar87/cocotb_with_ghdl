#!/bin/bash

docker run --rm -it --privileged -v ${PWD}:/home/containeruser/wkspace:Z  -v /opt/Xilinx/:/opt/Xilinx -u ${UID}:${GID} -e DISPLAY=$DISPLAY \
  --volume /tmp/.X11-unix:/tmp/.X11-unix -w /home/containeruser/wkspace cocotb_with_ghdl make
