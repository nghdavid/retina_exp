close all;
%% decide mea size and center on LED screen
mea_size=529;%461; %use odd number!
% mea_size = 493;
%small_mea_size= 73;
cal_size = 529;%number of channels for one side, should be an odd number
N = 7;%
baseRect = [0 0 mea_size mea_size];  %use odd number!

meaCenter_x=709;
meaCenter_y=629;
centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);
brightness = 1;
Screen('FillRect', w, brightness*255, centeredRect);
Screen('Flip', w);
frame = getsnapshot(vid);
imshow(frame);
%% decide mea coner on LED screen
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
dotColors=[255];
for i = [-1 1]
    for j = [-1 1]
        baseRect = [0 0 1 1];  % one pixel
        xCenter=meaCenter_x-i*cal_size/2; %determine the x coordination on monitor for this point
        yCenter=meaCenter_y-j*cal_size/2;
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        Screen('FillRect', w, dotColors, centeredRect);
    end
end
Screen('Flip', w);
frame = getsnapshot(vid);
imshow(frame-black_frame-black_frame_2);

detect_point = find_detect_pt(frame-black_frame-black_frame_2,2,0.9,[1 4],'on');
% ccd_pt_dis = 0;
% ccd_pt_dis = ccd_pt_dis + sqrt((detect_point(1,1)-detect_point(1,2))^2+(detect_point(2,1)-detect_point(2,2))^2)/4;
% ccd_pt_dis = ccd_pt_dis + sqrt((detect_point(1,1)-detect_point(1,3))^2+(detect_point(2,1)-detect_point(2,3))^2)/4;
% ccd_pt_dis = ccd_pt_dis + sqrt((detect_point(1,2)-detect_point(1,4))^2+(detect_point(2,2)-detect_point(2,4))^2)/4;
% ccd_pt_dis = ccd_pt_dis + sqrt((detect_point(1,3)-detect_point(1,4))^2+(detect_point(2,3)-detect_point(2,4))^2)/4;
% ccd_pt_dis = ccd_pt_dis/cal_size;
ccd_center = [mean(detect_point(1,:)) mean(detect_point(2,:))];
ccd_pt_dis_x = (-(detect_point(1,1)-detect_point(1,3))-(detect_point(1,2)-detect_point(1,4)))/2/cal_size;
ccd_pt_dis_y = -(-(detect_point(2,1)-detect_point(2,2))-(detect_point(2,3)-detect_point(2,4)))/2/cal_size;
ideal_pt = cell(cal_size);
for i = -(cal_size-1)/2:(cal_size-1)/2
    for j = -(cal_size-1)/2:(cal_size-1)/2
        ideal_pt{i+(cal_size+1)/2,j+(cal_size+1)/2} = ccd_center + [ccd_pt_dis_x*i ccd_pt_dis_y*j];
    end
end
