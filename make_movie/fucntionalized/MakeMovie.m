clear all;
makemovie_folder = 'C:\Users\hydro_leo\Desktop\0304v\makemovie';
date = '0602';
cd(makemovie_folder);
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')
% 
% makeGratingvideo(makemovie_folder, 300, 'D:\0304v\videos', 'D:\0304v\videoworkspace', date);
makeTestHMMvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\HMM', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\HMM', date);
% makeHMMvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\HMM', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\HMM', date);
% makeHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0304v\videos\HMM', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\HMM', date);
% makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0304v\videos\HMM\UL_DR', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\HMM', date);
% makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0304v\videos\HMM\UR_DL', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\HMM', date);
% 
% makeOUvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\OU\RL', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\OU', date);
% makeOUvideo(makemovie_folder, pi/2, 'UD', 'D:\0304v\videos\OU\UD', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\OU', date);
% makeOUvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0304v\videos\OU\UL_DR', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\OU', date);
% makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0304v\videos\OU\UR_DL', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace\OU', date);
% 
% makeCalOnOffvideo(makemovie_folder, 'D:\0304v\videos',  date);
% makeCirclevideo(makemovie_folder, 'D:\0304v\videos', 'C:\Users\hydro_leo\Desktop\0304v\videoworkspace', date);
% checkerboard(makemovie_folder,  'D:\0304v\videos','D:\0304v\videoworkspace',  date);
% OnOffvideo(makemovie_folder, 'D:\0304v\videos',  date);
% 
% makeREvideo(makemovie_folder, 0, 'RL','D:\0304v\videos', 'D:\0304v\videoworkspace', date, 3);
% makeREvideo(makemovie_folder,  pi/2, 'UD', 'D:\0304v\videos', 'D:\0304v\videoworkspace', date, 3);
% makeREvideo(makemovie_folder, pi/4, 'UL_DR','D:\0304v\videos', 'D:\0304v\videoworkspace', date, 3);
% makeREvideo(makemovie_folder,  3*pi/4, 'UR_DL', 'D:\0304v\videos', 'D:\0304v\videoworkspace', date, 3);
% 
% makeDark_REvideo(makemovie_folder, 0, 'RL','D:\0304v\videos', 'D:\0304v\videoworkspace', date, 2.4);
% makeDark_REvideo(makemovie_folder,  pi/2, 'UD', 'D:\0304v\videos', 'D:\0304v\videoworkspace', date, 2.4);
% makeDark_REvideo(makemovie_folder, pi/4, 'UL_DR','D:\0304v\videos', 'D:\0304v\videoworkspace', date, 2.4);
% makeDark_REvideo(makemovie_folder,  3*pi/4, 'UR_DL', 'D:\0304v\videos', 'D:\0304v\videoworkspace', date, 2.4);
% 
% makeshort_HMMvideo(makemovie_folder, 0, 'RL', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace', date);
% makeshort_HMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace', date);
% makeshort_HMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace', date);
% makeshort_HMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0304v\videos\HMM', 'D:\0304v\videoworkspace', date);
% 
% makeRona_short_HMMvideo(makemovie_folder, 'D:\0304v\videos', 'D:\0304v\videoworkspace', date);
% 
