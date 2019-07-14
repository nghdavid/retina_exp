close all;
clear all;
code_folder = pwd;

exp_folder = 'H:\0709';
displaychannel = 1:60;%Choose which channel to display
cd(exp_folder)

%% For unsorted spikes
load('data\0625_Grating_300micro_72s_Br50_Q80.mat')
analyze_spikes = Spikes;

%% For sorted spikes
% load('sort_merge_spike\sort_merge_0507_Checkerboard_20Hz_13_5min_Br50_Q100_re.mat')
% analyze_spikes = sorted_spikes;


analyze_spikes{31} = [0];

trial_num =8;
display_trial = 1:trial_num;
fps = 60;
channel_number = 1:60;
diode_start = zeros(1,trial_num);
num = 1;
pass = 0;
Samplingrate=20000; %fps of diode in A3

%% Determine time of start and end
lumin=a_data(3,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
plateau_n=200;  %least number of point for plateau
last_gray = max(lumin)*0.25+min(lumin)*0.75;
thre_up = max(lumin)*0.7+min(lumin)*0.3;
thre_down = max(lumin)*0.25+min(lumin)*0.75;
%Find when it starts
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


%% Plot when each grating start
figure(1);plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
hold on;plot(diode_end,lumin(diode_end),'g*');
xlabel('time')
ylabel('lumin')
title('start and end')


%% Seperate orientation 
diode_start = [diode_start./20000. diode_end./20000.]+1.33;%Minus first 1.33 sec for adaptation
trial_length = diff(diode_start)-3;%Minus 1.33 sec for adaptation and minus 1.67 sec for mean luminance interval
trial_spikes = cell(trial_num,60);

for k = channel_number% k is the channel number
    for j = 1:trial_num
        trial_spikes{j,k} = null(100,1);
        for m = 1:length(analyze_spikes{k})
            if analyze_spikes{k}(m) < diode_start(j)+trial_length(j) && analyze_spikes{k}(m) > diode_start(j)
                trial_spikes{j,k} = [trial_spikes{j,k}  analyze_spikes{k}(m)-diode_start(j)];
            end
        end
    end
end


%% Plot PSTH for each directions
figure(2);
ha = tight_subplot(length(display_trial),1,[0 0],[0.05 0.05],[.02 .01]);

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
    imagesc(BinningTime,displaychannel,BinningSpike(displaychannel,:));
end


%% Calculate DSI
DSI =zeros(60,2);
direction_vector = exp((0:7)*pi/4*1j);
for k = channel_number % k is the channel number
    if sum(counter(:,k))/sum(trial_length) >= 0.1%Only mean firing rate greater than 0.1 HZ is considered
        DSI(k,1) = abs(dot(direction_vector, counter(:,k)))/sum(counter(:,k)); %DSI in number of spikes
        DSI(k,2) = sum(counter(:,k)); %total firing spikes
        disp(['Channel ',int2str(k),' has mean firing rate of ',num2str(sum(counter(:,k))/sum(trial_length)),' HZ'])
        disp(['DSI of Channel ',int2str(k),' is ',num2str(DSI(k,1))])
        if DSI(k,1) > 0.3%Check whether it is DS cell
            disp(['Channel ',int2str(k),' is directional selective cell'])
            disp(' ')
            %Polar plot of DS cell
            if ismember(k,displaychannel)
                figure(k+2)
                %For fixed radius of 1
                max_lim = 1;
                x_fake=[0 max_lim 0 -max_lim];
                y_fake=[max_lim 0 -max_lim 0];
                h_fake=compass(x_fake,y_fake);
                hold on;
                h = compass(dot(direction_vector, counter(:,k))/sum(counter(:,k)));
                title(['Polar plot of channel ',int2str(k)])
                set(h_fake,'Visible','off');
            end
        end
    end
end

cd(code_folder)






