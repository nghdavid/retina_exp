clear all;
makemovie_folder = 'E:\makemovie';
date = '0319';
seed_date = '0421';
cd(makemovie_folder);
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')
% 
% makeGratingvideo(makemovie_folder, 300, 'D:\0304v\videos', 'D:\0304v\videoworkspace', date);
%makeTestHMMvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\HMM', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\HMM', date);
makeHMMvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace\HMM', seed_date,date,5);
makeHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace\HMM', seed_date,date,5);
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace\HMM', seed_date,date,5);
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace\HMM', seed_date,date,5);


makeDarkHMMvideo(makemovie_folder, pi/2, 'UD', 'E:\', 'D:\0304v\videoworkspace\HMM', seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'E:\', 'D:\0304v\videoworkspace\HMM', seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'E:\', 'D:\0304v\videoworkspace\HMM', seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, 0, 'RL', 'E:\', 'D:\0304v\videoworkspace\HMM', seed_date,date,5);
% makeOUvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\OU\RL', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\OU', date);
% makeOUvideo(makemovie_folder, pi/2, 'UD', 'D:\0304v\videos\OU\UD', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\OU', date);
% makeOUvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0304v\videos\OU\UL_DR', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\OU', date);
% makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0304v\videos\OU\UR_DL', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\OU', date);
% 
%Gollish_OnOff_movie(makemovie_folder, 'D:\0304v\videos',  date);
% makeCirclevideo(makemovie_folder, 'D:\0304v\videos', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace', date);
% checkerboard(makemovie_folder,  'D:\0304v\videos','D:\0304v\videoworkspace',  date);
% OnOffvideo(makemovie_folder, 'D:\0304v\videos',  date);
% 
% makeREvideo(makemovie_folder, 0, 'RL','D:\0304v\videos', 'D:\0304v\videoworkspace', date, 4.5);
% makeREvideo(makemovie_folder,  pi/2, 'UD', 'D:\0304v\videos', 'D:\0304v\videoworkspace', date, 4.5);
% makeREvideo(makemovie_folder, pi/4, 'UL_DR','D:\0304v\videos', 'D:\0304v\videoworkspace', date, 4.5);
% makeREvideo(makemovie_folder,  3*pi/4, 'UR_DL', 'D:\0304v\videos', 'D:\0304v\videoworkspace', date, 4.5);
% 
% makeDark_REvideo(makemovie_folder, 0, 'RL','D:\0304v\videos', 'D:\0304v\videoworkspace', date, 4.5);
% makeDark_REvideo(makemovie_folder,  pi/2, 'UD', 'D:\0304v\videos', 'D:\0304v\videoworkspace', date, 4.5);
% makeDark_REvideo(makemovie_folder, pi/4, 'UL_DR','D:\0304v\videos', 'D:\0304v\videoworkspace', date, 4.5);
% makeDark_REvideo(makemovie_folder,  3*pi/4, 'UR_DL', 'D:\0304v\videos', 'D:\0304v\videoworkspace', date, 4.5);

% makeshort_HMMvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace', date);
% makeshort_HMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace', date);
% makeshort_HMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace', date);
% makeshort_HMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace', date);
% 
% makeRona_short_HMMvideo(makemovie_folder, 'D:\0304v\videos', 'D:\0304v\videoworkspace', date);
% 
% makeGratingvideo(makemovie_folder, 300, 0.75,'D:\0304v\videos', 'D:\0304v\videoworkspace', date)
