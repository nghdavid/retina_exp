function xarray=makeGratingvideo(makemovie_folder,video_folder, bar_real_width, temporal_frequency,number_repeat,date,calibration_date)


load(['C:\calibration\',calibration_date,'\calibrate_pt.mat'])%Load dotPositionMatrix
load(['C:\calibration\',calibration_date,'\screen_brightness.mat'])%Load screen_brightness
load(['C:\calibration\',calibration_date,'\boundary_set.mat'])
screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;

% %             width   interval
% % grating     300     300
% % jittering   150     150
bar_wid = bar_real_width/ micro_per_pixel/2 %unit of bar_real_width is micro
bar_interval = bar_wid*4;%The distance between bar and bar

cd (video_folder)
%video frame file
name=[date,'_Grating_',num2str(bar_real_width) ,'micro_',num2str(temporal_frequency),'HZ_',num2str(number_repeat),'times_Br50_Q100'];
name

video_fps=60;
writerObj = VideoWriter([name,'.avi']);
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);
Y =meaCenter_y;

for l = 1:60*10
    a = ones(1024,1280);
    a = a.*0.2;%Gray frame
    a(500-35:500+35,1230:1280)=0; % dark
    writeVideo(writerObj,a);
end


for time = 1:number_repeat%Number of repeat
    for reversal = [0 1]
        for theta = [0 pi/4 pi/2 pi*3/4]%Direction of moving bar
            if pi/4 <= theta && pi*3/4 >= theta
                longest_dis = mea_size_bm/sin(theta); %the distance a bar would travel
            else
                longest_dis = abs(mea_size_bm/cos(theta));
            end
            bar_le = longest_dis/2;
            num_bar = ceil(longest_dis/bar_interval)+1;%number of bar in movie
            num_move = 400; %Number of steps that move %6.67s

            R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];

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
            %video setting
            % Time=T; %sec
            for kk =1:length(xarray)

                a = zeros(1024,1280);%Initialize each frame
                cd(makemovie_folder);
                for i = 1:num_bar%Plot each bar
                    %record = [record ;kk i];
                    X=xarray(i,kk);
                    barX= X +(mea_size_bm-1)/2-(longest_dis/2);
                    barY=Y-lefty_bd;
                    Vertex = cell(2);
                    Vertex{1} = round([barX-bar_wid  barY-bar_le]);  %V1  V4
                    Vertex{2} = round([barX-bar_wid  barY+bar_le]);  %V2  V3
                    Vertex{3} = round([barX+bar_wid  barY+bar_le]);
                    Vertex{4} = round([barX+bar_wid  barY-bar_le]);
                    %rotation
                    for i = 1:4
                        Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
                    end
                    a = write_CalBar(a,Vertex, theta,  mea_size_bm); %a = the bar

                end
                %                         a(:,leftx_bd+11)=1;
                %                         a(:,leftx_bd+471)=1;
                a(500-35:500+35,1230:1280)=1;
                cd (video_folder)
                writeVideo(writerObj,a);



            end
            %Interval frame
            for l = 1:100%1.67sec rest
                a = ones(1024,1280);%Gray frame
                a = a.*0.2;
                a(500-35:500+35,1230:1280)=0; % dark
                writeVideo(writerObj,a);
            end
        end
    end
end
for mm=1:10
    img=zeros(1024,1280);
    img(500-35:500+35,1230:1280)=0.2; %gray
    writeVideo(writerObj,img);
end
close(writerObj);
end

