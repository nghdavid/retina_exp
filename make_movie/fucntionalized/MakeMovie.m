clear all;
makemovie_folder = 'C:\Users\hydrolab\Desktop\Leo\1031videos\makemovie';
date = '1207';
cd(makemovie_folder);
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
mea_size=433;
mea_size_bm=465; %bigger mea size , from luminance calibrated region
meaCenter_x=632; 
meaCenter_y=570; 

leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
bar_le=floor((mea_size_bm-1)/2/sqrt(2)); %half of bar length / pixel number on LCD /total length = mea_size = 1919 um
bar_wid=11; %half of bar width / total length = 11*2+1=23 pixels = 65 um
%R-L
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar

makeHMMvideo(makemovie_folder, 0, 'RL', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videos\1031_Br_50\HMM\RL', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videoworkspaces\1031_Br_50\HMM\RL', date);
makeHMMvideo(makemovie_folder, pi/2, 'UD', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videos\1031_Br_50\HMM\UD', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videoworkspaces\1031_Br_50\HMM\UD', date);
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videos\1031_Br_50\HMM\UL_DR', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videoworkspaces\1031_Br_50\HMM\UL_DR', date);
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videos\1031_Br_50\HMM\UR_DL', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videoworkspaces\1031_Br_50\HMM\UR_DL', date);

makeOUvideo(makemovie_folder, 0, 'RL', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videos\1031_Br_50\OU\RL', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videoworkspaces\1031_Br_50\HMM\RL', date);
makeOUvideo(makemovie_folder, pi/2, 'UD', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videos\1031_Br_50\OU\UD', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videoworkspaces\1031_Br_50\HMM\UD', date);
makeOUvideo(makemovie_folder, pi/4, 'UL_DR', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videos\1031_Br_50\OU\UL_DR', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videoworkspaces\1031_Br_50\HMM\UL_DR', date);
makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videos\1031_Br_50\OU\UR_DL', 'C:\Users\hydrolab\Desktop\Leo\1031videos\videoworkspaces\1031_Br_50\HMM\UR_DL', date);

