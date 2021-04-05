function make_OLED_scene(makemovie_folder, video_folder, videoworkspace_folder,mat_directory,date,calibration_date)
    
    %% Load boundary_set.mat and calibration.mat
    load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
    load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
    cd(mat_directory)
    load([mat_directory,'\stimulus.000001.mat']);
    cd(mat_directory)
    pic_size = size(bgimage,1);%Picture size that tina gives you
    all_file = dir('*.mat');%Load random seed
    %% Scene setting
    total_frame = length(all_file);
    pic = (mea_size_bm-pic_size)/2;
    newXarray = zeros(1,total_frame);
    leftx_bar=leftx_bd+pic; %Left boundary of bar
    rightx_bar=rightx_bd-pic; %Right boundary of bar
    upy_bar = lefty_bd+pic;
    downy_bar = righty_bd-pic;
    %% Video setting
    cd(video_folder)
    fps = 60;%freq of the screen flipping
    video_fps=fps;
    name=[date,'saccade']
    writerObj = VideoWriter([name,'.avi']);  %change video name here!
    writerObj.FrameRate = video_fps;
    writerObj.Quality = 100;
    open(writerObj);
    %% Start part: dark adaptation
    for mm=1:fps*20
        img=zeros(screen_y,screen_x);
        writeVideo(writerObj,img);
    end

    %% Load matrix
    for kk =0:total_frame-1
        if kk < 9
            load([mat_directory,'\stimulus.00000',int2str(kk+1),'.mat'])
        elseif kk < 99
            load([mat_directory,'\stimulus.0000',int2str(kk+1),'.mat'])
        elseif  kk <  999
            load([mat_directory,'\stimulus.000',int2str(kk+1),'.mat'])
        elseif  kk <  9999
            load([mat_directory,'\stimulus.00',int2str(kk+1),'.mat'])
        elseif  kk <  99999
            load([mat_directory,'\stimulus.0',int2str(kk+1),'.mat'])
        else
            load([mat_directory,'\stimulus.',int2str(kk+1),'.mat'])
        end
        imgs=mat2gray(bgimage);
        a=zeros(screen_y,screen_x);%full screen pixel matrix %it's the LED screen size
        pic_x = 1;
        pic_y = 1;
        
        %% Write image
        for y = upy_bar - lefty_bd : downy_bar - lefty_bd
            for x = leftx_bar - leftx_bd : rightx_bar - leftx_bd
                a(y+lefty_bd-1,x+leftx_bd-1) = imgs(pic_y,pic_x);
                pic_x = pic_x + 1;
            end
            pic_x = 1;
            pic_y = pic_y + 1;
        end
        
        %% square_flicker
        if mod(kk+1,3)==1 %odd number
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=1; % white square
        elseif mod(kk+1,3)==2
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
        else
            a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0; % dark
        end
        disp(['Process is ',num2str(kk/total_frame*100),'%'])
        writeVideo(writerObj,a);
        newXarray(kk+1) = kk+1;
        clear imgs;
    end    
    %% end part video
    for mm=1:10
        img=zeros(screen_y,screen_x);
        img(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4))=0.2; %gray
        writeVideo(writerObj,img);
    end

    img=zeros(screen_y,screen_x);
    writeVideo(writerObj,img);
    close(writerObj);
    cd(videoworkspace_folder)
    save([name,'.mat'],'newXarray')
    cd(makemovie_folder)
end
