clear all;
G_HMM = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];
G_OU = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];%list of Gamma value
calibration_date = '20200219';
HMM_time =5;%Time length of HMM of movie
OU_time = 5;%Time length of OU of movie
makemovie_folder = 'C:\Users\hydro_leo\Documents\GitHub\retina_exp\make_movie\fucntionalized'; %this approach sucks.
date = '0224';
seed_date = '0421';
mean_lumin =6.5;
movie_folder = '\\192.168.0.100\Experiment\Retina\2020Videos\0219v\videos\';
cd(movie_folder)
mkdir HMM
mkdir OU
videoworkspace_folder = '\\192.168.0.100\Experiment\Retina\2020Videos\0219v\videoworkspace\';
cd(makemovie_folder);

% G_HMM = [4.3];
% G_OU = [4.3];
% movie_folder = 'Z:\';
% videoworkspace_folder = 'Z:\';
% HMM_time = 5;%Time length of HMM of movie
% OU_time = 1;%Time length of OU of movie
%% Intensity
make_Intensity_HMM_video(makemovie_folder,[movie_folder,'HMM'], videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,mean_lumin);
make_Intensity_OU_video(makemovie_folder,[movie_folder,'OU'], videoworkspace_folder,seed_date,date,calibration_date,OU_time,G_OU,mean_lumin);
make_Intensity_cSTA_video(makemovie_folder,movie_folder,videoworkspace_folder,date,calibration_date,3,mean_lumin);
%% HMM 5min Bright part
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], videoworkspace_folder,'HMM',seed_date,date,calibration_date,HMM_time,G_HMM,'Bright',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'],videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,'Bright',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,'Bright',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,'Bright',mean_lumin,0,0);
%% HMM 5min Dark part
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,'Dark',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'],videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,'Dark',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,'Dark',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,'Dark',mean_lumin,0,0);
%% OU Bright part
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'],videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,0);
%% OU Dark part
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'],videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,0);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,0);
%% Smooth OU Bright part
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,0.5);
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1);
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,5);
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,10);
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,15);

makeOLED_Bar_video(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,0.5);
makeOLED_Bar_video(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1);
makeOLED_Bar_video(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,5);
makeOLED_Bar_video(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,10);
makeOLED_Bar_video(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,15);

makeOLED_Bar_video(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,0.5)
makeOLED_Bar_video(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1);
makeOLED_Bar_video(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,5);
makeOLED_Bar_video(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,10);
makeOLED_Bar_video(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,15);

makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,0.5);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,5);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,10);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,15);

%% Smooth OU Dark part
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,5);
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,10);
makeOLED_Bar_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,15);

makeOLED_Bar_video(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,5);
makeOLED_Bar_video(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,10);
makeOLED_Bar_video(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,15);

makeOLED_Bar_video(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,5);
makeOLED_Bar_video(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,10);
makeOLED_Bar_video(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,15);

makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,5);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,10);
makeOLED_Bar_video(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,0,15);
%% HMM edge part
makeOLED_Edge_video(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,0,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,0,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,1,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder,pi/2, 'UD', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,1,mean_lumin,0);

makeOLED_Edge_video(makemovie_folder,3*pi/4, 'UR_DL', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,0,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder,3*pi/4, 'UR_DL', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,1,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,0,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'HMM'], videoworkspace_folder,'HMM', seed_date,date,calibration_date,HMM_time,G_HMM,1,mean_lumin,0);
%% OU edge part
makeOLED_Edge_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,0,mean_lumin);
makeOLED_Edge_video(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,0,mean_lumin);
makeOLED_Edge_video(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,1,mean_lumin);
makeOLED_Edge_video(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,1,mean_lumin);

