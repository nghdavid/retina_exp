calibration_date = '20191115v';
load(['C:\calibration\',calibration_date,'\calibrate_pt.mat'])%Load dotPositionMatrix
load(['C:\calibration\',calibration_date,'\screen_brightness.mat'])%Load screen_brightness
load(['C:\calibration\',calibration_date,'\boundary_set.mat'])
name = '0930saccade';
mat_directory = 'C:\2019_02_15_matimg\';
pic_size = 441;%Picture size that tina gives you

pic = (mea_size_bm-pic_size)/2;

newXarray = zeros(1,30000);
leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
rightx_bd=meaCenter_x+(mea_size_bm-1)/2;
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
righty_bd=meaCenter_y+(mea_size_bm-1)/2;

leftx_bar=leftx_bd+pic; %Left boundary of bar
rightx_bar=rightx_bd-pic; %Right boundary of bar
upy_bar = lefty_bd+pic;
downy_bar = righty_bd-pic;




fps =60;  %freq of the screen flipping
T=5*60; %second
dt=1/fps;
T=dt:dt:T;

screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;


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

for kk =0:30000-1
    if kk < 9
        load([mat_directory,'stimulus0000',int2str(kk+1),'.mat'])
    elseif kk < 99
        load([mat_directory,'stimulus000',int2str(kk+1),'.mat'])
    elseif  kk <  999
        load([mat_directory,'stimulus00',int2str(kk+1),'.mat'])
    elseif  kk <  9999
        load([mat_directory,'stimulus0',int2str(kk+1),'.mat'])
    else
        load([mat_directory,'stimulus',int2str(kk+1),'.mat'])
    end
    imgs=mat2gray(imgs);
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    pic_x = 1;
    pic_y = 1;
    %square_flicker
    
    for y = upy_bar - lefty_bd : downy_bar - lefty_bd

        for x = leftx_bar - leftx_bd : rightx_bar - leftx_bd
            cal_x = dotPositionMatrix{y,x}(1);
            cal_y = dotPositionMatrix{y,x}(2);
            
            cal_lum = imgs(pic_y,pic_x);
            a(cal_y,cal_x) = cal_lum;
            
            pic_x = pic_x + 1;
        end
        pic_x = 1;
        pic_y = pic_y + 1;
    end
    
    if mod(kk+1,3)==1 %odd number
            a(500-35:500+35,1230:1280)=1; % white square
        elseif mod(kk+1,3)==2
            a(500-35:500+35,1230:1280)=0.2; %gray
        else
            a(500-35:500+35,1230:1280)=0; % dark
    end
    writeVideo(writerObj,a);
    clear imgs;
end    


% 
% %end part video
for mm=1:10
    img=zeros(1024,1280);
    img(500-35:500+35,1230:1280)=0.2; %gray
    writeVideo(writerObj,img);
end


img=zeros(1024,1280);
writeVideo(writerObj,img);


close(writerObj);

save([name,'.mat'],'newXarray')
