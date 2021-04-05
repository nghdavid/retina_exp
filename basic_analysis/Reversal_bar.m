close all;
clear all;
calibration_date = '20200219';
exp_folder = 'E:\20200620\';
cd(exp_folder)
mkdir FIG\Reversal\sort
mkdir FIG\Reversal\unsort
sorted = 0;
save_photo = 1;
channel_number = 1:60;
trial_num = 12;
fps = 60;
display_trial = [1 2 3 4 5 6 7 8 9 10 11 12];
%% Run through each speed and reverse direction
for speed = [1,1.5,2.0,2.5]
%speed = 2.5;
BinningTimes = cell(1,2);
BinningSpikes = cell(1,2);
rescale_trajectorys = cell(1,2);
min_trial_lengths = cell(1,2);
%% Set name and load data
for num = [1,2]
direction = 'LR';
fig_name = ['Comp_0224_Reversal_moving_',direction,'_',num2str(speed),'mm_ch'];
if num == 1
    type = '1st';
elseif num == 2
    type = '2nd';
end
file_name = ['0224_',type,'_Reversal_moving_',direction,'_',num2str(speed),'mm_Q100']
if sorted
    sort_directory = 'sort\';
    file_name = ['sort_merge_',file_name];
    load([exp_folder,'sort_merge_spike\',file_name,'.mat'])
    analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,unit);
else
    sort_directory = 'unsort\';
    file_name = ['merge_',file_name];
    load([exp_folder,'merge\',file_name,'.mat'])
    analyze_spikes = reconstruct_spikes;
end

%% Reversal bar parameter
load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
real_distance = (rightx_bar-leftx_bar-bar_wid*2)*micro_per_pixel/1000;%mm
deltaT = real_distance/speed;
rest_T = 10;%Interval between each trial
num_trial = 12;
fps =60;%freq of the screen flipping
pre_exist = 4;%Time that bar stay still before moving
post_exist = 2;%Time that bar stay still after moving
T=(pre_exist+post_exist+2*deltaT);
num_trial_frame = ceil(T*fps);
stimulus_length = TimeStamps(2)-TimeStamps(1);

%% Parameter for catching each trial
start_frame = zeros(trial_num+1,1);
trial_length = zeros(trial_num,1);
trial_num_counter = 1;
start_frame(trial_num+1,1) = length(bin_pos);
on_ornot = 0;
start_frame = zeros(trial_num,1);
trial_length = zeros(trial_num,1);
trial_num_counter = 1;
trial_pos = zeros(trial_num,num_trial_frame+1);
trial_frame = ones(trial_num,num_trial_frame+1);
%% Run each frame and get trial
for i = 1:length(bin_pos)-1
    if bin_pos(i) >= leftx_bar + bar_wid && bin_pos(i) <= rightx_bar - bar_wid
        if on_ornot ~= 1
            if bin_pos(i+1) >= bin_pos(i)
                start_frame(trial_num_counter) = i;
            end
        end
        on_ornot = 1;
        trial_pos(trial_num_counter, i+1-start_frame(trial_num_counter)) = bin_pos(i);
        trial_frame(trial_num_counter, i+1-start_frame(trial_num_counter)) =i;
    else
        if on_ornot
            trial_length(trial_num_counter) = i - start_frame(trial_num_counter);
            trial_num_counter =trial_num_counter+1;
        end
        on_ornot = 0;
    end
end

% figure;
% plot(bin_pos);hold on
% plot(start_frame,bin_pos(start_frame),'r*')
% for i = 1:trial_num
%     plot(trial_frame(i,:),bin_pos(trial_frame(i,:)),'b*')
% end

% for i = 1:12
%     find(trial_pos(i,:)==max(trial_pos(i,:)))
% end

%% Get spikes from each trial
trial_spikes = cell(trial_num,60);
for k = 1:60  % i is the channel number
    for j = 1:trial_num
        trial_spikes{j,k} = null(100,1);
    end
end
for k = channel_number  % i is the channel number
    for j = 1:trial_num
        for m = 1:length(analyze_spikes{k})
            if analyze_spikes{k}(m) < (start_frame(j)+trial_length(j))/fps && analyze_spikes{k}(m) > start_frame(j)/fps
                trial_spikes{j,k} = [trial_spikes{j,k}  analyze_spikes{k}(m)-start_frame(j)/fps];
            end
        end
    end
end
BinningTime = [BinningInterval : BinningInterval : min(trial_length)*BinningInterval];
for j = 1:length(display_trial)
    BinningSpike = zeros(60,length(BinningTime));
     for k = channel_number % k is the channel number
        [n,~] = hist(trial_spikes{display_trial(j),k},BinningTime);
        BinningSpike(k,:) =  BinningSpike(k,:)+n;
     end
end
%% Get trial length and trial position
min_trial_length = min(trial_length);
short_trial = find(trial_length==min_trial_length);
rescale_trajectory = trial_pos(short_trial(1),1:min_trial_length)-leftx_bar-bar_wid;
rescale_trajectory = rescale_trajectory/max(rescale_trajectory);
BinningTimes{num} = BinningTime;
BinningSpikes{num} = BinningSpike;
min_trial_lengths{num} = min_trial_length;
rescale_trajectorys{num} = rescale_trajectory;
end

%% Plot figure
for k =  channel_number
    BinningSpike = BinningSpikes{1};
    if sum(BinningSpike(k,:))/(min_trial_length*BinningInterval*trial_num)<0.1
        continue
    end
    figure(k)
    subplot(2,1,1)
    plot(BinningTimes{1},BinningSpike(k,:));hold on
    plot(BinningTimes{1},rescale_trajectorys{1}*max(BinningSpike(k,:)),'r')
    xlabel('time(sec)')
    ylabel('firing rate(Hz)')
    title('Comparison of firing rate between first and second order reversal')
    subplot(2,1,2)
    BinningSpike = BinningSpikes{2};
    plot(BinningTimes{2},BinningSpike(k,:));hold on
    plot(BinningTimes{2},rescale_trajectorys{2}*max(BinningSpike(k,:)),'r')
    xlabel('time(sec)')
    ylabel('firing rate(Hz)')
    if save_photo
        saveas(gcf,['FIG\Reversal\',sort_directory,fig_name,num2str(k),'.tif'])
    end
end
close all;
end