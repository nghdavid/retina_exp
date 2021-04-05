function a = write_2ndCalBar(img, theBarVertex_matrix,barsShift, theta,  mea_size_bm,calibration_date)
%Rotation is degree that bar rotate
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
% V1
%     V4
%V2
%    V3
Vertex = cell(2);
Vertex{1} = theBarVertex_matrix(:,1)+[(mea_size_bm+1)/2 ; (mea_size_bm+1)/2];
Vertex{2} = theBarVertex_matrix(:,2)+[(mea_size_bm+1)/2 ; (mea_size_bm+1)/2];
Vertex{3} = theBarVertex_matrix(:,3)+[(mea_size_bm+1)/2 ; (mea_size_bm+1)/2];
Vertex{4} = theBarVertex_matrix(:,4)+[(mea_size_bm+1)/2 ; (mea_size_bm+1)/2];
b = img;
if theta == 0 || theta == pi/2  % vertical case
    min_x = Vertex{2}(1);
    max_x = Vertex{4}(1);
    lower_y = Vertex{1}(2);
    upper_y = Vertex{3}(2);
    for x = floor(min_x) : ceil(max_x)
        for y = floor(lower_y) : ceil(upper_y)
            b(y+lefty_bd-1+barsShift(2), x+leftx_bd-1+barsShift(1)) = img(y+lefty_bd-1, x+leftx_bd-1);
        end
    end
else
    min_x = Vertex{2}(1);
    max_x = Vertex{4}(1);
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
        for y = floor(lower_y) : ceil(upper_y)
            b(y+lefty_bd-1+barsShift(2), x+leftx_bd-1+barsShift(1)) = img(y+lefty_bd-1, x+leftx_bd-1);
        end
    end
end
%clear out out range pixels
a = zeros(screen_y,screen_x);
a(lefty_bd:righty_bd,leftx_bd:rightx_bd) = b(lefty_bd:righty_bd,leftx_bd:rightx_bd);
end