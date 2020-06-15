function makeREvideo(makemovie_folder, theta, direction, video_folder, videoworkspace_folder,date,calibration_date,mean_lumin,deltaT)

%% ON OFF

%moving times.
rest_T = 10;
num_trial = 1;
fps =60;%freq of the screen flipping
pre_exist = 2;
post_exist = 2;
T=(rest_T+pre_exist+post_exist+2*deltaT)*num_trial; %second
dt=1/fps;
T=dt:dt:T;

%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
rotation = theta*4/pi;
% matrix_folder = ['C:\',calibration_date,'2ndBar_matrix_',num2str(mean_lumin),'mW\'];
% if exist([matrix_folder '\',num2str(rotation)]) == 0
%     make_2ndbar_matrix(calibration_date,mean_lumin,rotation);
% else
%     disp('Already have produced matrix')
% end
matrix_folder = ['C:\',calibration_date,'Bar_matrix_',num2str(mean_lumin),'mW\'];
if exist([matrix_folder,num2str(rotation)]) == 0
    make_bar_matrix(calibration_date,mean_lumin,rotation);
else
    disp('Already have produced matrix')
end
Xarray = zeros(1,length(T));
Xarray(1,1)=0; % since the mean value of damped eq is zero
%Use rntest(t)!!!

for i = 1:round(num_trial*(rest_T+pre_exist+post_exist+2*deltaT)*fps)
    if mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps
        Xarray(i) = 0;
    elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps+deltaT*fps
        Xarray(i) = (mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps)-pre_exist*fps)/(deltaT*fps) ;
    elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < pre_exist*fps+2*deltaT*fps
        Xarray(i) = 1- (mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps)-(pre_exist+deltaT)*fps)/(deltaT*fps) ;
    elseif mod(i , (rest_T+pre_exist+post_exist+2*deltaT)*fps) < (pre_exist+post_exist)*fps+2*deltaT*fps
        Xarray(i) = 0;
    else
        Xarray(i) = -2;
    end
end

max(Xarray)
% Normalize to proper moving range
max_x = floor(rightx_bar-bar_wid)
min_x = ceil(leftx_bar+bar_wid)
for i = 1:length(Xarray)
    if Xarray(i) >= 0
        newXarray(i)= ceil(Xarray(i)*(max_x-min_x)+min_x);
    else
        newXarray(i) = -1;
    end
end
cd (video_folder)
%video frame file
name=[date,'_Reversal_moving_',direction,'_',num2str(T(end)) ,'s_Q100'];

name

%video setting
Time=T; %sec
video_fps=fps;
writerObj = VideoWriter([name,'.avi']);  %change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);
%start part: dark adaptation
% for mm=1:fps*20
%     img=zeros(1024,1280);
%     writeVideo(writerObj,img);
% end

%%draw moving bar
for kk =1:length(T)
    cd(makemovie_folder)
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    if mod(kk , fps*(rest_T+pre_exist+post_exist+2*deltaT))<(pre_exist+post_exist+2*deltaT)*fps
        X=newXarray(kk);
%         X
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

%end part video
% for mm=1:10
%         img=zeros(screen_y,screen_x);
%         img(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
%         writeVideo(writerObj,img);
% end
img=zeros(screen_y,screen_x);
writeVideo(writerObj,img);
close(writerObj);
cd(videoworkspace_folder)
save([name,'.mat'],'newXarray','direction','theta')

%video setting




cd(makemovie_folder)

end