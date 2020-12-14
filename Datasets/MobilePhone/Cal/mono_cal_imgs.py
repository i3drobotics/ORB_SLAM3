import numpy as np
import cv2
import glob

# termination criteria
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

chSize = (9,6)

# prepare object points, like (0,0,0), (1,0,0), (2,0,0) ....,(6,5,0)
objp = np.zeros((chSize[0]*chSize[1],3), np.float32)
objp[:,:2] = np.mgrid[0:chSize[0],0:chSize[1]].T.reshape(-1,2)

# Arrays to store object points and image points from all the images.
objpoints = [] # 3d point in real world space
imgpoints = [] # 2d points in image plane.

print("Loading image filenames from folder..")
images = glob.glob('*.JPEG')

print("Finding checkerboard in images...")
for fname in images:
    print(fname)
    img = cv2.imread(fname)
    gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

    # Find the chess board corners
    ret, corners = cv2.findChessboardCorners(gray, (chSize[0],chSize[1]),None)

    # If found, add object points, image points (after refining them)
    if ret == True:
        objpoints.append(objp)

        corners2 = cv2.cornerSubPix(gray,corners,(11,11),(-1,-1),criteria)
        imgpoints.append(corners2)

        # Draw and display the corners
        img = cv2.drawChessboardCorners(img, (chSize[0],chSize[1]), corners2,ret)
        cv2.imshow('img',img)
        cv2.waitKey(1)

cv2.destroyAllWindows()

# calibrate
print ('Calibrating...')
ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)

#writes array to .yml file
fs_write = cv2.FileStorage('cam.yml', cv2.FILE_STORAGE_WRITE)
fs_write.write("image_width", np.size(gray, 1))
fs_write.write("image_height", np.size(gray, 0))
fs_write.write("camera_matrix", mtx)
fs_write.write("distortion_coefficients", dist)
fs_write.release()
        
cv2.destroyAllWindows()
