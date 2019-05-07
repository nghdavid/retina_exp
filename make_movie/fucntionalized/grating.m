clear all;
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')
parameter1 = [376,94,1,800];%1199um
parameter2 = [152 ,38,3,400];%485um
parameter3 = [90,22,5,400];%287um
parameters = [parameter1;parameter2;parameter3];



video_fps=60;
writerObj = VideoWriter('grating.avi');%change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 80;
open(writerObj);
Y =meaCenter_y;
%start part: dark adaptation
for mm=1:fps*20
    img=zeros(1024,1280);
    writeVideo(writerObj,img);
end


for k = 1:3
    for theta = [0 pi/2]%Direction of moving bar
        for reversal = [0 1]
            for coherent = [0 1]%grating set 0, coherent set 1
                bar_interval = parameters(k,1);%The distance between bar and bar
                bar_wid = parameters(k,2);%The bar width is 2*bar_wid+1
                num_bar = parameters(k,3);%number of bar in movie
                num_move = parameters(k,4);%Number of steps that move
                
                screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
                screen_brightness(screen_brightness>1)=1;
                screen_brightness(screen_brightness<0)=0;
                R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];

                xarray = zeros(num_bar,num_move);%Array that store each bar postion(each row store each bar postions)
                xarray(1,1) = leftx_bd+bar_wid+1;%Left bar first position

                
                if coherent %grating set 0, coherent set 1
                    for i = 2:length(xarray)%Initialize left bar
                        if xarray(1,i-1) <= xarray(1,1)
                            xarray(1,i) = xarray(1,i-1)+2*randsample([1,0],1);
                        else
                            xarray(1,i) = xarray(1,i-1)+2*randsample([1,-1],1);
                        end

                    end
                else
                    for i = 2:length(xarray)
                        xarray(1,i) = xarray(1,i-1)+2;
                    end
                end

                if num_bar > 1
                    for i = 2:size(xarray,1)%Calculate other bar
                        xarray(i,:) = xarray(i-1,:)+bar_interval;
                    end
                end
                if reversal
                    xarray = fliplr(xarray);%For reverse direction
                end

                %video setting
                % Time=T; %sec
                
                for kk =1:length(xarray)
                    if xarray(1,kk) > 0%Grating frame

                        a = zeros(1024,1280);%Initialize each frame

                        for i = 1:num_bar%Plot each bar

                            X=xarray(i,kk);

                            barX=X-round(leftx_bd);
                            barY=round(Y)-round(lefty_bd);

                            Vertex = cell(4);
                            Vertex{1} = [barX-bar_wid  barY-bar_le];  %V1  V4
                            Vertex{2} = [barX-bar_wid  barY+bar_le];  %V2  V3
                            Vertex{3} = [barX+bar_wid  barY+bar_le];
                            Vertex{4} = [barX+bar_wid  barY-bar_le];
                            %rotation
                            for i = 1:4
                                Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
                            end

                            a = write_CalBar(a,Vertex, theta,  mea_size_bm); %a = the bar

                        end
                        a(500-35:500+35,1230:1280)=1;
                        writeVideo(writerObj,a);

                        %Interval frame
                        for l = 1:100
                            a = zeros(1024,1280).*0.2;%Gray frame
                            writeVideo(writerObj,a);
                        end
                    end
                end
            end
        end
    end
end

for mm=1:10
    img=zeros(1024,1280);
    
    writeVideo(writerObj,img);
end
close(writerObj);

