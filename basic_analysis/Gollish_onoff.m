%% This code analyze on off response of retina
%load on off data first
clear all;
close all;
code_folder = pwd;
exp_folder =  'E:\20190823';
save_photo =0;%0 is no save grating photo, 1 is save
cd(exp_folder)
% p_channel = [25,33,34,45,46];%Green is predictive
% n_channel = [52,53,57,58,59,60];%Purple is non-predictive
p_channel = [];%Green is predictive
n_channel = [];%Purple is non-predictive

Samplingrate=20000; %fps of diode in A3
%% For unsorted spikes
load('data\0821_Gollish_OnOff_movie_5min_Br50_Q100_0.5.mat')
sorted = 0;
%% For sorted spikes
% load('sort\0710_CalONOFF_5min_Br50_Q100.mat')
% sorted = 1;
name = '0821_Gollish_OnOff';
num_cycle =40;
lumin=a_data(3,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
rr =[9,17,25,33,41,49,...
          2,10,18,26,34,42,50,58,...
          3,11,19,27,35,43,51,59,...
          4,12,20,28,36,44,52,60,...
          5,13,21,29,37,45,53,61,...
          6,14,22,30,38,46,54,62,...
          7,15,23,31,39,47,55,63,...
            16,24,32,40,48,56];
%% Create directory
% mkdir FIG
% cd FIG
% mkdir ONOFF
% cd ONOFF
% mkdir sort
% mkdir unsort


%%  Find when it final end
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
diode_on_start =zeros(1,num_cycle);%It stores
num = 1; 
pass = 0;
for i = 1:length(useful_lumin)-100
    
    if(useful_lumin(i+100)-useful_lumin(i))/100 > 0.3 && pass < 200 &&  useful_lumin(i)>thre_up
        diode_on_start(num) = i;
        num = num + 1;
        pass = 20000;
    end
    pass = pass - 1;
end

%% Find when off starts
diode_off_start =zeros(1,num_cycle);
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


%% Plot when on off start
figure(2);plot(useful_lumin)
hold on; plot(diode_on_start,useful_lumin(diode_on_start),'g*');
hold on; plot(diode_off_start,useful_lumin(diode_off_start),'r*');
xlabel('time')
ylabel('lumin')
title('on start and off start')


%% Cut spikes and merge spikes, then binning spikes
BinningInterval = 1/100;  %s
diode_on_start=diode_on_start./Samplingrate;%Change to sec
diode_off_start=diode_off_start./Samplingrate;%Change to sec
diode_end = diode_end/Samplingrate;%Change to sec
[cut_onspikes,cut_offspikes] = seperate_Gollishtrials(Spikes,diode_on_start,diode_off_start,diode_end); % Cut spikes and merge spikes

%On binning
onDataTime=mean(diff(diode_on_start));%Each stimulus length
onBinningTime = [ 0 : BinningInterval : onDataTime];
onBinningSpike = zeros(60,length(onBinningTime));
for i = 1:60  % i is the channel number
    [n,~] = hist(cut_onspikes{i},onBinningTime) ;
    onBinningSpike(i,:) = n ;
end

%Off binning
offDataTime=mean(diff(diode_off_start));
offBinningTime = [ 0 : BinningInterval : offDataTime];
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

%% PSTH
% subplot all channels' OnOff   PSTH
on_s=0;
off_s = 0;
for channelnumber=1:60
on_s= on_s+ onBinningSpike(channelnumber,:);
off_s= off_s+ offBinningSpike(channelnumber,:);
end
figure(4);
subplot(3,1,1),plot(onBinningTime,on_s);
subplot(3,1,2),plot(offBinningTime,off_s);
subplot(3,1,3),plot(onBinningTime,on_off)
ylim([0 2])

%% Delete useless spikes (not in 50ms~550ms interval)
on_spikes = zeros(1,60);
off_spikes = zeros(1,60);
for channelnumber=1:60
    on_ss = cut_onspikes{channelnumber};
    off_ss = cut_offspikes{channelnumber};
    %Remove useless spikes
    on_ss(on_ss<0.05) = [];
    on_ss(on_ss>0.55)=[];
    off_ss(off_ss<0.05) = [];
    off_ss(off_ss>0.55)=[];
%     cut_onspikes{channelnumber} =  on_ss;
%     cut_offspikes{channelnumber} =  off_ss;
    on_spikes(channelnumber) = length(on_ss);
    off_spikes(channelnumber) =  length(off_ss); 
end
%% Caculate on_off index

on_off_index = zeros(1,60);
for channelnumber=1:60
    on_spikes(channelnumber) = sum(BinningSpike(channelnumber,1:50));
    if new
        off_spikes(channelnumber) = sum(BinningSpike(channelnumber,1000:1050));
    else
        off_spikes(channelnumber) = sum(BinningSpike(channelnumber,200:250));
    end
    on_off_index(channelnumber) = (on_spikes(channelnumber)-off_spikes(channelnumber))/(on_spikes(channelnumber)+off_spikes(channelnumber));
    if max(BinningSpike(channelnumber,:)) >2
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
        else
            disp(['Channel ',int2str(channelnumber),'  does not have spikes'])
        end
    end
end

%% Plot all channels on off response
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);


for channelnumber=1:60
    axes(ha(rr(channelnumber))); 
    if max(BinningSpike(channelnumber,:)) >2%If spikes are not enough
        plot(BinningTime,BinningSpike(channelnumber,:));hold on;
        plot(BinningTime,on_off,'r-')
        if ismember(channelnumber,p_channel)
            set(gca,'Color',[0.8 1 0.8])
        elseif ismember(channelnumber,n_channel)
            set(gca,'Color',[0.8 0.8 1])
        else
            
        end
    end
     if new
        xlim([0 14])
     else
        xlim([0 4])
     end
      if ~isnan(on_off_index(channelnumber))
          if on_off_index(channelnumber)>0.3%Criteria from 'Causal evidence for retina-dependent and -independent visual motion computations in mouse cortex'
              title([int2str(channelnumber),'ON'])
          elseif on_off_index(channelnumber)<-0.3
              title([int2str(channelnumber),'OFF'])
          else
              title([int2str(channelnumber),'ON-OFF'])
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
end

plot single channel PSTH
channelnumber=18;
figure;
on_s=0;
on_s=  BinningSpike(channelnumber,:);
plot(BinningTime,on_s);
xlim([0 18])
title(channelnumber)

