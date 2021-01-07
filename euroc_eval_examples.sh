#!/bin/bash
datasetEurocFolder='Datasets/EuRoC'
examplesAppsFolder='install/Examples/Apps'
examplesDataFolder='install/Examples/Data'

# Single Session Example (Pure visual)
echo "Launching MH01 with Stereo sensor"
./${examplesDataFolder}/Stereo/stereo_euroc ./Vocabulary/ORBvoc.txt ./${examplesDataFolder}/Stereo/EuRoC.yaml "$datasetEurocFolder"/MH01 ./${examplesDataFolder}/Stereo/EuRoC_TimeStamps/MH01.txt dataset-MH01_stereo
echo "------------------------------------"
echo "Evaluation of MH01 trajectory with Stereo sensor"
python evaluation/evaluate_ate_scale.py evaluation/Ground_truth/EuRoC_left_cam/MH01_GT.txt f_dataset-MH01_stereo.txt --plot MH01_stereo.pdf



# MultiSession Example (Pure visual)
echo "Launching Machine Hall with Stereo sensor"
./${examplesDataFolder}/Stereo/stereo_euroc ./Vocabulary/ORBvoc.txt ./${examplesDataFolder}/Stereo/EuRoC.yaml "$datasetEurocFolder"/MH01 ./${examplesDataFolder}/Stereo/EuRoC_TimeStamps/MH01.txt "$datasetEurocFolder"/MH02 ./${examplesDataFolder}/Stereo/EuRoC_TimeStamps/MH02.txt "$datasetEurocFolder"/MH03 ./${examplesDataFolder}/Stereo/EuRoC_TimeStamps/MH03.txt "$datasetEurocFolder"/MH04 ./${examplesDataFolder}/Stereo/EuRoC_TimeStamps/MH04.txt "$datasetEurocFolder"/MH05 ./${examplesDataFolder}/Stereo/EuRoC_TimeStamps/MH05.txt dataset-MH01_to_MH05_stereo
echo "------------------------------------"
echo "Evaluation of MAchine Hall trajectory with Stereo sensor"
python evaluation/evaluate_ate_scale.py evaluation/Ground_truth/EuRoC_left_cam/MH_GT.txt f_dataset-MH01_to_MH05_stereo.txt --plot MH01_to_MH05_stereo.pdf


# Single Session Example (Visual-Inertial)
echo "Launching V102 with Monocular-Inertial sensor"
./${examplesDataFolder}/Monocular-Inertial/mono_inertial_euroc ./Vocabulary/ORBvoc.txt ./${examplesDataFolder}/Monocular-Inertial/EuRoC.yaml "$datasetEurocFolder"/V102 ./${examplesDataFolder}/Monocular-Inertial/EuRoC_TimeStamps/V102.txt dataset-V102_monoi
echo "------------------------------------"
echo "Evaluation of V102 trajectory with Monocular-Inertial sensor"
python evaluation/evaluate_ate_scale.py "$datasetEurocFolder"/V102/mav0/state_groundtruth_estimate0/data.csv f_dataset-V102_monoi.txt --plot V102_monoi.pdf


# MultiSession Monocular Examples

echo "Launching Vicon Room 2 with Monocular-Inertial sensor"
./${examplesDataFolder}/Monocular-Inertial/mono_inertial_euroc ./Vocabulary/ORBvoc.txt ./${examplesDataFolder}/Monocular-Inertial/EuRoC.yaml "$datasetEurocFolder"/V201 ./${examplesDataFolder}/Monocular-Inertial/EuRoC_TimeStamps/V201.txt "$datasetEurocFolder"/V202 ./${examplesDataFolder}/Monocular-Inertial/EuRoC_TimeStamps/V202.txt "$datasetEurocFolder"/V203 ./${examplesDataFolder}/Monocular-Inertial/EuRoC_TimeStamps/V203.txt dataset-V201_to_V203_monoi
echo "------------------------------------"
echo "Evaluation of Vicon Room 2 trajectory with Stereo sensor"
python evaluation/evaluate_ate_scale.py evaluation/Ground_truth/EuRoC_imu/V2_GT.txt f_dataset-V201_to_V203_monoi.txt --plot V201_to_V203_monoi.pdf

