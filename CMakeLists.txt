cmake_minimum_required(VERSION 2.9)
project(ORB_SLAM3)

option(BUILD_EXAMPLES "Build examples" ON)

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release)
ENDIF()

MESSAGE("Build type: " ${CMAKE_BUILD_TYPE})

# Define GNU standard installation directories
include(GNUInstallDirs)

if (NOT WIN32)
   set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -Wall   -O3")
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall   -O3")
   set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -march=native")
   set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=native")
endif()

if (WIN32)
   set (CMAKE_CXX_STANDARD 11)
   add_definitions(-DCOMPILEDWITHC11)
   set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
else (WIN32)
   #Check C++11 or C++0x support
   include(CheckCXXCompilerFlag)
   CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
   CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
   if(COMPILER_SUPPORTS_CXX11)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
      add_definitions(-DCOMPILEDWITHC11)
      message(STATUS "Using flag -std=c++11.")
   elseif(COMPILER_SUPPORTS_CXX0X)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
      add_definitions(-DCOMPILEDWITHC0X)
      message(STATUS "Using flag -std=c++0x.")
   else()
      message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
   endif()
endif()

find_package(OpenCV 4)
if(NOT OpenCV_FOUND)
   find_package(OpenCV 3)
   if(NOT OpenCV_FOUND)
      find_package(OpenCV 2.4.3 QUIET)
      if(NOT OpenCV_FOUND)
         message(FATAL_ERROR "OpenCV > 2.4.3 not found.")
      endif()
   endif()
endif()

MESSAGE("OPENCV VERSION:")
MESSAGE(${OpenCV_VERSION})

find_package(Eigen3 3.1.0 REQUIRED)
if(NOT Eigen3_FOUND)
   message(FATAL_ERROR "Eigen3 not found.")
else()
   message("Found Eigen3")
endif()

find_package(Pangolin REQUIRED)
if(NOT Pangolin_FOUND)
   message(FATAL_ERROR "Pangolin not found.")
else()
   message("Found Pangolin")
endif()

find_package(Boost COMPONENTS serialization REQUIRED)
if(NOT Boost_FOUND)
   message(FATAL_ERROR "Boost not found.")
endif()

include_directories(
   ${PROJECT_SOURCE_DIR}
   ${PROJECT_SOURCE_DIR}/include
   ${PROJECT_SOURCE_DIR}/include/CameraModels
   ${EIGEN3_INCLUDE_DIR}
   ${Pangolin_INCLUDE_DIRS}
   ${OpenCV_INCLUDE_DIRS}
   ${Boost_INCLUDE_DIRS}
)
if (WIN32)
   include_directories(${PROJECT_SOURCE_DIR}/include/winutil)
   set(WIN_EXTRA_SRC src/winutil/usleep.cpp)
endif()

add_library(${PROJECT_NAME} SHARED
   src/System.cc
   src/Tracking.cc
   src/LocalMapping.cc
   src/LoopClosing.cc
   src/ORBextractor.cc
   src/ORBmatcher.cc
   src/FrameDrawer.cc
   src/Converter.cc
   src/MapPoint.cc
   src/KeyFrame.cc
   src/Atlas.cc
   src/Map.cc
   src/MapDrawer.cc
   src/Optimizer.cc
   src/PnPsolver.cc
   src/Frame.cc
   src/KeyFrameDatabase.cc
   src/Sim3Solver.cc
   src/Initializer.cc
   src/Viewer.cc
   src/ImuTypes.cc
   src/G2oTypes.cc
   src/CameraModels/Pinhole.cpp
   src/CameraModels/KannalaBrandt8.cpp
   src/OptimizableTypes.cpp
   src/MLPnPsolver.cpp
   src/TwoViewReconstruction.cc
   ${WIN_EXTRA_SRC}
)

if (WIN32)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
   set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /FORCE:MULTIPLE")
endif (WIN32)

