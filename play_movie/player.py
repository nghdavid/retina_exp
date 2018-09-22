import cv2
import numpy as np
import time

video_to_play = ['short1.avi']
for video in video_to_play:
    cap = cv2.VideoCapture(video)
    frames = []
    ii = 0
    while(cap.isOpened()):
        
            ret, frame = cap.read()
            if ret == True:
                frames.append(frame)
                print(ii)
                ii = ii + 1
            else:
                break
    print ("end")
    for i in range(len(frames)):
        cv2.imshow('Frame',frames[i])               
        cv2.waitKey(1)
    cap.release()
    cv2.destroyAllWindows()
    time.sleep(5)

