%% Setup video input
vid = videoinput('gige',1,'Mono8') %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);

set(vid, 'Exposureabs', 100);

frame = getsnapshot(vid);
image(frame);
%% Open phychotoolbox
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',2, [0 0 0]); %black background 


%% Set mea parameter
mea_size=433; %use odd number!
cal_size = 511;%number of channels for one side, should be an odd number
N = 7;%
baseRect = [0 0 mea_size mea_size];  %use odd number!
meaCenter_x=631; %%%%%%%%%%%%Check
meaCenter_y=605; %%%%%%%%%%%%Check 


x_array=[]; y_array=[];
dotPositionMatrix=cell(cal_size ,cal_size);%Matrix that stores the position of every dot


%start calculating the x,y coordination of each dots
for i=0:cal_size-1
    x_array(1,i+1)= meaCenter_x - (cal_size-1)/2 + i;  %start from the lefttest x position
end
for i=0:cal_size-1
    y_array(1,i+1)=meaCenter_y - (cal_size-1)/2 + i;
end





dotColors=[255];
%Show seven dots at one time and keep moving
for i = 1:cal_size%x coordination 
    for j = 1:cal_size/N%y coordination
        point0 = zeros(2,N);
        
%         for z = 0:N-1%Show seven points on monitor
%             baseRect = [0 0 1 1];  % one pixel
%             centeredRect = CenterRectOnPointd(baseRect, x_array(i), y_array(z*cal_size/N+j));
%             point0(1,z+1) = x_array(i);
%             point0(2,z+1) = y_array(z*cal_size/N+j);
%             Screen('FillRect', w, dotColors, centeredRect);
%         end
%         Screen('Flip', w);
%         img = getsnapshot(vid);
%         detect_pt = find_detect_pt(img,N,0.95,'off');
            
        %Change position on the monitor
        ideal_point = zeros(2,N);
        for k = 0:N-1
             ideal_point(1,k+1) = ideal_pt{cal_size-k*cal_size/N+j,i}(1);
             ideal_point(2,k+1) = ideal_pt{cal_size-k*cal_size/N+j,i}(2);     
        end
        
        min = ones(1,N)*10000000;
        min_point = cell(1,N);
        point = ideal_point;
        for z = 1:10
            [distances,coordinates] = mindistance(point,ideal_point);
            for i = 1:N
                if distances(i) < min(i)
                    min(i) = distances(i);
                    min_point(i) = coordinates(i);
                end
                
            end
            point = coordinates;
        end
        
        
        for k = 0:N-1
             dotPositionMatrix(y_array(k*cal_size/N+j),x_array(i)) = min_point(k+1);     
        end
        
        end
    end
    end

save('calibirate_pt.mat','dotPositionMatrix')