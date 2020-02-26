clear all;
close all;
type = 'DSXGA_color_wf';
type = 'random';
%% Phychotoolbox
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',2, [0 0 0]); %black background


%% Center and size of square
mea_size=800; %use odd number!
baseRect = [0 0 mea_size mea_size];  %use odd number!
meaCenter_x=400;
meaCenter_y=300;
centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);
lum = [120:245]./255;%Screen luminance to calibrate
lum = lum( randperm(length(lum),length(lum)));
lum2 = lum;
% lum = [255:-1:0]./255;
measure_lum = zeros(1,length(lum));
%% DAQ settings
rate=10000;  
du=1;
PDmax=11;%uw
span=500;
%% Calibration
t = 1;
for brightness = lum

%% Change luminance
Screen('FillRect', w, brightness*255, centeredRect);
Screen('Flip', w);
brightness
pause(0.1)
%% DAQ Read
daq_in = daqmx_Task('chan','Dev1/ai0' ,'rate',rate, 'SampleNum', du*rate);
daq_in.read;
lumin=daq_in.data;
lumin = smooth(lumin,span)/2*PDmax;
measure_lum(t) = mean(lumin(du*rate*0.25:du*rate*0.75));
t=t+1;
end
Screen('Flip', w);

real_mea_size = (0.8*0.6*(1430/188)^2);%/193/193*800*600;%mm^2
real_lum = (measure_lum/real_mea_size*1000)';
%136/(0.8*0.6*(1430/188)^2)
figure(2)
scatter(lum,real_lum);
figure(1)
[lum I] = sort(lum);
real_lum =smooth(real_lum(I));
plot(lum,real_lum);
title(['Gamma correction'])
xlabel('oled luminance')
ylabel('real intensity (mW/m^2)')
xlim([0,1])
ddd=date;
save([ddd,'_',type,'_lum_calibration.mat'],'real_lum','real_mea_size','lum','measure_lum','PDmax')