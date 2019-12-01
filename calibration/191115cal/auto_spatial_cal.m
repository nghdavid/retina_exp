clear all;
close all;
%% Open phychotoolbox
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',1, [0 0 0]); %black background 




%% Set mea parameter
mea_size=461; %Mea size
cal_size = 493;%number of dots for one side, should be an odd number
N = 29;%Number of dots each time of calibration
baseRect = [0 0 mea_size mea_size];  %use odd number!
meaCenter_x=704;
meaCenter_y=620;
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

%% Setup video input
vid = videoinput('gige',1); %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);
set(scr_obj,'GainRaw',27)
set(scr_obj,'ExposureTimeAbs',9000000)

Screen('Flip', w);
black_frame = getsnapshot(vid);
set(scr_obj,'GainRaw',25)
set(scr_obj,'ExposureTimeAbs',8000000)
black_frame_2 = getsnapshot(vid);
figure;
imshow(black_frame+black_frame_2);

%% Axis of each variable 
%point0 (1 is x,2 is y) same x together
%new_point (1 is x,2 is y) same x together
%ideal_point (1 is x,2 is y) same x together
%detect_pt (1 is x,2 is y) same x together
%min_point (1 is x,2 is y) same x together
%dotPositionMatrix (Cell array 1 is y, 2 is x) but stores (1 is x,2 is y)
%ideal_pt (Cell array 1 is y, 2 is x) but stores (1 is x,2 is y)
close all;
set(scr_obj,'GainRaw',27)
set(scr_obj,'ExposureTimeAbs',8000000)
tic

%Show N^2 dots at one time and keep moving
for i = [12]%13:cal_size/N%x coordination 
    for j = 2:3%:cal_size/N%y coordination
        
        [i j]
        min_dis = ones(N,N)*10000000;% Store mininum distance between ideal_point and detect_point
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
            if i>=7 && i<= 9
                sensitivity = 0.92;%Sensitivity of detecting coordinate of each dot
            else
                sensitivity = 0.95;%Sensitivity of detecting coordinate of each dot
            end
            radius_range = [1 6];%Range that detect circle(dot in ccd)
            detect_pt = find_detect_pt(img-1*black_frame-1*black_frame_2, N, sensitivity, radius_range,'off',ideal_point);%'on' means show figure 'off' means don't show
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
                if distances(k) < min_dis(k)
                    min_dis(k) = distances(k);
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
