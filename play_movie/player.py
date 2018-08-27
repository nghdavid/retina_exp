import cv2
import numpy as np
import time

video_to_play = ['test.avi','test1.avi']
for video in video_to_play:
    cap = cv2.VideoCapture(video)

    while(cap.isOpened()):
        ret, frame = cap.read()
        cv2.imshow('Frame',frame)
        cv2.waitKey(16.666666)

    cap.release()
    cv2.destroyAllWindows()
    time.sleep(360)

