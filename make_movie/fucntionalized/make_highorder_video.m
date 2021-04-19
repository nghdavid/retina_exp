function make_highorder_video(makemovie_folder, theta, video_folder, videoworkspace_folder,type,date,calibration_date,mean_lumin,contrast,img_array)
directions = {'RL','UR_DL','UD','UL_DR'};
direction = directions{floor(theta*4/pi)+1};
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
rotation = theta*4/pi;
fps=60;  %freq of the screen flipping
dt=1/fps; %second
Time = (1:length(img_array))*dt;

%% Video setting
name = [date,'_',type,'_',direction,'_',num2str(mean_lumin),'mW_',num2str(contrast)];
video_fps=fps;
writerObj = VideoWriter([video_folder,name,'.avi']);  %change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);
%% Start part: adaptation
img=zeros(screen_y,screen_x);
for mm=1:fps*20
    writeVideo(writerObj,img);
end
monitor_mean_lumin = interp1(real_lum,lum,mean_lumin,'linear');
background_mean_lumin = interp1(real_lum,lum,mean_lumin*(1-contrast),'linear');
img_array = img_array*monitor_mean_lumin;
img_array(img_array==0) = background_mean_lumin;
%% Draw matrix
for kk =1:length(Time)
    a = transform_matrix(calibration_date,img_array(kk,:),rotation*45);
    %% Square_flicker
    if mod(kk,3)==1 %odd number
        a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=1; % white square
    elseif mod(kk,3)==2
        a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
    else
        a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0; % dark
    end
    writeVideo(writerObj,a);
end
%% End part video for detection of ending
img=zeros(screen_y,screen_x);
img(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
for mm=1:10
    writeVideo(writerObj,img);
end
img=zeros(screen_y,screen_x);
writeVideo(writerObj,img);
close(writerObj);
end