#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

install_folder=$SCRIPTPATH/install
eigen_root=$SCRIPTPATH/../eigen/install/share/eigen3/cmake

mkdir $SCRIPTPATH/build
cd $SCRIPTPATH/build

if [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)

    # Setup CMake build
    cmake -D Eigen3_DIR=$eigen_root .. 

    # Build
    cmake --build . --config Release --parallel $((`nproc`)) -j $((`nproc`))
else
    # Setup CMake build
    cmake  -D Eigen3_DIR=$eigen_root .. 
    # Build
    make -j$((`nproc`+1))
fi