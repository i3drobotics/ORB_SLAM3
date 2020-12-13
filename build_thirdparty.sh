#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

echo "Configuring Thirdparty/eigen ..."
cd Thirdparty/eigen
./build.sh
cd $SCRIPTPATH

echo "Configuring Thirdparty/boost ..."
cd Thirdparty/boost
./build.sh
cd $SCRIPTPATH

echo "Configuring and building Thirdparty/g2o ..."
cd Thirdparty/g2o
./build.sh
cd $SCRIPTPATH

echo "Configuring and building Thirdparty/opencv ..."
cd Thirdparty/opencv
./build.sh
cd $SCRIPTPATH

echo "Configuring and building Thirdparty/DBoW2 ..."
cd Thirdparty/DBoW2
./build.sh
cd $SCRIPTPATH

echo "Configuring Thirdparty/Pangolin ..."
cd Thirdparty/Pangolin
./build.sh
cd $SCRIPTPATH
