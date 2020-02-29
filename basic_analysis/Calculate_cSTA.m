%% This code calculate cSTA whole field intensity STA
%rewrite from which for bar position STA
close all;
clear all;
code_folder = pwd;
exp_folder = 'D:\Leo\0225';
load('oled_boundary_set.mat')
cd(exp_folder);
sorted = 0;
XOsave = 1;
unit = 1;
name = '0224_cSTA_wf_3min_Q100'
mean_lumin = 6.5;
mkdir Analyzed_data
mkdir FIG
if sorted
    mkdir Analyzed_data sort
    mkdir FIG sort
    cd sort_merge_spike
    load(['sort_merge_', name, '.mat'])
else
    mkdir Analyzed_data unsort
    mkdir FIG unsort
    cd merge
    load(['merge_', name, '.mat'])
end
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;
forward = 60;%60 bins (1s) before spikes for calculating STA. Only half of it would be plot out.
backward = 0;%0 bins after spikes for calculating STA

% put your stimulus here!!
TheStimuli=bin_pos;  %recalculated bar position
time=[-forward :backward]*BinningInterval*1000;% ms
% Binning
bin=BinningInterval*10^3; %ms
BinningTime =diode_BT;

%% BinningSpike
BinningSpike = zeros(60,length(BinningTime));
analyze_spikes = cell(1,60);

complex_channel = [];
if sorted
    if unit == 0
        fileID = fopen([exp_folder, '\Analyzed_data\unit_a.txt'],'r');
        formatSpec = '%c';
        txt = textscan(fileID,'%s','delimiter','\n');
        for m = 1:size(txt{1}, 1)
            complex_channel = [complex_channel str2num(txt{1}{m}(1:2))];
        end
    end
    for i = 1:60  % i is the channel number
        analyze_spikes{i} =[];
        if unit == 0
            if any(complex_channel == i)
                unit_a = str2num(txt{1}{find(complex_channel==i)}(3:end));
                for u = unit_a
                    analyze_spikes{i} = [analyze_spikes{i} sorted_spikes{u,i}'];
                end
            else
                analyze_spikes{i} = [analyze_spikes{i} sorted_spikes{1,i}'];
            end
        else
            for u = unit
                analyze_spikes{i} = [analyze_spikes{i} sorted_spikes{u,i}'];
            end
        end
        analyze_spikes{i} = sort(analyze_spikes{i});
    end
else
    analyze_spikes = reconstruct_spikes;
end

%% and calculate STA
sum_n = zeros(1,60);
cSTA = zeros(60,forward+backward+1);
dcSTA = zeros(6,forward+backward+3);
for i = 1:60  % i is the channel number
    %         if sum(abs(TheStimuli(i,:))) <= 0
    %             disp(['channel ',int2str(i),'does not have RF center'])
    %             continue
    %         end
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


useful_channelnumber = [];
for i = 1:60
    if isempty(find( abs(cSTA(i,round(size(cSTA,2)/2):end))>= 7*std(cSTA(i,1:round(size(cSTA,2)/2)))))
        cSTA(i,:) = NaN;
    else
        useful_channelnumber = [useful_channelnumber i];
    end
end

%% ploting and saving dtata and figure
rr =[9,17,25,33,41,49,...
    2,10,18,26,34,42,50,58,...
    3,11,19,27,35,43,51,59,...
    4,12,20,28,36,44,52,60,...
    5,13,21,29,37,45,53,61,...
    6,14,22,30,38,46,54,62,...
    7,15,23,31,39,47,55,63,...
    16,24,32,40,48,56];
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
for channelnumber=useful_channelnumber
    if sum(cSTA(channelnumber,:)) == 0
        disp(['channel ',int2str(channelnumber),' does not have RF center'])
        continue
    end
    axes(ha(rr(channelnumber)));
    plot(time(round(size(cSTA,2)/2):end),cSTA(channelnumber,round(size(cSTA,2)/2):end),'LineWidth',2,'LineStyle','-');hold on;
    grid on
    %Y axis is um
    title(channelnumber)
end
set(gcf,'units','normalized','outerposition',[0 0 1 1])
fig = gcf;
fig.PaperPositionMode = 'auto';

if XOsave
    if sorted
        save([exp_folder,'\Analyzed_data\sort\',name,'.mat'],'time','cSTA')
        saveas(fig,[exp_folder,'\FIG\sort\',name,'.tiff'])
        saveas(gcf,[exp_folder,'\FIG\sort\',name,'.fig'])
    else
        save([exp_folder,'\Analyzed_data\unsort\',name,'.mat'],'time','cSTA')
        saveas(fig,[exp_folder,'\FIG\unsort\',name,'.tiff'])
        saveas(gcf,[exp_folder,'\FIG\unsort\',name,'.fig'])
    end
end


figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.03 .01],[0.02 0.02],[.01 .01]);
for channelnumber=useful_channelnumber
    axes(ha(rr(channelnumber)));
    plot(time(round(size(cSTA,2)/2):end),dcSTA(channelnumber,round(size(cSTA,2)/2):end),'LineWidth',1.5);%,'color',cc(z,:)
    title(channelnumber)
end
if XOsave
    if sorted
        saveas(gcf,[exp_folder,'\FIG\sort\', 'dcsta_',name,'.tiff'])
    else
        saveas(gcf,[exp_folder,'\FIG\unsort\', 'dcsta_',name,'.tiff'])
    end
end
%% Calculate OnOff Index and dSTA/dt
tau =  zeros(1,60);
Filker_OnOff_Index = ones(1,60)*-10000000;
for channelnumber=useful_channelnumber
    Filker_OnOff_Index(channelnumber) = sum(cSTA(channelnumber,round(length(cSTA)/2)-200/bin:round(length(cSTA)/2))) / sum(abs(cSTA(channelnumber, round(length(cSTA)/2)-200/bin:round(length(cSTA)/2))));
    diff_smooth_cSTA = diff(smooth(cSTA(channelnumber,:)));
    for l = fliplr(2:length(diff_smooth_cSTA))
        if diff_smooth_cSTA(l)*diff_smooth_cSTA(l-1) <= 0
            [channelnumber l]
            tau(channelnumber) = (length(diff_smooth_cSTA)-l+1)*bin;
            break
        end
    end
end
Filker_OnOff_Index (find(Filker_OnOff_Index == -10000000)) = NaN;
figure;
hist(Filker_OnOff_Index(useful_channelnumber));
xlim([-1 1])
set(gcf,'units','normalized','outerposition',[0 0 1 1])
fig =gcf;
fig.PaperPositionMode = 'auto';
fig.InvertHardcopy = 'off';
%
if XOsave
    if sorted
        save([exp_folder,'\Analyzed_data\sort\',name,'.mat'],'time','cSTA', 'dcSTA', 'Filker_OnOff_Index', 'tau')
        saveas(gcf,[exp_folder,'\FIG\sort\', name,'on_off_index.tiff'])
    else
        saveas(gcf,[exp_folder,'\FIG\unsort\', name,'on_off_index.tiff'])
        save([exp_folder,'\Analyzed_data\unsort\', name,'.mat'],'time','cSTA', 'dcSTA', 'Filker_OnOff_Index', 'tau')
    end
end

