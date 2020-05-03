function make_grating_matrix(calibration_date,mean_lumin,rotation,bar_real_width,temporal_frequency)
%Rotation is degree that bar rotate
%mean_lumin is luminance of bar
matrix_folder = 'C:\';
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
bar_wid = round(bar_real_width/ micro_per_pixel-1)/2%unit of bar_real_width is micro
bar_interval = bar_wid*4+2 ;%The distance between bar and bar
monitor_mean_lumin = interp1(real_lum,lum,mean_lumin,'linear');
folder_name = [calibration_date,'grating_matrix_',num2str(mean_lumin),'mW_',num2str(bar_real_width) ,'micro_',num2str(temporal_frequency),'HZ'];
mkdir ([matrix_folder,folder_name])

Y =meaCenter_y;
%rotation theta = 0 for RL theta
%theta must between [0,pi]
for o = rotation
    mkdir([matrix_folder,folder_name],num2str(o))
    theta = o*pi/4;
    if pi/4 <= theta && pi*3/4 >= theta
        longest_dis = mea_size_bm/sin(theta)+bar_interval; %the distance a bar would travel
    else
        longest_dis = abs(mea_size_bm/cos(theta))+bar_interval;
    end
    bar_le = longest_dis/2;
    num_bar = ceil(longest_dis/bar_interval);%number of bar in movie
    num_move = 400; %Number of steps that move %6.67s
    if temporal_frequency == 0.375
        num_move = num_move*2;%Number of steps that move %13.33s
    end
    R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];
    
    for X = 0:num_bar*bar_interval
        a = zeros(screen_y,screen_x);
        barX= X +(mea_size_bm-1)/2-(longest_dis/2);
        barY=Y-lefty_bd;
        Vertex = cell(2);
        Vertex{1} = [barX-bar_wid  barY-bar_le];  %V1  V4
        Vertex{2} = [barX-bar_wid  barY+bar_le];  %V2  V3
        Vertex{3} = [barX+bar_wid  barY+bar_le];
        Vertex{4} = [barX+bar_wid  barY-bar_le];
        %rotation
        for i = 1:4
            Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
        end
        a = write_CalBar(a,Vertex,theta,mea_size_bm,calibration_date,monitor_mean_lumin); %a = the bar
        save([matrix_folder,'\',folder_name,'\',num2str(o),'\',num2str(X),'.mat'],'a');
    end
end
