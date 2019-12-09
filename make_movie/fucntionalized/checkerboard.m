function checkerboard(makemovie_folder,video_folder, videoworkspace_folder,refresh_fps,num_pixel,date,mins,calibration_date)
%% Checkerboard
fps =60;  %freq of the screen flipping
frame_per_board = fps/refresh_fps;
T=mins*60; %second
dt=1/fps;
T=dt:dt:T;
cd(makemovie_folder);
load(['C:\calibration\',calibration_date,'\calibrate_pt.mat'])%Load dotPositionMatrix
load(['C:\calibration\',calibration_date,'\screen_brightness.mat'])%Load screen_brightness
load(['C:\calibration\',calibration_date,'\boundary_set.mat'])
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;

all_file = dir('*.mat');
cd (video_folder);
%video frame file

name=[date,'_Checkerboard_',int2str(refresh_fps),'Hz_',int2str(num_pixel),'_',int2str(mins),'min_Br50_Q100'];
name

newXarray = cell(length(T),1);
initial_checkerboard = zeros(num_pixel);
checkerboard = zeros(num_pixel);
for k = 1:floor(num_pixel^2/2)
    initial_checkerboard (k) = 1;
end

for  i = 0 : length(T)/frame_per_board-1
    r = randperm(num_pixel^2);
    for k = 1:num_pixel^2
        checkerboard(k) = initial_checkerboard(r(k));
    end
    for j = 1:frame_per_board
        newXarray(frame_per_board*i+j)  = { checkerboard };
    end
end
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


for kk =1:length(T)
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    
    %square_flicker
    for y = 1 : mea_size_bm
        for x = 1 : mea_size_bm
            if newXarray{kk}(ceil(y*num_pixel/mea_size_bm),ceil(x*num_pixel/mea_size_bm)) ==1
                cal_x = dotPositionMatrix{y,x}(1);
                cal_y = dotPositionMatrix{y,x}(2);
                cal_lum = screen_brightness(y,x);
                a(cal_y,cal_x) = cal_lum;
            end
        end
    end
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
save([name,'.mat'],'newXarray')
    
cd(makemovie_folder);
end
