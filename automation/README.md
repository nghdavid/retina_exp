This directory stores our experiment automation code.  <br />
Automation code(exp.bat) is a batch file which consists of two parts.  <br />
First, we use arduino to pull up or down the black board to control light to pass or not. <br />
Second, we use psexec to execute exe remotely. Besides, we play movie and manipulate MC_rack and record monitor via psexec.  <br />

The way you can generate exp.bat:  <br />
1. Make sure play_list.txt and batch.py are in the same directory  <br />
2. Put name of movie and time of movie(sec) into play_list.txt (Remember to follow the format of example)  <br />
3. Run batch.py to produce exp.bat  <br />



Description of this directory:  <br />
arduino store manual_gws.ino to control arduino  <br />
MC_rack store exe we use to start and end recording.  <br />
monitor_record store bat we use mcd file(reconstruct) to check monitor  <br />
batch.py is to make exp.bat  <br />
exp.bat is to the batch that automate experiment  <br />
play_list.txt is the txt file that saves name of movies and time of movies.  <br />
rename.py is to change mcd file name <br />

PS: <br />
Tutorial of downloading pstools(psexec):  <br />
https://www.youtube.com/watch?v=nh_ilHMrDlI <br />
Tutorial of psexec: <br />
http://blog.xuite.net/jyoutw/xtech/24607577-PsTools+%E4%B9%8B+PsExec+%E7%9A%84%E7%94%A8%E6%B3%95 <br />
Solution of problem you may encouter: <br />
https://stackoverflow.com/questions/18388381/make-sure-that-the-default-admin-share-is-enable-on-servername <br />

