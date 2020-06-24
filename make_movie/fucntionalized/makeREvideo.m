function makeREvideo(makemovie_folder, theta, direction, video_folder, videoworkspace_folder,type,date,calibration_date,mean_lumin,speed,reverse)
%type is '1st' or '2nd'
%speed is moving bar velocity(mm/s)
%revesal represent change direction or not. 0 is not change, 1 is change.
%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
%% Moving setting
real_distance = (rightx_bar-leftx_bar-bar_wid*2)*micro_per_pixel/1000;%mm
deltaT = real_distance/speed;%moving time(left to right time)
rest_T = 10;%Interval between each trial
num_trial = 12;
fps =60;%freq of the screen flipping
pre_exist = 4;%Time that bar stay still before moving
post_exist = 2;%Time that bar stay still after moving
T=(rest_T+pre_exist+post_exist+2*deltaT)*1;%Total time(second)
dt=1/fps;
T=dt:dt:T;

%% Load matrix
rotation = theta*4/pi;
if strcmp(type,'2nd')
    matrix_folder = ['C:\',calibration_date,'2ndBar_matrix_',num2str(mean_lumin),'mW\'];
    if exist([matrix_folder '\',num2str(rotation)]) == 0
        make_2ndbar_matrix(calibration_date,mean_lumin,rotation);
    else
        disp('Already have produced matrix')
    end
elseif strcmp(type,'1st')
    matrix_folder = ['C:\',calibration_date,'Bar_matrix_',num2str(mean_lumin),'mW\'];
    if exist([matrix_folder,num2str(rotation)]) == 0
        make_bar_matrix(calibration_date,mean_lumin,rotation);
    else
        disp('Already have produced matrix')
    end
end

%% Setup trajectory
Xarray = zeros(1,length(T));
Xarray(1,1)=0; % since the mean value of damped eq is zero
if ~reverse
    for i = 1:round(1*(rest_T+pre_exist+post_exist+2*deltaT)*fps)
        if mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps
            Xarray(i) = 0;
        elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps+deltaT*fps
            Xarray(i) = (mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps)-pre_exist*fps)/(deltaT*fps);
        elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps+2*deltaT*fps
            Xarray(i) = 1-(mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps)-(pre_exist+deltaT)*fps)/(deltaT*fps);
        elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < (pre_exist+post_exist)*fps+2*deltaT*fps
            Xarray(i) = 0;
        else
            Xarray(i) = -2;
        end
    end
else
    for i = 1:round(1*(rest_T+pre_exist+post_exist+2*deltaT)*fps)
        if mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps
            Xarray(i) = 1;
        elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps+deltaT*fps
            Xarray(i) = 1-(mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps)-pre_exist*fps)/(deltaT*fps);
        elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps+2*deltaT*fps
            Xarray(i) = (mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps)-(pre_exist+deltaT)*fps)/(deltaT*fps);
        elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < (pre_exist+post_exist)*fps+2*deltaT*fps
            Xarray(i) = 1;
        else
            Xarray(i) = -2;
        end
    end
end
Xarray1 = repmat(Xarray,1,num_trial);

%% Normalize to proper moving range
max_x = floor(rightx_bar-bar_wid);
min_x = ceil(leftx_bar+bar_wid);
for i = 1:length(Xarray1)
    if Xarray1(i) >= 0
        newXarray(i)= ceil(Xarray1(i)*(max_x-min_x)+min_x);
    else
        newXarray(i) = -1;
    end
end
newXarray(end) = -1;
if mod(length(newXarray),3) == 1
   newXarray(end) = []; 
elseif mod(length(newXarray),3) == 2
   newXarray = [newXarray,-1]; 
end
%% Video name
if ~reverse
name=[date,'_',type,'_Reversal_moving_',direction,'_',num2str(speed) ,'mm_Q100'];
else
    if strcmp(direction,'RL') || strcmp(direction,'UD')
        direction = flip(direction);
        name=[date,'_',type,'_Reversal_moving_',direction,'_',num2str(speed),'mm_Q100'];
    else
        direction = [direction(4:5),'_',direction(1:2)];
        name=[date,'_',type,'_Reversal_moving_',direction,'_',num2str(speed) ,'mm_Q100'];
    end
end
name

cd (video_folder)
%% Video setting
video_fps=fps;
writerObj = VideoWriter([name,'.avi']);  %change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);

%% Start part:dark adaptation

for mm=1:fps*10
    img=zeros(1024,1280);
    writeVideo(writerObj,img);
end

%% Draw moving bar
for kk =1:length(newXarray)
    cd(makemovie_folder)
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    if newXarray(kk)>-1%mod(kk , fps*(rest_T+pre_exist+post_exist+2*deltaT))<(pre_exist+post_exist+2*deltaT)*fps && kk<length(T)
        X=newXarray(kk);
        load([matrix_folder,num2str(theta*4/pi),'\',num2str(X),'.mat']);% Load picture matrix
    end
    if mod(kk,3)==1 %odd number
        a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=1; % white square
    elseif mod(kk,3)==2
        a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
    else
        a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0; % dark
    end
    writeVideo(writerObj,a);
end

%% End part video
for mm=1:10
    img=zeros(screen_y,screen_x);
    img(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
    writeVideo(writerObj,img);
end
img=zeros(screen_y,screen_x);
writeVideo(writerObj,img);
close(writerObj);

cd(videoworkspace_folder)
save([name,'.mat'],'newXarray','direction','theta','type','speed','reverse')
cd(makemovie_folder)
end