#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

opencv_dir=$SCRIPTPATH/Thirdparty/opencv/install
boost_root=$SCRIPTPATH/Thirdparty/boost/boost_1_74_0/stage/lib/cmake
eigen_include_dir=$SCRIPTPATH/Thirdparty/eigen/install/include/eigen3
pangolin_dir=$SCRIPTPATH/Thirdparty/Pangolin/install/lib/cmake/Pangolin
vs_version="Visual Studio 15 2017 Win64" # Windows only

# Comment this out if you have already done this
#./build_thirdparty.sh

echo "Uncompress vocabulary ..."
cd $SCRIPTPATH/Vocabulary
tar -xf ORBvoc.txt.tar.gz
cd $SCRIPTPATH

echo "Configuring and building ORB_SLAM3 ..."
mkdir build
cd build
cmake_options="\
-D CMAKE_BUILD_TYPE=RELEASE \
-D OpenCV_DIR=$opencv_dir \
-D BOOST_ROOT=$boost_root \
-D G2O_EIGEN3_INCLUDE=$eigen_include_dir \
-D Pangolin_DIR=$pangolin_dir"

if [[ "$OSTYPE" == "msys" ]]; then
    # Setup CMake build
    cmake -G "$vs_version" $cmake_options ..
    # Build
    cmake --build . --config Release --parallel $((`nproc`+1)) -j $((`nproc`+1))
else
    # Setup CMake build
    cmake $cmake_options ..
    # Build
    make -j$((`nproc`+1))
fi
