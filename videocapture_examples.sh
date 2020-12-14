#!/bin/bash
pathDatasets='Datasets'
if [[ "$OSTYPE" == "msys" ]]; then
    releaseFolder='Release/' # Windows creates 'Release' folder when building
else
    releaseFolder=''
fi

#./Examples/Monocular/${releaseFolder}mono_videocapture ./Vocabulary/ORBvoc.txt ./Examples/Monocular/Webcam.yaml 0 webcam
./Examples/Monocular/${releaseFolder}mono_videocapture ./Vocabulary/ORBvoc.txt ./Examples/Monocular/MobilePhone.yaml "$pathDatasets"/MobilePhone/MobilePhone-bedroom.mp4 mobile-mono