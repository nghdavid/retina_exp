% Analysis STA experiment, by Rona
clear all
close all
exp_folder = 'D:\Leo\1219exp';
cal_date = datestr([2019,12,19, 11, 7, 18]);  %type in cal_date, the latter three is unimportant but necessary. Don't change them.
cd(exp_folder);
mkdir('Analyzed_data')
mkdir Analyzed_data sort
mkdir Analyzed_data unsort
mkdir('FIG')
mkdir FIG sort
mkdir FIG unsort
% all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
% n_file = length(all_file);
SamplingRate = 20000;
cc = hsv(3);
rr =[9,17,25,33,41,49,...
    2,10,18,26,34,42,50,58,...
    3,11,19,27,35,43,51,59,...
    4,12,20,28,36,44,52,60,...
    5,13,21,29,37,45,53,61,...
    6,14,22,30,38,46,54,62,...
    7,15,23,31,39,47,55,63,...
    16,24,32,40,48,56];
roi = [1:60];


% clearvars -except all_file n_file z SamplingRate cc ey isi2 statispks statistime w fr information rr STA roi
% file = all_file(z).name ;
% [pathstr, name, ext] = fileparts(file);
% directory = [pathstr,'\'];
% filename = [name,ext];
lumin = '_lumin10';
load([exp_folder, '\playmovie\calibration', cal_date(1:end-9), '.mat']);
%% For unsorted spikes
load([exp_folder, '\data\csta',lumin,'.mat']);
analyze_spikes = Spikes;
sorted = 0;
%% For sorted spikes
load([exp_folder, '\sort\csta',lumin,'.mat']);
unit = 0;

complex_channel = [];
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
                analyze_spikes{i} = [analyze_spikes{i} Spikes{u,i}'];
            end
        else
            analyze_spikes{i} = [analyze_spikes{i} Spikes{1,i}'];
        end
    else
        for u = unit
            analyze_spikes{i} = [analyze_spikes{i} Spikes{u,i}'];
        end
    end
    analyze_spikes{i} = sort(analyze_spikes{i});
end
sorted = 1;



%% diode as TriggerData
%     load(['E:\google_rona\20170929\diode\diode_',filename]);
%     [~,locs_a2]=findpeaks(diff(diff(a2)),'MINPEAKHEIGHT',5*std(diff(diff(a2))));
%     TimeStamps_a2 = (locs_a2)/SamplingRate;
%     TriggerData = eyf(TimeStamps_a2(1)*SamplingRate:TimeStamps_a2(end)*SamplingRate);% figure;plot(isi);
%% a_data as TriggerData
bin = 5;  BinningInterval = bin*10^-3;  %ms
TriggerData = (a_data(1,TimeStamps(1)*SamplingRate:TimeStamps(length(TimeStamps))*SamplingRate)-min(a_data(1,:)))/10^6;% figure;plot(isi);
inten = downsample(TriggerData,SamplingRate*BinningInterval);

x=volt;
y=(lumin_filter)';
z=(true_lumin)';
[z, index] = unique(z);
l = interp1(x(index),z,inten,'linear');% ex=calibrate voltage
inten = l;

plot(inten);
%% spike process
BinningTime = [TimeStamps(1) : BinningInterval : TimeStamps(end)];
BinningSpike = zeros(60,length(BinningTime));
for i = 1:60
    [n,xout] = hist(analyze_spikes{i},BinningTime) ;
    BinningSpike(i,:) = n ;
end
BinningSpike(:,1) = 0;BinningSpike(:,end) = 0;
temprr=0;


%% STA
window = 1;  %STA window
window2 =1;
cSTA = zeros(60, round(window/BinningInterval)+round(window2/BinningInterval)+1);
useful_channelnumber = [];
for nn = 1:length(roi)
    spike = BinningSpike(roi(nn),:);
    
    
    sts = [];
    temp = 0;
    spike(1:window/BinningInterval) = 0;
    spike(length(spike)-window2/BinningInterval-10:end) = 0;
    for in = 1:length(spike)
        if spike(in)~=0
            temp = temp+1;
            sts(temp,:) = spike(in)*inten(in-round(window/BinningInterval):in+round(window2/BinningInterval));
        end
    end
    STA = sum(sts)/sum(spike);%;
    STA = STA-mean(STA(round(length(STA)/2)));
    STA = STA/max(abs(STA));
    %         figure(roi(nn));hold on;
    
    STA = STA/max(abs(STA));
    dSTA = [STA 0 0] - [0 0 STA];
    dSTA(end) = [];
    dSTA(1) = [];
    dSTA = dSTA/max(abs(dSTA));
    cSTA(roi(nn),:) = STA;
    dcSTA(roi(nn),:) = dSTA;
    if isempty(find(abs(cSTA(nn,1:round(length(cSTA)/2))) >= 7*std(cSTA(nn,round(length(cSTA)/2):end))))
        cSTA(roi(nn),:) = NaN;
    else
        useful_channelnumber = [useful_channelnumber roi(nn)];
    end
end

time = [-window*1000:bin:window2*1000];
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.03 .01],[0.02 0.02],[.01 .01]);
for channelnumber=useful_channelnumber
    axes(ha(rr(channelnumber)));
    plot(time(101:201),cSTA(channelnumber,101:201),'LineWidth',1.5);%,'color',cc(z,:)
    title(channelnumber)
end
if sorted
    saveas(gcf,['FIG\sort\', 'csta',lumin,'.tiff'])
else
    saveas(gcf,['FIG\unsort\', 'csta',lumin,'.tiff'])
end

figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.03 .01],[0.02 0.02],[.01 .01]);
for channelnumber=useful_channelnumber
    axes(ha(rr(channelnumber)));
    plot(time(101:201),dcSTA(channelnumber,101:201),'LineWidth',1.5);%,'color',cc(z,:)
    title(channelnumber)
end
if sorted
    saveas(gcf,['FIG\sort\', 'dcsta',lumin,'.tiff'])
else
    saveas(gcf,['FIG\unsort\', 'dcsta',lumin,'.tiff'])
end
%% Calculate OnOff Index
tau =  zeros(1,60);
Filker_OnOff_Index = ones(1,60)*-10000000;
for channelnumber=useful_channelnumber
    Filker_OnOff_Index(channelnumber) = sum(cSTA(channelnumber,round(length(cSTA)/2)-200/bin:round(length(cSTA)/2))) / sum(abs(cSTA(channelnumber, round(length(cSTA)/2)-200/bin:round(length(cSTA)/2))));
    diff_smooth_cSTA = diff(smooth(cSTA(channelnumber,:)));
    
    for l = fliplr(2:length(diff_smooth_cSTA)/2)
        if diff_smooth_cSTA(l)*diff_smooth_cSTA(l-1) < 0
            tau(channelnumber) = (length(diff_smooth_cSTA)/2-l+1)*bin;
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
if sorted
    save([exp_folder,'\Analyzed_data\sort\','csta',lumin,'.mat'],'time','cSTA', 'dcSTA', 'Filker_OnOff_Index', 'tau')
    saveas(gcf,['FIG\sort\', 'csta',lumin,'on_off_index.tiff'])
else
    saveas(gcf,['FIG\unsort\', 'csta',lumin,'on_off_index.tiff'])
    save([exp_folder,'\Analyzed_data\unsort\','csta',lumin,'.mat'],'time','cSTA', 'dcSTA', 'Filker_OnOff_Index', 'tau')
end
