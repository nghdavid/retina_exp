function a = write_CalBar(a, Vertex, barsShift, theta,  mea_size_bm, calibration_date, monitor_mean_lumin, bar_lumin)
%Rotation is degree that bar rotate
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
% V1
%     V4
%V2
%    V3
%define range of x
min_x = Vertex(1,2) + meaCenter_x + barsShift(1);
max_x = Vertex(1,4) + meaCenter_x + barsShift(1);
%pervent out of rnage
if min_x < leftx_bd, min_x = leftx_bd; end
if max_x > rightx_bd, max_x = rightx_bd; end

if theta == 0 || theta == pi/2  % vertical case
    %define range of y
    lower_y = Vertex(2,1) + meaCenter_y + barsShift(2);
    upper_y = Vertex(2,3) + meaCenter_y + barsShift(2);
    %pervent out of rnage
    if lower_y < lefty_bd, lower_y = lefty_bd; end
    if upper_y > righty_bd, upper_y = righty_bd; end
    a(lower_y:upper_y, min_x:max_x) = bar_lumin;
else
    for x = floor(min_x) : ceil(max_x)
        %define range of y
        if x < Vertex(1,1)
            lower_y = Vertex(2,1) + (Vertex(2,1)-Vertex(2,2))/(Vertex(1,1)-Vertex(1,2)) * (x-Vertex(1,1));
        else
            lower_y = Vertex(2,1) + (Vertex(2,1)-Vertex(2,4))/(Vertex(1,1)-Vertex(1,4)) * (x-Vertex(1,1));
        end
        if x < Vertex(1,3)
            upper_y = Vertex(2,3) + (Vertex(2,3)-Vertex(2,2))/(Vertex(1,3)-Vertex(1,2)) * (x-Vertex(1,3));
        else
            upper_y = Vertex(2,3) + (Vertex(2,3)-Vertex(2,4))/(Vertex(1,3)-Vertex(1,4)) * (x-Vertex(1,3));
        end
        %pervent out of rnage
        if lower_y < lefty_bd, lower_y = lefty_bd; end
        if upper_y > righty_bd, upper_y = righty_bd; end
        a(lower_y:upper_y, x) = bar_lumin;
    end
end
end