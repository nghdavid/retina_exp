function [distances,coordinates] = mindistance(new_point,ideal_point)
    N = 7;
    w = 10;
    for z = 1:size(new_point,2)%Show seven points on monitor
        baseRect = [0 0 1 1];  % one pixel
        %centeredRect = CenterRectOnPointd(baseRect, round(ideal_point(1,z)), round(ideal_point(2,z)));
        centeredRect = CenterRectOnPointd(baseRect, round(new_point(1,z)), round(new_point(2,z)));
        Screen('FillRect', w, 255, centeredRect);
    end
    Screen('Flip', w);
    
    img = getsnapshot(vid);
    detect_pt = find_detect_pt(img,N,0.95,'off');
    
    for i = 1:size(new_point,2)
         ideal_x = ideal_point(1,i);
         ideal_y = ideal_point(2,i);
         detect_x = detect_pt(1,i);
         detect_y = detect_pt(2,i);
         if ideal_x > detect_x
             new_point(1,i) = new_point(1,i) +1 ;
             
         elseif ideal_x < detect_x
             new_point(1,i) = new_point(1,i) -1 ;
         else
         end
         
         if ideal_y > detect_y
             new_point(2,i) = new_point(2,i) -1 ;
         elseif ideal_y < detect_y
             new_point(2,i) = new_point(2,i) +1 ;
         else
         end
    end
    
    distances = zeros(1,N);
    for i = 1:size(ideal_point,2)
        distances(i) = distances(i) + norm(detect_pt(:,1)-ideal_point(:,i));
    end
    coordinates = new_points;
end