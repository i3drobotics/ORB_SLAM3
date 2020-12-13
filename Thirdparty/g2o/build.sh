#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

install_folder=$SCRIPTPATH/install
# Define Visual Studio version to use in CMake (Windows Only)
vs_version="Visual Studio 15 2017 Win64"
eigen_root=$SCRIPTPATH/../eigen/install/share/eigen3/cmake

mkdir $SCRIPTPATH/build
cd $SCRIPTPATH/build

if [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)

    # Setup CMake build
    cmake -G "$vs_version" -D Eigen3_DIR=$eigen_root .. 

    # Build
    cmake --build . --config Release --parallel $((`nproc`+1)) -j $((`nproc`+1))
else
    # Setup CMake build
    cmake  -D Eigen3_DIR=$eigen_root .. 
    # Build
    make -j$((`nproc`+1))
fi