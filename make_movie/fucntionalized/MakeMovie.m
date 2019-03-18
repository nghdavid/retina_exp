clear all;
makemovie_folder = 'C:\Users\hydro_leo\Desktop\0304v\makemovie';
date = '0319';
cd(makemovie_folder);
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')



makeHMMvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\HMM', 'C:\Users\Leo\Desktop\0304v\videoworkspace\HMM', date);
makeHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0304v\videos\HMM', 'C:\Users\Leo\Desktop\0304v\videoworkspace\HMM', date);
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0304v\videos\HMM', 'C:\Users\Leo\Desktop\0304v\videoworkspace\HMM', date);
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0304v\videos\HMM', 'C:\Users\Leo\Desktop\0304v\videoworkspace\HMM', date);

makeOUvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\OU', 'C:\Users\Leo\Desktop\0304v\videoworkspace\OU', date);
makeOUvideo(makemovie_folder, pi/2, 'UD', 'D:\0304v\videos\OU', 'C:\Users\Leo\Desktop\0304v\videoworkspace\OU', date);
makeOUvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0304v\videos\OU', 'C:\Users\Leo\Desktop\0304v\videoworkspace\OU', date);
makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0304v\videos\OU', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace', date);
makeCalOnOffvideo(makemovie_folder, 'D:\0304v\videos',  date);
makeCirclevideo(makemovie_folder, 'D:\0304v\videos', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace', date);