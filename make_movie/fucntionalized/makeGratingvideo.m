function makeGratingvideo(makemovie_folder,video_folder,date,calibration_date,mean_lumin)

load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
% %             width   interval
% % grating     300     300
% % jittering   150     150
rest_mean_lumin = interp1(real_lum,lum,mean_lumin/2,'linear');
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
    a = ones(1024,1280);
    a = a.*rest_mean_lumin;%Gray frame
    a(500-35:500+35,1230:1280)=0; % dark
    writeVideo(writerObj,a);
end

cd(makemovie_folder)
for bar_real_width = [300,600]%Number of repeat
    for temporal_frequency = [0.375 0.75,1.5]%Number of repeat
        bar_wid = bar_real_width/ micro_per_pixel/2%unit of bar_real_width is micro
        bar_interval = bar_wid*4;%The distance between bar and bar
    for reversal = [0 1]%For opposite direction
        for theta = [0 pi/4 pi/2 pi*3/4]%Direction of moving bar
            %% Check each grating matrix have calculated or not 
            matrix_folder = ['C:\',calibration_date,'grating_matrix_',num2str(mean_lumin),'mW_',num2str(bar_real_width) ,'micro_',num2str(temporal_frequency),'HZ\'];
            if exist([matrix_folder,num2str(theta*4/pi)]) == 0
                make_grating_matrix(calibration_date,mean_lumin,theta*4/pi,bar_real_width,temporal_frequency)
            end
            
            %% Calculate each bar
            if pi/4 <= theta && pi*3/4 >= theta
                longest_dis = mea_size_bm/sin(theta); %the distance a bar would travel
            else
                longest_dis = abs(mea_size_bm/cos(theta));
            end
            bar_le = longest_dis/2;
            num_bar = ceil(longest_dis/bar_interval)+1;%number of bar in movie
            num_move = 400; %Number of steps that move %6.67s
            if temporal_frequency == 0.375
                num_move = num_move*2;
            end
            xarray = zeros(num_bar,num_move);%Array that store each bar postion(each row store each bar postions)
            xarray(1,1) = 1;%leftx_bd+bar_wid+1;%Left bar first position
            for i = 2:num_move
                xarray(1,i) = xarray(1,i-1)+temporal_frequency*bar_real_width/micro_per_pixel/60*2;
            end
            if num_bar > 1
                for i = 2:num_bar%Calculate other bar
                    xarray(i,:) = xarray(i-1,:)+bar_interval;
                end
            end
            xarray = mod(xarray-1 , num_bar*bar_interval) +1-bar_wid; % set all xarray into mea region
            if reversal
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
            for l = 1:100%1.67sec rest
                a = ones(1024,1280);%Gray frame
                a = a.*rest_mean_lumin;
                a(500-35:500+35,1230:1280)=0;% dark
                writeVideo(writerObj,a);
            end
        end
    end
    end
end
%% Ending
for mm=1:10
    img=zeros(1024,1280);
    img(500-35:500+35,1230:1280)=0.2; %gray
    writeVideo(writerObj,img);
end
close(writerObj);
end

