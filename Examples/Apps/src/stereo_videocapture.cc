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

static void normaliseDisparity(cv::Mat inDisparity, cv::Mat &outNormalisedDisparity){
    cv::Mat disparity_norm;

    inDisparity.copyTo(disparity_norm);

    cv::normalize(disparity_norm, disparity_norm, 0, 255, cv::NORM_MINMAX);

    disparity_norm.convertTo(disparity_norm, CV_8U);

    outNormalisedDisparity = disparity_norm;
}

void pointCloudFromDepthImage(cv::Mat depth, cv::Mat &point_cloud){
    cv::Mat flat_depth = depth.reshape(1, depth.rows * depth.cols);
    point_cloud = cv::Mat::zeros(cv::Size(3, depth.rows * depth.cols), CV_32FC1);
    for (size_t i = 0, end = depth.rows * depth.cols; i < end; ++i) {
        float x = flat_depth.at<cv::Point3f>(i).x;
        float y = flat_depth.at<cv::Point3f>(i).y;
        float z = flat_depth.at<cv::Point3f>(i).z;
        point_cloud.at<float>(0,i) = x;
        point_cloud.at<float>(1,i) = y;
        point_cloud.at<float>(2,i) = z;
    }
}

void savePointCloud(cv::Mat point_cloud, std::string filename){
    ofstream outfile(filename);
    outfile << "ply\n" << "format ascii 1.0\n" << "comment I3DR point cloud\n";
    outfile << "element vertex " << point_cloud.rows << "\n";
    outfile << "property float x\n" << "property float y\n" << "property float z\n";
    outfile << "property float red\n" << "property float green\n" << "property float blue\n";
    outfile << "end_header\n";
    for (size_t i = 0, end = point_cloud.rows; i < end; ++i) {
        float x = point_cloud.at<float>(0,i);
        float y = point_cloud.at<float>(1,i);
        float z = point_cloud.at<float>(2,i);
        outfile << x << " ";
        outfile << y << " ";
        outfile << z << " ";
        outfile << 0 << " ";
        outfile << 0 << " ";
        outfile << 0 << " ";
        outfile << "\n";
    }
    //outfile.close();
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

    // Read fps from settings
    cv::FileStorage fsSettings(argv[2], cv::FileStorage::READ);
    if(!fsSettings.isOpened())
    {
        cerr << "ERROR: Wrong path to settings" << endl;
        return -1;
    }
    bool ignore_fps = (int)fsSettings["Camera.ignore_fps"] == 1;
    int fps = fsSettings["Camera.fps"];

    double start_time = std::time(0);
    double frame_time = 1.0/fps;

    // Read rectification parameters
    cv::Mat K_l, K_r, P_l, P_r, R_l, R_r, D_l, D_r;
    fsSettings["LEFT.K"] >> K_l;
    fsSettings["RIGHT.K"] >> K_r;

    fsSettings["LEFT.P"] >> P_l;
    fsSettings["RIGHT.P"] >> P_r;

    fsSettings["LEFT.R"] >> R_l;
    fsSettings["RIGHT.R"] >> R_r;

    fsSettings["LEFT.D"] >> D_l;
    fsSettings["RIGHT.D"] >> D_r;

    int rows_l = fsSettings["LEFT.height"];
    int cols_l = fsSettings["LEFT.width"];
    int rows_r = fsSettings["RIGHT.height"];
    int cols_r = fsSettings["RIGHT.width"];

    if(K_l.empty() || K_r.empty() || P_l.empty() || P_r.empty() || R_l.empty() || R_r.empty() || D_l.empty() || D_r.empty() ||
            rows_l==0 || rows_r==0 || cols_l==0 || cols_r==0)
    {
        cerr << "ERROR: Calibration parameters to rectify stereo are missing!" << endl;
        return -1;
    }

    cv::Mat M1l,M2l,M1r,M2r;
    cv::initUndistortRectifyMap(K_l,D_l,R_l,P_l.rowRange(0,3).colRange(0,3),cv::Size(cols_l,rows_l),CV_32F,M1l,M2l);
    cv::initUndistortRectifyMap(K_r,D_r,R_r,P_r.rowRange(0,3).colRange(0,3),cv::Size(cols_r,rows_r),CV_32F,M1r,M2r);

    // Calculate Q matrix
    cv::Mat Q = cv::Mat::zeros(4, 4, CV_64F);
    double cx = P_l.at<double>(0,2);
    double cxr = P_r.at<double>(0,2);
    double cy = P_l.at<double>(1,2);
    double fx = K_l.at<double>(0,0);

    double p14 = P_r.at<double>(0,3);
    double baseline = -p14 / fx;

    double q33 = -(cx - cxr) / baseline;

    Q.at<double>(0,0) = 1.0;
    Q.at<double>(0,3) = -cx;
    Q.at<double>(1,1) = 1.0;
    Q.at<double>(1,3) = -cy;
    Q.at<double>(2,3) = fx;
    Q.at<double>(3,2) = 1.0 / baseline;
    Q.at<double>(3,3) = q33;

    Q.convertTo(Q, CV_32F);

    // Create stereo matcher
    cv::Ptr<cv::StereoBM> cvStereoBM = cv::StereoBM::create(0,21);

    // Create SLAM system. It initializes all system threads and gets ready to process frames.
    ORB_SLAM3::System SLAM(argv[1],argv[2],ORB_SLAM3::System::STEREO, true);

    int frame_count = 0;
    while(true){
        cv::Mat im;
        cap >> im;
        if( im.empty() ) break; // end of video stream

        //Split rgb frame into left and right image
        cv::Mat imSplit[3];
        flip(im, im, 0);
        split(im, imSplit);
        cv::Mat imLeft = imSplit[1].clone();
        cv::Mat imRight = imSplit[2].clone();

        //Rectify left and right images
        cv::Mat imLeftRect, imRightRect;
        cv::remap(imLeft,imLeftRect,M1l,M2l,cv::INTER_LINEAR);
        cv::remap(imRight,imRightRect,M1r,M2r,cv::INTER_LINEAR);
        
        double tframe;
        if (ignore_fps){
            tframe = std::time(0);
        } else {
            tframe = start_time + (frame_time*frame_count);
        }

        // Pass the image to the SLAM system
        cv::Mat pose = SLAM.TrackStereo(imLeftRect,imRightRect,tframe, vector<ORB_SLAM3::IMU::Point>());
        int state = SLAM.GetTrackingState();
        std::cout << "(" << pose.at<float>(0,3) << "," << pose.at<float>(1,3) << "," << pose.at<float>(2,3) << ")" << std::endl;

        if (state == ORB_SLAM3::Tracking::eTrackingState::OK){
            //Calculated disparity image
            cv::Mat disp;
            cvStereoBM->compute(imLeftRect,imRightRect,disp);

            //Display disparity image
            cv::Mat disp_norm;
            normaliseDisparity(disp,disp_norm);
            cv::imshow("Disparity",disp_norm);

            //Calculate depth image from disparity image
            cv::Mat depth;
            cv::reprojectImageTo3D(disp,depth,Q,false,CV_32F);

            //Convert depth image to point cloud
            cv::Mat point_cloud;
            pointCloudFromDepthImage(depth,point_cloud);

            //Add W=1 column to point cloud for use with transformation matrix
            cv::Mat w_col = cv::Mat::ones(cv::Size(1,point_cloud.rows),CV_32FC1);
            cv::Mat point_cloud_w;
            cv::hconcat(point_cloud,w_col,point_cloud_w);

            //Transform point cloud by pose
            cv::Mat point_cloud_rel_w = point_cloud_w * pose;
            //Remove W column from point cloud
            cv::Mat point_cloud_rel = point_cloud_rel_w.colRange(0, 2);

            //TODO flatten image to line up image colors with point cloud

            int key = cv::waitKey(1);
            if (key == 13){ //Enter pressed
                std::cout << "Saving cloud..." << std::endl;
                std::string point_cloud_filename = "PointCloud.ply";
                //savePointCloud(point_cloud_rel,point_cloud_filename);
                savePointCloud(point_cloud,point_cloud_filename);
            }
        }

        if (SLAM.isViewerFinished()){
            cout << "Viewer closed" << endl;
            break;
        }
        frame_count++;
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
