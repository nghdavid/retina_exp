function oled_checkerboard(makemovie_folder,video_folder, videoworkspace_folder,refresh_fps,num_pixel,date,mins,calibration_date,bright_lum)
% refresh_fps is checkerboard fps
% num_pixel is how big each square in checkerboard is
% bright_lum is luminance that bright square it has
%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
monitor_mean_lumin = interp1(real_lum,lum,bright_lum/2,'linear');
%% Checkerboard setting
fps =60;  %freq of the screen flipping
frame_per_board = fps/refresh_fps;
T=mins*60; %second
dt=1/fps;
T=dt:dt:T;
cd(makemovie_folder);

cd (video_folder);
%% Video name
name=[date,'_Checkerboard_',int2str(refresh_fps),'Hz_',int2str(num_pixel),'_',int2str(mins),'min_Br50_Q100'];
name
%% Generate checkerboard
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
        newXarray(frame_per_board*i+j)  = {checkerboard};
    end
end
monitor_bright_lumin= interp1(real_lum,lum,bright_lum,'linear');

%% video setting
video_fps=fps;
writerObj = VideoWriter([name,'.avi']);  %change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);

%% start part: adaptation
img=zeros(screen_y,screen_x); 
img(lefty_bd:righty_bd,leftx_bd:rightx_bd) = monitor_mean_lumin;
for mm=1:fps*20
    writeVideo(writerObj,img);
end

%% Write checkerboard
for kk =1:length(T)
    a=zeros(screen_y,screen_x);%full screen pixel matrix %it's the LED screen size
    %square_flicker
    for y = 1 : mea_size_bm
        for x = 1 : mea_size_bm
            if newXarray{kk}(ceil(y*num_pixel/mea_size_bm),ceil(x*num_pixel/mea_size_bm)) ==1
                a(y+lefty_bd-1,x+leftx_bd-1) = monitor_bright_lumin;
            end
        end
    end
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

%% end part video
for mm=1:10
    img=zeros(screen_y,screen_x);
    img(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
    writeVideo(writerObj,img);
end

img=zeros(screen_y,screen_x);
writeVideo(writerObj,img);
close(writerObj);
cd(videoworkspace_folder)
%save parameters needed
save([name,'.mat'],'newXarray')
    
cd(makemovie_folder);
end
