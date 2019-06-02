function makeDark_REvideo(makemovie_folder, theta, direction, video_folder, videoworkspace_folder, date, deltaT)

%% ON OFF

%moving times.
%deltaT = 2.4; %s

rest_T = 10;
fps =60;  %freq of the screen flipping
T=(rest_T+2+2*deltaT)*12; %second
dt=1/fps;
T=dt:dt:T;

load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;
R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];


all_file = dir('*.mat');


Xarray = zeros(1,length(T));
Xarray(1,1)=0; % since the mean value of damped eq is zero
%Use rntest(t)!!!

for i = 1:round(12*(rest_T+2+2*deltaT)*fps)
    if mod(i , (rest_T+2+2*deltaT)*fps) < 1*fps
        Xarray(i) = 0;
    elseif mod(i , (rest_T+2+2*deltaT)*fps) < 1*fps+deltaT*fps
        Xarray(i) = (mod(i , (rest_T+2+2*deltaT)*fps)-1*fps)/(deltaT*fps) ;
    elseif mod(i , (rest_T+2+2*deltaT)*fps) < 1*fps+2*deltaT*fps
        Xarray(i) = 1- (mod(i , (rest_T+2+2*deltaT)*fps)-(1+deltaT)*fps)/(deltaT*fps) ;
    elseif mod(i , (rest_T+2+2*deltaT)*fps) < 2*fps+2*deltaT*fps
        Xarray(i) = 0;
    else
        Xarray(i) = -2;
    end
end


% Normalize to proper moving range
max_x = floor(rightx_bar-re_bar_wid);
min_x = ceil(leftx_bar+re_bar_wid);
for i = 1:length(Xarray)
    if Xarray(i) >= 0
        newXarray(i)= Xarray(i)*(max_x-min_x)+min_x;
    else
        newXarray(i) = -1;
    end
end
Y =meaCenter_y;
cd (video_folder)
%video frame file
name=[date,'Dark_Reversal_moving_',direction,'_',num2str(T(end)) ,'s_Br50_Q100'];

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
for kk =1:length(T)
    
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    
    for y = 1 : length(screen_brightness)
        for x = 1 : length(screen_brightness)
            cal_x = dotPositionMatrix{y,x}(1);
            cal_y = dotPositionMatrix{y,x}(2);
            cal_lum = screen_brightness(y,x);
            a(cal_y,cal_x) = cal_lum;
        end
    end
    
    if mod(kk , fps*(rest_T+2+2*deltaT))<(2+2*deltaT)*fps
        X=newXarray(kk);
        barX=X-round(leftx_bd);
        barY=round(Y)-round(lefty_bd);
        
        Vertex = cell(4);
        Vertex{1} = [barX-re_bar_wid  barY-bar_le];  %V1  V4
        Vertex{2} = [barX-re_bar_wid  barY+bar_le];  %V2  V3
        Vertex{3} = [barX+re_bar_wid  barY+bar_le];
        Vertex{4} = [barX+re_bar_wid  barY-bar_le];
        %ratation
        for i = 1:4
            Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
        end
        
        if theta == 0 || theta == pi/2  % vertical case
            for y = round(Vertex{1}(2)) : round(Vertex{3}(2))
                for x = round(Vertex{2}(1)):round(Vertex{4}(1))
                    cal_x = dotPositionMatrix{y,x}(1);
                    cal_y = dotPositionMatrix{y,x}(2);
                    a(cal_y,cal_x) = 0;
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
            %stupid way
            %         for y = 1:mea_size_bm %floor(Vertex{1}(2)) : ceil(Vertex{3}(2))
            %             for x = 1:mea_size_bm %floor(Vertex{2}(2)) : ceil(Vertex{4}(2))
            %                 if (y-Vertex{1}(2)) - (Vertex{1}(1)-Vertex{2}(1))/(Vertex{1}(2)-Vertex{2}(2)) * (x-Vertex{1}(2)) >= 0 && (y-Vertex{4}(2)) - (Vertex{4}(1)-Vertex{3}(1))/(Vertex{4}(2)-Vertex{3}(2)) * (x-Vertex{4}(2)) <= 0
            %                     if (y-Vertex{1}(2)) - (Vertex{1}(1)-Vertex{4}(1))/(Vertex{1}(2)-Vertex{4}(2)) * (x-Vertex{1}(2)) >= 0 && (y-Vertex{2}(2)) - (Vertex{2}(1)-Vertex{3}(1))/(Vertex{2}(2)-Vertex{3}(2)) * (x-Vertex{2}(2)) <= 0
            %                         cal_x = dotPositionMatrix{y,x}(1);
            %                         cal_y = dotPositionMatrix{y,x}(2);
            %                         cal_lum = screen_brightness(y,x);
            %                         a(cal_y,cal_x) = cal_lum;
            %                     end
            %                 end
            %             end
            %         end
            
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
                    a(cal_y,cal_x) = 0;
                end
            end
        end

%         a=zeros(1024,1280); % dark
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
save([date,'Dark_Reversal_moving_',direction,'_',num2str(T(end)) ,'s_Br50_Q100.mat'],'newXarray')


%video setting




cd(makemovie_folder)

end