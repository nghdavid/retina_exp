function Gollish_OnOff_movie(makemovie_folder,  video_folder,  date)
%% It is adopted from STAR-METHODS of Activity Correlations between Direction-Selective Retinal Ganglion Cells Synergistically Enhance Motion Decoding from Complex Visual Scenes
%{
It used flashes of 500 ms of increased or decreased light level at 40% from mean luminance alternately, interleaved by 1.5 s of mean luminance. 

To assess the degree of ON versus OFF responses, an ON-OFF index was
calculated from the spike countsfonandfoff, measured in a time window of 50
to 550 ms after the onset of the ON- and OFF-flash, respectively, such that
the ．．Flashes ON-OFF Index・・ is (f_on-f_off)/(f_on+f_off)
%}

%0.8 ONOFF parameter 
on_brightness =0.9116;
off_brightness = 0.6006;
rest_brightness = 0.8;
%0.5 ONOFF parameter 
% on_brightness =0.6072;
% off_brightness = 0.3704;
% rest_brightness = 0.5;

num_cycle = 40;
on_time = 0.5; %s
off_time = 0.5; %s
rest_time = 1.5; %s
fps =60;  %freq of the screen flipping
single_trial = [];
for i = 1:on_time*fps
    single_trial = [single_trial on_brightness];
end
for i = 1:rest_time*fps
    single_trial = [single_trial rest_brightness];
end
for i = 1:off_time*fps
    single_trial = [single_trial off_brightness];
end
for i = 1:rest_time*fps
    single_trial = [single_trial rest_brightness];
end
total_trial = [];
for i = 1:num_cycle
    total_trial = [total_trial single_trial];
end
cd(makemovie_folder);
load('boundary_set.mat')

all_file = dir('*.mat');
cd (video_folder);
%video frame file
name=[[date,'_Gollish_OnOff_movie_5min_Br50_Q100_',num2str(rest_brightness)]];
name


%video setting

video_fps=fps;
writerObj = VideoWriter([name,'.avi']);  %change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);
%start part: dark adaptation
for mm=1:fps*20
    img=ones(1024,1280)*rest_brightness;
    writeVideo(writerObj,img);
end



for kk =total_trial
    a=ones(1024,1280);%full screen pixel matrix %it's the LED screen size
    a = a.*kk;
    writeVideo(writerObj,a);
end

%end part video
for mm=1:10
    img=zeros(1024,1280);
    writeVideo(writerObj,img);
end



close(writerObj);

cd(makemovie_folder);
end
