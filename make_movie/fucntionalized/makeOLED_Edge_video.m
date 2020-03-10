function makeOLED_Edge_video(makemovie_folder, theta, direction, video_folder, videoworkspace_folder,type,seed_date,date,calibration_date,mins,G_list,reverse,mean_lumin)
%% This code can produce moving bar video whose trajectory is made of HMM process
%It can make two kinds version of moving edge: reverse or not
%makemovie_folder is where you put your code
%theta means how much degree you want to rotate. 0 means RL, 1/4pi means UL_DR, 1/2pi means UD, 3/4pi means UR_DL
%video_folder is where you want to save your video
%videoworkspace_folder is where you want to save your videoworkspace
%seed_date is which seed you want to use(0421,0809,0810)
%date is which day produce video
%mins is how long your stimulus is
%calibration_date is which day you calibrate
%G_list is a list of gamma value you want to use
%Reverse is to change direction
%mean_lumin is mean luminance of edge
%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
%% Setup matrix_folder and make matrix
rotation = theta*4/pi;
matrix_folder = ['C:\',calibration_date,'edge_matrix_',num2str(mean_lumin),'mW\'];
if exist([matrix_folder,num2str(theta*4/pi),'\']) == 0
    make_edge_matrix(calibration_date,mean_lumin,rotation);
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
T=dt:dt:T;
%% Run each many Gamma value
for Gvalue=G_list
    %% HMM or OU parameter and video name
    %Random number files ( I specifically choose some certain random seed series)
    file = all_file(find(list==Gvalue)).name;
    [~, name, ext] = fileparts(file);
    filename = [name,ext];
    load(['C:\',seed_directory_name,'\',filename]);
    name=[name];
    %% HMM or OU trajectory
    if strcmp(type,'HMM')
        Xarray = HMM_generator(T,dt,Gvalue,rntest);
    elseif strcmp(type,'OU')
        Xarray = OU_generator(T,dt,Gvalue,rntest);
    elseif strcmp(type,'sOU')%Smooth OU
        Xarray = OU_generator(T,dt,Gvalue,rntest);
    end
    %% Normalize to proper moving range and video name
    nrx=abs((mea_size_bm+1)/(max(Xarray)-min(Xarray)));
    Xarray2=Xarray*nrx; 
    if reverse
        Xarray3=Xarray2-min(Xarray2)+meaCenter_x;%rearrange the boundary values 
        if strcmp(direction,'RL') || strcmp(direction,'UD')
            name=[date,'_',type,'_Edge_',flip(direction),'_G',num2str(Gvalue) ,'_',int2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
        else
            name=[date,'_',type,'_Edge_',direction(4:5),'_',direction(1:2),'_G',num2str(G_HMM) ,'_',int2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
        end
    else
        Xarray3=Xarray2-min(Xarray2)+meaCenter_x-mea_size_bm+1;%rearrange the boundary values
        name=[date,'_',type,'_Edge_',direction,'_G',num2str(Gvalue) ,'_',int2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
    end
    newXarray=round(Xarray3);
    cd (video_folder)
    name
    %% Video setting
    video_fps=fps;
    writerObj = VideoWriter([name,'.avi']);  %change video name here!
    writerObj.FrameRate = video_fps;
    writerObj.Quality = 100;
    open(writerObj);
    %% Start part: adaptation
    for mm=1:fps*20
        img=zeros(screen_y,screen_x);    
        writeVideo(writerObj,img);
    end
    
    %% Draw moving bar
    for kk =1:length(T)
        X=newXarray(kk);%Get bar center position
        load([matrix_folder,num2str(theta*4/pi),'\',num2str(X),'.mat']);% Load picture matrix
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