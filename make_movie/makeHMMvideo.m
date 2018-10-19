%% HMM base from RL motion
clear all;
cd('D:\retina\makemovie');

mea_size=433;
mea_size_bm=465; %bigger mea size , from luminance calibrated region
meaCenter_x=631; 
meaCenter_y=580; 

leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
bar_le=floor((mea_size_bm-1)/2/sqrt(2)); %half of bar length / pixel number on LCD /total length = mea_size = 1919 um
bar_wid=11; %half of bar width / total length = 11*2+1=23 pixels = 65 um
%R-L
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar

G_list=[2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];  %list of Gamma value
%G_list=[20];
%G_list=[9]; 
countt=1;
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
cd('0421 new video Br25/rn_workspace');  
all_file = dir('*.mat');

fps =60;  %freq of the screen flipping 
T=7*60; %second
dt=1/fps;
T=dt:dt:T;

screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;

%%rotation theta = 0 for RL theta
%theta must between [0,pi)
theta =3*pi/4;
R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];

for Gvalue=G_list
    cd('D:\retina\makemovie\0421 new video Br25\rn_workspace');
    G_HMM =Gvalue; % damping / only G will influence correlation time
    D_HMM = 2700000; %dynamical range
    omega =G_HMM/2.12;   % omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
    %for randon number files ( I specifically choose some certain random seed series

    file = all_file(countt).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([filename]);
    name=[name];
    name
    Gvalue
    countt=countt+1;

    Xarray = zeros(1,length(T));
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    Vx = zeros(1,length(T));
    %Use rntest(t)!!!
    for t = 1:length(T)-1
            Xarray(t+1) = Xarray(t) + Vx(t)*dt;
            Vx(t+1) = (1-G_HMM*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D_HMM)*rntest(t); 
    end
    % Normalize to proper moving range
    nrx=abs((rightx_bar-leftx_bar-2*bar_wid)/(max(Xarray)-min(Xarray)));
    Xarray2=Xarray*nrx;
    Xarray3=Xarray2+leftx_bar+bar_wid-min(Xarray2);%rearrange the boundary values
    newXarray=round(Xarray3); 
    Y =meaCenter_y; 
    cd ('D:\retina\videos\0903_HMM_video_Br_50')
    %video frame file
    name=['0903 HMM UR_DL G',num2str(G_HMM) ,' 7min Br50 Q100'];
    name


    %video setting
    Time=T; %sec
    video_fps=fps;
    writerObj = VideoWriter([name,'.avi']);  %change video name here!
    writerObj.FrameRate = video_fps;
    writerObj.Quality = 100;
    open(writerObj);
    %start part: dark adaptation
    for mm=1:fps*20
        img=zeros(1024,1280);   
        writeVideo(writerObj,img);
    end

    
    
    %%draw moving bar
    for kk =1:length(T)
        a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size

        %HMM RL bar trajectory
        X=newXarray(kk);
        barX=X-round(leftx_bd);
        barY=round(Y)-round(lefty_bd);
        
        Vertex = cell(4);
        Vertex{1} = [barX-bar_wid  barY-bar_le];  %V1  V4
        Vertex{2} = [barX-bar_wid  barY+bar_le];  %V2  V3
        Vertex{3} = [barX+bar_wid  barY+bar_le];
        Vertex{4} = [barX+bar_wid  barY-bar_le];
        %ratation
        for i = 1:4
            Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
        end
        
        if theta == 0 || theta == pi/2  % vertical case
            for y = round(Vertex{1}(2)) : round(Vertex{3}(2))
                for x = round(Vertex{2}(1)):round(Vertex{4}(1))
                    cal_x = dotPositionMatrix{y,x}(1);
                    cal_y = dotPositionMatrix{y,x}(2);
                    cal_lum = screen_brightness(y,x);
                    a(cal_y,cal_x) = cal_lum;
                end
            end
            
        else 
            if theta > pi/2
                newVertex = Vertex{1};
                for i = 1:3
                    Vertex{i} = Vertex{i+1};
                end
                Vertex{4} = newVertex;
            end
            %stupid way
            %         for y = 1:mea_size_bm %floor(Vertex{1}(2)) : ceil(Vertex{3}(2))
            %             for x = 1:mea_size_bm %floor(Vertex{2}(2)) : ceil(Vertex{4}(2))
            %                 if (y-Vertex{1}(2)) - (Vertex{1}(1)-Vertex{2}(1))/(Vertex{1}(2)-Vertex{2}(2)) * (x-Vertex{1}(2)) >= 0 && (y-Vertex{4}(2)) - (Vertex{4}(1)-Vertex{3}(1))/(Vertex{4}(2)-Vertex{3}(2)) * (x-Vertex{4}(2)) <= 0
            %                     if (y-Vertex{1}(2)) - (Vertex{1}(1)-Vertex{4}(1))/(Vertex{1}(2)-Vertex{4}(2)) * (x-Vertex{1}(2)) >= 0 && (y-Vertex{2}(2)) - (Vertex{2}(1)-Vertex{3}(1))/(Vertex{2}(2)-Vertex{3}(2)) * (x-Vertex{2}(2)) <= 0
            %                         cal_x = dotPositionMatrix{y,x}(1);
            %                         cal_y = dotPositionMatrix{y,x}(2);
            %                         cal_lum = screen_brightness(y,x);
            %                         a(cal_y,cal_x) = cal_lum;
            %                     end
            %                 end
            %             end
            %         end
            
            %better way
                %pervent out of rnage
            if Vertex{2}(1) < 1
                min_x = 1;
            else
                min_x = Vertex{2}(1);
            end
            if Vertex{4}(1) > mea_size_bm
                max_x = mea_size_bm;
            else
                max_x = Vertex{4}(1);
            end
            
            for x = floor(min_x) : ceil(max_x)
                % find bar region
                if x < Vertex{1}(1)
                    lower_y = Vertex{1}(2) + (Vertex{1}(2)-Vertex{2}(2))/(Vertex{1}(1)-Vertex{2}(1)) * (x-Vertex{1}(1));
                else
                    lower_y = Vertex{1}(2) + (Vertex{1}(2)-Vertex{4}(2))/(Vertex{1}(1)-Vertex{4}(1)) * (x-Vertex{1}(1));
                end
                if x < Vertex{3}(1)
                    upper_y = Vertex{3}(2) + (Vertex{3}(2)-Vertex{2}(2))/(Vertex{3}(1)-Vertex{2}(1)) * (x-Vertex{3}(1));
                else
                    upper_y = Vertex{3}(2) + (Vertex{3}(2)-Vertex{4}(2))/(Vertex{3}(1)-Vertex{4}(1)) * (x-Vertex{3}(1));
                end
                
                    %pervent out of rnage
                if lower_y < 1
                    lower_y = 1;
                end
                if upper_y > mea_size_bm
                    upper_y = mea_size_bm;
                end
                
                for y = floor(lower_y) : ceil(upper_y)
                    cal_x = dotPositionMatrix{y,x}(1);
                    cal_y = dotPositionMatrix{y,x}(2);
                    cal_lum = screen_brightness(y,x);
                    a(cal_y,cal_x) = cal_lum;
                end
            end
        end
        %expandind theta
        
%         if Vertex{1}(2) < 1
%             min_y = 1;
%         else
%             min_y = Vertex{1}(2);
%         end
%         if Vertex{3}(2) > mea_size_bm
%             max_y = 1;
%         else
%             max_y = Vertex{3}(2);
%         end
        %square_flicker
        if mod(kk,3)==1 %odd number
        a(500-35:500+35,1230:1280)=1; % white square
        elseif mod(kk,3)==2
        a(500-35:500+35,1230:1280)=0.2; %gray 
        else
        a(500-35:500+35,1230:1280)=0; % dark
        end
        writeVideo(writerObj,a);
    end

    %end part video
    for mm=1:10
        img=zeros(1024,1280);
        img(500-35:500+35,1230:1280)=0.2; %gray
        writeVideo(writerObj,img);
    end
    
    img=zeros(1024,1280);
    writeVideo(writerObj,img);
    
    close(writerObj);
    cd('D:\retina\videos\0903_HMM_video_Br_50')
    %save parameters needed 
    save(['0903 HMM UR_DL G',num2str(G_HMM) ,' 7min Br50 Q100','.mat'],'newXarray')
    
end
cd('D:\retina\makemovie')
