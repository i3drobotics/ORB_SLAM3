#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

install_folder=$SCRIPTPATH/install

git clone https://github.com/stevenlovegrove/Pangolin.git

# Copy corrected CMake to Pangolin folder
cp -fr CMakeLists.txt $SCRIPTPATH/Pangolin/CMakeLists.txt

mkdir $SCRIPTPATH/Pangolin/build
cd $SCRIPTPATH/Pangolin/build

if [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)

    # Setup CMake build
    cmake \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=$install_folder .. 

    # Build
    cmake --build . --config Release --target install --parallel $((`nproc`+1)) -j $((`nproc`+1))
else
    # Install dependencies
    sudo apt install libglew-dev
    
    # Setup CMake build
    cmake \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=$install_folder .. 
    # Build
    make -j$((`nproc`+1))
    make install
fi