function makeGrating_shuffledvideo(makemovie_folder,video_folder, videoworkspace_folder, date,calibration_date, background_lumin, bar_lumin)

load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
% %             width   interval
% % grating     300     300
% % jittering   150     150
rest_mean_lumin = interp1(real_lum,lum,(background_lumin+bar_lumin)/2,'linear');
OLED_bar_lumin = interp1(real_lum,lum,bar_lumin,'linear');
OLED_background_lumin = interp1(real_lum,lum,background_lumin,'linear');
background = zeros(1024,1280);
background(lefty_bd:righty_bd, leftx_bd:rightx_bd) = OLED_background_lumin;
Y =meaCenter_y;
cd (video_folder)
%% video setting
name=[date,'_Grating_', num2str(background_lumin),'-', num2str(bar_lumin), 'mW'];
name
video_fps=60;
writerObj = VideoWriter([name,'.avi']);
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);


%% Pre adaptation
for l = 1:60*10
    a = zeros(1024,1280);
    a(lefty_bd:righty_bd, leftx_bd:rightx_bd) = rest_mean_lumin;%Gray frame
    a(500-35:500+35,1230:1280)=0; % dark
    writeVideo(writerObj,a);
end
bar_real_width_set = [130 300 600];
temporal_frequency_set = [3/16 ones(1,2)*3/8 ones(1,4)*3/4];
theta_set = [[0 pi/4 pi/2 pi*3/4] pi+[0 pi/4 pi/2 pi*3/4]];
SET_I = 1:length(bar_real_width_set)*length(temporal_frequency_set)*length(theta_set);
Order = [];
cd(makemovie_folder)
theta2pi = pi*20;
while ~isempty(SET_I)
    last_theta = theta2pi;
    ii = randi(length(SET_I));
    [i j k] = ind2sub([length(bar_real_width_set) length(temporal_frequency_set) length(theta_set)], SET_I(ii));
    bar_real_width = bar_real_width_set(i);
    temporal_frequency = temporal_frequency_set(j);
    theta2pi = theta_set(k);
    if length(SET_I) == 1
    elseif theta2pi == last_theta
        continue
    end
    if theta2pi >= pi
        theta = theta2pi-pi;
    else
        theta = theta2pi;
    end
    Order = [Order SET_I(ii)];
    SET_I(ii) = [];
    %% Calculate parameters of bar on the OLED
    bar_wid = round( (bar_real_width/micro_per_pixel-1)/2 );
    bar_interval = bar_wid*4+2;
    if pi/4 <= theta && pi*3/4 >= theta
        longest_dis = mea_size_bm/sin(theta)+bar_interval;%the distance a bar would travel
    else
        longest_dis = abs(mea_size_bm/cos(theta))+bar_interval;
    end
    bar_len = ceil(longest_dis/2);
    bar_center = [meaCenter_x meaCenter_y];
        %% Check each grating matrix have calculated or not
    matrix_folder = ['C:\', calibration_date,'arbitrary_bar_location_', num2str(bar_wid),'x', num2str(bar_len), '_center(',num2str(bar_center(1)),',',num2str(bar_center(2)),')\'];
    if exist([matrix_folder,num2str(theta*4/pi)]) == 0
        disp('Does not have matrix yet')
        locate_arbitrary_bar(calibration_date, bar_wid, bar_len, bar_center, theta/pi*4)
    end
    num_bar = ceil(longest_dis/bar_interval);%number of bar in movie
    num_move = 400; %Number of steps that move %6.67s
    if temporal_frequency <= 3/16
        num_move = num_move*4;
    elseif temporal_frequency <= 3/8
        num_move = num_move*2;
    end
    xarray = zeros(num_bar,num_move);%Array that store each bar postion(each row store each bar postions)
    xarray(1,1) = randi(num_bar*bar_interval)-1;%leftx_bd+bar_wid+1;%Left bar first position %randomly 0~mea_size_bm-1
    for i = 2:num_move
        xarray(1,i) = xarray(1,i-1)+temporal_frequency*bar_interval/60;
    end
    if num_bar > 1
        for i = 2:num_bar%Calculate other bar
            xarray(i,:) = xarray(i-1,:)+bar_interval;
        end
    end
    xarray = mod(xarray , num_bar*bar_interval); % set all xarray into mea region
    if theta2pi >= pi, xarray = fliplr(xarray);  end%For reverse direction
    %% Plot each bar
    for kk =1:length(xarray)
        temp = zeros(1024,1280);%Initialize each frame
        for i = 1:num_bar%Plot each bar
            X=round(xarray(i,kk)+ meaCenter_x-longest_dis/2-bar_wid);
            load([matrix_folder,num2str(theta*4/pi),'\',num2str(X),'.mat']);% Load picture matrix
            temp = temp + a*(OLED_bar_lumin - OLED_background_lumin);
        end
        temp = temp + background;
        temp(500-35:500+35,1230:1280)=1;
        writeVideo(writerObj,temp);
    end
    %% Interval frame
    for l = 1:100 %1.67sec rest
        a = zeros(1024,1280);%Gray frame
        a(lefty_bd:righty_bd, leftx_bd:rightx_bd) = rest_mean_lumin;%Gray frame
        a(500-35:500+35,1230:1280)=0;% dark
        writeVideo(writerObj,a);
    end
end
%% Ending
for mm=1:10
    img=zeros(1024,1280);
    img(500-35:500+35,1230:1280)=1; %thus I can use diode_start to cut.
    writeVideo(writerObj,img);
end
close(writerObj);
save([videoworkspace_folder,'/',name,'.mat'],'Order', 'bar_real_width_set', 'temporal_frequency_set', 'theta_set')
end
