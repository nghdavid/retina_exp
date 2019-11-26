% Analysis STA experiment, by Rona
clear all
close all
load('rr.mat')
exp_folder = '\\Desktop-7k9ep2u\20190916';
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
window = 1;  %STA window
window2 = 1;
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
    STA = STA-STA(end);
    STA = STA/max(abs(STA));
    cSTA(roi(nn),:) = STA;
  
    if isempty(find(abs(cSTA(nn,1:round(length(cSTA)/2))) >= 7*std(cSTA(nn,1:300/bin))))
        cSTA(roi(nn),:) = NaN;
    else
        useful_channelnumber = [useful_channelnumber roi(nn)];
    end
end
%% Plot STA
time = [-window*1000:bin:window2*1000];
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.04 .02],[0.02 0.02],[.01 .01]);
for channelnumber=useful_channelnumber
    axes(ha(rr(channelnumber)));
    plot(time,cSTA(channelnumber,:),'LineWidth',1.5);
    grid on
    xlim([-500 0])
    title(channelnumber)
end
set(gcf,'units','normalized','outerposition',[0 0 1 1])
fig = gcf;
fig.PaperPositionMode = 'auto';
if save_photo
    if sorted
        saveas(fig,[exp_folder, '\FIG\cSTA\','\sort\', name,'.tiff'])
        saveas(fig,[exp_folder, '\FIG\cSTA\','\sort\', name,'.fig'])
        cd([exp_folder, '\FIG\cSTA\','\sort'])
    else
        saveas(fig,[exp_folder, '\FIG\cSTA\','\unsort\', name,'.tiff'])
        saveas(fig,[exp_folder, '\FIG\cSTA\','\unsort\', name,'.fig'])
        cd([exp_folder, '\FIG\cSTA\','\unsort'])
    end
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
Filker_OnOff_Index (find(Filker_OnOff_Index == --10000000)) = NaN;
figure(1000);
hist(Filker_OnOff_Index(useful_channelnumber));
xlim([-1 1])
if save_photo
    if sorted
        saveas(gcf,[exp_folder, '\FIG\cSTA\','\sort\', name,'_index','.tiff'])
        saveas(gcf,[exp_folder, '\FIG\cSTA\','\sort\', name, '_index','.fig'])
        save([exp_folder,'\Analyzed_data\','csta','.mat'],'time','cSTA', 'Filker_OnOff_Index', 'tau')
        cd([exp_folder, '\FIG\cSTA\','\sort'])
    else
        saveas(gcf,[exp_folder, '\FIG\cSTA\','\unsort\', name, '_index','.tiff'])
        saveas(gcf,[exp_folder, '\FIG\cSTA\','\unsort\',name, '_index','.fig'])
        save([exp_folder,'\Analyzed_data\','csta','.mat'],'time','cSTA', 'Filker_OnOff_Index', 'tau')
        cd([exp_folder, '\FIG\cSTA\','\unsort'])
    end
end

