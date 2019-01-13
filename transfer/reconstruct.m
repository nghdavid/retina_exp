%load mat file first
clear all
close all
x = 7

%%
lumin=[];
lumin=a_data(2,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
figure;plot(lumin);

start_lum = 34376;
diode_start = [];
for i = 1:length(lumin)
    if (lumin(i)-start_lum)<=0.0001
        diode_start = [diode_start i];
    end
end
% Samplingrate=20000; %fps of diode in A3
% idealStimuli=[];

% start_lum=3.5*10^4; %81*10^4;


%find stimulation period
% diode_start=find(lumin>=start_lum,1);
% 
% diode_start=find(lumin>=start_lum);
% tempp=find(lumin<=start_lum);
% diode_end=tempp(end);

% plot
figure;plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
% hold on;plot(diode_end,lumin(diode_end),'r*');
