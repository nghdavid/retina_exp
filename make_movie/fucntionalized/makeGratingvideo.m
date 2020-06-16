function makeGratingvideo(makemovie_folder,video_folder,date,calibration_date, background_lumin, bar_lumin)

load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
% %             width   interval
% % grating     300     300
% % jittering   150     150
rest_mean_lumin = interp1(real_lum,lum,(back_lumin+bar_lumin)/2,'linear');
Y =meaCenter_y;
cd (video_folder)
%% video setting
name=[date,'_Grating'];
name
video_fps=60;
writerObj = VideoWriter([name,'.avi']);
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);


%% Pre adaptation
for l = 1:60*10
    a = zeros(1024,1280);
    a(leftx_bd:rightx_bd, lefty_bd:righty_bd) = rest_mean_lumin;%Gray frame
    a(500-35:500+35,1230:1280)=0; % dark
    writeVideo(writerObj,a);
end
bar_real_width_set = [130 300 600];
temporal_frequency_set = [3/16 ones(1,2)*3/8 ones(1,4)*3/4];
theta_set = [[0 pi/4 pi/2 pi*3/4] -1*[pi pi/4 pi/2 pi*3/4]]  ;
SET_I = 1:length(bar_real_width_set)*length(temporal_frequency_set)*length(theta_set);
cd(makemovie_folder)
theta = pi*20;
while isempty(SET_I)
    last_theta = theta;
    ii = randi(length(SET_I));
    [i j k] = ind2sub([length(bar_real_width_set) length(temporal_frequency_set) length(theta_set)], SET_I(ii));
    bar_real_width = bar_real_width_set(i);
    temporal_frequency = temporal_frequency_set(j);
    theta = abs(theta_set(k));
    if length(SET_I) == 1
    elseif theta == last_theta
        continue
    end
    if theta == pi
        theta == 0;
    end
    SET_I(ii) = []
        
    %% Check each grating matrix have calculated or not
    matrix_folder = ['C:\',calibration_date,'grating_matrix_',num2str(bar_lumin), '-', num2str(background_lumin),'mW_',num2str(bar_real_width) ,'micro_'];
    if exist([matrix_folder,num2str(theta*4/pi)]) == 0
        disp('Does not have matrix yet')
        make_grating_matrix(calibration_date,mean_lumin,theta*4/pi,bar_real_width,temporal_frequency)
    end
    %% Calculate each bar
    if pi/4 <= theta && pi*3/4 >= theta
        longest_dis = mea_size_bm/sin(theta)+bar_interval;%the distance a bar would travel
    else
        longest_dis = abs(mea_size_bm/cos(theta))+bar_interval;
    end
    bar_le = ceil(longest_dis/2);
    num_bar = ceil(longest_dis/bar_interval);%number of bar in movie
    num_move = 400; %Number of steps that move %6.67s
    if temporal_frequency <= 3/16
        num_move = num_move*4;
    elseif temporal_frequency <= 3/8
        num_move = num_move*2;
    end
    xarray = zeros(num_bar,num_move);%Array that store each bar postion(each row store each bar postions)
    xarray(1,1) = randi(mea_size_bm);%leftx_bd+bar_wid+1;%Left bar first position %randomly
    for i = 2:num_move
        xarray(1,i) = xarray(1,i-1)+temporal_frequency*bar_interval/60;
    end
    if num_bar > 1
        for i = 2:num_bar%Calculate other bar
            xarray(i,:) = xarray(i-1,:)+bar_interval;
        end
    end
    xarray = mod(xarray , num_bar*bar_interval); % set all xarray into mea region
    if theta_set(k) < 0
        xarray = fliplr(xarray);%For reverse direction
    end
    %% Plot each bar
    for kk =1:length(xarray)
        temp = zeros(1024,1280);%Initialize each frame
        for i = 1:num_bar%Plot each bar
            X=round(xarray(i,kk));
            load([matrix_folder,num2str(theta*4/pi),'\',num2str(X),'.mat']);% Load picture matrix
            temp = temp + a;
        end
        temp(500-35:500+35,1230:1280)=1;
        writeVideo(writerObj,temp);
    end
    %% Interval frame
    for l = 1:100 %1.67sec rest
        a = zeros(1024,1280);%Gray frame
        a(leftx_bd:rightx_bd, lefty_bd:righty_bd) = rest_mean_lumin;%Gray frame
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
end