#!/bin/bash
datasetTUM_VIFolder='Datasets/TUM_VI'
examplesAppsFolder='install/Examples/Apps'
examplesDataFolder='install/Examples/Data'

# Single Session Example
echo "Launching Magistrale 1 with Stereo-Inertial sensor"
./${examplesAppsFolder}/stereo_inertial_tum_vi Vocabulary/ORBvoc.txt ${examplesDataFolder}/Stereo-Inertial/TUM_512.yaml "$datasetTUM_VIFolder"/dataset-magistrale1_512_16/mav0/cam0/data "$pathDatasetTUM_VI"/dataset-magistrale1_512_16/mav0/cam1/data ${examplesDataFolder}/Stereo-Inertial/TUM_TimeStamps/dataset-magistrale1_512.txt ${examplesDataFolder}/Stereo-Inertial/TUM_IMU/dataset-magistrale1_512.txt dataset-magistrale1_512_stereoi
echo "------------------------------------"
echo "Evaluation of Magistrale 1 trajectory with Stereo-Inertial sensor"
python evaluation/evaluate_ate_scale.py "$datasetTUM_VIFolder"/magistrale1_512_16/mav0/mocap0/data.csv f_dataset-magistrale1_512_stereoi.txt --plot magistrale1_512_stereoi.pdf
