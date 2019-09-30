clear all;
makemovie_folder = 'E:\makemovie';
date = '0421';
seed_date = '0421';
cd(makemovie_folder);
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')

%% HMM 5min part
makeHMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);

%% HMM 7 min part
makeHMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeDarkHMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeDarkHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeDarkHMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeDarkHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);

%% Long HMM 5min part
makeLongHMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeLongHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeLongDarkHMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);
makeLongDarkHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,5);

%% Long HMM 7 min part
makeLongHMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeLongHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeLongDarkHMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);
makeLongDarkHMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace\HMM', seed_date,date,7);

%% OU part
makeOUvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeOUvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeOUvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeDarkOUvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeDarkOUvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeDarkOUvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeDarkOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);

%% Long OU part
makeLongOUvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeLongOUvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeLongDarkOUvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);
makeLongDarkOUvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\OU', 'D:\0930v\videoworkspace\OU', date);

%% Short HMM part
makeshort_HMMvideo(makemovie_folder, 0, 'RL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace', date);
makeshort_HMMvideo(makemovie_folder, pi/2, 'UD', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace', date);
makeshort_HMMvideo(makemovie_folder, pi/4, 'UL_DR', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace', date);
makeshort_HMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', 'D:\0930v\videos\HMM', 'D:\0930v\videoworkspace', date);

%% Short HMM Rona part
makeRona_short_HMMvideo(makemovie_folder, 'D:\0930v\videos', 'D:\0930v\videoworkspace', date);

%% Gollisch onoff part
Gollish_OnOff_movie(makemovie_folder, 'D:\0930v\videos',date,0.5);
Gollish_OnOff_movie(makemovie_folder, 'D:\0930v\videos',date,0.8);

%% Checkerboard
checkerboard(makemovie_folder,'D:\0930v\videos', 'D:\0930v\videoworkspace',20,13,date,5);
checkerboard(makemovie_folder,'D:\0930v\videos', 'D:\0930v\videoworkspace',30,13,date,5);
checkerboard(makemovie_folder,'D:\0930v\videos', 'D:\0930v\videoworkspace',20,15,date,5);
checkerboard(makemovie_folder,'D:\0930v\videos', 'D:\0930v\videoworkspace',30,15,date,5);

%% Grating
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 300, 0.75,5,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 600, 0.75,5,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 300, 0.375,5,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 300, 1.5,5,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 600, 0.375,5,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 600, 1.5,5,date);

makeGratingvideo(makemovie_folder,'D:\0930v\videos', 300, 0.75,8,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 600, 0.75,8,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 300, 0.375,8,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 300, 1.5,8,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 600, 0.375,8,date);
makeGratingvideo(makemovie_folder,'D:\0930v\videos', 600, 1.5,8,date);
%% Reversal bar
makeREvideo(makemovie_folder,0, 'RL','D:\0930v\videos', 'D:\0930v\videoworkspace',date,2.4);
makeREvideo(makemovie_folder,pi/2, 'UD','D:\0930v\videos', 'D:\0930v\videoworkspace',date,2.4);
makeREvideo(makemovie_folder,pi/4, 'UL_DR','D:\0930v\videos', 'D:\0930v\videoworkspace',date,2.4);
makeREvideo(makemovie_folder,3*pi/4, 'UR_DL','D:\0930v\videos', 'D:\0930v\videoworkspace',date,2.4);