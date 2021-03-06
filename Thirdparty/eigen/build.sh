#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

eigen_version=3.3.9
install_folder=$SCRIPTPATH/install

# download eigen repo
git clone https://gitlab.com/libeigen/eigen.git

# checkout specific eigen version
cd eigen
git checkout tags/$eigen_version

# Create install folder
mkdir $install_folder

mkdir $SCRIPTPATH/eigen/build
cd $SCRIPTPATH/eigen/build

if [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)

    # Setup CMake build
    cmake -D CMAKE_INSTALL_PREFIX=$install_folder .. 

    # Build
    cmake --build . --config Release --target install --parallel $((`nproc`)) -j $((`nproc`))
else
    # Setup CMake build
    cmake -D CMAKE_INSTALL_PREFIX=$install_folder .. 
    # Build
    make -j$((`nproc`+1))
    make install
fi