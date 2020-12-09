#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

opencv_version=4.5.0
install_folder=$SCRIPTPATH/install
# Define Visual Studio version to use in CMake (Windows Only)
vs_version="Visual Studio 15 2017 Win64"

# download opencv repo
git clone https://github.com/opencv/opencv.git

# checkout specific opencv version
cd opencv
git checkout tags/$opencv_version

# Create install folder
mkdir $install_folder

# Create build folder
mkdir $SCRIPTPATH/opencv/build
cd $SCRIPTPATH/opencv/build

#CMake options chosen for a fast build
cmake_options="\
-D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=$install_folder \
-D BUILD_opencv_world=ON \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D BUILD_opencv_python=OFF \
-D BUILD_opencv_python3=OFF \
-D BUILD_opencv_python2=OFF \
-D BUILD_EXAMPLES=OFF \
-D ENABLE_FAST_MATH=ON \
-D WITH_TBB=ON \
-D WITH_OPENMP=ON \
-D WITH_IPP=ON \
-D BUILD_DOCS=OFF \
-D BUILD_PERF_TESTS=OFF \
-D BUILD_TESTS=OFF \
-D WITH_CSTRIPES=ON \
-D WITH_OPENCL=ON"

if [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)

    # Setup CMake build (options chosen for a fast build)
    cmake -G "$vs_version" $cmake_options ..

    # Build and install OpenCV
    cmake --build . --config Release --target install --parallel $((`nproc`+1)) -j $((`nproc`+1))
else
    # Install dependencies
    sudo apt-get install libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev
    sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
    sudo apt-get install libxvidcore-dev libx264-dev
    sudo apt-get install libgtk-3-dev
    sudo apt-get install build-essential cmake pkg-config
    sudo apt-get install libatlas-base-dev gfortran

    # Setup CMake build (options chosen for a fast build)
    cmake $cmake_options ..

    # Build OpenCV
    make -j$((`nproc`+1))
    # Install OpenCV
    make install
fi