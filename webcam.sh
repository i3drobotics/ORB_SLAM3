#!/bin/bash
if [[ "$OSTYPE" == "msys" ]]; then
    releaseFolder='Release/' # Windows creates 'Release' folder when building
else
    releaseFolder=''
fi

./Examples/Monocular/${releaseFolder}mono_webcam ./Vocabulary/ORBvoc.txt ./Examples/Monocular/Webcam.yaml 0 webcam_mono