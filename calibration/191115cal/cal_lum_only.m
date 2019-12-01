dotPositionMatrix=cell(cal_size ,cal_size);
for x = 1:cal_size
    for y = 1:cal_size
        dotPositionMatrix{y, x}= [meaCenter_x-(cal_size+1)/2+x, meaCenter_y-(cal_size+1)/2+y];
    end
end
%% Setup video input
vid = videoinput('gige',1); %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);
set(scr_obj,'GainRaw',20)
set(scr_obj,'ExposureTimeAbs',2000000)%Brightness 50
%set(scr_obj,'ExposureTimeAbs',900000)%Brightness 25
% frame = getsnapshot(vid);
% imshow(frame);
%preview(vid);
Screen('Flip', w);
black_frame = getsnapshot(vid);
%% MEA parameter
cal_size = 529;%Calibration cal_size
baseRect = [0 0 cal_size cal_size]; %use odd number %for bigger mea region % I just think 541 is appropriate

meaCenter_x=714;
meaCenter_y=629;
LED_based_color=256*0.25-1;%Luminance 10mW/m^2
dotbrightnessMatrix = zeros(cal_size,cal_size);%Store brightness of corresponding points on ccd
screen_brightness =ones(cal_size,cal_size)*LED_based_color;%Store brightness of  points on monitor
%% Display dots with same brightness
for i=1:cal_size%x
    for j=1:cal_size %y
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
frame = imgaussfilt(frame - black_frame,1);
%save('0816before_cal_img.mat','frame');
imshow(frame);
for i=1:cal_size%x
    for j=1:cal_size%y
        dotbrightnessMatrix(j,i) = frame(round(ideal_pt{cal_size+1-j,i}(2)),round(ideal_pt{cal_size+1-j,i}(1)));
    end
end
figure;histogram(dotbrightnessMatrix(:))%See the distribution of brightness om ccd
center_color = mean(dotbrightnessMatrix(:));%Find most brightness on ccd
%% Tune the brightness on monitor to let brightness on ccd approach center_color
for num_calibration = 1:10
    %Change screen_brightness
    for i=1:cal_size%x
        for j=1:cal_size%y
            if dotbrightnessMatrix(j,i) > center_color+0.5
                screen_brightness(j,i) = screen_brightness(j,i) + 0.7*(center_color - dotbrightnessMatrix(j,i));
            elseif dotbrightnessMatrix(j,i) < center_color-0.5
                screen_brightness(j,i) = screen_brightness(j,i) + 0.7*(center_color - dotbrightnessMatrix(j,i)); 
            else    
            end
        end
    end
    
    %Project dots on monitor
    for i=1:cal_size%x
        for j=1:cal_size%y
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
    frame = imgaussfilt(frame - black_frame,1);
    
    for i=1:cal_size%x
        for j=1:cal_size%y
            dotbrightnessMatrix(j,i) = frame(round(ideal_pt{cal_size+1-j,i}(2)),round(ideal_pt{cal_size+1-j,i}(1)));
        end
    end
end
save('screen_brightness.mat','screen_brightness');
save('calibrate_pt.mat','dotPositionMatrix');
