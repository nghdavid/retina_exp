%% ON OFF
clear all;

mea_size=433;
mea_size_bm=465; %bigger mea size , from luminance calibrated region
meaCenter_x=631; 
meaCenter_y=580; 

%ONOFF times.
on_time = 2; %s
off_time = 10; %s
    
leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar
upy_bar = ceil(meaCenter_y-(mea_size_bm-1)/2/sqrt(2)); 
downy_bar = floor(meaCenter_y+(mea_size_bm-1)/2/sqrt(2)); 




fps =60;  %freq of the screen flipping 
T=5*60; %second
dt=1/fps;
T=dt:dt:T;

load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;

all_file = dir('*.mat');
cd ('E:\retina_v\videos\0903_Br_50\ONOFF')
%video frame file
name=['0903 CalONOFF 5min Br50 Q100'];
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

%%rotation theta = 0 for RL

for kk =0:length(T)-1
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    
    %square_flicker
    
    for y = upy_bar - leftx_bd : downy_bar - leftx_bd
        for x = leftx_bar - leftx_bd : rightx_bar - leftx_bd
            if mod(kk,fps*(on_time+off_time))<on_time*fps %odd number
                cal_x = dotPositionMatrix{y,x}(1);
                cal_y = dotPositionMatrix{y,x}(2);
                cal_lum = screen_brightness(y,x);
                a(cal_y,cal_x) = cal_lum;
            elseif mod(kk,fps*(on_time+off_time))>on_time*fps
                a=zeros(1024,1280); % dark
            else
            end
        end
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




cd('E:\retina\videos\0903_ONOFF_video_Br_50')