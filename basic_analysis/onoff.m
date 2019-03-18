%%This code analyze on off response of retina
%load on off data first
load('0119_CalONOFF_5min_Br50_Q100.mat')
lumin=[];
lumin=a_data(3,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
plateau_n=200;  %least number of point for plateau
last_gray = max(lumin)*0.25+min(lumin)*0.75;

thre_up = max(lumin)*0.7+min(lumin)*0.3;
% thre_up = max(lumin)*0.65+min(lumin)*0.35;

% thre_down = max(lumin)*0.15+min(lumin)*0.85;
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
figure;plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
hold on;plot(diode_end,lumin(diode_end),'g*');
xlabel('time')
ylabel('lumin')
title('start and end')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diode_start=diode_start./20000.
cut_spikes = seperate_trials(Spikes,diode_start); 
DataTime=diode_start(2)-diode_start(1);
% Binning
BinningInterval = 1/100;  %s
BinningTime = [ BinningInterval : BinningInterval : DataTime];
BinningSpike = zeros(60,length(BinningTime));
for i = 1:60  % i is the channel number
    [n,~] = hist(cut_spikes{i},BinningTime) ;
%     [n,~] = hist(yk_spikes{i},BinningTime) ;
    BinningSpike(i,:) = n ;
end


%%  Heat Map / all channels
on_off = zeros(1,length(BinningTime));
on_off(1,1:200) = 1;
subplot(2,1,1),imagesc(BinningTime,[1:60],BinningSpike);
colorbar
title(' OnOff / BinningInterval=10ms')
xlabel('time(s)');   ylabel('channel ID');
subplot(2,1,2),plot(BinningTime,on_off)
ylim([0 2])




%Heatmap /  specific channels only
% sp_BinningSpike=[];
% ff=1;
% chlist=[54 53 52  18 17 16   22 21 12]; %choose channels
% for ch=chlist
%     sp_BinningSpike(ff,:)=BinningSpike(ch,:);
%     ff=ff+1;
% end
% figure;  
% imagesc(BinningTime,[1,length(chlist)],sp_BinningSpike);

%% PSTH
% subplot all channels' OnOff   PSTH
s=0;
for channelnumber=1:60
s= s+ BinningSpike(channelnumber,:);

end
figure;
subplot(2,1,1),plot(BinningTime,s);
subplot(2,1,2),plot(BinningTime,on_off)
ylim([0 2])
  
%plot single channel PSTH
% channelnumber=18;
% figure;
% s=0;
% s=  BinningSpike(channelnumber,:);
% plot(BinningTime,s);
% xlim([0 18])
% title(channelnumber)
