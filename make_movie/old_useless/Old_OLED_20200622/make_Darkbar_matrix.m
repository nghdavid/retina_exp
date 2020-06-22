function make_Darkbar_matrix(calibration_date,mean_lumin,contrast,rotation)
    %Contrast is ratio between the luminacne of background and dark bar(dark bar/background)
    %Rotation is degree that bar rotate
    %mean_lumin is luminance of background
    matrix_folder = 'C:\';
    load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
    load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
    monitor_mean_lumin = interp1(real_lum,lum,mean_lumin,'linear');
    monitor_dark_lum = interp1(real_lum,lum,mean_lumin*contrast,'linear');
    folder_name = [calibration_date,'DarkBar_matrix_',num2str(mean_lumin),'mW_',num2str(contrast*100),'%'];
    mkdir ([matrix_folder,folder_name])
    %rotation theta = 0 for RL theta
    %theta must between [0,pi]
    for o = rotation
        mkdir ([matrix_folder,folder_name],num2str(o))
        theta = o*pi/4;
        R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];
        for X = ceil(leftx_bar+bar_wid):floor(rightx_bar-bar_wid)
            a=zeros(screen_y,screen_x);%full screen pixel matrix %it's the LED screen size
            a(lefty_bd:righty_bd,leftx_bd:rightx_bd)= monitor_mean_lumin;
            barX=X-round(leftx_bd);
            barY=meaCenter_y-round(lefty_bd);
            Vertex = cell(2);
            Vertex{1} = [barX-bar_wid  barY-bar_le];  %V1  V4
            Vertex{2} = [barX-bar_wid  barY+bar_le];  %V2  V3
            Vertex{3} = [barX+bar_wid  barY+bar_le];
            Vertex{4} = [barX+bar_wid  barY-bar_le];
            %rotation
            for i = 1:4
                Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
            end
            a = write_DarkCalBar(a,Vertex,theta,mea_size_bm,calibration_date,monitor_dark_lum); %a = the bar
            save([matrix_folder,'\',folder_name,'\',num2str(o),'\',num2str(X),'.mat'],'a');
        end
    end
end