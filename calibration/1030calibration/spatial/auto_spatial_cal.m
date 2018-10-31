clear all;
close all;
%% Open phychotoolbox
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',2, [0 0 0]); %black background 

%% Setup video input
vid = videoinput('gige',1); %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);
set(scr_obj,'GainRaw',20)
set(scr_obj,'ExposureTimeAbs',6000000)

Screen('Flip', w);
black_frame = getsnapshot(vid);
figure;
imshow(black_frame);


%% Set mea parameter
mea_size=433; %Mea size
cal_size = 465;%number of dots for one side, should be an odd number
N = 31;%Number of dots each time of calibration
baseRect = [0 0 mea_size mea_size];  %use odd number!
meaCenter_x=632;
meaCenter_y=570;
centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);

%% start calculating the x,y coordination of each dots
x_array=[]; y_array=[];
dotPositionMatrix=cell(cal_size ,cal_size);%Matrix that stores the position of calibrated dot
for i=0:cal_size-1
    x_array(1,i+1) = meaCenter_x - (cal_size-1)/2 + i;  %start from the lefttest x position
end
for i=0:cal_size-1
    y_array(1,i+1) = meaCenter_y - (cal_size-1)/2 + i;
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

%Show N^2 dots at one time and keep moving
for i = 2:cal_size/N%x coordination 
    for j = 1:cal_size/N%y coordination
        
        min = ones(N,N)*10000000;% Store mininum distance between ideal_point and detect_point
        min_point = zeros(2,N^2);% Store mininum coordinate on monitor
        
        point0=zeros(2,N^2);%Store initial points on monitor
        for q = 0:N-1%x
            for a = 1:N%y
                point0(1,a+q*N) = x_array(q*cal_size/N+i);
                point0(2,a+q*N) = y_array((a-1)*cal_size/N+j);
            end
        end
        new_point = point0;% Store changing coordinate on monito
        
        ideal_point = zeros(2,N^2);%Store the ideal position of each points on monitor
        for q = 0:N-1%x
            for a = 1:N%y
                ideal_point(1,a+q*N) = ideal_pt{cal_size+1-((a-1)*cal_size/N+j),(q*cal_size/N+i)}(1);
                ideal_point(2,a+q*N) = ideal_pt{cal_size+1-((a-1)*cal_size/N+j),(q*cal_size/N+i)}(2);  
            end
        end
                
        for num_calibration = 1:3%Run many times of calibration and choose best one
            
            %num_calibration
            for k = 1:N^2%Show N^2 points on monitor
                baseRect = [0 0 1 1]; % one pixel
                centeredRect = CenterRectOnPointd(baseRect, round(new_point(1,k)), round(new_point(2,k)));
                Screen('FillRect', w, 255, centeredRect);
            end
            Screen('Flip', w);
    
            img = getsnapshot(vid);
            if i < 7 && i > 9%Because marginal of ccd is darker, so use higher sensitivity
                sensitivity = 0.95;%Sensitivity of detecting coordinate of each dot
            else
                sensitivity = 0.92;
            end
            radius_range = [1 6];%Range that detect circle(dot in ccd)
            detect_pt = find_detect_pt(img-black_frame,N,sensitivity,radius_range,'off',ideal_point);%'on' means show figure 'off' means don't show
            %img-black_frame is to clear noise on ccd
            %Change N point coordinate
            for k = 1:N^2
               ideal_x = ideal_point(1,k);
               ideal_y = ideal_point(2,k);
               detect_x = detect_pt(1,k);
               detect_y = detect_pt(2,k);
               %Change x
               new_point(1,k) = new_point(1,k) + round((ideal_x - detect_x)/ideal_distance_pt(1));
               %Change y(Remember to change upside down)
               new_point(2,k) = new_point(2,k) - round((ideal_y - detect_y)/ideal_distance_pt(2));
            end
        
            %Calculate distance between ideal_point and detect_point
            distances = zeros(1,N^2);
            for k = 1:N^2
                distances(k) = norm(detect_pt(:,k)-ideal_point(:,k));
            end
            %Compare whether it is smallest
            for k = 1:N^2
                if distances(k) < min(k)
                    min(k) = distances(k);
                    min_point(:,k) = new_point(:,k);
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

save('calibrate_pt.mat','dotPositionMatrix');
