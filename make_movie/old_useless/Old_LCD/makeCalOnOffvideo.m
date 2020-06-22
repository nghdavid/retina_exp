function CalOnOffvideo(makemovie_folder,  video_folder,  date)
%% ON OFF

%ONOFF times.
on_time = 2; %s
off_time = 2; %s
rest_time = 5; %s

fps =60;  %freq of the screen flipping

T=5*60; %second
dt=1/fps;
T=dt:dt:T;
cd(makemovie_folder);
load('boundary_set.mat')
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;

all_file = dir('*.mat');
cd (video_folder);
%video frame file
name=[[date,'_CalONOFF_5min_Br50_Q100']];
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
    if mod(kk,fps*(on_time+off_time) )<on_time*fps %odd number
        for y = upy_bar - lefty_bd : downy_bar - lefty_bd
            for x = leftx_bar - leftx_bd : rightx_bar - leftx_bd
                cal_x = dotPositionMatrix{y,x}(1);
                cal_y = dotPositionMatrix{y,x}(2);
                cal_lum = screen_brightness(y,x);
                a(cal_y,cal_x) = cal_lum;
            end
        end
        a(500-35:500+35,1230:1280)=1;
    end
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

cd(makemovie_folder);
end
