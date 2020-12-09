#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

url_prefix='http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset'
all_dataset_name='machine_hall'
all_dataset_scene=('MH_01_easy' 'MH_02_easy' 'MH_03_medium' 'MH_04_difficult' 'MH_05_difficult')
all_dataset_folder=('MH01' 'MH02' 'MH03' 'MH04' 'MH05')
for ((i=0;i<${#all_dataset_scene[@]};++i)); do
    if [ ! -d ${all_dataset_folder[i]} ]; then # only download if folder doesn't already exist
        url=${url_prefix}/${all_dataset_name}/${all_dataset_scene[i]}/${all_dataset_scene[i]}.zip
        echo $url
        curl -L -o ${all_dataset_scene[i]}.zip $url
        mkdir ${all_dataset_folder[i]}
        cd ${all_dataset_folder[i]}
        unzip ../${all_dataset_scene[i]}.zip
        cd ..
    fi
done

all_dataset_name='vicon_room1'
all_dataset_scene=('V1_01_easy' 'V1_02_medium' 'V1_03_difficult')
all_dataset_folder=('V101' 'V102' 'V103')
for ((i=0;i<${#all_dataset_scene[@]};++i)); do
    if [ ! -d ${all_dataset_folder[i]} ]; then # only download if folder doesn't already exist
        url=${url_prefix}/${all_dataset_name}/${all_dataset_scene[i]}/${all_dataset_scene[i]}.zip
        echo $url
        curl -L -o ${all_dataset_scene[i]}.zip $url
        mkdir ${all_dataset_folder[i]}
        cd ${all_dataset_folder[i]}
        unzip ../${all_dataset_scene[i]}.zip
        cd ..
    fi
done

all_dataset_name='vicon_room2'
all_dataset_scene=('V2_01_easy' 'V2_02_medium' 'V2_03_difficult')
all_dataset_folder=('V201' 'V202' 'V203')
for ((i=0;i<${#all_dataset_scene[@]};++i)); do
    if [ ! -d ${all_dataset_folder[i]} ]; then # only download if folder doesn't already exist
        url=${url_prefix}/${all_dataset_name}/${all_dataset_scene[i]}/${all_dataset_scene[i]}.zip
        echo $url
        curl -L -o ${all_dataset_scene[i]}.zip $url
        mkdir ${all_dataset_folder[i]}
        cd ${all_dataset_folder[i]}
        unzip ../${all_dataset_scene[i]}.zip
        cd ..
    fi
done