%%This code analyze on off response of retina
%load on off data first
clear all;
%load('D:\Leo\0529exp\data\0529_Grating_300micro_72s_Br50_Q80.mat')
load('D:\Leo\0620exp\data\0613_Grating_300micro_72s_Br50_Q80.mat')
analyze_spikes = Spikes;
analyze_spikes{31} = [0];
lumin=[];
lumin=a_data(3,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
plateau_n=200;  %least number of point for plateau
last_gray = max(lumin)*0.25+min(lumin)*0.75;

thre_up = max(lumin)*0.7+min(lumin)*0.3;
% thre_up = max(lumin)*0.65+min(lumin)*0.35;

% thre_down = max(lumin)*0.15+min(lumin)*0.85;
thre_down = max(lumin)*0.25+min(lumin)*0.75;

trial_num =8;
display_trial = 1:trial_num;
fps = 60;
channel_number = 1:60;
diode_start = zeros(1,trial_num);
num = 1;
pass = 0;


% Find when it starts
for i = 1:length(lumin)-100
    
    if (lumin(i+50)-lumin(i))/50 > 10*5/16 && (lumin(i+100)-lumin(i))/100 > 6*5/16 && (lumin(i+10)-lumin(i))/10 > 7*5/16 && pass < 200
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
% for i = 1:length(lumin)
%     if lumin(i) < 3.43*10^4
%         diode_end = i;
%         break        
%     end
% end


Samplingrate=20000; %fps of diode in A3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
hold on;plot(diode_end,lumin(diode_end),'g*');
xlabel('time')
ylabel('lumin')
title('start and end')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diode_start = [diode_start./20000. diode_end./20000.]+1.33;


trial_length = diff(diode_start)-3;%4/3-450/60;


trial_spikes = cell(trial_num,60);
for k = channel_number % k is the channel number
    for j = 1:trial_num
        trial_spikes{j,k} = null(100,1);
    end
end
for k = channel_number  % k is the channel number
    for j = 1:trial_num
        for m = 1:length(analyze_spikes{k});
            if analyze_spikes{k}(m) < diode_start(j)+trial_length(j) && analyze_spikes{k}(m) > diode_start(j)
                trial_spikes{j,k} = [trial_spikes{j,k}  analyze_spikes{k}(m)-diode_start(j)];
            end
        end
        %trial_spikes{j,k} = trial_spikes{j,k} - 1/fps;
    end
end


%for ploting
figure;
ha = tight_subplot(length(display_trial)+1,1,[0 0],[0.05 0.05],[.02 .01]);
%BinningSpike = zeros(60,length(BinningTime),trial_num);
counter= zeros(trial_num, 60);
for j = 1:length(display_trial)
    BinningInterval = 1/fps;  %s
    BinningTime = [0 : BinningInterval : trial_length(display_trial(j))];
    BinningSpike = zeros(60,length(BinningTime));
    sub_Spikes = cell(60,1);
    for k = channel_number % i is the channel number
        [n,~] = hist(trial_spikes{display_trial(j),k},BinningTime) ;
        BinningSpike(k,:) = n;
        counter(display_trial(j),k) = counter(display_trial(j),k) + sum(n);
    end
    axes(ha(j));
    imagesc(BinningTime,channel_number,BinningSpike(channel_number,:));
    %plot(BinningTime, BinningSpike(channel_number,:))
    %     subplot(length(display_trial)+1,1,j);
    %     LineFormat.Color = [0.3 0.3 0.3];
    %     plotSpikeRaster(sub_Spikes,'PlotType','vertline','LineFormat',LineFormat);
    %     hold on;
end
% subplot(length(display_trial)+1,1,length(display_trial)+1);
% plot(1/60:1/60:trial_length(1)/60, trial_pos(1, 1:trial_length(1)));
% samexaxis('abc','xmt','on','ytac','join','yld',1) % function need ''parseArgs'' function, from matlab center
% axes(ha(length(display_trial)+1));
% plot(1:trial_length(1), trial_pos(1, 1:trial_length(1)))

%calculate DSI
DSI =zeros(60,2);
direction_vector = exp((0:7)*pi/4*1j );
%direction_vector_2 = exp(([0:3 0:3])*pi/4*1j );
for k = channel_number % k is the channel number
    if sum(counter(:,k)) ~= 0
        DSI(k,1) = abs(dot(direction_vector, counter(:,k)))/sum(counter(:,k)); %DSI in number of spikes
        %DSI(k,2) = abs(dot(direction_vector_2, counter(:,k)))/sum(counter(:,k));
        DSI(k,2) = sum(counter(:,k)); %total firing spikes
    end
end









