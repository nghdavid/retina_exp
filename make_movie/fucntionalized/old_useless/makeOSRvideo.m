function makeOSRvideo(makemovie_folder,  video_folder,  date)
%% ON OFF
fps = 60;
rep = 20; %20 trials
rest = 5; %5s inter-trial
trial = 25; %20s trial
w = 0.05; %pulse width =50ms
p = 0.20; %period 
allX(1:2:2*6000)= w;
allX(2:2:2*6000)= p-w;%X; for OSR!
ey1=[];

for i=1:rep*2 %length(allX) for OSR!
    if mod(i,2)==0
       ey1=[ey1 zeros(1,round(allX(i)*fps))];
    else
       ey1=[ey1 ones(1,round(allX(i)*fps))];
    end
end
ey = [];
for i = 1:trial
    ey = [ey ey1 zeros(1,round(rest*fps))];
end


cd(makemovie_folder);
load('boundary_set.mat')
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;

leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar
upy_bar = ceil(meaCenter_y-(mea_size_bm-1)/2/sqrt(2));
downy_bar = floor(meaCenter_y+(mea_size_bm-1)/2/sqrt(2));

cd (video_folder);
%video frame file
name=[[date,'_OSR_Br50_Q100']];
name


%video setting

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

for kk =1:length(ey)
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    
    %square_flicker
    if ey(kk) > 0%odd number
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
