#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

install_folder=$SCRIPTPATH/install
opencv_dir=$SCRIPTPATH/../opencv/install
boost_root=$SCRIPTPATH/../boost/boost_1_74_0/stage/lib/cmake # (Windows only, Linux installs from apt-get)
echo $boost_root
# Define Visual Studio version to use in CMake (Windows Only)
vs_version="Visual Studio 15 2017 Win64"

mkdir $SCRIPTPATH/build
cd $SCRIPTPATH/build

if [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)

    # Setup CMake build
    cmake -G "$vs_version" \
        -D CMAKE_INSTALL_PREFIX=$install_folder \
        -D OpenCV_DIR=$opencv_dir \
        -D BOOST_ROOT=$boost_root .. 

    # Build
    cmake --build . --config Release --parallel $((`nproc`+1)) -j $((`nproc`+1))
else
    # Setup CMake build
    cmake \
        -D CMAKE_INSTALL_PREFIX=$install_folder \
        -D OpenCV_DIR=$opencv_dir .. 
    # Build
    make -j$((`nproc`+1))
fi