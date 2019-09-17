%% This code analyze on off response of retina(Gollish version)
%load on off data first
clear all;
close all;
load('rr.mat');
code_folder = pwd;
exp_folder =  'E:\20190916';
save_photo =1;%0 is no save on off photo and data, 1 is save
cd(exp_folder)
broken_channel = 31;
p_channel = [];%Green is predictive
np_channel = [];%Purple is non-predictive
%load('predictive_channel\0602_HMM_RL_5G_7min_Br50_Q100_1.mat')
name = '0821_Gollish_OnOff_movie_5min_Br50_Q100_0.8_re';%Name that used to save photo and data
Samplingrate=20000; %fps of diode in A3
%% For unsorted spikes
load(['data\',name,'.mat'])
sorted = 0;
%% For sorted spikes
% load(['sort\',name,'.mat'])
% sorted = 1;

num_cycle =40;
lumin=a_data(3,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!

%% Create directory
if save_photo
mkdir Analyzed_data
mkdir FIG
cd FIG
mkdir ONOFF
cd ONOFF
mkdir sort
mkdir unsort
end

%%  Find when is its final end
for i = 1:length(lumin)-700
    if lumin(i)-lumin(i+700)>500 &&  (lumin(i)-lumin(i+100))/100 > 0.85  && (lumin(i)-lumin(i+25))/25 > 0.5
        diode_end = i;
        figure(1);plot(lumin)
        hold on;plot(diode_end,lumin(diode_end),'g*');
        xlabel('time')
        ylabel('lumin')
        title('end')
        break
    end
end
useful_lumin = lumin(1:diode_end);

%% Calculate threhold
plateau_n=200;  %least number of point for plateau
last_gray = max(lumin)*0.25+min(lumin)*0.75;

thre_up = max(useful_lumin)*0.15+mode(useful_lumin)*0.85;%On threhold
thre_down = min(useful_lumin)*0.15+mode(useful_lumin)*0.85;%Off threhold

%% Find when on starts
diode_on_start =zeros(1,num_cycle);%It stores when on starts
num = 1; 
pass = 0;
for i = 1:length(useful_lumin)-100
    if(useful_lumin(i+80)-useful_lumin(i))/80 > 0.3 && pass < 200 &&  useful_lumin(i)>thre_up
        diode_on_start(num) = i;
        num = num + 1;
        pass = 20000;
    end
    pass = pass - 1;
end
if length(diode_on_start) ~= num_cycle
    disp('There are some problems of finding diode start')
end
%% Find when off starts
diode_off_start =zeros(1,num_cycle);%It stores when off starts
num = 1; 
pass = 0;
for i = 1:length(useful_lumin)-300
    if (useful_lumin(i)-useful_lumin(i+50))/50 > 0.3 &&(useful_lumin(i)-useful_lumin(i+100))/100 > 0.3 && pass < 200 &&  useful_lumin(i)<thre_down
        diode_off_start(num) = i;
        num = num + 1;
        pass = 40000;
    end
    pass = pass - 1;
end
if length(diode_off_start) ~= num_cycle
    disp('There are some problems of finding diode end')
end
%% Plot when on off start
figure(2);plot(useful_lumin)
hold on; plot(diode_on_start(1:end-1),useful_lumin(diode_on_start(1:end-1)),'g*');
hold on; plot(diode_off_start,useful_lumin(diode_off_start),'r*');
xlabel('time')
ylabel('lumin')
title('on start and off start')


%% Cut spikes and merge spikes, then binning spikes
BinningInterval = 1/100;  %s
diode_on_start=diode_on_start./Samplingrate;%Change to sec
diode_off_start=diode_off_start./Samplingrate;%Change to sec
diode_end = diode_end/Samplingrate;%Change to sec
[cut_onspikes,cut_offspikes] = seperate_Gollishtrials(Spikes,diode_on_start,diode_off_start,diode_end); % Cut spikes and merge each trial spikes in one trial

%On binning
onDataTime=mean(diff(diode_on_start))/2;%Average each stimulus length
onBinningTime = [ 0 : BinningInterval : onDataTime];
onBinningSpike = zeros(60,length(onBinningTime));
for i = 1:60  % i is the channel number
    [n,~] = hist(cut_onspikes{i},onBinningTime) ;
    onBinningSpike(i,:) = n ;
end

%Off binning
offBinningTime = [ 0 : BinningInterval : onDataTime];
offBinningSpike = zeros(60,length(offBinningTime));
for i = 1:60  % i is the channel number
    [n,~] = hist(cut_offspikes{i},offBinningTime) ;
    offBinningSpike(i,:) = n ;
end


%%  Heat Map / all channels
figure(3)
on_off = zeros(1,length(onBinningTime));
on_off(1,1:50) = 1;
subplot(3,1,1),imagesc(onBinningTime,[1:60],onBinningSpike);
title(' OnOff / BinningInterval=10ms')
xlabel('On---time(s)');   ylabel('channel ID');
subplot(3,1,2),imagesc(offBinningTime,[1:60],offBinningSpike);
xlabel('Off---time(s)');   ylabel('channel ID');
subplot(3,1,3),plot(onBinningTime,on_off)
ylim([0 2])

%% Subplot sum of all channels  On and Off  PSTH
on_s=0;
off_s = 0;
for channelnumber=1:60
on_s= on_s+ onBinningSpike(channelnumber,:);
off_s= off_s+ offBinningSpike(channelnumber,:);
end
figure(4);
subplot(3,1,1),plot(onBinningTime,on_s);
xlabel('On---time(s)'); 
subplot(3,1,2),plot(offBinningTime,off_s);
xlabel('Off---time(s)'); 
subplot(3,1,3),plot(onBinningTime,on_off)
ylim([0 2])

%% Delete useless spikes (not in 50ms~550ms interval) and Calculate on-off index
on_spikes = zeros(1,60);%It stores sum of on response spike
off_spikes = zeros(1,60);%It stores sum of off response spike
on_off_index = ones(1,60)*-10000000;
useless_channel = [];
for channelnumber=1:60
    if channelnumber == broken_channel
        continue
    end
    on_ss = cut_onspikes{channelnumber};
    off_ss = cut_offspikes{channelnumber};
    %Exclude channels that mean firing rate is lower than one
    if (length(on_ss)+length(off_ss))/(onDataTime*num_cycle*2) < 1
        useless_channel = [useless_channel channelnumber];
        %disp(['Channel ',int2str(channelnumber),'  mean firing rate is lower than one'])
        continue
    end
    %Remove useless spikes
    on_ss(on_ss<0.05) = [];
    on_ss(on_ss>0.55)=[];
    off_ss(off_ss<0.05) = [];
    off_ss(off_ss>0.55)=[];
    on_spikes(channelnumber) = length(on_ss);
    off_spikes(channelnumber) =  length(off_ss); 
    on_off_index(channelnumber) = (on_spikes(channelnumber)-off_spikes(channelnumber))/(on_spikes(channelnumber)+off_spikes(channelnumber));
    if ~isnan(on_off_index(channelnumber))
        if on_off_index(channelnumber)>0.3%Criteria from 'Causal evidence for retina-dependent and -independent visual motion computations in mouse cortex'
            disp(['Channel ',int2str(channelnumber),' is on cell '])
            disp(['Channel ',int2str(channelnumber),' on_off index is ',num2str(on_off_index(channelnumber))])
        elseif on_off_index(channelnumber)<-0.3
            disp(['Channel ',int2str(channelnumber),' is off cell '])
             disp(['Channel ',int2str(channelnumber),' on_off index is ',num2str(on_off_index(channelnumber))])   
        else 
            disp(['Channel ',int2str(channelnumber),' is on-off cell '])
             disp(['Channel ',int2str(channelnumber),' on_off index is ',num2str(on_off_index(channelnumber))])
        end
    end
end
on_off_index (find(on_off_index == -10000000)) = NaN;
%% Plot all channels on off response
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);


for channelnumber=1:60
    if channelnumber == broken_channel
        continue
    end
    axes(ha(rr(channelnumber))); 
    if ~ismember(channelnumber,useless_channel)%If spikes are not enough
        plot(onBinningTime,onBinningSpike(channelnumber,:),'b');hold on;%Blue is on
        plot(offBinningTime,offBinningSpike(channelnumber,:),'r');%Red is off
        plot(onBinningTime,on_off*max([onBinningSpike(channelnumber,:),offBinningSpike(channelnumber,:)]),'k-')
        if ismember(channelnumber,p_channel)%Green is predictive
            set(gca,'Color',[0.8 1 0.8])
        elseif ismember(channelnumber,np_channel)
            set(gca,'Color',[0.8 0.8 1])%Purple is non-predictive
        else
            
        end
    end
    xlim([0 2])
     
  if ~isnan(on_off_index(channelnumber))
      if on_off_index(channelnumber)>0.3%Criteria from 'Causal evidence for retina-dependent and -independent visual motion computations in mouse cortex'
          title([int2str(channelnumber),'ON'])
      elseif on_off_index(channelnumber)<-0.3
          title([int2str(channelnumber),'OFF'])
      elseif on_off_index(channelnumber)>0
          title([int2str(channelnumber),'ON-OFF'])
      elseif on_off_index(channelnumber)<0
          title([int2str(channelnumber),'OFF-ON'])
      end
  end
end
set(gcf,'units','normalized','outerposition',[0 0 1 1])
fig = gcf;
fig.PaperPositionMode = 'auto';
if save_photo
    if sorted
        saveas(fig,[exp_folder, '\FIG\ONOFF\','\sort\', name,'.tiff'])
        saveas(fig,[exp_folder, '\FIG\ONOFF\','\sort\', name,'.fig'])
        cd([exp_folder, '\FIG\ONOFF\','\sort'])
    else
        saveas(fig,[exp_folder, '\FIG\ONOFF\','\unsort\', name,'.tiff'])
        saveas(fig,[exp_folder, '\FIG\ONOFF\','\unsort\', name,'.fig'])
        cd([exp_folder, '\FIG\ONOFF\','\unsort'])
    end
    save([exp_folder,'\Analyzed_data\',name,'.mat'],'on_off_index','onBinningSpike','offBinningSpike','onBinningTime','offBinningTime')
end

%% plot single channel PSTH
% channelnumber=[10];
% for i = channelnumber
% figure(i+60);
% subplot(3,1,1),plot(onBinningTime,onBinningSpike(i,:));
% title(['channel ',int2str(i),' ON OFF Respense'])
% xlabel('On---time(s)'); 
% subplot(3,1,2),plot(offBinningTime,offBinningSpike(i,:));
% xlabel('Off---time(s)'); 
% subplot(3,1,3),plot(onBinningTime,on_off)
% ylim([0 2])
% end