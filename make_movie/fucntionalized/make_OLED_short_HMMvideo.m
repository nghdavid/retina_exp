function make_OLED_short_HMMvideo(makemovie_folder, theta, direction, video_folder, videoworkspace_folder,seed_date,date,calibration_date,Dark,mean_lumin,contrast)

%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
%% Setup matrix_folder
rotation = theta*4/pi;
if strcmp(Dark,'Dark')%Dark bar
    matrix_folder = ['C:\',calibration_date,'DarkBar_matrix_',num2str(mean_lumin),'mW_',num2str(100-contrast*100),'%\'];
    make_Darkbar_matrix(calibration_date,mean_lumin,contrast,rotation);
elseif strcmp(Dark,'Bright')%Bright bar
    matrix_folder = ['C:\',calibration_date,'Bar_matrix_',num2str(mean_lumin),'mW\'];
    make_bar_matrix(calibration_date,mean_lumin,rotation);
else
    disp('There is error about contrast')
    return
end
%% HMM base from RL motion
%% video parameter
list = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];%Gamma value complete list
G_list = [4.3];
seed_directory_name = [seed_date,' new video Br50\rn_workspace'];
cd(['C:\',seed_directory_name]);%New seed for HMM movie
all_file = dir('*.mat');%Load random seed
fps =60;%freq of the screen flipping
deltaT = 10; %s
rest_T = 20;
trial_num = 30;
T = (deltaT+rest_T)*trial_num; %second
dt = 1/fps;
T = dt:dt:T;

%%rotation theta = 0 for RL theta
%theta must between [0,pi)
for Gvalue=G_list
    %% HMM parameter and video name
    G_HMM =Gvalue; %damping / only G will influence correlation time
    D_HMM = 2700000; %dynamical range
    omega =G_HMM/2.12; %omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
    %Random number files ( I specifically choose some certain random seed series)
    file = all_file(find(list==Gvalue)).name;
    [~, name, ext] = fileparts(file);
    filename = [name,ext];
    load(['C:\',seed_directory_name,'\',filename]);
    name=[name];
    name
    Gvalue
    
    Xarray = zeros(1,deltaT*fps);
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    Vx = zeros(1,deltaT*fps);
    %Use rntest(t)!!!
    for t = 1:deltaT*fps-1
        Xarray(t+1) = Xarray(t) + Vx(t)*dt;
        Vx(t+1) = (1-G_HMM*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D_HMM)*rntest(t);
    end
    % Normalize to proper moving range
    nrx=abs((rightx_bar-leftx_bar-2*bar_wid)/(max(Xarray)-min(Xarray)));
    Xarray2=Xarray*nrx;
    Xarray3=Xarray2+leftx_bar+bar_wid-min(Xarray2);%rearrange the boundary values
    Xarray4 = zeros(1,length(T));
    for t = 1:length(T)
        if mod(t, (deltaT+rest_T)*fps) <= deltaT*fps && mod(t, (deltaT+rest_T)*fps) > 0
            Xarray4(t) = Xarray3(mod(t, (deltaT+rest_T)*fps));
        else
            Xarray4(t) = -1;
        end
    end
    newXarray=round(Xarray4);
    
    Y =meaCenter_y;
    cd (video_folder)
    %video frame file
    if strcmp(Dark,'Dark')
        name=[date,'_short_HMM_Dark_',direction,'_G',num2str(G_HMM) ,'_15min_Q100_',num2str(mean_lumin),'mW_',num2str(contrast*100)];
    elseif strcmp(Dark,'Bright')
        name=[date,'_short_HMM_',direction,'_G',num2str(G_HMM) ,'_15min_Q100_',num2str(mean_lumin),'mW'];
    end
    name
    
    
    %video setting
    video_fps=fps;
    writerObj = VideoWriter([name,'.avi']);  %change video name here!
    writerObj.FrameRate = video_fps;
    writerObj.Quality = 100;
    open(writerObj);
    %start part: dark adaptation
    for mm=1:fps*20
        img=zeros(screen_y,screen_x);
        writeVideo(writerObj,img);
    end
    %%draw moving bar
    for kk =1:length(T)
        X=newXarray(kk);%Get bar center position
        if X>=0
            X=newXarray(kk);%Get bar center position
            load([matrix_folder,num2str(theta*4/pi),'\',num2str(X),'.mat']);% Load picture matrix
        else
            a=zeros(screen_y,screen_x);
        end
        %square_flicker
        if mod(kk,3)==1 %odd number
            a(500-35:500+35,1230:screen_x)=1; % white square
        elseif mod(kk,3)==2
            a(500-35:500+35,1230:screen_x)=0.2; %gray
        else
            a(500-35:500+35,1230:screen_x)=0; % dark
        end
        writeVideo(writerObj,a);
    end
    
    %end part video
    for mm=1:10
        img=zeros(screen_y,screen_x);
        img(500-35:500+35,1230:screen_x)=0.2; %gray
        writeVideo(writerObj,img);
    end
    img=zeros(screen_y,screen_x);
    writeVideo(writerObj,img);
    
    close(writerObj);
    cd(videoworkspace_folder)
    %save parameters needed
    save([name,'.mat'],'newXarray')
    
end
cd(makemovie_folder)

end