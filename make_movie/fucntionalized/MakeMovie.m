clear all;
G_HMM = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];
G_OU = [1.55 2.45 3.2 4 5.03 5.7 7.6 10.5];%list of Gamma value
calibration_date = '20191115v';
HMM_time = 5;%Time length of HMM of movie
makemovie_folder = pwd;
date = '1209';
seed_date = '0421';%'0809' or '0810'


movie_folder = '\\DESKTOP-JMQPLEJ\temp_movie\videos\';
cd(movie_folder)
mkdir HMM
mkdir OU
videoworkspace_folder = '\\DESKTOP-JMQPLEJ\temp_movie\videoworkspace\';
cd(videoworkspace_folder)
mkdir HMM
mkdir OU
cd(makemovie_folder);
%% HMM 5min part
% makeHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Short','Bright');
makeHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Short','Bright');
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Short','Bright');
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Short','Bright');
% makeHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Short','Dark');
% makeHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Short','Dark');
% makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Short','Dark');
% makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Short','Dark');

%% Long HMM 5min part

% makeHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Long','Bright');
% makeHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Long','Bright');
% makeHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Long','Dark');
% makeHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'],[videoworkspace_folder,'HMM'], seed_date,date,calibration_date,HMM_time,G_HMM,'Long','Dark');

%% OU part
% makeOUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Short','Bright');
% makeOUvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Short','Bright');
% makeOUvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Short','Bright');
% makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Short','Bright');
% makeOUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Short','Dark');
% makeOUvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Short','Dark');
% makeOUvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Short','Dark');
% makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Short','Dark');

%% Long OU part

% makeOUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Long','Bright');
% makeOUvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Long','Bright');
% makeOUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Long','Dark');
% makeOUvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date,calibration_date,G_OU,'Long','Dark');
% %% Short HMM part
% makeshort_HMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], videoworkspace_folder, date);
% makeshort_HMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], videoworkspace_folder, date);
% makeshort_HMMvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'HMM'], videoworkspace_folder, date);
% makeshort_HMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], videoworkspace_folder, date);
% 
% %% Short HMM Rona part
% makeRona_short_HMMvideo(makemovie_folder,movie_folder, videoworkspace_folder, date);
% 
% %% Gollisch onoff part
% Gollish_OnOff_movie(makemovie_folder, movie_folder,date,0.5);
% Gollish_OnOff_movie(makemovie_folder, movie_folder,date,0.8);
% 
% %% Checkerboard
% checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,20,13,date,5);
% checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,30,13,date,5);
% checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,20,15,date,5);
% checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,30,15,date,5);
% 
% %% Grating
% makeGratingvideo(makemovie_folder,movie_folder, 300, 0.75,5,date);
% makeGratingvideo(makemovie_folder,movie_folder, 600, 0.75,5,date);
% makeGratingvideo(makemovie_folder,movie_folder, 300, 0.375,5,date);
% makeGratingvideo(makemovie_folder,movie_folder, 300, 1.5,5,date);
% makeGratingvideo(makemovie_folder,movie_folder, 600, 0.375,5,date);
% makeGratingvideo(makemovie_folder,movie_folder, 600, 1.5,5,date);
% 
% makeGratingvideo(makemovie_folder,movie_folder, 300, 0.75,8,date);
% makeGratingvideo(makemovie_folder,movie_folder, 600, 0.75,8,date);
% makeGratingvideo(makemovie_folder,movie_folder, 300, 0.375,8,date);
% makeGratingvideo(makemovie_folder,movie_folder, 300, 1.5,8,date);
% makeGratingvideo(makemovie_folder,movie_folder, 600, 0.375,8,date);
% makeGratingvideo(makemovie_folder,movie_folder, 600, 1.5,8,date);
% %% Reversal bar
% makeREvideo(makemovie_folder,0, 'RL',movie_folder, videoworkspace_folder,date,2.4);
% makeREvideo(makemovie_folder,pi/2, 'UD',movie_folder, videoworkspace_folder,date,2.4);
% makeREvideo(makemovie_folder,pi/4, 'UL_DR',movie_folder, videoworkspace_folder,date,2.4);
% makeREvideo(makemovie_folder,3*pi/4, 'UR_DL',movie_folder, videoworkspace_folder,date,2.4);