function makeHMMvideo(makemovie_folder, theta, direction, video_folder, videoworkspace_folder, seed_date,date,calibration_date,mins,G_list,Length,Dark)
%% This code can produce moving bar video whose trajectory is made of HMM process
%It can make four kinds version of moving bar: Long and Bright, Long and Dark, Short and Bright, Short and Dark
%makemovie_folder is where you put your code
%theta means how much degree you want to rotate. 0 means RL, 1/4pi means UL_DR, 1/2pi means UD, 3/4pi means UR_DL
%video_folder is where you want to save your video
%videoworkspace_folder is where you want to save your videoworkspace
%seed_date is which seed you want to use(0421,0809,0810)
%date is which day produce video
%mins is how long your stimulus is
%calibration_date is which day you calibrate
%G_list is a list of gamma value you want to use
%Length is to decide long or short. 'Long' represent longer version, 'Short' represent shorter version,
%Dark is to decide Bright or Dark. 'Bright' represent Bright version, 'Dark' represent Dark version,
%% Load boundary_set.mat
load(['C:\calibration\',calibration_date,'\boundary_set.mat'])
%% Setup matrix_folder
if strcmp(Length,'Long')%Longer bar and bigger range
    if theta == 3*pi/4||theta==pi/4
        disp('Long bar cannot be 45 or 135 degrees')%Because it will exceed boundary
        return
    end
    if strcmp(Dark,'Dark')%Dark bar
        matrix_folder = 'C:\1208DarkLongBar_matrix\';
    elseif strcmp(Dark,'Bright')%Bright bar
        matrix_folder = 'C:\1208LongBar_matrix\';
    else
        disp('There is error about contrast')
        return
    end
elseif strcmp(Length,'Short')%Shorter bar and smaller range
    if strcmp(Dark,'Dark')%Dark bar
        matrix_folder = 'C:\1208DarkBar_matrix\';
    elseif strcmp(Dark,'Bright')%Bright bar
        matrix_folder = 'C:\1119Bar_matrix\';
    else
        disp('There is error about contrast')
        return
    end
else
    disp('There is error about bar length')
    return
end

%% video parameter
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
    %% HMM parameter and video name
    
    G_HMM =Gvalue; %damping / only G will influence correlation time
    D_HMM = 2700000; %dynamical range
    omega =G_HMM/2.12; %omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
    %Random number files ( I specifically choose some certain random seed series)
    file = all_file(find(list==Gvalue)).name ;
    [~, name, ext] = fileparts(file);
    filename = [name,ext];
    load([filename]);
    name=[name];
    name
    Gvalue
    
    %% HMM trajectory 
    Xarray = zeros(1,length(T));
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    Vx = zeros(1,length(T));
    %Use rntest(t)!!!
    for t = 1:length(T)-1
        Xarray(t+1) = Xarray(t) + Vx(t)*dt;
        Vx(t+1) = (1-G_HMM*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D_HMM)*rntest(t);
    end
    %% Normalize to proper moving range and video name
    if strcmp(Length,'Long')%Longer bar and bigger range
        nrx=abs((rightx_bd-leftx_bd-2*bar_wid)/(max(Xarray)-min(Xarray)));
        Xarray2=Xarray*nrx;
        Xarray3=Xarray2+leftx_bd+bar_wid-min(Xarray2);%rearrange the boundary values
        if strcmp(Dark,'Dark')
            name=[date,'_HMM_Dark_',direction,'_G',num2str(G_HMM) ,'_',int2str(mins),'min_Br50_Q100_Long'];
        elseif strcmp(Dark,'Bright')
            name=[date,'_HMM_',direction,'_G',num2str(G_HMM) ,'_',int2str(mins),'min_Br50_Q100_Long'];
        end
    else
        nrx=abs((rightx_bar-leftx_bar-2*bar_wid)/(max(Xarray)-min(Xarray)));
        Xarray2=Xarray*nrx;
        Xarray3=Xarray2+leftx_bar+bar_wid-min(Xarray2);%rearrange the boundary values
        if strcmp(Dark,'Dark')
           name=[date,'_HMM_Dark_',direction,'_G',num2str(G_HMM) ,'_',int2str(mins),'min_Br50_Q100'];
        elseif strcmp(Dark,'Bright')
           name=[date,'_HMM_',direction,'_G',num2str(G_HMM) ,'_',int2str(mins),'min_Br50_Q100'];
        end
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
    %% Start part: dark adaptation
    for mm=1:fps*20
        img=zeros(1024,1280);
        writeVideo(writerObj,img);
    end
    
    %% Draw moving bar
    for kk =1:length(T)
        X=newXarray(kk);%Get bar center position
        load([matrix_folder,num2str(theta*4/pi),'\',num2str(X),'.mat']);% Load picture matrix
        %% Square_flicker
        if mod(kk,3)==1 %odd number
            a(500-35:500+35,1230:1280)=1; % white square
        elseif mod(kk,3)==2
            a(500-35:500+35,1230:1280)=0.2; %gray
        else
            a(500-35:500+35,1230:1280)=0; % dark
        end
        writeVideo(writerObj,a);
    end
    
    %% End part video for detection of ending
    for mm=1:10
        img=zeros(1024,1280);
        img(500-35:500+35,1230:1280)=0.2; %gray
        writeVideo(writerObj,img);
    end
    img=zeros(1024,1280);
    writeVideo(writerObj,img);
    close(writerObj);
    cd(videoworkspace_folder)
    %% Save parameters needed
    save([name,'.mat'],'newXarray')  
end
cd(makemovie_folder)
end