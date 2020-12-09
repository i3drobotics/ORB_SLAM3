#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

url_prefix='https://cdn3.vision.in.tum.de/tumvi/exported/euroc/512_16'
all_dataset_folder=('dataset-room1_512_16' 'dataset-room2_512_16' 'dataset-room3_512_16' \
'dataset-room4_512_16' 'dataset-room5_512_16' 'dataset-room6_512_16')
for ((i=0;i<${#all_dataset_folder[@]};++i)); do
    if [ ! -d ${all_dataset_folder[i]} ]; then # only download if folder doesn't already exist
        url=${url_prefix}/${all_dataset_folder[i]}.tar
        echo $url
        curl -L -o ${all_dataset_folder[i]}.tar $url
        tar xvf ${all_dataset_folder[i]}.tar
    fi
done

all_dataset_folder=('dataset-corridor1_512_16' 'dataset-corridor2_512_16' \
'dataset-corridor3_512_16' 'dataset-corridor4_512_16' 'dataset-corridor5_512_16')
for ((i=0;i<${#all_dataset_folder[@]};++i)); do
    if [ ! -d ${all_dataset_folder[i]} ]; then # only download if folder doesn't already exist
        url=${url_prefix}/${all_dataset_folder[i]}.tar
        echo $url
        curl -L -o ${all_dataset_folder[i]}.tar $url
        tar xvf ${all_dataset_folder[i]}.tar
    fi
done

all_dataset_folder=('dataset-magistrale1_512_16' 'dataset-magistrale2_512_16' \
'dataset-magistrale3_512_16' 'dataset-magistrale4_512_16' 'dataset-magistrale5_512_16' \
'dataset-magistrale6_512_16')
for ((i=0;i<${#all_dataset_folder[@]};++i)); do
    if [ ! -d ${all_dataset_folder[i]} ]; then # only download if folder doesn't already exist
        url=${url_prefix}/${all_dataset_folder[i]}.tar
        echo $url
        curl -L -o ${all_dataset_folder[i]}.tar $url
        tar xvf ${all_dataset_folder[i]}.tar
    fi
done

all_dataset_folder=('dataset-outdoors1_512_16' 'dataset-outdoors2_512_16' \
'dataset-outdoors3_512_16' 'dataset-outdoors4_512_16' 'dataset-outdoors5_512_16' \
'dataset-outdoors6_512_16' 'dataset-outdoors7_512_16' 'dataset-outdoors8_512_16')
for ((i=0;i<${#all_dataset_folder[@]};++i)); do
    if [ ! -d ${all_dataset_folder[i]} ]; then # only download if folder doesn't already exist
        url=${url_prefix}/${all_dataset_folder[i]}.tar
        echo $url
        curl -L -o ${all_dataset_folder[i]}.tar $url
        tar xvf ${all_dataset_folder[i]}.tar
    fi
done

all_dataset_folder=('dataset-slides1_512_16' 'dataset-slides2_512_16' 'dataset-slides3_512_16')
for ((i=0;i<${#all_dataset_folder[@]};++i)); do
    if [ ! -d ${all_dataset_folder[i]} ]; then # only download if folder doesn't already exist
        url=${url_prefix}/${all_dataset_folder[i]}.tar
        echo $url
        curl -L -o ${all_dataset_folder[i]}.tar $url
        tar xvf ${all_dataset_folder[i]}.tar
    fi
done