function make_Intensity_HMM_video(makemovie_folder, video_folder, videoworkspace_folder,seed_date,date,calibration_date,mins,G_list,mean_lumin)
%mean_lumin is mean luminance of HMM
%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);

%% video parameter
list = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];%Gamma value complete list
seed_directory_name = [seed_date,' new video Br50\rn_workspace'];
cd(['C:\',seed_directory_name]);%New seed for HMM movie
all_file = dir('*.mat');%Load random seed
fps =60;  %freq of the screen flipping
T=mins*60; %second
dt=2/fps;
T=dt:dt:T;
%% Run each many Gamma value
for Gvalue=G_list
    %% HMM parameter and video name
    G_HMM =Gvalue; % damping / only G will influence correlation time
    D_HMM = 2700000; %dynamical range
    omega =G_HMM/2.12;   % omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
    %Random number files ( I specifically choose some certain random seed series
    file = all_file(find(list==Gvalue)).name;
    [~, name, ext] = fileparts(file);
    filename = [name,ext];
    load(['C:\',seed_directory_name,'\',filename]);
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
    % Normalize to proper range
    Xarray2 = 0.3*mean_lumin*Xarray/std(Xarray);
    newXarray = Xarray2 - mean(Xarray2)+mean_lumin;   
    newXarray(newXarray > 1.95*mean_lumin) = 1.95*mean_lumin;
    newXarray(newXarray < 0.05*mean_lumin) = 0.05*mean_lumin;
    newXarray = imresize(newXarray, [1 2*length(T)], 'nearest');
    OLEDXarray = interp1(real_lum,lum,newXarray,'linear');
    monitor_mean_lumin= interp1(real_lum,lum,mean_lumin,'linear');
    cd(video_folder)
    %video frame file
    name=[date,'_HMM_wf','_G',num2str(G_HMM) ,'_',int2str(mins),'min_Q100'];
    name
    
    %video setting
    Time=T; %sec
    video_fps=fps;
    writerObj = VideoWriter([name,'.avi']);  %change video name here!
    writerObj.FrameRate = video_fps;
    writerObj.Quality = 100;
    open(writerObj);
    
    %start part: dark adaptation
    for mm=1:fps*20
        img=zeros(screen_y,screen_x);
        img(lefty_bd:righty_bd,leftx_bd:rightx_bd) = monitor_mean_lumin;
        writeVideo(writerObj,img);
    end
    %%draw picture
    for kk =1:length(T)
        a=zeros(screen_y,screen_x);%full screen pixel matrix %it's the LED screen size
        a(lefty_bd:righty_bd,leftx_bd:rightx_bd)=OLEDXarray(kk);
        %square_flicker
        if mod(kk,3)==1 %odd number
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=1; % white square
        elseif mod(kk,3)==2
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
        else
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0; % dark
        end
        writeVideo(writerObj,a);
    end
    
    %end part video
    for mm=1:10
        img=zeros(screen_y,screen_x);
        img(lefty_bd:righty_bd,leftx_bd:rightx_bd) = monitor_mean_lumin;
        img(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
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
