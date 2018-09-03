%% OU RL
clear all;

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

G_list=[1.55 2.45 3.2 4 5.7 7.6 10.5 5.03];  %list of Gamma valau
countt=1;
load('E:\retina\makemovie\calibrate_pt.mat')%Load dotPositionMatrix
load('E:\retina\makemovie\screen_brightness.mat')%Load screen_brightness

all_file = dir('*.mat');

fps =60;  %freq of the screen flipping 
T=5*60; %second
dt=1/fps;
T=dt:dt:T;

screen_brightness=screen_brightness./255; %make it to 0-1 range for double (due to imwrite format)
screen_brightness(screen_brightness>1)=1;

%%rotation theta = 0 for RL
theta = 0;
R_matrix = [cos(theta) sin(theta) ; -sin(theta) cos(theta)];

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
    
    
    nrx=abs((rightx_bar-leftx_bar-2*bar_wid)/(max(x)-min(x)));
    x2=x*nrx;
    x3=x2-min(x2)+leftx_bar+bar_wid;%rearrange the boundary values
    new_x=round(x3); 
    Y =meaCenter_y;

    cd ('E:\retina\videos\0903_OU_video_Br_50')
    %video frame file
    name=['0819 OU RL G',num2str(G_OU) ,' 5min Br50 Q100'];
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

        %OU RL bar trajectory
        X=new_x(kk);

        barX=X-round(leftx_bd);
        barY=round(Y)-round(lefty_bd);
        for y = barY-bar_le: barY+bar_le
            for x = barX-bar_wid:barX+bar_wid
               R_cor = ceil(R_matrix*[x-(mea_size_bm+1)/2  y-(mea_size_bm+1)/2]'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]'); %ratation
               %R_cor = [x y];
               if R_cor(2) < 1
                   R_cor(2)
                   R_cor(2) = 1;
               elseif R_cor(2) > mea_size_bm
                   R_cor(2)
                   R_cor(2) = mea_size_bm;
               else                   
               end
               if R_cor(1) < 1
                   R_cor(1)
                   R_cor(1) = 1;
               elseif R_cor(1) > mea_size_bm
                   R_cor(1)
                   R_cor(1) = mea_size_bm;
               else
               end
               
               cal_x = dotPositionMatrix{R_cor(2),R_cor(1)}(1);
               cal_y = dotPositionMatrix{R_cor(2),R_cor(1)}(2);
               cal_lum = screen_brightness(R_cor(2),R_cor(1));
               a(cal_y,cal_x) = cal_lum;
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
    close(writerObj);
    cd('E:\retina\makemovie\OU_0903_video_Br_50_workspace')
    %save parameters needed 
    save(['0903 OU RL G',num2str(G_OU) ,' 5min Br50 Q100','.mat'],'new_x')
    
end
cd('E:\retina\makemovie')
