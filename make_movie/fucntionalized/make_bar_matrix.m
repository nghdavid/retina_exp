function make_bar_matrix(calibration_date,mean_lumin,contrast,rotation)
%Rotation is degree that bar rotate
%mean_lumin is luminance of bar
matrix_folder = 'C:\';
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
background_lumin = interp1(real_lum,lum,mean_lumin,'linear');
bar_lumin = interp1(real_lum,lum,(contrast+1)*mean_lumin,'linear');
folder_name = [calibration_date,'Bar_matrix_',num2str(mean_lumin),'mW_',num2str(contrast*100),'%'];
mkdir ([matrix_folder,folder_name])
%rotation theta = 0 for RL theta
%theta must between [0,pi]
for o = rotation
    mkdir ([matrix_folder,folder_name],num2str(o))
    theta = o*pi/4;
    R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];
    %find the moving bar
    Vertex = zeros(4,2);
    Vertex(1,:) = [-bar_wid  -bar_le];  %V1  V4
    Vertex(2,:) = [-bar_wid  +bar_le];  %V2  V3
    Vertex(3,:) = [+bar_wid  +bar_le];
    Vertex(4,:) = [+bar_wid  -bar_le];
    Vertex = R_matrix*Vertex';
    if theta > pi/2
        newVertex = Vertex(:,1);
        for i = 1:3
            Vertex(:,i) =Vertex(:,i+1);
        end
        Vertex(:,4) = newVertex;
    end
    
    for X = ceil(leftx_bar+bar_wid):floor(rightx_bar-bar_wid)
        barsShift = round(R_matrix*[X-meaCenter_x;0]) ;
        a = ones(screen_y,screen_x)*background_lumin;%full screen pixel matrix %it's the LED screen size
        a = write_Bar(a, Vertex, barsShift, theta,  mea_size_bm, calibration_date, background_lumin, bar_lumin);%a = the bar
        save([matrix_folder,'\',folder_name,'\',num2str(o),'\',num2str(X),'.mat'],'a');
    end
end
end
