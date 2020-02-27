function Oled_Gollish_OnOff_movie(makemovie_folder,video_folder,date,calibration_date,average_brightness)
%% It is adopted from STAR-METHODS of Activity Correlations between Direction-Selective Retinal Ganglion Cells Synergistically Enhance Motion Decoding from Complex Visual Scenes
%{
It used flashes of 500 ms of increased or decreased light level at 40% from mean luminance alternately, interleaved by 1.5 s of mean luminance. 

To assess the degree of ON versus OFF responses, an ON-OFF index was
calculated from the spike countsfonandfoff, measured in a time window of 50
to 550 ms after the onset of the ON- and OFF-flash, respectively, such that
the Flashes ON-OFF Index is (f_on-f_off)/(f_on+f_off)
%}
%average_brightness is mean luminance of OnOFF
%% Load boundary_set.mat and calibration.mat
load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
%% Parameter
on_brightness = interp1(real_lum,lum,average_brightness*1.4,'linear');
rest_brightness = interp1(real_lum,lum,average_brightness*1,'linear');
off_brightness = interp1(real_lum,lum,average_brightness*0.6,'linear');
flicker_on_brightness =0.9116;
flicker_off_brightness = 0.6006;
flicker_rest_brightness = 0.8;
num_cycle = 40;
on_time = 0.5; %s
off_time = 0.5; %s
rest_time = 1.5; %s
fps =60;  %freq of the screen flipping
single_trial = [];
second_trial = [];
for i = 1:on_time*fps
    single_trial = [single_trial on_brightness];
    second_trial = [second_trial flicker_on_brightness];
end
for i = 1:rest_time*fps
    single_trial = [single_trial rest_brightness];
    second_trial = [second_trial flicker_rest_brightness];
end
for i = 1:off_time*fps
    single_trial = [single_trial off_brightness];
    second_trial = [second_trial flicker_off_brightness];
end
for i = 1:rest_time*fps
    single_trial = [single_trial rest_brightness];
    second_trial = [second_trial flicker_rest_brightness];
end
total_trial = [];
flicker_trial = [];
for i = 1:num_cycle
    total_trial = [total_trial single_trial];
    flicker_trial = [flicker_trial second_trial];
end
cd(makemovie_folder);
all_file = dir('*.mat');
cd (video_folder);
%video frame file
name=[[date,'_Gollish_OnOff_movie_5min_Br50_Q100_',num2str(average_brightness),'mW']];
name

%video setting

video_fps=fps;
writerObj = VideoWriter([name,'.avi']);  %change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);
%start part: dark adaptation
for mm=1:fps*20
    img=zeros(screen_y,screen_x);
    img(lefty_bd:righty_bd,leftx_bd:rightx_bd) = rest_brightness;
    img(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4)) = flicker_rest_brightness;
    writeVideo(writerObj,img);
end
for kk =1:length(total_trial)
    a=zeros(screen_y,screen_x);%full screen pixel matrix %it's the LED screen size
    a(lefty_bd:righty_bd,leftx_bd:rightx_bd) = total_trial(kk);
    a(flicker_loc(1):flicker_loc(2),flicker_loc(3):flicker_loc(4)) = flicker_trial(kk);
    writeVideo(writerObj,a);
end

%end part video
for mm=1:10
    img=zeros(screen_y,screen_x);
    writeVideo(writerObj,img);
end
close(writerObj);
cd(makemovie_folder);
end
