function OnOffvideo(makemovie_folder,  video_folder,  date)
%% ON OFF

%ONOFF times.
fps = 60;
repeat = 7;
rt = 5; % rest time
OT = 2; % dim time
T = 2; % bright time
ns = 3; % # of  step in a loop
period = rt+ns*(T+OT); % period of a loop
m = 0;% onoff 0-0.18
d = 1;% increment of lumin
x1 = 1:period*fps*repeat;
ey = zeros;
a2 = -0.1*ones;
at = 30;%adaptation time
aL = (m+d)/2;
ey(1:at*fps)=aL;
for i = 1:repeat
    ey(at*fps+period*fps*(i-1)+1:at*fps+period*fps*(i-1)+rt*fps)= aL; %«e¤­¬í
    %             a2(at*fps+period*fps*(i-1)+1:at*fps+period*fps*(i-1)+rt*fps)=-0.1;
    for j = 1:ns % how many a2 in a trial
        ey(at*fps+period*fps*(i-1)+rt*fps+(j-1)*(T+OT)*fps+1:at*fps+period*fps*(i-1)+rt*fps+(j-1)*(T+OT)*fps+T*fps)=m+d;
        ey(at*fps+period*fps*(i-1)+rt*fps+(j-1)*(T+OT)*fps+T*fps+1:at*fps+period*fps*(i-1)+rt*fps+(j-1)*(T+OT)*fps+T*fps+OT*fps)=m;
    end
    
end


fps =60;  %freq of the screen flipping

T=5*60; %second
dt=1/fps;
T=dt:dt:T;
cd(makemovie_folder);

all_file = dir('*.mat');
cd (video_folder);
%video frame file
name=[[date,'_ONOFF_5min_Br50_Q100']];
name


%video setting
Time=T; %sec
video_fps=fps;
writerObj = VideoWriter([name,'.avi']);  %change video name here!
writerObj.FrameRate = video_fps;
writerObj.Quality = 100;
open(writerObj);
%start part: dark adaptation


%%rotation theta = 0 for RL

for kk =1:length(ey)
    a=zeros(1024,1280);%full screen pixel matrix %it's the LED screen size
    if ey(kk) ~= 0
    %square_flicker
    a(1:1024, 1:1280) = ey(kk);
        if ey(kk) == aL
            a(500-35:500+35,1230:1280)=0.2;
        end
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

cd(makemovie_folder);
end
