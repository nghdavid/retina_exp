clear all;
makemovie_folder = 'D:\0115videos\makemovie';
date = '0119';
cd(makemovie_folder);
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness

mea_size=433;
mea_size_bm=465; %bigger mea size , from luminance calibrated region
meaCenter_x=640; 
meaCenter_y=461; 
leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
bar_le=floor((mea_size_bm-1)/2/sqrt(2)); %half of bar length / pixel number on LCD /total length = mea_size = 1919 um
bar_wid=11; %half of bar width / total length = 11*2+1=23 pixels = 65 um
%R-L
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar


makeCalOnOffvideo(makemovie_folder, 'D:\0115videos\videos',  date);
makeHMMvideo(makemovie_folder, 0, 'RL', 'D:\0115videos\videos\HMM\RL', 'D:\0115videos\videoworkspace', date);
makeHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0115videos\videos\HMM\UD', 'D:\0115videos\videoworkspace', date);
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0115videos\videos\HMM\UL_DR', 'D:\0115videos\videoworkspace', date);
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0115videos\videos\HMM\UR_DL', 'D:\0115videos\videoworkspace', date);

makeOUvideo(makemovie_folder, 0, 'RL', 'D:\0115videos\videos\OU\RL', 'D:\0115videos\videoworkspace', date);
makeOUvideo(makemovie_folder, pi/2, 'UD', 'D:\0115videos\videos\OU\UD', 'D:\0115videos\videoworkspace', date);
makeOUvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0115videos\videos\OU\UL_DR', 'D:\0115videos\videoworkspace', date);
makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0115videos\videos\OU\UR_DL', 'D:\0115videos\videoworkspace', date);
