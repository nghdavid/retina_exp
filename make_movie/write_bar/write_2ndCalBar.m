function [theBarIndexX, theBarIndexY] = write_2ndCalBar(img, Vertex_matrix, theta,  mea_size_bm,calibration_date,monitor_mean_lumin)
Vertex = cell(2);
Vertex{1} = Vertex_matrix(1,:);  %V1  V4
Vertex{2} = Vertex_matrix(2,:);  %V2  V3
Vertex{3} = Vertex_matrix(3,:);
Vertex{4} = Vertex_matrix(4,:);
%Rotation is degree that bar rotate
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
theBarIndexX = [];
theBarIndexY = [];
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
        theBarIndexX = [theBarIndexX x+leftx_bd-1];
        theBarIndexY = [theBarIndexY y+lefty_bd-1];
    end
end
end