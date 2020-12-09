#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

if [[ "$OSTYPE" == "msys" ]]; then

    boost_version=1.74.0
    boost_version_=${boost_version//[.]/_}

    downloadfile=boost_$boost_version_.tar.gz
    url=https://sourceforge.net/projects/boost/files/boost/$boost_version/$downloadfile/download
    echo $url

    echo Downloading boost...
    curl -o "$downloadfile" -L $url

    echo Extracting boost...
    tar -xf $downloadfile

    cd boost_$boost_version_

    cmd.exe /c "bootstrap"
    ./b2 --with-serialization --toolset=msvc-14.1 architecture=x86 address-model=64 link=static

    cd $SCRIPTPATH
    rm $downloadfile

else
    # Install boost
    sudo apt install libboost-dev
    sudo apt install libboost-all-dev

fi