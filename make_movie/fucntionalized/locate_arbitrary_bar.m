function locate_arbitrary_bar(calibration_date, bar_wid, bar_len, bar_center, rotation)
%Rotation is degree that bar rotate
%mean_lumin is luminance of bar
matrix_folder = 'C:\';

temp =  bar_wid;
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
bar_wid =temp;

folder_name = [calibration_date,'arbitrary_bar_location_', num2str(bar_wid),'x', num2str(bar_len), '_center(',num2str(bar_center(1)),',',num2str(bar_center(2)),')'];
mkdir ([matrix_folder,folder_name])
%rotation theta = 0 for RL theta
%theta must between [0,pi]
for o = rotation
    mkdir ([matrix_folder,folder_name],num2str(o))
    theta = o*pi/4;
    R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];
    %find the moving bar
    Vertex = zeros(4,2);
    Vertex(1,:) = [-bar_wid  -bar_len];  %V1  V4
    Vertex(2,:) = [-bar_wid  +bar_len];  %V2  V3
    Vertex(3,:) = [+bar_wid  +bar_len];
    Vertex(4,:) = [+bar_wid  -bar_len];
    Vertex = Vertex + reshape(bar_center, 1, []) - [meaCenter_x meaCenter_y];
    Vertex = R_matrix*Vertex';
    if theta > pi/2
        newVertex = Vertex(:,1);
        for i = 1:3
            Vertex(:,i) =Vertex(:,i+1);
        end
        Vertex(:,4) = newVertex;
    end
    
    bar_interval = 4*bar_wid+2;
    if pi/4 <= theta && pi*3/4 >= theta
        longest_dis = mea_size_bm/sin(theta)+bar_interval;%the distance a bar would travel
    else
        longest_dis = abs(mea_size_bm/cos(theta))+bar_interval;
    end
    for X = floor(meaCenter_x-longest_dis/2-bar_wid) + (0:ceil(longest_dis/bar_interval)*bar_interval+1)
        barsShift = R_matrix*[X-meaCenter_x;0];
        a = logical(zeros(screen_y,screen_x));
        a = locate_Bar(a, Vertex, barsShift, theta,  mea_size_bm, calibration_date);%a = the bar
        save([matrix_folder,'\',folder_name,'\',num2str(o),'\',num2str(X),'.mat'],'a');
    end
end
end