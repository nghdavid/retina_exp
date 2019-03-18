function makeCirclevideo(makemovie_folder, video_folder, videoworkspace_folder, date)

%% ON OFF

%moving times.
deltaT = 0.7; %s


fps =60;  %freq of the screen flipping 
T=(7+2*deltaT)*12; %second
dt=1/fps;
T=dt:dt:T;

load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;



all_file = dir('*.mat');


Xarray = zeros(1,length(T));
Xarray(1,1)=0; % since the mean value of damped eq is zero
%Use rntest(t)!!!

for i = 1:round(12*(7+2*deltaT)*fps)
    if mod(i , (7+2*deltaT)*fps) < 1*fps
        Xarray(i) = 0;
    elseif mod(i , (7+2*deltaT)*fps) < 1*fps+deltaT*fps
        Xarray(i) = (mod(i , (7+2*deltaT)*fps)-1*fps)/(deltaT*fps) ;
    elseif mod(i , (7+2*deltaT)*fps) < 1*fps+2*deltaT*fps
        Xarray(i) = 1- (mod(i , (7+2*deltaT)*fps)-(1+deltaT)*fps)/(deltaT*fps) ;
    elseif mod(i , (7+2*deltaT)*fps) < 2*fps+2*deltaT*fps
        Xarray(i) = 0;
    else
        Xarray(i) = -2;
    end
end


% Normalize to proper moving range
max_x = floor(mea_size/2);
min_x = max_x/2;

for i = 1:length(Xarray)
    if Xarray(i) >= 0
        newXarray(i)= Xarray(i)*(max_x-min_x)+min_x;
    else
        newXarray(i) = -1;
    end
end
cd (video_folder)
%video frame file
name=[date,'_circle_Br50_Q100'];
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



%%draw moving bar
for kk =0:length(T)-1
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    if mod(kk,fps*(7+2*deltaT))<(2+2*deltaT)*fps 
        R = newXarray(kk+1);
        for x = round(mea_size_bm/2)- ceil(R): round(mea_size_bm/2) + ceil(R)
            for y = round(mea_size_bm/2)- ceil(R):round(mea_size_bm/2) + ceil(R)
                if (x-round(mea_size_bm/2))^2 + (y-round(mea_size_bm/2))^2 <= R^2
                    cal_x = dotPositionMatrix{y,x}(1);
                    cal_y = dotPositionMatrix{y,x}(2);
                    cal_lum = screen_brightness(y,x);
                    a(cal_y,cal_x) = cal_lum;
                end
            end
        end
        
        
    else 
        a=zeros(1024,1280); % dark
    end

    
    

    if mod(kk,3)==1 %odd number
        a(500-35:500+35,1230:1280)=1; % white square
    elseif mod(kk,3)==2
        a(500-35:500+35,1230:1280)=0.2; %gray
    else
        a(500-35:500+35,1230:1280)=0; % dark
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
cd(videoworkspace_folder)
save([date,'_circle_Br50_Q100'],'newXarray')
    
    
    
    
%video setting




cd(makemovie_folder)

end