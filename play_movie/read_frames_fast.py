# import the necessary packages
from imutils.video import FileVideoStream
from imutils.video import FPS
import numpy as np
import argparse
import imutils
import time
import cv2
import screeninfo
# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-v", "--video", required=True,
	help="path to input video file")
args = vars(ap.parse_args())
 
# start the file video stream thread and allow the buffer to
# start to fill
print("[INFO] starting video file thread...")
fvs = FileVideoStream(args["video"]).start()
time.sleep(1.0)
 
# start the FPS timer
fps = FPS().start()
# loop over frames from the video file stream
screen_id = 0
is_color = False

# get the size of the screen
screen = screeninfo.get_monitors()[screen_id]
width, height = screen.width, screen.height

# create image
if is_color:
    image = np.ones((height, width, 3), dtype=np.float32)
    image[:10, :10] = 0  # black at top-left corner
    image[height - 10:, :10] = [1, 0, 0]  # blue at bottom-left
    image[:10, width - 10:] = [0, 1, 0]  # green at top-right
    image[height - 10:, width - 10:] = [0, 0, 1]  # red at bottom-right
else:
    image = np.ones((height, width), dtype=np.float32)
    image[0, 0] = 0  # top-left corner
    image[height - 2, 0] = 0  # bottom-left
    image[0, width - 2] = 0  # top-right
    image[height - 2, width - 2] = 0  # bottom-right

window_name = 'projector'
cv2.namedWindow(window_name, cv2.WND_PROP_FULLSCREEN)
cv2.moveWindow(window_name, screen.x - 1, screen.y - 1)
cv2.setWindowProperty(window_name, cv2.WND_PROP_FULLSCREEN,cv2.WINDOW_FULLSCREEN)
while fvs.more():
# grab the frame from the threaded video file stream, resize
# it, and convert it to grayscale (while still retaining 3
# channels)
    frame = fvs.read()
#frame = imutils.resize(frame, width=450)
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    frame = np.dstack([frame, frame, frame])
     
# show the frame and update the FPS counter
        
    
    cv2.imshow(window_name, frame)
	#cv2.imshow("Frame", frame)
    cv2.waitKey(1)
    fps.update()
fps.stop()
print("[INFO] elasped time: {:.2f}".format(fps.elapsed()))
print("[INFO] approx. FPS: {:.2f}".format(fps.fps()))
 
# do a bit of cleanup
cv2.destroyAllWindows()
fvs.stop()
