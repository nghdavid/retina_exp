clear all;
makemovie_folder = 'E:\makemovie';
date = '1202';
seed_date = '0421';

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
makeHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeDarkHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);

%% HMM 7 min part
makeHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeHMMvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeDarkHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeDarkHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeDarkHMMvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeDarkHMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);

%% Long HMM 5min part
makeLongHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeLongHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeLongDarkHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,5);
makeLongDarkHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'],[videoworkspace_folder,'HMM'], seed_date,date,5);

%% Long HMM 7 min part
makeLongHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeLongHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeLongDarkHMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);
makeLongDarkHMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], [videoworkspace_folder,'HMM'], seed_date,date,7);

%% OU part
makeOUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date);
makeOUvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date);
makeOUvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date);
makeOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date);
makeDarkOUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date);
makeDarkOUvideo(makemovie_folder, pi/2, 'UD',[movie_folder,'OU'], [videoworkspace_folder,'OU'], date);
makeDarkOUvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date);
makeDarkOUvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date);

%% Long OU part
makeLongOUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'],[videoworkspace_folder,'OU'], date);
makeLongOUvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'OU'],[videoworkspace_folder,'OU'], date);
makeLongDarkOUvideo(makemovie_folder, 0, 'RL', [movie_folder,'OU'], [videoworkspace_folder,'OU'], date);
makeLongDarkOUvideo(makemovie_folder, pi/2, 'UD',[movie_folder,'OU'],[videoworkspace_folder,'OU'], date);

%% Short HMM part
makeshort_HMMvideo(makemovie_folder, 0, 'RL', [movie_folder,'HMM'], videoworkspace_folder, date);
makeshort_HMMvideo(makemovie_folder, pi/2, 'UD', [movie_folder,'HMM'], videoworkspace_folder, date);
makeshort_HMMvideo(makemovie_folder, pi/4, 'UL_DR', [movie_folder,'HMM'], videoworkspace_folder, date);
makeshort_HMMvideo(makemovie_folder, 3*pi/4, 'UR_DL', [movie_folder,'HMM'], videoworkspace_folder, date);

%% Short HMM Rona part
makeRona_short_HMMvideo(makemovie_folder,movie_folder, videoworkspace_folder, date);

%% Gollisch onoff part
Gollish_OnOff_movie(makemovie_folder, movie_folder,date,0.5);
Gollish_OnOff_movie(makemovie_folder, movie_folder,date,0.8);

%% Checkerboard
checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,20,13,date,5);
checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,30,13,date,5);
checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,20,15,date,5);
checkerboard(makemovie_folder,movie_folder, videoworkspace_folder,30,15,date,5);

%% Grating
makeGratingvideo(makemovie_folder,movie_folder, 300, 0.75,5,date);
makeGratingvideo(makemovie_folder,movie_folder, 600, 0.75,5,date);
makeGratingvideo(makemovie_folder,movie_folder, 300, 0.375,5,date);
makeGratingvideo(makemovie_folder,movie_folder, 300, 1.5,5,date);
makeGratingvideo(makemovie_folder,movie_folder, 600, 0.375,5,date);
makeGratingvideo(makemovie_folder,movie_folder, 600, 1.5,5,date);

makeGratingvideo(makemovie_folder,movie_folder, 300, 0.75,8,date);
makeGratingvideo(makemovie_folder,movie_folder, 600, 0.75,8,date);
makeGratingvideo(makemovie_folder,movie_folder, 300, 0.375,8,date);
makeGratingvideo(makemovie_folder,movie_folder, 300, 1.5,8,date);
makeGratingvideo(makemovie_folder,movie_folder, 600, 0.375,8,date);
makeGratingvideo(makemovie_folder,movie_folder, 600, 1.5,8,date);
%% Reversal bar
makeREvideo(makemovie_folder,0, 'RL',movie_folder, videoworkspace_folder,date,2.4);
makeREvideo(makemovie_folder,pi/2, 'UD',movie_folder, videoworkspace_folder,date,2.4);
makeREvideo(makemovie_folder,pi/4, 'UL_DR',movie_folder, videoworkspace_folder,date,2.4);
makeREvideo(makemovie_folder,3*pi/4, 'UR_DL',movie_folder, videoworkspace_folder,date,2.4);