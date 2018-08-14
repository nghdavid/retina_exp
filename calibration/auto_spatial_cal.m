clear all;
close all;
%% Open phychotoolbox
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',1, [0 0 0]); %black background 

%% Setup video input
vid = videoinput('gige',1) %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);
set(scr_obj,'GainRaw',5)
set(scr_obj,'ExposureTimeAbs',9000000)

frame = getsnapshot(vid);
imshow(frame);



%% Set mea parameter
mea_size=433; %use odd number!
cal_size = 529;%number of channels for one side, should be an odd number
N = 23;%
baseRect = [0 0 mea_size mea_size];  %use odd number!
centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);
meaCenter_x=631; 
meaCenter_y=572; 

%% start calculating the x,y coordination of each dots
x_array=[]; y_array=[];
dotPositionMatrix=cell(cal_size ,cal_size);%Matrix that stores the position of calibrated dot
for i=0:cal_size-1
    x_array(1,i+1)= meaCenter_x - (cal_size-1)/2 + i;  %start from the lefttest x position
end
for i=0:cal_size-1
    y_array(1,i+1)=meaCenter_y - (cal_size-1)/2 + i;
end

%% Load ideal_pt
load('ideal_pt.mat')

%% Axis of each variable 
%point0 (1 is x,2 is y) same x together
%new_point (1 is x,2 is y) same x together
%ideal_point (1 is x,2 is y) same x together
%detect_pt (1 is x,2 is y) same x together
%min_point (1 is x,2 is y) same x together
%dotPositionMatrix (Cell array 1 is y, 2 is x) but stores (1 is x,2 is y)
%ideal_pt (Cell array 1 is y, 2 is x) but stores (1 is x,2 is y)
tic
%Show N dots at one time and keep moving
for i = 1:cal_size/N%x coordination 
    for j = 1:cal_size/N%y coordination
        
        
        min = ones(N,N)*10000000;% Store mininum distance between ideal_point and detect_point
        min_point = cell(N,N);% Store mininum coordinate on monitor
        
        point0=zeros(2,N^2);%Store initial points on monitor
        for q = 0:N-1%x
            for a = 1:N%y
                point0(1,a+q*N) = x_array(q*cal_size/N+i);
                point0(2,a+q*N) = y_array((a-1)*cal_size/N+j);
            end
        end
        new_point = point0;% Store changing coordinate on monitor

            
        
        ideal_point = zeros(2,N^2);%Store the ideal position of each points on monitor
        for q = 0:N-1%x
            for a = 1:N%y
                ideal_point(1,a+q*N) = ideal_pt{cal_size-((a-1)*cal_size/N+j-1),cal_size-(q*cal_size/N+i-1)}(1);
                ideal_point(2,a+q*N) = ideal_pt{cal_size-((a-1)*cal_size/N+j-1),cal_size-(q*cal_size/N+i-1)}(2);  
            end
        end
        
        
        for num_calibration = 1:10%Run many times of calibration and choose best one
            
            
            for k = 1:N^2%Show N^2 points on monitor
                baseRect = [0 0 1 1];  % one pixel
                centeredRect = CenterRectOnPointd(baseRect, round(new_point(1,k)), round(new_point(2,k)));
                Screen('FillRect', w, 255, centeredRect);
            end
            Screen('Flip', w);
    
            img = getsnapshot(vid);
            sensitivity = 0.95;%Sensitivity of detecting coordinate of each dot
            radius_range = [2 4];%Range that detect circle(dot in ccd)
            detect_pt = find_detect_pt(img,N,sensitivity,radius_range,'off',ideal_point);%'on' means show figure 'off' means don't show
            
            %Change N point coordinate
            for k = 1:N^2
               ideal_x = ideal_point(1,k);
               ideal_y = ideal_point(2,k);
               detect_x = detect_pt(1,k);
               detect_y = detect_pt(2,k);
               %Change x
               if ideal_x > detect_x%if detect_point is too left 
                   new_point(1,v) = new_point(1,k) +1 ;%then move right on monitor
                   %new_point(1,v)= new_point(1,k) + round((ideal_x -detect_x)/ideal_distance_pt);
               elseif ideal_x < detect_x%if detect_point is too right
                   new_point(1,v) = new_point(1,k) -1 ;%round((ideal_x - detect_x)/ideal_distance_pt) ;%then move left on monitor
               else
               end
               %Change y(Remember to change upside down)
               if ideal_y > detect_y%if detect_point is too up
                   new_point(2,v) = new_point(2,k) -1;%+ round((ideal_y - detect_y)/ideal_distance_pt) ;%then move down on monitor
               elseif ideal_y < detect_y%if detect_point is too up
                   new_point(2,v) = new_point(2,k) + 1;%round((ideal_y - detect_y)/ideal_distance_pt) ;%then move up on monitor
               else
               end
            end
        
            %Calculate distance between ideal_point and detect_point
            distances = zeros(1,N^2);
            for k = 1:N^2
                distances(k) = norm(detect_pt(:,1)-ideal_point(:,k));
            end
            %Compare whether it is smallest
            for k = 1:N^2
                if distances(k) < min(k)
                    min(k) = distances(k);
                    min_point{:,k} = new_point(:,k);
                end

            end
        
        
        end
        
        %Save minimum position on monitor
        for q = 0:N-1%x
            for a = 1:N%y
                dotPositionMatrix{(a-1)*cal_size/N+j,q*cal_size/N+i} = min_point(:,a+q*N); 
            end
        end
        
        
        
    end
end

toc
save('calibirate_pt.mat','dotPositionMatrix')