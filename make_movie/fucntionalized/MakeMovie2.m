clear all;
G_HMM = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];
G_OU = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];%list of Gamma value
calibration_date = '20200219';
HMM_time =5;%Time length of HMM of movie
OU_time = 5;%Time length of OU of movie
makemovie_folder = 'C:\Users\hydro_leo\Documents\GitHub\retina_exp\make_movie\fucntionalized'; %this approach sucks.
date = '0609';
seed_date = '0421';
mean_lumin =6.5;
movie_folder = '\\192.168.0.100\Experiment\Retina\2020Videos\0609v\videos\';
cd(movie_folder)
mkdir HMM
mkdir OU
videoworkspace_folder = '\\192.168.0.100\Experiment\Retina\2020Videos\0609v\videoworkspace\';
cd(makemovie_folder);

% G_HMM = [4.3];
% G_OU = [4.3];
% movie_folder = 'Z:\';
% videoworkspace_folder = 'Z:\';
% HMM_time = 5;%Time length of HMM of movie
% OU_time = 1;%Time length of OU of movie
%% Bar cSTA
makeOLED_Bar_video2(makemovie_folder, 0, 'RL', movie_folder, videoworkspace_folder,'cSTA', seed_date,date,calibration_date,5,[2.5],mean_lumin,1,1);
makeOLED_Bar_video2(makemovie_folder, 3*pi/4, 'UR_DL', movie_folder, videoworkspace_folder,'cSTA', seed_date,date,calibration_date,5,[2.5],mean_lumin,1,1);
makeOLED_Bar_video2(makemovie_folder, pi/2, 'UD', movie_folder, videoworkspace_folder,'cSTA', seed_date,date,calibration_date,5,[2.5]',mean_lumin,1,1);
makeOLED_Bar_video2(makemovie_folder, pi/4, 'UL_DR', movie_folder, videoworkspace_folder,'cSTA', seed_date,date,calibration_date,5,[2.5],mean_lumin,1,1);

makeOLED_Bar_video2(makemovie_folder, 0, 'RL', movie_folder, videoworkspace_folder,'cSTA', seed_date,date,calibration_date,5,[2.5],mean_lumin,-1,1);
makeOLED_Bar_video2(makemovie_folder, 3*pi/4, 'UR_DL', movie_folder, videoworkspace_folder,'cSTA', seed_date,date,calibration_date,5,[2.5]',mean_lumin,-1,1);
makeOLED_Bar_video2(makemovie_folder, pi/2, 'UD', movie_folder, videoworkspace_folder,'cSTA', seed_date,date,calibration_date,5,[2.5],mean_lumin,-1,1);
makeOLED_Bar_video2(makemovie_folder, pi/4, 'UL_DR', movie_folder, videoworkspace_folder,'cSTA', seed_date,date,calibration_date,5,[2.5],mean_lumin,-1,1);

%% Smooth OU Bright part
makeOLED_Bar_video2(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,mean_lumin,1,1);
makeOLED_Bar_video2(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,mean_lumin,1,1);
makeOLED_Bar_video2(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,mean_lumin,1,1);
makeOLED_Bar_video2(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,mean_lumin,1,1);

