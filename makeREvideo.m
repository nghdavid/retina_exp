%% ON OFF
clear all;

mea_size=433;
mea_size_bm=465; %bigger mea size , from luminance calibrated region
meaCenter_x=631; 
meaCenter_y=580; 

%moving times.
deltaT = 0.7; %s

leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
bar_le=floor((mea_size_bm-1)/2/sqrt(2)); %half of bar length / pixel number on LCD /total length = mea_size = 1919 um
bar_wid=11; %half of bar width / total length = 11*2+1=23 pixels = 65 um
%R-L
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar

fps =60;  %freq of the screen flipping 
T=(7+2*deltaT)*12; %second
dt=1/fps;
T=dt:dt:T;

load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;

%%rotation theta = 0 for RL theta
%theta must between [0,pi)
theta =0;
R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];

all_file = dir('*.mat');


Xarray = zeros(1,length(T));
Xarray(1,1)=0; % since the mean value of damped eq is zero
%Use rntest(t)!!!
for tr = 0:11
    for t0 = 1 : 1*fps 
        Xarray(tr*(7+2*deltaT)+t0) = 0;
    end
    for t1 = 1 : deltaT*fps 
        Xarray(tr*(7+2*deltaT)+t0+t1) = t1/deltaT*fps ;
    end
    for t2 = 1 : deltaT*fps 
        Xarray(tr*(7+2*deltaT)+t0+t1+t2) = 1-t2/deltaT*fps ;
    end
    for t3 = 1 : 6*fps
        Xarray(tr*(7+2*deltaT)+t0+t1+t2+t3) = 0;
    end
end


% Normalize to proper moving range
nrx=abs((rightx_bar-leftx_bar-2*bar_wid)/(max(Xarray)-min(Xarray)));
Xarray2=Xarray*nrx;
Xarray3=Xarray2+leftx_bar+bar_wid-min(Xarray2);%rearrange the boundary values
newXarray=round(Xarray3);
Y =meaCenter_y;
cd ('E:\retina_v\videos\0903_Br_50\Reversal_moving')
%video frame file
name=['0903 Reversal_moving 5min Br50 Q100'];
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
        
        X=newXarray(kk+1);
        barX=X-round(leftx_bd);
        barY=round(Y)-round(lefty_bd);
        
        Vertex = cell(4);
        Vertex{1} = [barX-bar_wid  barY-bar_le];  %V1  V4
        Vertex{2} = [barX-bar_wid  barY+bar_le];  %V2  V3
        Vertex{3} = [barX+bar_wid  barY+bar_le];
        Vertex{4} = [barX+bar_wid  barY-bar_le];
        %ratation
        for i = 1:4
            Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
        end
        
        if theta == 0 || theta == pi/2  % vertical case
            for y = round(Vertex{1}(2)) : round(Vertex{3}(2))
                for x = round(Vertex{2}(1)):round(Vertex{4}(1))
                    cal_x = dotPositionMatrix{y,x}(1);
                    cal_y = dotPositionMatrix{y,x}(2);
                    cal_lum = screen_brightness(y,x);
                    a(cal_y,cal_x) = cal_lum;
                end
            end
            
        else
            if theta > pi/2
                newVertex = Vertex{1};
                for i = 1:3
                    Vertex{i} = Vertex{i+1};
                end
                Vertex{4} = newVertex;
            end

            
            %better way
            %pervent out of rnage
            if Vertex{2}(1) < 1
                min_x = 1;
            else
                min_x = Vertex{2}(1);
            end
            if Vertex{4}(1) > mea_size_bm
                max_x = mea_size_bm;
            else
                max_x = Vertex{4}(1);
            end
            
            for x = floor(min_x) : ceil(max_x)
                % find bar region
                if x < Vertex{1}(1)
                    lower_y = Vertex{1}(2) + (Vertex{1}(2)-Vertex{2}(2))/(Vertex{1}(1)-Vertex{2}(1)) * (x-Vertex{1}(1));
                else
                    lower_y = Vertex{1}(2) + (Vertex{1}(2)-Vertex{4}(2))/(Vertex{1}(1)-Vertex{4}(1)) * (x-Vertex{1}(1));
                end
                if x < Vertex{3}(1)
                    upper_y = Vertex{3}(2) + (Vertex{3}(2)-Vertex{2}(2))/(Vertex{3}(1)-Vertex{2}(1)) * (x-Vertex{3}(1));
                else
                    upper_y = Vertex{3}(2) + (Vertex{3}(2)-Vertex{4}(2))/(Vertex{3}(1)-Vertex{4}(1)) * (x-Vertex{3}(1));
                end
                
                %pervent out of rnage
                if lower_y < 1
                    lower_y = 1;
                end
                if upper_y > mea_size_bm
                    upper_y = mea_size_bm;
                end
                
                for y = floor(lower_y) : ceil(upper_y)
                    cal_x = dotPositionMatrix{y,x}(1);
                    cal_y = dotPositionMatrix{y,x}(2);
                    cal_lum = screen_brightness(y,x);
                    a(cal_y,cal_x) = cal_lum;
                end
            end
            
    else 
        a=zeros(1024,1280); % dark
    end

    
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

    
    
    
%video setting




cd('E:\retina\videos\0903_ONOFF_video_Br_50')