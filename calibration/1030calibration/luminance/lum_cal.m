%% initiate the PTB
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',1, [0 0 0]); %black background

load('calibrate_pt.mat');%It load dotPositionMatrix
load('ideal_pt.mat');%It load ideal_pt and ideal_distance_pt

%% Setup video input
vid = videoinput('gige',1); %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);
set(scr_obj,'GainRaw',0)
set(scr_obj,'ExposureTimeAbs',800000)%Brightness 50
%set(scr_obj,'ExposureTimeAbs',900000)%Brightness 25
% frame = getsnapshot(vid);
% imshow(frame);
%preview(vid);

%% MEA parameter
width = 465;%Calibration width
baseRect = [0 0 width width]; %use odd number %for bigger mea region % I just think 541 is appropriate
meaCenter_x=631;
meaCenter_y=580;%%%%%%%%%%%%%%%%Remember to check
LED_based_color=180;%Luminance 50
dotbrightnessMatrix = zeros(width,width);%Store brightness of corresponding points on ccd
screen_brightness =ones(width,width)*LED_based_color;%Store brightness of  points on monitor

%frame is (y,x)
%ideal_pt (Cell array 1 is y, 2 is x) but stores (1 is x,2 is y)
%dotbrightnessMatrix is (y,x)
%screen_brightness  is (y,x)
%% Display dots with same brightness
for i=1:width%x
    for j=1:width %y
        baseRect = [0 0 1 1];  % one pixel
        xCenter=dotPositionMatrix{j,i}(1); %determine the x coordination on monitor for this point
        yCenter=dotPositionMatrix{j,i}(2);
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        Screen('FillRect', w, screen_brightness(j,i), centeredRect);
    end
end
Screen('Flip', w);
%% Take photo and find corresponding brightness on ccd
frame = getsnapshot(vid);
frame = frame - black_frame;
%save('0816before_cal_img.mat','frame');
imshow(frame);
for i=1:width%x
    for j=1:width%y
        dotbrightnessMatrix(j,i) = frame(round(ideal_pt{width+1-j,i}(2)),round(ideal_pt{width+1-j,i}(1)));
    end
end
figure;histogram(dotbrightnessMatrix(:))%See the distribution of brightness om ccd
center_color = mode(dotbrightnessMatrix(:));%Find most brightness on ccd

%% Tune the brightness on monitor to let brightness on ccd approach center_color
for num_calibration = 1:10
    %Change screen_brightness
    for i=1:width%x
        for j=1:width%y
            if dotbrightnessMatrix(j,i) > center_color+0.5
                screen_brightness(j,i) = screen_brightness(j,i) + (center_color - dotbrightnessMatrix(j,i));
            elseif dotbrightnessMatrix(j,i) < center_color-0.5
                screen_brightness(j,i) = screen_brightness(j,i) + (center_color - dotbrightnessMatrix(j,i)); 
            else    
            end
        end
    end
    
    %Project dots on monitor
    for i=1:width%x
        for j=1:width%y
            baseRect = [0 0 1 1];  % one pixel
            xCenter=dotPositionMatrix{j,i}(1); %determine the x coordination on monitor for this point
            yCenter=dotPositionMatrix{j,i}(2);
            centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
            Screen('FillRect', w, screen_brightness(j,i), centeredRect);
        end
    end
    Screen('Flip', w);

    %Detect brightness
    frame = getsnapshot(vid);
    frame = frame - black_frame;
    for i=1:width%x
        for j=1:width%y
        dotbrightnessMatrix(j,i) = frame(round(ideal_pt{width+1-j,i}(2)),round(ideal_pt{width+1-j,i}(1)));
        end
    end
end
    
 
for i=1:width%x
        for j=1:width%y
            baseRect = [0 0 1 1];  % one pixel
            xCenter=dotPositionMatrix{j,i}(1); %determine the x coordination on monitor for this point
            yCenter=dotPositionMatrix{j,i}(2);
            centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
            Screen('FillRect', w, screen_brightness(j,i), centeredRect);
        end
end
Screen('Flip', w);

%%Check whether it is succesfully calibrated
frame = getsnapshot(vid);
imshow(frame)
%save('0816after_cal_img.mat','frame');
x1 = max(ideal_pt{1}(1), ideal_pt{width,1}(1));
x2 = min(ideal_pt{end}(1), ideal_pt{1,width}(1));
y1 = max(ideal_pt{1}(2), ideal_pt{1,width}(2));
y2 = min(ideal_pt{end}(2), ideal_pt{width,1}(2));
figure;imshow(frame(y1:y2,x1:x2));
histogram(frame(y1:y2,x1:x2))
%save('screen_brightness.mat','screen_brightness');
%save('0816final_calibration.mat','frame');

