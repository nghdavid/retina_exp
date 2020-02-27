function make_Intensity_short_HMMvideo(makemovie_folder, video_folder, videoworkspace_folder,date,calibration_date,mean_lumin)
%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
%% HMM base from RL motion
G_list=[4.3];  %list of Gamma value

countt=1;
cd('0421 new video Br50/rn_workspace');
all_file = dir('*.mat');

fps =60;  %freq of the screen flipping
deltaT = 10; %s
rest_T = 20;
trial_num = 30;
T = (deltaT+rest_T)*trial_num; %second
dt = 1/fps;
T = dt:dt:T;

for Gvalue=G_list
    G_HMM =Gvalue; % damping / only G will influence correlation time
    D_HMM = 2700000; %dynamical range
    omega =G_HMM/2.12;   % omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
    %for randon number files ( I specifically choose some certain random seed series
    
    file = all_file(countt).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([filename]);
    name=[name];
    name
    Gvalue
    countt=countt+1;
    
    Xarray = zeros(1,deltaT*fps);
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    Vx = zeros(1,deltaT*fps);
    %Use rntest(t)!!!
    for t = 1:deltaT*fps-1
        Xarray(t+1) = Xarray(t) + Vx(t)*dt;
        Vx(t+1) = (1-G_HMM*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D_HMM)*rntest(t);
    end
    % Normalize to proper moving range
    Xarray2 = 0.3*mean_lumin*Xarray/std(Xarray);
    Xarray3 = Xarray2 - mean(Xarray2)+mean_lumin;   
    Xarray3(Xarray3 > 1.95*mean_lumin) = 1.95*mean_lumin;
    Xarray3(Xarray3 < 0.05*mean_lumin) = 0.05*mean_lumin;
    Xarray3(2:2:end) =Xarray3(1:2:end);
    Xarray5 = interp1(real_lum,lum,Xarray3,'linear');
    interp1(real_lum,lum,0.91,'linear')
    plot(lum,real_lum); hold on;
    scatter(interp1(lum,real_lum,0.91,'linear'), 0.91);
    % Normalize to proper moving range
    Xarray4 = zeros(1,length(T));
    for t = 1:length(T)
        if mod(t, (deltaT+rest_T)*fps) <= deltaT*fps && mod(t, (deltaT+rest_T)*fps) > 0
            Xarray4(t) = Xarray3(mod(t, (deltaT+rest_T)*fps));
            OLEDXarray(t) = Xarray5(mod(t, (deltaT+rest_T)*fps));
        else
            Xarray4(t) = -1;
            OLEDXarray(t) = -1;
        end
    end
    newXarray=Xarray4;
    
    Y =meaCenter_y;
    cd (video_folder)
    %video frame file
    name=[date,'Intensity_short_HMM_G',num2str(G_HMM) ,'_15min_Br50_Q100'];
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
        img=zeros(1024,1280);
        writeVideo(writerObj,img);
    end
    
    
    
    %%draw moving bar
    for kk =1:length(T)
        a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
        if newXarray(kk) >= 0
            a(1:600,1:800) = OLEDXarray(kk);
        end
        %square_flicker
        a(500-70:500+70,1180:1280) = 0; % 
        if mod(kk,3)==1 %odd number
            a(500-35:500+35,1230:1280)=1; % white square
        elseif mod(kk,3)==2
            a(500-35:500+35,1230:1280)=0.2; %gray
        else
            a(500-35:500+35,1230:1280)=0; % dark
        end
%         percentage = kk/length(T)*100;
%         percentage
        writeVideo(writerObj,a);
    end
    
    %end part video
    for mm=1:10
        img=zeros(1024,1280);
        img(500-35:500+35,1230:1280)=0.2; %gray
        writeVideo(writerObj,img);
    end
    img=zeros(1024,1280);
    writeVideo(writerObj,img);
    
    close(writerObj);
    cd(videoworkspace_folder)
    %save parameters needed
    save([date,'Intensity_short_HMM_G',num2str(G_HMM) ,'_15min_Br50_Q100','.mat'],'newXarray')
    
end
cd(makemovie_folder)

end