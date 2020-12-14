/**
* This file is part of ORB-SLAM3
*
* Copyright (C) 2017-2020 Carlos Campos, Richard Elvira, Juan J. Gómez Rodríguez, José M.M. Montiel and Juan D. Tardós, University of Zaragoza.
* Copyright (C) 2014-2016 Raúl Mur-Artal, José M.M. Montiel and Juan D. Tardós, University of Zaragoza.
*
* ORB-SLAM3 is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ORB-SLAM3 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
* the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with ORB-SLAM3.
* If not, see <http://www.gnu.org/licenses/>.
*/



#include<iostream>
#include<algorithm>
#include<fstream>
#include<chrono>

#include <opencv2/core/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/opencv.hpp>

#ifdef _WIN32
#include <usleep.h>
#endif

#include<System.h>

using namespace std;

bool is_number(const std::string& s)
{
    return !s.empty() && std::find_if(s.begin(), 
        s.end(), [](unsigned char c) { return !std::isdigit(c); }) == s.end();
}

int main(int argc, char **argv)
{  
    if(argc != 4 && argc != 5)
    {
        cerr << endl << "Usage: ./mono_webcam path_to_vocabulary path_to_settings device_index (trajectory_file_name)" << endl;
        return 1;
    }

    bool bFileName = (argc == 5);
    string file_name;
    if (bFileName)
    {
        file_name = string(argv[argc-1]);
        cout << "file name: " << file_name << endl;
    }

    string device = argv[3];
    bool bDeviceNum = false;
    int device_num = 0;
    if (is_number(device)){
        bDeviceNum = true;
        device_num = std::stoi(device);
    }

    cout.precision(17);

    // Open Camera
    cv::VideoCapture cap;
    bool is_opened = false;
    if (bDeviceNum){
        is_opened = cap.open(device_num);
    } else {
        is_opened = cap.open(device);
    }
    if(!is_opened){
        cerr << "Failed to open device: " << device << endl;
        return 0;
    }

    // Create SLAM system. It initializes all system threads and gets ready to process frames.
    ORB_SLAM3::System SLAM(argv[1],argv[2],ORB_SLAM3::System::MONOCULAR, true); 

    while(true){
        cv::Mat im;
        cap >> im;
        if( im.empty() ) break; // end of video stream
        
        double tframe = std::time(0);

        // Pass the image to the SLAM system
        cout << "tframe = " << tframe << endl;
        SLAM.TrackMonocular(im,tframe);

        if (SLAM.isViewerFinished()){
            cout << "Viewer closed" << endl;
            break;
        }
    }

    // Stop all threads
    SLAM.Shutdown(); //TODO fix Error 1400: Invalid window handle. When viewer is closed before shutdown
    cout << "SLAM Shutdown" << endl;

    cap.release();

    // Save camera trajectory
    if (bFileName)
    {
        const string kf_file =  "kf_" + string(argv[argc-1]) + ".txt";
        const string f_file =  "f_" + string(argv[argc-1]) + ".txt";
        SLAM.SaveTrajectoryEuRoC(f_file);
        SLAM.SaveKeyFrameTrajectoryEuRoC(kf_file);
    }
    else
    {
        SLAM.SaveTrajectoryEuRoC("CameraTrajectory.txt");
        SLAM.SaveKeyFrameTrajectoryEuRoC("KeyFrameTrajectory.txt");
    }

    return 0;
}
