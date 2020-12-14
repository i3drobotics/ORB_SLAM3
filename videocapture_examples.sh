#!/bin/bash
pathDatasetiPhone='Datasets/iPhone'
if [[ "$OSTYPE" == "msys" ]]; then
    releaseFolder='Release/' # Windows creates 'Release' folder when building
else
    releaseFolder=''
fi

#./Examples/Monocular/${releaseFolder}mono_videocapture ./Vocabulary/ORBvoc.txt ./Examples/Monocular/Webcam.yaml 0 webcam
./Examples/Monocular/${releaseFolder}mono_videocapture ./Vocabulary/ORBvoc.txt ./Examples/Monocular/iPhone7Plus.yaml "$pathDatasetiPhone"/iPhone7Plus_bookcase.mp4 webcam