function makeLongOUvideo(makemovie_folder, theta, direction, video_folder, videoworkspace_folder, date)

%% OU RL



G_list=[1.55 2.45 3.2 4 5.7 7.6 10.5 5.03];  %list of Gamma valau


countt=1;

load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')

all_file = dir('*.mat');

fps =60;  %freq of the screen flipping
T=5*60; %second
dt=1/fps;
T=dt:dt:T;

screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;
screen_brightness(screen_brightness<0)=0;

%%rotation theta = 0 for RL theta
%theta must between [0,pi)
R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];

for Gvalue=G_list
      
    G_OU = Gvalue; % damping / only G will influence correlation time
    D_OU = 2700000; %dynamical range
    omega =G_OU/2.12;   % omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
    
    Gvalue
    x = zeros(1,length(T));
    x(1,1)=0; % since the mean value of damped eq is zero
    for uu = 1:length(T)-1
          x(uu+1) = (1-dt*G_OU/(2.12)^2)*x(uu)+sqrt(dt*D_OU)*randn;
    end
    %%% Normalize to proper moving range
    
    
    nrx=abs((mea_size_bm-2*bar_wid-1)/(max(x)-min(x)));
    Xarray2=x*nrx;
    Xarray3=Xarray2-min(Xarray2)+leftx_bd+bar_wid;%rearrange the boundary values
    newXarray=round(Xarray3);
    Y =meaCenter_y;

    cd (video_folder)
    %video frame file
    name=[date,'_OU_Dark_',direction,'_G',num2str(G_OU) ,'_5min_Br50_Q100_Long'];
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
    
    

    for kk =1:length(T)
        
        a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
         for y = 1 : length(screen_brightness)
            for x = 1 : length(screen_brightness)
                cal_x = dotPositionMatrix{y,x}(1);
                cal_y = dotPositionMatrix{y,x}(2);
                cal_lum = screen_brightness(y,x);
                a(cal_y,cal_x) = cal_lum;
            end
        end
        %OU RL bar trajectory
        X=newXarray(kk);

        barX=X-round(leftx_bd)+1;
        barY=round(Y)-round(lefty_bd)+1;
        bar_le = (mea_size_bm-1)/2;
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
                    a(cal_y,cal_x) = 0;
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
                    a(cal_y,cal_x) =0;
                end
            end
        end
        
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
    cd(videoworkspace_folder)
    %save parameters needed
    save([date,'_OU_Dark_',direction,'_G',num2str(G_OU) ,'_5min_Br50_Q100_Long','.mat'],'newXarray')
    
end
cd(makemovie_folder)

end