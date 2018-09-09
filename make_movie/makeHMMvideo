%% HMM RL
clear all;
cd('/Users/nghdavid/Desktop/make_movie');

mea_size=433;
mea_size_bm=465; %bigger mea size , from luminance calibrated region
meaCenter_x=631; 
meaCenter_y=580; 

leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
bar_le=floor((mea_size_bm-1)/2/sqrt(2)); %half of bar length / pixel number on LCD /total length = mea_size = 1919 um
bar_wid=11; %half of bar width / total length = 11*2+1=23 pixels = 65 um
%R-L
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar

G_list=[ 2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];  %list of Gamma value
G_list=[9 12 20]; 
countt=1;
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
cd('0421 new video Br25/rn_workspace');  
all_file = dir('*.mat');

fps =60;  %freq of the screen flipping 
T=7*60; %second
dt=1/fps;
T=dt:dt:T;

screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;

for Gvalue=G_list
    cd('/Users/nghdavid/Desktop/make_movie/0421 new video Br25/rn_workspace');
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

    Xarray = zeros(1,length(T));
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    Vx = zeros(1,length(T));
    %Use rntest(t)!!!
    for t = 1:length(T)-1
            Xarray(t+1) = Xarray(t) + Vx(t)*dt;
            Vx(t+1) = (1-G_HMM*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D_HMM)*rntest(t); 
    end
    % Normalize to proper moving range
    nrx=abs(floor((rightx_bar-leftx_bar)/(max(Xarray)-min(Xarray))));
    Xarray2=Xarray*nrx;
    Xarray3=Xarray2+leftx_bar-min(Xarray2);%rearrange the boundary values
    newXarray=round(Xarray3); 
    Y =meaCenter_y; 
    cd ('/Users/nghdavid/Desktop/make_movie/0819_video_Br_50')
    %video frame file
    name=['0819 HMM RL G',num2str(G_HMM) ,' 7min Br50 Q100'];
    name


    %video setting
    Time=T; %sec
    video_fps=fps;
    writerObj = VideoWriter([name,'.avi']);  %change video name here!
    writerObj.FrameRate = video_fps;
    writerObj.Quality = 100;
    open(writerObj);
    %start part: dark adaptation
    for mm=1:60
        img=zeros(1024,1280);   
        writeVideo(writerObj,img);
    end

    %%rotation theta = 0 for RL
    theta = pi/4;
    R_matrix = [cos(theta) sin(theta) ; sin(theta) cos(theta)];
    
    %%draw moving bar
    for kk =1:length(T)
        a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size

        %HMM RL bar trajectory
        X=newXarray(kk);
        barX=X-round(leftx_bd);
        barY=round(Y)-round(lefty_bd);
        for y = barY-bar_le: barY+bar_le
            for x = barX-bar_wid:barX+bar_wid
               R_cor = R_matrix*[x-(mea_size_bm+1)/2  y-(mea_size_bm+1)/2]+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]; %ratation
               cal_x = dotPositionMatrix{R_cor(2),R_cor(1)}(1);
               cal_y = dotPositionMatrix{R_cor(2),R_cor(1)}(2);
               cal_lum = screen_brightness(R_cor(2),R_cor(1));
               a(cal_y,cal_x) = cal_lum;
            end
        end
        
        %square_flicker
        if mod(kk,3)==1 %odd number
        a(500-35:500+35,1230:1280)=1; % white square
        elseif mod(kk,3)==2
        a(500-35:500+35,1230:1280)=0.2; %gray 
        else
        a(500-35:500+35,1230:1280)=0; % dark
        end
        
        
        writeVideo(writerObj,a);
    end

    %end part video
    for mm=1:10
        img=zeros(1024,1280);
        img(500-35:500+35,1230:1280)=0.2; %gray
        writeVideo(writerObj,img);
    end
    close(writerObj);
    cd('/Users/nghdavid/Desktop/make_movie/0819_video_Br_50_workspace')
    %save parameters needed 
    save(['0819 HMM RL G',num2str(G_HMM) ,' 7min Br50 Q100','.mat'],'newXarray')
    
end
cd('/Users/nghdavid/Desktop/make_movie')