IF(WIN32)
   set(DBoW2_LIBS ${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/Release/DBoW2.lib)
   set(g2o_LIBS ${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/Release/g2o.lib)
else(WIN32)
   set(DBoW2_LIBS ${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so)
   set(g2o_LIBS ${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so)
   set(extra_LIBS -lcrypto)
endif(WIN32)

target_link_libraries(${PROJECT_NAME}
   ${OpenCV_LIBS}
   ${Pangolin_LIBRARIES}
   ${DBoW2_LIBS}
   ${g2o_LIBS}
   Boost::serialization
)

# Include headers in library
target_include_directories(${PROJECT_NAME} PUBLIC
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
   $<INSTALL_INTERFACE:include>
   PRIVATE src)

# Include version in library
set_target_properties(${PROJECT_NAME} PROPERTIES
   VERSION ${PROJECT_VERSION}
   SOVERSION ${PROJECT_VERSION})

# Export cmake config
install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Config
   ARCHIVE  DESTINATION ${CMAKE_INSTALL_LIBDIR}
   LIBRARY  DESTINATION ${CMAKE_INSTALL_LIBDIR}
   RUNTIME  DESTINATION ${CMAKE_INSTALL_BINDIR})

# Install headers in install folder
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME})

# Install cmake config in install folder
install(EXPORT ${PROJECT_NAME}Config DESTINATION lib/cmake/${PROJECT_NAME})

# Install cmake targets in install folder
export(TARGETS ${PROJECT_NAME} FILE ${PROJECT_NAME}Config.cmake)

if(BUILD_EXAMPLES)
   if (WIN32)
      # Define dlls files to copy to executables
      set(OpenCV_DLLS
         ${OpenCV_DIR}/x64/vc16/bin/opencv_world450.dll
         ${OpenCV_DIR}/x64/vc16/bin/opencv_videoio_ffmpeg450_64.dll
      )
      set(ORBSLAM3_DLLS
         ${OpenCV_DLLS}
         ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${PROJECT_NAME}.dll
      )
   endif()

   # Create directory structure for examples
   install(DIRECTORY DESTINATION Examples/Apps)

   if (WIN32)
      # Copy dlls to examples install folder
      install(FILES ${ORBSLAM3_DLLS} DESTINATION Examples/Apps)
   endif()
   # Copy example data to install folder
   install(DIRECTORY ${PROJECT_SOURCE_DIR}/Examples/Apps/Data DESTINATION Examples)
   # Copy scripts for downloading datasets to install folder
   install(DIRECTORY ${PROJECT_SOURCE_DIR}/Datasets DESTINATION Examples FILES_MATCHING PATTERN "*.sh")
   # Copy Vocabulary file to install folder
   install(DIRECTORY ${PROJECT_SOURCE_DIR}/Vocabulary DESTINATION Examples FILES_MATCHING PATTERN "*.txt.tar.gz")
   
   # Build examples
   add_executable(mono_tum Examples/Apps/src/mono_tum.cc)
   target_link_libraries(mono_tum PRIVATE ${PROJECT_NAME})
   install(TARGETS mono_tum DESTINATION Examples/Apps)

   add_executable(mono_kitti Examples/Apps/src/mono_kitti.cc)
   target_link_libraries(mono_kitti PRIVATE ${PROJECT_NAME})
   install(TARGETS mono_kitti DESTINATION Examples/Apps)

   add_executable(mono_euroc Examples/Apps/src/mono_euroc.cc)
   target_link_libraries(mono_euroc PRIVATE ${PROJECT_NAME})
   install(TARGETS mono_euroc DESTINATION Examples/Apps)

   add_executable(mono_tum_vi Examples/Apps/src/mono_tum_vi.cc)
   target_link_libraries(mono_tum_vi PRIVATE ${PROJECT_NAME})
   install(TARGETS mono_tum_vi DESTINATION Examples/Apps)

   add_executable(mono_videocapture Examples/Apps/src/mono_videocapture.cc)
   target_link_libraries(mono_videocapture PRIVATE ${PROJECT_NAME})
   install(TARGETS mono_videocapture DESTINATION Examples/Apps)

   add_executable(mono_inertial_euroc Examples/Apps/src/mono_inertial_euroc.cc)
   target_link_libraries(mono_inertial_euroc PRIVATE ${PROJECT_NAME})
   install(TARGETS mono_inertial_euroc DESTINATION Examples/Apps)

   add_executable(mono_inertial_tum_vi Examples/Apps/src/mono_inertial_tum_vi.cc)
   target_link_libraries(mono_inertial_tum_vi PRIVATE ${PROJECT_NAME})
   install(TARGETS mono_inertial_tum_vi DESTINATION Examples/Apps)

   add_executable(stereo_kitti Examples/Apps/src/stereo_kitti.cc)
   target_link_libraries(stereo_kitti PRIVATE ${PROJECT_NAME})
   install(TARGETS stereo_kitti DESTINATION Examples/Apps)

   add_executable(stereo_euroc Examples/Apps/src/stereo_euroc.cc)
   target_link_libraries(stereo_euroc PRIVATE ${PROJECT_NAME})
   install(TARGETS stereo_euroc DESTINATION Examples/Apps)

   add_executable(stereo_tum_vi Examples/Apps/src/stereo_tum_vi.cc)
   target_link_libraries(stereo_tum_vi PRIVATE ${PROJECT_NAME})
   install(TARGETS stereo_tum_vi DESTINATION Examples/Apps)

   add_executable(stereo_videocapture Examples/Apps/src/stereo_videocapture.cc)
   target_link_libraries(stereo_videocapture PRIVATE ${PROJECT_NAME})
   install(TARGETS stereo_videocapture DESTINATION Examples/Apps)

   add_executable(stereo_inertial_euroc Examples/Apps/src/stereo_inertial_euroc.cc)
   target_link_libraries(stereo_inertial_euroc PRIVATE ${PROJECT_NAME})
   install(TARGETS stereo_inertial_euroc DESTINATION Examples/Apps)

   add_executable(stereo_inertial_tum_vi Examples/Apps/src/stereo_inertial_tum_vi.cc)
   target_link_libraries(stereo_inertial_tum_vi PRIVATE ${PROJECT_NAME})
   install(TARGETS stereo_inertial_tum_vi DESTINATION Examples/Apps)

   add_executable(rgbd_tum Examples/Apps/src/rgbd_tum.cc)
   target_link_libraries(rgbd_tum PRIVATE ${PROJECT_NAME})
   install(TARGETS rgbd_tum DESTINATION Examples/Apps)

endif()

