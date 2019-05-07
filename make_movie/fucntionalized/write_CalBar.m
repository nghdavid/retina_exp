function frame = write_CalBar(frame,Vertex, theta,  mea_size_bm)


load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;

if theta == 0 || theta == pi/2  % vertical case
    for y = round(Vertex{1}(2)) : round(Vertex{3}(2))
        for x = round(Vertex{2}(1)):round(Vertex{4}(1))
            new_y = y;
            new_x = x;
            if y > size(dotPositionMatrix,1)
                new_y = mod(y,size(dotPositionMatrix,1))+(mea_size_bm-mea_size);
                
            end
            if x > size(dotPositionMatrix,1)
                new_x = mod(x,size(dotPositionMatrix,1))+(mea_size_bm-mea_size);
                
            end
            
            cal_x = dotPositionMatrix{new_y,new_x}(1);
            cal_y = dotPositionMatrix{new_y,new_x}(2);
            cal_lum = screen_brightness(y,new_x);
            frame(cal_y,cal_x) = cal_lum;
            
            
        end
    end
    
else
    if theta > pi/2
        newVertex = Vertex{1};
        for i = 1:3
            Vertex{i} = Vertex{i+1};
        end
        Vertex{4} = newVertex;
    end
    
    %pervent out of rnage
    if Vertex{2}(1) < 1
        min_x = 1;
    else
        min_x = Vertex{2}(1);
    end
    if Vertex{4}(1) > mea_size_bm
        max_x = mea_size_bm;
    else
        max_x = Vertex{4}(1);
    end
    
    for x = floor(min_x) : ceil(max_x)
        % find bar region
        if x < Vertex{1}(1)
            lower_y = Vertex{1}(2) + (Vertex{1}(2)-Vertex{2}(2))/(Vertex{1}(1)-Vertex{2}(1)) * (x-Vertex{1}(1));
        else
            lower_y = Vertex{1}(2) + (Vertex{1}(2)-Vertex{4}(2))/(Vertex{1}(1)-Vertex{4}(1)) * (x-Vertex{1}(1));
        end
        if x < Vertex{3}(1)
            upper_y = Vertex{3}(2) + (Vertex{3}(2)-Vertex{2}(2))/(Vertex{3}(1)-Vertex{2}(1)) * (x-Vertex{3}(1));
        else
            upper_y = Vertex{3}(2) + (Vertex{3}(2)-Vertex{4}(2))/(Vertex{3}(1)-Vertex{4}(1)) * (x-Vertex{3}(1));
        end
        
        %pervent out of rnage
        if lower_y < 1
            lower_y = 1;
        end
        if upper_y > mea_size_bm
            upper_y = mea_size_bm;
        end
        
        for y = floor(lower_y) : ceil(upper_y)
            cal_x = dotPositionMatrix{y,x}(1);
            cal_y = dotPositionMatrix{y,x}(2);
            cal_lum = screen_brightness(y,x);
            frame(cal_y,cal_x) = cal_lum;
        end
    end
end

end