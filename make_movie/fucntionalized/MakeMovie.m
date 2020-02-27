clear all;
G_HMM = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];
G_OU = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];%list of Gamma value
calibration_date = '20200219';
HMM_time = 5;%Time length of HMM of movie
OU_time = 5;%Time length of OU of movie
makemovie_folder = pwd;
date = '0224';
seed_date = '0421';

movie_folder = '\\192.168.0.100\Experiment\Retina\2020Videos\0219v\videos\';
cd(movie_folder)
mkdir HMM
mkdir OU
videoworkspace_folder = '\\192.168.0.100\Experiment\Retina\2020Videos\0219v\videoworkspace\';
cd(makemovie_folder);
  
%% Intensity
make_Intensity_HMM_video(makemovie_folder,[movie_folder,'HMM'], videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,6.5);
make_Intensity_OU_video(makemovie_folder,[movie_folder,'OU'], videoworkspace_folder,seed_date,date,calibration_date,OU_time,G_OU,6.5);
make_Intensity_cSTA_video(makemovie_folder,movie_folder,videoworkspace_folder,date,calibration_date,3,6.5);
%% HMM 5min Bright part
makeOLED_HMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,'Bright',6.5,0);
makeOLED_HMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'],videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,'Bright',6.5,0);
makeOLED_HMMvideo(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'HMM'], videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,'Bright',6.5,0);
makeOLED_HMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,'Bright',6.5,0);
%% HMM 5min Dark part
makeOLED_HMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,'Dark',6.5,0);
makeOLED_HMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'],videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,'Dark',6.5,0);
makeOLED_HMMvideo(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'HMM'], videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,'Dark',6.5,0);
makeOLED_HMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], videoworkspace_folder, seed_date,date,calibration_date,HMM_time,G_HMM,'Dark',6.5,0);
%% OU Bright part
makeOLED_OUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder, seed_date,date,calibration_date,OU_time,G_OU,'Bright',6.5,0);
makeOLED_OUvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'],videoworkspace_folder, seed_date,date,calibration_date,OU_time,G_OU,'Bright',6.5,0);
makeOLED_OUvideo(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder, seed_date,date,calibration_date,OU_time,G_OU,'Bright',6.5,0);
makeOLED_OUvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder, seed_date,date,calibration_date,OU_time,G_OU,'Bright',6.5,0);
%% OU Dark part
makeOLED_OUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], videoworkspace_folder, seed_date,date,calibration_date,OU_time,G_OU,'Dark',6.5,0);
makeOLED_OUvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'],videoworkspace_folder, seed_date,date,calibration_date,OU_time,G_OU,'Dark',6.5,0);
makeOLED_OUvideo(makemovie_folder,pi/4, 'UL_DR', [movie_folder,'OU'], videoworkspace_folder, seed_date,date,calibration_date,OU_time,G_OU,'Dark',6.5,0);
makeOLED_OUvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], videoworkspace_folder, seed_date,date,calibration_date,OU_time,G_OU,'Dark',6.5,0);

%% Short HMM part
make_OLED_short_HMMvideo(makemovie_folder, 0, 'RL', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Bright',6.5,0);
make_OLED_short_HMMvideo(makemovie_folder, pi/2, 'UD', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Bright',6.5,0);
make_OLED_short_HMMvideo(makemovie_folder, pi/4, 'UL_DR', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Bright',6.5,0);
make_OLED_short_HMMvideo(makemovie_folder,  3*pi/4, 'UR_DL', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Bright',6.5,0);
make_OLED_short_HMMvideo(makemovie_folder, 0, 'RL', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Dark',6.5,0);
make_OLED_short_HMMvideo(makemovie_folder, pi/2, 'UD', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Dark',6.5,0);
make_OLED_short_HMMvideo(makemovie_folder, pi/4, 'UL_DR', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Dark',6.5,0);
make_OLED_short_HMMvideo(makemovie_folder,  3*pi/4, 'UR_DL', movie_folder, videoworkspace_folder,seed_date,date,calibration_date,'Dark',6.5,0);
make_Intensity_short_HMMvideo(makemovie_folder, movie_folder, videoworkspace_folder,date,calibration_date,6.5)

%% Checkerboard
oled_checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,30,27,date,0.05,calibration_date, 6.5)
oled_checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,20,27,date,5,calibration_date, 6.5)
%% Gollisch onoff part
Oled_Gollish_OnOff_movie(makemovie_folder,movie_folder,date,calibration_date,6.5)
