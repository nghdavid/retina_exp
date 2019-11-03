%% Code for PCA of cSTA result
%Methods from "Retinal Ganglion Cells Can Rapidly Change Polarity from Off to On'
clear all;
close all;
exp_folder = '\\LEO\Leo\0807exp\';
cd(exp_folder);
save_photo =1;%0 is no save on off photo and data, 1 is save
name = 'csta';%Name that used to save photo and data
bin = 5;  BinningInterval = bin*10^-3;  %ms
%% For unsorted spikes
load(['data\',name,'.mat'])
%% For sorted spikes
load(['sort\',name,'.mat'])

SamplingRate = 20000;
roi =1:60;


%% Create directory
mkdir Analyzed_data\PCA
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
inten = inten-mean(inten);
inten = 2*(inten-min(inten))/(max(inten)-min(inten))-1;
%% spike process
BinningTime = [TimeStamps(1) : BinningInterval : TimeStamps(end)];
BinningSpike = zeros(60,length(BinningTime));
for i = 1:60
    [n,xout] = hist(Spikes{1,i},BinningTime) ;
    BinningSpike(i,:) = n ;
end
BinningSpike(:,1) = 0;BinningSpike(:,end) = 0;
temprr=0;


%% STA
window1 = 0.5;  %pre spike window
window2 = 0.0;  %post spike window
cSTA = zeros(60, round(window1/BinningInterval)+round(window2/BinningInterval)+1);
useful_channelnumber = [];
total_STA = cell(1,60);% Store each channel STA
total_coeff = cell(1,60);% Eigenvector(principal components)
total_score = cell(1,60);% principal component scores
total_PCA1 = cell(1,60);%Projection of each spike triggered stimulus to principal component 1
total_PCA2 = cell(1,60);%Projection of each spike triggered stimulus to principal component 2
time=[-round(window1/BinningInterval) :round(window2/BinningInterval)]*BinningInterval;%Time before spike

for channel = roi
    spike = BinningSpike(channel,:);
    spike(1:window1/BinningInterval) = 0;
    spike(length(spike)-window2/BinningInterval-10:end) = 0;
    lum_STA = zeros(sum(spike),round(window1/BinningInterval)+round(window2/BinningInterval)+1);%It store every spike triggered average
    num_spike =1;
    %Run through every bin
    for time_shift = round(window1/BinningInterval)+1:length(BinningTime)-round(window2/BinningInterval)
        if spike(time_shift) ~= 0
            for num = 1:spike(time_shift)
                %Run through pre spike 
                lum_STA(num_spike,:) = inten(time_shift-round(window1/BinningInterval):time_shift+round(window2/BinningInterval));
                num_spike = num_spike+1;
            end
        end
    end
    total_STA{channel} = lum_STA;
    if isempty(total_STA{channel})
        continue
    end
    [coeff,score,latent] = pca(total_STA{channel});
    PCA1 = zeros(1,num_spike-1);
    PCA2 = zeros(1,num_spike-1);
    if size(coeff,2) >=2%Check if has two principal components
        for i = 1:num_spike-1
            PCA1(1,i) = dot(lum_STA(i,:),coeff(:,1));%Projection of each spike triggered stimulus to principal component 1
            PCA2(1,i) = dot(lum_STA(i,:),coeff(:,2));%Projection of each spike triggered stimulus to principal component 2
        end
        if num_spike/(length(TriggerData)/SamplingRate)>0.5%Check firing rate is over 0.5 HZ
            figure(channel)
            scatter(PCA1,PCA2)%Scatter plot of projection to PCA1 and PCA2
            xlabel('Stimulus*PCA1')
            ylabel('Stimulus*PCA2')
            title('Scatter plot of projection to PCA1 and PCA2')
            axis equal
            total_PCA1{channel} = PCA1;%Projection of each spike triggered stimulus to principal component 1
            total_PCA2{channel} = PCA2;%Projection of each spike triggered stimulus to principal component 2
        end
    end
    total_coeff{channel} = coeff;% principal component scores
    total_score{channel} = score;% principal component variances
    save([exp_folder,'\Analyzed_data\PCA\',name,'.mat'],'time','total_STA','total_coeff','total_score','total_PCA1','total_PCA2')
end

