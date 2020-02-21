clear all;
calibration_date = '20191115v';
load(['C:\calibration\',calibration_date,'\calibrate_pt.mat'])%Load dotPositionMatrix
load(['C:\calibration\',calibration_date,'\screen_brightness.mat'])%Load screen_brightness
load(['C:\calibration\',calibration_date,'\boundary_set.mat'])
dotPositionMatrix = flip(flip(dotPositionMatrix,2))';

screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;

%%rotation theta = 0 for RL theta
%theta must between [0,pi)
for o = [0 2]
    theta = o*pi/4;
    R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];
    mkdir(num2str(o))
    for X = ceil(leftx_bd+bar_wid):floor(rightx_bd-bar_wid)
        a = zeros(1024,1280);
        for y = 1 : length(screen_brightness)
            for x = 1 : length(screen_brightness)
                cal_x = dotPositionMatrix{y,x}(1);
                cal_y = dotPositionMatrix{y,x}(2);
                cal_lum = screen_brightness(y,x);
                a(cal_y,cal_x) = cal_lum;
            end
        end
        barX=X-round(leftx_bd);
        barY=meaCenter_y-round(lefty_bd);
        Vertex = cell(2);
        Vertex{1} = [barX-bar_wid  barY-long_bar_le];  %V1  V4
        Vertex{2} = [barX-bar_wid  barY+long_bar_le];  %V2  V3
        Vertex{3} = [barX+bar_wid  barY+long_bar_le];
        Vertex{4} = [barX+bar_wid  barY-long_bar_le];
        %rotation
        for i = 1:4
            Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
        end
        a = write_DarkCalBar(a, Vertex, theta,  mea_size_bm,calibration_date); %a = the bar
        save([pwd,'/',num2str(o),'/',num2str(X),'.mat'],'a');
    end
end
