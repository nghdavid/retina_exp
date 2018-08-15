%% initiate the PTB
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',2, [0 0 0]); %black background

load('calibirate_pt.mat');
load('ideal_pt.mat')%It load ideal_pt and ideal_distance_pt
%% Setup video input
vid = videoinput('gige',1) %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);
set(scr_obj,'GainRaw',0)
set(scr_obj,'ExposureTimeAbs',9000000)



%preview(vid);

%% 
[oldmaximumvalue, oldclampcolors, oldapplyToDoubleInputMakeTexture] = Screen('ColorRange', w);
width = 465;
baseRect = [0 0 width width]; %use odd number %for bigger mea region % I just think 541 is appropriate
meaCenter_x=631;
meaCenter_y=572;%%%%%%%%%%%%%%%%Remember to check
LED_based_color=180;%Luminance 50
centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);
Screen('FillRect', w, LED_based_color,centeredRect); 
Screen('Flip', w);

for i=1:width
    for j=1:width 
        baseRect = [0 0 1 1];  % one pixel
        xCenter=dotPositionMatrix{i,j}(1); %determine the x coordination on monitor for this point
        yCenter=dotPositionMatrix{i,j}(2);
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        Screen('FillRect', w, dotColors, centeredRect);
    end
end
Screen('Flip', w);
%% select the calibration region from ccd image
%because from the ccd image, only part of the region correspond to the bigger mea region. Therefore, we just need to calibrate that region
%choose that region in this section
frame = getsnapshot(vid);
imshow(frame);

dotbrightnessMatrix = zeros(width,width);
for i=1:width%x
    for j=1:width%y
        dotbrightnessMatrix(j,i) = frame(ideal_pt{(a-1)*cal_size/N+j,(q*cal_size/N+i)}(1),ideal_pt{(a-1)*cal_size/N+j,(q*cal_size/N+i)}(2))
    end
    
end


% Igray = rgb2gray(A);
% BW2 = edge(Igray,'Prewitt');
% imshow(BW2);


% [x,y] = ginput(1); %catch the edge coordinate
% x1=717; %top left x
% x2=1425; %bottom right x
% y1=669;  %top left y
% y2=1377;  %bottom right y

% 
% figure; imshow(A(y1:y2,x1:x2));
% colorbar

