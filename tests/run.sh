#!/bin/bash

docker run --rm -it --privileged -v ${PWD}:/home/containeruser/wkspace:Z -u ${UID}:${GID}  -w /home/containeruser/wkspace cocotb_with_ghdl make
