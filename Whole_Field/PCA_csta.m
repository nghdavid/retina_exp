% Analysis STA experiment, by Rona
clear all
close all
load('rr.mat')
exp_folder = 'E:\20190825';
cd(exp_folder);
save_photo =1;%0 is no save on off photo and data, 1 is save
name = 'csta';%Name that used to save photo and data
bin = 5;  BinningInterval = bin*10^-3;  %ms
%% For unsorted spikes
load(['data\',name,'.mat'])
sorted = 0;
%% For sorted spikes
load(['sort\',name,'.mat'])
sorted = 1;

SamplingRate = 20000;
roi =1:60;


%% Create directory
mkdir Analyzed_data
if save_photo
mkdir FIG
cd FIG
mkdir cSTA
cd cSTA
mkdir sort
mkdir unsort
end

%% a_data as TriggerData
TriggerData = a_data(1,TimeStamps(1)*SamplingRate:TimeStamps(length(TimeStamps))*SamplingRate);% figure;plot(isi);
inten = downsample(TriggerData,SamplingRate*BinningInterval);

%% spike process
BinningTime = [TimeStamps(1) : BinningInterval : TimeStamps(end)];
BinningSpike = zeros(60,length(BinningTime));
for i = 1:60
    [n,xout] = hist(Spikes{i},BinningTime) ;
    BinningSpike(i,:) = n ;
end
BinningSpike(:,1) = 0;BinningSpike(:,end) = 0;
temprr=0;


%% STA
window1 = 1;  %STA window
window2 = 1;
cSTA = zeros(60, round(window1/BinningInterval)+round(window2/BinningInterval)+1);
useful_channelnumber = [];
total_STA = cell(1,60);
total_coeff = cell(1,60);
total_score = cell(1,60);
for nn = 1:length(roi)
    spike = BinningSpike(roi(nn),:);
    lum_STA = zeros(sum(n),round(window1/BinningInterval)+round(window2/BinningInterval)+1);
    num_spike =1;
    sts = [];
    temp = 0;
    spike(1:window1/BinningInterval) = 0;
    spike(length(spike)-window2/BinningInterval-10:end) = 0;
    for time_shift = round(window1/BinningInterval)+1:length(BinningTime)-round(window2/BinningInterval)
        if spike(time_shift) ~= 0
            for num = 1:BinningSpike(time_shift)
                lum_STA(num_spike,:) = inten(time_shift-round(window1/BinningInterval):time_shift+round(window2/BinningInterval));
                num_spike = num_spike+1;
            end
        end
    end
    
end