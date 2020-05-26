function makeOLED_Bar_video_sN(makemovie_folder, theta, direction, video_folder, videoworkspace_folder, type, seed_date, date, calibration_date, mins, G_list, Dark, mean_lumin, cutOffFreq, num_dot)
%% This code can produce moving bar video whose trajectory is made of HMM or OU process
%It can make kinds version of moving bar in several pattern: Bright or Dark, by HMM, OU, or smoothed_OU.
%sN means Spatial Noise.
%makemovie_folder is where you put your code
%theta means how much degree you want to rotate. 0 means RL, 1/4pi means UL_DR, 1/2pi means UD, 3/4pi means UR_DL
%video_folder is where you want to save your video
%videoworkspace_folder is where you want to save your videoworkspace
%seed_date is which seed you want to use(0421,0809,0810)
%date is which day produce video
%mins is how long your stimulus is
%calibration_date is which day you calibrate
%G_list is a list of gamma value you want to use
%Dark is to decide Bright or Dark. 'Bright' represent Bright version, 'Dark' represent Dark version,
%mean_lumin is mean luminance of bar

%Bar_lumin is set to be 100% btight or 100% dark.
%The 'Spatial Noise' will be repersent by random distributed dots.
%A dot is set to be a 33^2 pixel square with 50% mean_lumin
%                           ~ 251^2 micro ~ 3% of mea_area
%num_pot is the numder of dots, which is the only tuneable parameter of Spatial Noise.
covered_area = 0.03*num_dot;
%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
mea_range = [leftx_bar rightx_bar meaCenter_y-floor(mea_size/2) meaCenter_y+floor(mea_size/2) mea_size];
%% Setup matrix_folder and make matrix
rotation = theta*4/pi;
if strcmp(Dark,'Dark')%Dark bar
    matrix_folder = ['C:\',calibration_date,'DarkBar_matrix_',num2str(mean_lumin),'mW_0%\', num2str(theta*4/pi)];
    if exist(matrix_folder) == 0
        make_Darkbar_matrix(calibration_date,mean_lumin,0,rotation);
    else
        disp('Already have produced matrix')
    end
elseif strcmp(Dark,'Bright')%Bright bar
    matrix_folder = ['C:\',calibration_date,'Bar_matrix_',num2str(mean_lumin),'mW\', num2str(theta*4/pi)];
    if exist(matrix_folder) == 0
        make_bar_matrix(calibration_date,mean_lumin,rotation);
    else
        disp('Already have produced matrix')    
    end
else
    disp('There is error about contrast')
    return
end

Noise_matrix_folder = ['C:\',calibration_date,'Spatial_Noise_matrix_',num2str(mean_lumin/2),'mW\', num2str(num_dot)];
if ~exist(matrix_folder)
    make_Spatial_Noise_matrix(calibration_date, mean_lumin/2, num_dot);
else
    disp('Already have produced matrix')
end

%% Video parameter
list = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];%Gamma value complete list
seed_directory_name = [seed_date,' new video Br50\rn_workspace'];
cd(['C:\',seed_directory_name]);%New seed for HMM movie
all_file = dir('*.mat');%Load random seed
fps =60;  %freq of the screen flipping
T=mins*60; %second
dt=1/fps;
Time=dt:dt:T;
%% Run each many Gamma value
for Gvalue=G_list
    %% HMM or OU parameter and video name
    %Random number files ( I specifically choose some certain random seed series)
    file = all_file(find(list==Gvalue)).name;
    [~, name, ext] = fileparts(file);
    filename = [name,ext];
    load(['C:\',seed_directory_name,'\',filename]);
    name=[name];
    if strcmp(Dark,'Dark')
        name=[date,'_',type,'_Dark_',direction,'_G',num2str(Gvalue) ,'_',int2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
    elseif strcmp(Dark,'Bright')
        name=[date,'_',type,'_',direction,'_G',num2str(Gvalue) ,'_',int2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
    end
    %% HMM trajectory
    if strcmp(type,'HMM')
        Xarray = HMM_generator(T,dt,Gvalue,rntest);
    elseif strcmp(type,'OU')
        Xarray = OU_generator(T,dt,Gvalue,rntest);
    elseif strcmp(type,'OUsmooth')%Smooth OU
        Xarray = Smooth_OU_generator(T,dt,Gvalue,rntest,cutOffFreq);
        name = [name,'_',num2str(cutOffFreq),'Hz_', num2str(covered_area), 'covered'];
    end
    name
    %% Normalize to proper moving range and video name
    newXarray = round(rescale(Xarray, leftx_bar+bar_wid, rightx_bar-bar_wid));
    cd (video_folder)
    
    %% Video setting
    video_fps=fps;
    writerObj = VideoWriter([name,'.avi']);  %change video name here!
    writerObj.FrameRate = video_fps;
    writerObj.Quality = 100;
    open(writerObj);
    %% Start part: adaptation
    for mm=1:fps*20
        img=zeros(screen_y,screen_x);
        if strcmp(Dark,'Dark')%Set to mean luminance
            img(lefty_bd:righty_bd,leftx_bd:rightx_bd) = interp1(real_lum,lum,mean_lumin,'linear');
        end    
        writeVideo(writerObj,img);
    end
    
    %% Draw moving bar
    dot_lumin  =  interp1(real_lum,lum,mean_lumin/2,'linear');
    for kk =1:length(Time)
        X=newXarray(kk);%Get bar center position
        load([matrix_folder,'\',num2str(X),'.mat']);% Load picture matrix
        temp = a;
        load([Noise_matrix_folder,'\',num2str(500),'.mat']);% Load picture matrix
        temp(find(a~=0)) = 0;
        a = temp+a;
        %% Square_flicker
        if mod(kk,3)==1 %odd number
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=1; % white square
        elseif mod(kk,3)==2
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
        else
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0; % dark
        end
        writeVideo(writerObj,a);
    end
    
    %% End part video for detection of ending
    for mm=1:10
        img=zeros(screen_y,screen_x);
        img(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
        writeVideo(writerObj,img);
    end
    img=zeros(screen_y,screen_x);
    writeVideo(writerObj,img);
    close(writerObj);
    cd(videoworkspace_folder)
    %% Save parameters needed
    save([name,'.mat'],'newXarray')
end
cd(makemovie_folder)
end