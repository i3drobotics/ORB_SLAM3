#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

install_folder=$SCRIPTPATH/install
if [[ "$OSTYPE" == "msys" ]]; then
    boost_root=$SCRIPTPATH/../boost/boost_1_74_0/stage/lib/cmake # (Windows only, Linux installs from apt-get)
    opencv_dir=$SCRIPTPATH/../opencv/install
else
    opencv_dir=$SCRIPTPATH/../opencv/install/lib/cmake/opencv4
fi

mkdir $SCRIPTPATH/build
cd $SCRIPTPATH/build

if [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)

    # Setup CMake build
    cmake \
        -D CMAKE_INSTALL_PREFIX=$install_folder \
        -D OpenCV_DIR=$opencv_dir \
        -D BOOST_ROOT=$boost_root .. 

    # Build
    cmake --build . --config Release --parallel $((`nproc`)) -j $((`nproc`))
else
    # Setup CMake build
    cmake \
        -D CMAKE_INSTALL_PREFIX=$install_folder \
        -D OpenCV_DIR=$opencv_dir .. 
    # Build
    make -j$((`nproc`+1))
fi