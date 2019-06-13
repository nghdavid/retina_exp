function makeRona_short_HMMvideo(makemovie_folder, video_folder, videoworkspace_folder, date)

%% HMM base from RL motion


G_list=[4.3];  %list of Gamma value


%G_list=[9];
countt=1;

load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')
cd('0421 new video Br25/rn_workspace');
all_file = dir('*.mat');

fps =60;  %freq of the screen flipping
deltaT = 10; %s
rest_T = 20;
trial_num = 30;
T = (deltaT+rest_T)*trial_num; %second
dt = 1/fps;
T = dt:dt:T;

screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;



for Gvalue=G_list
    cd([makemovie_folder, '\0421 new video Br25\rn_workspace']);
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
    nrx=abs(0.8/(max(Xarray)-min(Xarray)));
    Xarray3=(Xarray-min(Xarray))*nrx+0.2;%rearrange the boundary values
    Xarray4 = zeros(1,length(T));
    for t = 1:length(T)
        if mod(t, (deltaT+rest_T)*fps) <= deltaT*fps && mod(t, (deltaT+rest_T)*fps) > 0
            Xarray4(t) = Xarray3(mod(t, (deltaT+rest_T)*fps));
        else
            Xarray4(t) = -1;
        end
    end
    
    newXarray=Xarray4;
    
    Y =meaCenter_y;
    cd (video_folder)
    %video frame file
    name=[date,'Rona_short_HMM_G',num2str(G_HMM) ,'_15min_Br50_Q100'];
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
            a=ones(1024,1280)*newXarray(kk);
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
    save([date,'Rona_short_HMM_G',num2str(G_HMM) ,'_15min_Br50_Q100','.mat'],'newXarray')
    
end
cd(makemovie_folder)

end