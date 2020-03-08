%% This code calculate cSTA whole field intensity STA
close all;
clear all;
%% Setting
code_folder = pwd;
exp_folder = 'E:\20200306';
load('rr.mat')
cd(exp_folder);
sorted = 0;
save_photo = 1;
name = '0224_cSTA_wf_3min_Q100_re';
mean_lumin = 6.5;
type = 'cSTA';
%% Make directory
mkdir Analyzed_data
mkdir FIG cSTA
if sorted
    sort_directory = 'sort';
    mkdir Analyzed_data sort
    mkdir FIG\cSTA sort
    cd sort_merge_spike
    load(['sort_merge_', name, '.mat'])
else
    sort_directory = 'unsort';
    mkdir Analyzed_data unsort
    mkdir FIG\cSTA unsort
    cd merge
    load(['merge_', name, '.mat'])
end

%% BinningSpike
forward = 60;%60 bins (1s) before spikes for calculating STA. Only half of it would be plot out.
backward = 0;%0 bins after spikes for calculating STA
time=[-forward :backward]*BinningInterval*1000;% ms
BinningTime =diode_BT;
bin=BinningInterval*10^3; %ms
TheStimuli=bin_pos;  %Gaussian noise
stimulus_length = TimeStamps(2)-TimeStamps(1);
analyze_spikes = reconstruct_spikes;
%% Calculate STA
sum_n = zeros(1,60);
cSTA = zeros(60,forward+backward+1);
dcSTA = zeros(6,forward+backward+3);
for i = 1:60  % i is the channel number
    [n,~] = hist(analyze_spikes{i},BinningTime) ;
    BinningSpike(i,:) = n ;
    sum_n(i) = sum_n(i)+ sum(BinningSpike(i,forward+1:length(BinningTime)-backward));
    for time_shift = forward+1:length(BinningTime)-backward
        cSTA(i,:) = cSTA(i,:) + BinningSpike(i,time_shift)*TheStimuli(time_shift-forward:time_shift+backward);
    end
    if sum_n(i)
        cSTA(i,:) = cSTA(i,:)/sum_n(i);
    end
    dcSTA(i,:) = [cSTA(i,:) mean_lumin mean_lumin] - [mean_lumin mean_lumin cSTA(i,:)];
end
dcSTA(:,end) = [];
dcSTA(:,1) = [];
cSTA = cSTA-mean_lumin;

%% Exclude useless channel
useful_channelnumber = [];
for i = 1:60
    number_spike = length(analyze_spikes{i});
    if number_spike/(stimulus_length) <= 1%Firing rate is smaller than zero
        cSTA(i,:) = NaN;
    elseif isempty(find( abs(cSTA(i,round(length(cSTA)/2):end))>= 7*std(cSTA(i,1:round(length(cSTA)/2)))))
        cSTA(i,:) = NaN;
    else
        useful_channelnumber = [useful_channelnumber i];
    end
end

%% Plot figure
plot_all_channel(type,save_photo,time(round(size(cSTA,2)/2):end),cSTA(:,round(size(cSTA,2)/2):end),useful_channelnumber,exp_folder,sorted,name);
%% Calculate OnOff Index and dSTA/dt
tau = zeros(1,60);
OnOff_Index = ones(1,60)*-10000000;
for channelnumber=useful_channelnumber
    OnOff_Index(channelnumber) = sum(cSTA(channelnumber,round(length(cSTA)/2)-200/bin:round(length(cSTA)/2))) / sum(abs(cSTA(channelnumber, round(length(cSTA)/2)-200/bin:round(length(cSTA)/2))));
    diff_smooth_cSTA = diff(smooth(cSTA(channelnumber,:)));
    for l = fliplr(2:length(diff_smooth_cSTA))
        if diff_smooth_cSTA(l)*diff_smooth_cSTA(l-1) <= 0
            [channelnumber l]
            tau(channelnumber) = (length(diff_smooth_cSTA)-l+1)*bin;
            break
        end
    end
end
OnOff_Index(find(OnOff_Index == -10000000)) = NaN;
%% Histogram of on off index
figure;
hist(OnOff_Index(useful_channelnumber));
xlim([-1 1])
if save_photo
    save([exp_folder,'\Analyzed_data\',sort_directory,'\',name,'.mat'],'time','cSTA', 'dcSTA', 'OnOff_Index', 'tau')
end

cd (code_folder)