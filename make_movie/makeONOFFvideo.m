%% ON OFF
clear all;



all_file = dir('*.mat');

fps =60;  %freq of the screen flipping 
T=5*60; %second
dt=1/fps;
T=dt:dt:T;



      
    
cd ('E:\retina_v\videos\0903_Br_50\ONOFF')
%video frame file
name=['0903 ONOFF 5min Br50 Q100'];
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
    on_time = 2; %s
    off_time = 10; %s
    if mod(kk,fps*(on_time+off_time))<on_time*fps %odd number
        a=ones(1024,1280); % white square
    elseif mod(kk,fps*(on_time+off_time))>on_time*fps
        a=zeros(1024,1280); % dark
    else
        
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