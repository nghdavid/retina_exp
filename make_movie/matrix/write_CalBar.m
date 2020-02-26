function a = write_CalBar(a, Vertex, theta,  mea_size_bm,calibration_date,monitor_mean_lumin)
%Rotation is degree that bar rotate
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
if theta == 0 || theta == pi/2  % vertical case
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
    if Vertex{1}(2) < 1
        lower_y = 1;
    else
        lower_y = Vertex{1}(2);
    end
    if Vertex{3}(2) > mea_size_bm
        upper_y = mea_size_bm;
    else
        upper_y = Vertex{3}(2);
    end
    for x = floor(min_x) : ceil(max_x)
        for y = floor(lower_y) : ceil(upper_y)           
            a(y+lefty_bd-1,x+leftx_bd-1) = monitor_mean_lumin;
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
            a(y+lefty_bd-1,x+leftx_bd-1) = monitor_mean_lumin;
        end
    end
end

end