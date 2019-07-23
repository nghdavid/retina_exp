%%This code analyze on off response of retina
%load on off data first
clear all;
close all;
code_folder = pwd;
exp_folder =  'E:\20190719';
cd(exp_folder)
load('data\0710_CalONOFF_5min_Br50_Q100.mat')
% load('sort\0304_CalONOFF_5min_Br50_Q100.mat')
new =1;%0304onff use 0, 0710onoff use 1
rr =[9,17,25,33,41,49,...
          2,10,18,26,34,42,50,58,...
          3,11,19,27,35,43,51,59,...
          4,12,20,28,36,44,52,60,...
          5,13,21,29,37,45,53,61,...
          6,14,22,30,38,46,54,62,...
          7,15,23,31,39,47,55,63,...
            16,24,32,40,48,56];

lumin=a_data(3,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
plateau_n=200;  %least number of point for plateau
last_gray = max(lumin)*0.25+min(lumin)*0.75;

thre_up = max(lumin)*0.7+min(lumin)*0.3;

thre_down = max(lumin)*0.25+min(lumin)*0.75;


diode_start = zeros(1,15);
num = 1;
pass = 0;
% Find when it starts
for i = 1:length(lumin)-100
    
    if (lumin(i+50)-lumin(i))/50 > 10 && (lumin(i+100)-lumin(i))/100 > 6 && (lumin(i+10)-lumin(i))/10 > 7 && pass < 200
        diode_start(num) = i;
        num = num + 1;
        pass = 3500;
    end
    pass = pass - 1;
end

% Find when it ends
is_complete = 0;
for i = 1:length(lumin)
    
    if (lumin(i+30)-lumin(i))/30 > 2 && (lumin(i+100)-lumin(i))/100 < 2 && (lumin(i+70)-lumin(i))/70 > 2 && lumin(i+100) < thre_up
        diode_end = i;
        is_complete = 1;
        break
    end
    
end
if is_complete == 0
    disp('There are no normal signal')
    pass = 0;
    return
end

Samplingrate=20000; %fps of diode in A3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
hold on;plot(diode_end,lumin(diode_end),'g*');
xlabel('time')
ylabel('lumin')
title('start and end')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diode_start=diode_start./20000;
cut_spikes = seperate_trials(Spikes,diode_start); 
DataTime=diode_start(2)-diode_start(1);
% Binning
BinningInterval = 1/100;  %s
BinningTime = [ BinningInterval : BinningInterval : DataTime];
BinningSpike = zeros(60,length(BinningTime));
for i = 1:60  % i is the channel number
    [n,~] = hist(cut_spikes{i},BinningTime) ;
    BinningSpike(i,:) = n ;
end


%%  Heat Map / all channels
figure(2)
on_off = zeros(1,length(BinningTime));
if new 
    on_off(1,1:1000) = 1;
else
    on_off(1,1:200) = 1;
end
subplot(2,1,1),imagesc(BinningTime,[1:60],BinningSpike);
colorbar
title(' OnOff / BinningInterval=10ms')
xlabel('time(s)');   ylabel('channel ID');
subplot(2,1,2),plot(BinningTime,on_off)
ylim([0 2])




%% PSTH
% subplot all channels' OnOff   PSTH
s=0;
for channelnumber=1:60
s= s+ BinningSpike(channelnumber,:);

end
figure(3);
subplot(2,1,1),plot(BinningTime,s);
subplot(2,1,2),plot(BinningTime,on_off)
ylim([0 2])
  

%% Plot all channels on off response
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);


for channelnumber=1:60
    axes(ha(rr(channelnumber))); 
    if max(BinningSpike(channelnumber,:)) >2%If spikes are not enough
        plot(BinningTime,BinningSpike(channelnumber,:));hold on;
        plot(BinningTime,on_off,'r-')
    end
     if new
        xlim([0 12])
     else
        xlim([0 2])
     end
    title(channelnumber)

end
set(gcf,'units','normalized','outerposition',[0 0 1 1])

%% Caculate on_off index
on_spikes = zeros(1,60);
off_spikes = zeros(1,60);
on_off_index = zeros(1,60);
for channelnumber=1:60
    on_spikes(channelnumber) = sum(BinningSpike(channelnumber,1:50));
    off_spikes(channelnumber) = sum(BinningSpike(channelnumber,200:250));
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
%plot single channel PSTH
% channelnumber=18;
% figure;
% s=0;
% s=  BinningSpike(channelnumber,:);
% plot(BinningTime,s);
% xlim([0 18])
% title(channelnumber)

