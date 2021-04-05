function make_Intensity_cSTA_video(makemovie_folder, video_folder, videoworkspace_folder,date,calibration_date,mins,mean_lumin)
%mean_lumin is mean luminance of cSTA
%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
%% video parameter
fps =60;  %freq of the screen flipping
T=mins*60; %second
dt=1/fps;
T=dt:dt:T;
%% cSTA trajectory
Gaussian_noise = mean_lumin*0.3*(randn(1,length(T)));%Gaussian noise with 30% std
newXarray = zeros(1,length(T));
for i=1:2:length(T)
    newXarray(i)=mean_lumin+Gaussian_noise(i);
    newXarray(i+1)=mean_lumin+Gaussian_noise(i);
end
newXarray(newXarray > 1.95*mean_lumin) = 1.95*mean_lumin;
newXarray(newXarray < 0.05*mean_lumin) = 0.05*mean_lumin;
OLEDXarray = interp1(real_lum,lum,newXarray,'linear');
monitor_mean_lumin= interp1(real_lum,lum,mean_lumin,'linear');
cd(video_folder)
%video frame file
name=[date,'_cSTA_wf','_',int2str(mins),'min_Q100'];
name

%video setting
video_fps=fps;
writerObj = VideoWriter([name,'.avi']);  %change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);

%start part: adaptation
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
cd(makemovie_folder)
end
