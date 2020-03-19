function make_edge_matrix(calibration_date,mean_lumin,rotation,reverse)
%Rotation is degree that bar rotate
%mean_lumin is luminance of bar
matrix_folder = 'C:\';
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);

if mod(rotation,2) == 0
    bar_le = (mea_size_bm-1)/2;
    bar_wid = (mea_size_bm-1)/2;
else
    bar_le = (mea_size_bm-1)/sqrt(2);
    bar_wid = (mea_size_bm-1)/2;
end
monitor_mean_lumin = interp1(real_lum,lum,mean_lumin,'linear');
folder_name = [calibration_date,'edge_matrix_',num2str(mean_lumin),'mW'];
mkdir ([matrix_folder,folder_name])
%rotation theta = 0 for RL theta
%theta must between [0,pi]
for o = rotation
    mkdir ([matrix_folder,folder_name],num2str(o))
    theta = o*pi/4;
    R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];
    for X = meaCenter_x - mea_size_bm+1 : meaCenter_x + mea_size_bm+1
        a = zeros(screen_y,screen_x);
%         a(lefty_bd-50:righty_bd+50,leftx_bd:leftx_bd+1) = 0.5;
%         a(lefty_bd-50:righty_bd+50,rightx_bd:rightx_bd+1) = 0.5;
%         a(lefty_bd:lefty_bd+1,leftx_bd-50:rightx_bd+50) = 0.5;
%         a(righty_bd:righty_bd+1,leftx_bd-50:rightx_bd+50) = 0.5;
%         a(lefty_bar-50:righty_bar+50,leftx_bar:leftx_bar+1) = 0.5;
%         a(lefty_bar-50:righty_bar+50,rightx_bar:rightx_bar+1) = 0.5;
%         a(lefty_bar:lefty_bar+1,leftx_bar-50:rightx_bar+50) = 0.5;
%         a(righty_bar:righty_bar+1,leftx_bar-50:rightx_bar+50) = 0.5;
        barX=X-round(leftx_bd);
        barY=meaCenter_y-round(lefty_bd);
        Vertex = cell(2);
        if (reverse == 0 && rotation == 3) || (reverse == 0 && rotation == 1)
            Vertex{1} = [barX-bar_wid*sqrt(2)  barY-bar_le];  %V1  V4
            Vertex{2} = [barX-bar_wid*sqrt(2)  barY+bar_le];  %V2  V3
            Vertex{3} = [barX+bar_wid  barY+bar_le];
            Vertex{4} = [barX+bar_wid  barY-bar_le];
        elseif (reverse == 1 && rotation == 3) || (reverse == 1 && rotation == 1)
            Vertex{1} = [barX-bar_wid  barY-bar_le];  %V1  V4
            Vertex{2} = [barX-bar_wid  barY+bar_le];  %V2  V3
            Vertex{3} = [barX+bar_wid*sqrt(2)  barY+bar_le];
            Vertex{4} = [barX+bar_wid*sqrt(2)  barY-bar_le];
        end
        %rotation
        for i = 1:4
            Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
        end
        a = write_CalBar(a,Vertex,theta,mea_size_bm,calibration_date,monitor_mean_lumin); %a = the bar
        save([matrix_folder,'\',folder_name,'\',num2str(o),'\',num2str(X),'.mat'],'a');
    end
end
end