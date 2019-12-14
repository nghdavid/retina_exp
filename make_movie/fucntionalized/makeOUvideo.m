function makeOUvideo(makemovie_folder, theta, direction, video_folder, videoworkspace_folder, seed_date, date,calibration_date,G_list,Length,Dark)
%% This code can produce moving bar video whose trajectory is made of OU process
%It can make four kinds version of moving bar: Long and Bright, Long and Dark, Short and Bright, Short and Dark
%makemovie_folder is where you put your code
%theta means how much degree you want to rotate. 0 means RL, 1/4pi means UL_DR, 1/2pi means UD, 3/4pi means UR_DL
%video_folder is where you want to save your video
%videoworkspace_folder is where you want to save your videoworkspace
%date is which day produce video
%calibration_date is which day you calibrate
%G_list is a list of gamma value you want to use
%Length is to decide long or short. 'Long' represent longer version, 'Short' represent shorter version,
%Dark is to decide Bright or Dark. 'Bright' represent Bright version, 'Dark' represent Dark version,

%% Load boundary_set.mat
load(['C:\calibration\',calibration_date,'\boundary_set.mat'])
list = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];
%% Setup matrix_folder(matrix_folder has four kinds of versions)
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
fps =60;  %freq of the screen flipping
T=5*60; %second
dt=1/fps;
T=dt:dt:T;
seed_directory_name = [seed_date,' new video Br50\rn_workspace'];
cd(['C:\',seed_directory_name]);%New seed for HMM movie
all_file = dir('*.mat');%Load random seed
%% Run each many Gamma value
for Gvalue=G_list
    %% OU parameter and video name
    G_OU = Gvalue; % damping / only G will influence correlation time
    D_OU = 2700000; %dynamical range
    file = all_file(find(list==Gvalue)).name;
    [~, name, ext] = fileparts(file);
    filename = [name,ext];
    load(['C:\',seed_directory_name,'\',filename]);
    name=[name];
    name
    Gvalue
    x = zeros(1,length(T));
    x(1,1)=0; % since the mean value of damped eq is zero
    for uu = 1:length(T)-1
          x(uu+1) = (1-dt*G_OU/(2.12)^2)*x(uu)+sqrt(dt*D_OU)*rntest(uu);
    end
    %Normalize to proper moving range
    if strcmp(Length,'Long')%Longer bar and bigger range
        nrx=abs((rightx_bd-leftx_bd-2*bar_wid)/(max(x)-min(x)));
        x2=x*nrx;
        x3=x2+leftx_bd+bar_wid-min(x2);%rearrange the boundary values
        if strcmp(Dark,'Dark')
            name=[date,'_OU_Dark_',direction,'_G',num2str(G_OU) ,'_5min_Br50_Q100_Long'];
        elseif strcmp(Dark,'Bright')
            name=[date,'_OU_',direction,'_G',num2str(G_OU) ,'_5min_Br50_Q100_Long'];
        end
    else%Shorter bar and smaller range
        nrx=abs((rightx_bar-leftx_bar-2*bar_wid)/(max(x)-min(x)));
        x2=x*nrx;
        x3=x2-min(x2)+leftx_bar+bar_wid;%rearrange the boundary values
        if strcmp(Dark,'Dark')
           name=[date,'_OU_Dark_',direction,'_G',num2str(G_OU) ,'_5min_Br50_Q100'];
        elseif strcmp(Dark,'Bright')
           name=[date,'_OU_',direction,'_G',num2str(G_OU) ,'_5min_Br50_Q100'];
        end
    end
    
    newXarray=round(x3); 
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