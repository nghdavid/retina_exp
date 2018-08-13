%% Open phychotoolbox
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',1, [0 0 0]); %black background 


% 
% mea_size=433; %use odd number!
% baseRect = [0 0 mea_size mea_size];  %use odd number!
% baseRect = [0 0 4 4]; 
% meaCenter_x=631; 
% meaCenter_y=572;  
% centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);
% Screen('FillRect', w, 255,centeredRect); 
% Screen('Flip', w);

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
cal_size = 469;%number of channels for one side, should be an odd number
N = 7;%
baseRect = [0 0 mea_size mea_size];  %use odd number!
centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);
meaCenter_x=631; 
meaCenter_y=572; 


x_array=[]; y_array=[];
dotPositionMatrix=cell(cal_size ,cal_size);%Matrix that stores the position of every dot


%start calculating the x,y coordination of each dots
for i=0:cal_size-1
    x_array(1,i+1)= meaCenter_x - (cal_size-1)/2 + i;  %start from the lefttest x position
end
for i=0:cal_size-1
    y_array(1,i+1)=meaCenter_y - (cal_size-1)/2 + i;
end

% dotPositionMatrix=zeros(2,cal_size^2);
% %put into the matrix "dotPositionMatrix"
%  for q=0:cal_size-1
%     for a=1:cal_size
%         dotPositionMatrix(1,a+q*cal_size)=x_array(q+1);
%         dotPositionMatrix(2,a+q*cal_size)=y_array(a);
%     end
%  end
% 
%  
% 
% for i=1:size(dotPositionMatrix,2)  
%         baseRect = [0 0 1 1];  % one pixel
%         xCenter=dotPositionMatrix(1,i); %determine the x coordination on monitor for this point
%         yCenter=dotPositionMatrix(2,i);
%         centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
%         Screen('FillRect', w, dotColors, centeredRect);
% end
% Screen('Flip', w);


tic
%Show seven dots at one time and keep moving
for i = 1%:cal_size%x coordination 
    for j = 1:cal_size/N%y coordination
        point0=zeros(2,N);
        
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
             ideal_point(1,k+1) = ideal_pt{cal_size-(k*cal_size/N+j-1),i}(1);
             ideal_point(2,k+1) = ideal_pt{cal_size-(k*cal_size/N+j-1),i}(2);     
        end
        
        min = ones(1,N)*10000000;
        min_point = cell(1,N);
        for o = 1:N
            point0(1,o) = x_array(i);
            point0(2,o) = y_array((o-1)*cal_size/N+j);
        end
        new_point = point0;
        for o = 1:10
            
            
            for z = 1:size(new_point,2)%Show seven points on monitor
                baseRect = [0 0 1 1];  % one pixel
                %centeredRect = CenterRectOnPointd(baseRect, round(ideal_point(1,z)), round(ideal_point(2,z)));
                centeredRect = CenterRectOnPointd(baseRect, round(new_point(1,z)), round(new_point(2,z)));
                Screen('FillRect', w, 255, centeredRect);
            end
            Screen('Flip', w);
    
            img = getsnapshot(vid);
            detect_pt = find_detect_pt(img,N,0.95,'off',ideal_point);
    
            for v = 1:size(new_point,2)
               ideal_x = ideal_point(1,v);
               ideal_y = ideal_point(2,v);
               detect_x = detect_pt(1,v);
               detect_y = detect_pt(2,v);
               if ideal_x > detect_x
                   new_point(1,v) = new_point(1,v) +1 ;
                   %new_point(1,v)= new_point(1,v) + round((ideal_x -detect_x)/ideal_distance_pt);
               elseif ideal_x < detect_x
                   new_point(1,v) = new_point(1,v) + round((ideal_x - detect_x)/ideal_distance_pt) ;
               else
               end
         
                if ideal_y > detect_y
                    new_point(2,v) = new_point(2,v) + round((ideal_y - detect_y)/ideal_distance_pt) ;
                elseif ideal_y < detect_y
                    new_point(2,v) = new_point(2,v) + round((ideal_y - detect_y)/ideal_distance_pt) ;
                else
                end
            end
        
    
            distances = zeros(1,N);
            for u = 1:size(ideal_point,2)
                distances(u) = norm(detect_pt(:,1)-ideal_point(:,u));
            end
       
            for m = 1:N
                if distances(m) < min(m)
                    min(m) = distances(m);
                    min_point{:,m} = new_point(:,m);
                end

            end
        
        
        end
        
        for k = 0:N-1
             dotPositionMatrix{k*cal_size/N+j,i} = min_point(:,k+1);     
        end
        
        
    end
end

toc
save('calibirate_pt.mat','dotPositionMatrix')