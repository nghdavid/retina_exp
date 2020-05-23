function make_2ndbar_matrix(calibration_date,mean_lumin,rotation)
%Rotation is degree that bar rotate
%mean_lumin is luminance of bar
matrix_folder = 'C:\';
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
monitor_mean_lumin = interp1(real_lum,lum,mean_lumin,'linear');
folder_name = [calibration_date,'2ndBar_matrix_',num2str(mean_lumin),'mW'];
mkdir ([matrix_folder,folder_name])
%rotation theta = 0 for RL theta
%theta must between [0,pi]
for o = rotation
    mkdir ([matrix_folder,folder_name, '\', num2str(o)])
    try
        load([matrix_folder,'\',folder_name,'\origin.mat'])
    catch
        img=zeros(screen_y,screen_x);
        temp_img = [zeros(1, floor(mea_size_bm^2/2)) ones(1, ceil(mea_size_bm^2/2))];
        temp_img = temp_img(randperm(mea_size_bm^2));
        temp_img = reshape(temp_img, [mea_size_bm, mea_size_bm]);
        img(lefty_bd:righty_bd,leftx_bd:rightx_bd) = temp_img*monitor_mean_lumin;
        save([matrix_folder,'\',folder_name,'\origin.mat'],'img');
    end
    
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
        a = write_2ndCalBar(img,Vertex,barsShift,theta,mea_size_bm,calibration_date);
        save([matrix_folder,'\',folder_name,'\',num2str(o),'\',num2str(X),'.mat'],'a');
    end
end
end
