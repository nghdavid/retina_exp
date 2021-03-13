clear all;
calibration_date = '20200219';
makemovie_folder = 'E:\makemovie'; %this approach sucks.
date = '0313';
mean_lumin =6.5;
movie_folder = 'Z:/';
videoworkspace_folder = 'Z:/';
load('Z:\converge_off.mat')
make_highorder_video(makemovie_folder,pi/4,movie_folder,videoworkspace_folder,'converge_off',date,calibration_date,mean_lumin,1,x_zoom2)

load('Z:\converge_on.mat')
make_highorder_video(makemovie_folder,pi/4,movie_folder,videoworkspace_folder,'converge_on',date,calibration_date,mean_lumin,1,x_zoom2)