makeOLED_Edge_video(makemovie_folder,3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,0,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder,3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,1,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,0,mean_lumin,0);
makeOLED_Edge_video(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OU', seed_date,date,calibration_date,OU_time,G_OU,1,mean_lumin,0);
%% Short HMM part
make_OLED_short_HMMvideo(makemovie_folder, 0, 'RL', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Bright',mean_lumin,0);
make_OLED_short_HMMvideo(makemovie_folder, pi/2, 'UD', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Bright',mean_lumin,0);
make_OLED_short_HMMvideo(makemovie_folder, pi/4, 'UL_DR', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Bright',mean_lumin,0);
make_OLED_short_HMMvideo(makemovie_folder,  3*pi/4, 'UR_DL', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Bright',mean_lumin,0);
make_OLED_short_HMMvideo(makemovie_folder, 0, 'RL', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Dark',mean_lumin,0);
make_OLED_short_HMMvideo(makemovie_folder, pi/2, 'UD', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Dark',mean_lumin,0);
make_OLED_short_HMMvideo(makemovie_folder, pi/4, 'UL_DR', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Dark',mean_lumin,0);
make_OLED_short_HMMvideo(makemovie_folder,  3*pi/4, 'UR_DL', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Dark',mean_lumin,0);
make_Intensity_short_HMMvideo(makemovie_folder, movie_folder, videoworkspace_folder,date,calibration_date,mean_lumin)

%% Checkerboard
oled_checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,30,27,date,5,calibration_date, mean_lumin)
oled_checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,20,27,date,5,calibration_date, mean_lumin)
%% Gollisch onoff part
Oled_Gollish_OnOff_movie(makemovie_folder,movie_folder,date,calibration_date,mean_lumin)

mat_directory = 'F:\2020_02_23_stiimg';
make_OLED_scene(makemovie_folder, movie_folder, videoworkspace_folder,mat_directory,calibration_date)

%% Smooth OU Bright bar added Spatial Noise 
%contrast set to be 100%, cutoff frequence set to be 1
makeOLED_Bar_video_sN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,1);
makeOLED_Bar_video_sN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,3);
%makeOLED_Bar_video_sN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1,15);

makeOLED_Bar_video_sN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,1);
makeOLED_Bar_video_sN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,3);
%makeOLED_Bar_video_sN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1,15);

makeOLED_Bar_video_sN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,1);
makeOLED_Bar_video_sN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,3);
%makeOLED_Bar_video_sN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1,15);

makeOLED_Bar_video_sN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,1);
makeOLED_Bar_video_sN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,3);
%makeOLED_Bar_video_sN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1,15);

%% Smooth OU Drak bar added Spatial Noise 
%contrast set to be 100%, cutoff frequence set to be 1
makeOLED_Bar_video_sN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,1);
makeOLED_Bar_video_sN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,3);
%makeOLED_Bar_video_sN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1,15);

makeOLED_Bar_video_sN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,1);
makeOLED_Bar_video_sN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,3);
%makeOLED_Bar_video_sN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1,15);

makeOLED_Bar_video_sN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,1);
makeOLED_Bar_video_sN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,3);
%makeOLED_Bar_video_sN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,15);

makeOLED_Bar_video_sN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,1);
makeOLED_Bar_video_sN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,3);
%makeOLED_Bar_video_sN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,0,1,15);

%% Smooth OU Bright bar interrupt by homogenious gray
%contrast set to be 100%, cutoff frequence set to be 1
makeOLED_Bar_video_wfsN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,1);
makeOLED_Bar_video_wfsN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,3);
makeOLED_Bar_video_wfsN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,5);

makeOLED_Bar_video_wfsN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,1);
makeOLED_Bar_video_wfsN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,3);
makeOLED_Bar_video_wfsN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,5);

makeOLED_Bar_video_wfsN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,1);
makeOLED_Bar_video_wfsN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,3);
makeOLED_Bar_video_wfsN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,5);

makeOLED_Bar_video_wfsN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,1);
makeOLED_Bar_video_wfsN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,3);
makeOLED_Bar_video_wfsN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Bright',mean_lumin,1,5);

%% Smooth OU Drak bar interrupt by homogenious gray
%contrast set to be 100%, cutoff frequence set to be 1
makeOLED_Bar_video_wfsN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,1);
makeOLED_Bar_video_wfsN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,3);
makeOLED_Bar_video_wfsN(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,5);

makeOLED_Bar_video_wfsN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,1);
makeOLED_Bar_video_wfsN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,3);
makeOLED_Bar_video_wfsN(makemovie_folder,  pi/2, 'UD', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,5);

makeOLED_Bar_video_wfsN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,1);
makeOLED_Bar_video_wfsN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,3);
makeOLED_Bar_video_wfsN(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,5);

makeOLED_Bar_video_wfsN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,1);
makeOLED_Bar_video_wfsN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,3);
makeOLED_Bar_video_wfsN(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder,'OUsmooth', seed_date,date,calibration_date,OU_time,G_OU,'Dark',mean_lumin,1,5);