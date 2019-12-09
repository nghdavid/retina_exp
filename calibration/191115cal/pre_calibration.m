        %% initiate the PTB
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',2, [0 0 0]); %black background


%% test focus plane: see the edge of the black square is clear or not
baseRect = [0 0 2000 2000]; %the size of the rectangle
xCenter=670; %x coordination of the rectangel center
yCenter=460;
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
brightness = 1;
Screen('FillRect', w,  brightness*255,centeredRect); %255 is the luminance value
% Screen('Flip', w);


baseRect = [0 0 150 150];
xCenter=700; 
yCenter=600; 
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
Screen('FillRect', w, 0, centeredRect);
Screen('Flip', w);


%% decide mea region on LED screen
mea_size=461; %use odd number!
% mea_size = 493;
%small_mea_size= 73;
cal_size = 493;%number of channels for one side, should be an odd number
N = 7;%
baseRect = [0 0 mea_size mea_size];  %use odd number!

meaCenter_x=714;
meaCenter_y=629;
centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);
brightness = 1;
Screen('FillRect', w, brightness*255, centeredRect);
Screen('Flip', w);


%% Setup video input
vid = videoinput('gige',1); %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);
set(scr_obj,'GainRaw',20)
set(scr_obj,'ExposureTimeAbs',100000)
src.PacketDelay = 9014;
preview(vid);


set(scr_obj,'GainRaw',20)
set(scr_obj,'ExposureTimeAbs',6000000)
Screen('Flip', w);
black_frame = getsnapshot(vid);


imshow(black_frame);


%% Take photo and determine ideal_pt


sdi=8; %distance btw each dot's center  
N=4;  %Show 7*7 = 49 points 
dotPositionMatrix=zeros(2,225);
x_array=zeros(1,2*N-1);  %x coordination of the dots
y_array=zeros(1,2*N-1);
%start calculating the coordination of each dots
for i=0:2*N-2
    x_array(1,i+1)=round(meaCenter_x-(N-1)*sdi+i*sdi);  %start from the lefttest x position
end
for i=0:2*N-2
    y_array(1,i+1)=round(meaCenter_y-(N-1)*sdi+i*sdi);
end
%put into the matrix "dotPositionMatrix"
 for q=0:2*N-2
    for a=1:2*N-1
        dotPositionMatrix(1,a+q*(2*N-1))=x_array(q+1);
        dotPositionMatrix(2,a+q*(2*N-1))=y_array(a);
    end
 end
%draw dots and show the image on monitor
dotColors=[255];
for i=1:size(dotPositionMatrix,2)  
        baseRect = [0 0 1 1];  % one pixel
        xCenter=dotPositionMatrix(1,i); %determine the x coordination on monitor for this point
        yCenter=dotPositionMatrix(2,i);
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        Screen('FillRect', w, dotColors, centeredRect);
end
Screen('Flip', w);

frame = getsnapshot(vid);

imshow(frame);

[ideal_pt,ideal_distance_pt] = find_i_pt(frame-black_frame,2*N-1,cal_size ,sdi);
save('ideal_pt.mat','ideal_pt','ideal_distance_pt')
frame = frame-black_frame;
save('frame.mat', 'frame')