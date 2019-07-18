%variables that you can and should tune
clear all;
load('D:\Leo\0620exp\sort_merge_spike\sort_merge_0415_Reversal_moving_RL_201.6s_Br50_Q100.mat')
trial_num = 11;
fps = 60;
display_trial = [1 2 3 4 5 6 7 8 9 11];
analyze_spikes = sorted_spikes;
%analyze_spikes = reconstruct_spikes;
channel_number = 2;
type = 'RL';
BinningInterval = 1/fps*60;  %s


load('boundary_set.mat')
load('channel_pos.mat')

%%for stimuli
start_frame = zeros(trial_num+1,1);
trial_length = zeros(trial_num,1);
trial_num_counter = 1;
start_frame(trial_num+1,1) = length(bin_pos);
on_ornot = 0;
start_frame = zeros(trial_num+1,1);
trial_length = zeros(trial_num,1);
trial_num_counter = 1;
start_frame(trial_num+1,1) = length(bin_pos);
trial_pos = zeros(trial_num,ceil(length(bin_pos)/trial_num));
for i = 2:length(bin_pos)-1
    if bin_pos(i) > leftx_bar + re_bar_wid && bin_pos(i) < rightx_bar - re_bar_wid && bin_pos(i+1) >= bin_pos(i) && bin_pos(i) >= bin_pos(i-1)
        if on_ornot ~= 1
            start_frame(trial_num_counter) = i;
        end
        on_ornot = 1;
        trial_pos(trial_num_counter, i+1-start_frame(trial_num_counter)) = bin_pos(i);
    else
        if on_ornot
            trial_length(trial_num_counter) = i - start_frame(trial_num_counter);
            trial_num_counter =trial_num_counter+1;
        end
        on_ornot = 0;
    end
end

%%for spikes
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

%for ploting
%ha = tight_subplot(length(display_trial),1,[.1 .01],[0.05 0.05],[.02 .01]);
PSTH = null(1,1);
smooth_PSTH = null(1,1);
distance = null(1,1);
figure;
for j = 1:length(display_trial)
    
    BinningTime = [0 : BinningInterval : trial_length(display_trial(j))/fps];
    BinningSpike = zeros(60,length(BinningTime));
    dis = zeros(60,length(BinningTime));
    spike_dis = zeros(2,length(BinningTime),60);
    for k = channel_number % i is the channel number
        [n,~] = hist(trial_spikes{display_trial(j),k},BinningTime) ;
        BinningSpike(k,:) = n ;
        %for UD
        spike_dis(1,:,k)  = n ;
        if strcmp(type,'UD')
            for m = 1:trial_length (display_trial(j))
                dis(k, m) = (channel_pos(k,2)-meaCenter_y) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
                %spike_dis(2,m,k)= (channel_pos(k,2)-meaCenter_y) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
            end
        elseif  strcmp(type,'RL')
            for m = 1:trial_length (display_trial(j))
                dis(k, m) = (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), m)-meaCenter_x - re_bar_wid);
                %spike_dis(2,m,k)= (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
            end
        elseif  strcmp(type,'UR_DL')
            for m = 1:trial_length (display_trial(j))
                dis(k, m) = (-channel_pos(k,1)+ channel_pos(k,2)+meaCenter_x-meaCenter_x)/sqrt(2) - (trial_pos(display_trial(j), m)- meaCenter_x - re_bar_wid);
                %spike_dis(2,m,k)= (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
            end
        elseif  strcmp(type,'UL_DR')
            for m = 1:trial_length (display_trial(j))
                dis(k, m) = (channel_pos(k,1)+channel_pos(k,2)-meaCenter_x-meaCenter_x)/sqrt(2) - (trial_pos(display_trial(j), m)- meaCenter_x + re_bar_wid);
                %spike_dis(2,m,k)= (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
            end
        end
        plot(dis(k,1:length(BinningTime)),BinningSpike(k,1:length(BinningTime)),'k');
        hold on;
        PSTH = [PSTH BinningSpike(k,1:length(BinningTime))];
        %smooth_PSTH =  [smooth_PSTH smooth(BinningSpike(k,1:length(BinningTime)),10)'];
        distance = [distance dis(k,1:length(BinningTime))];
        
    end
     
end
plot(0:round(re_bar_wid*micro_per_pixel)+1, [0 ones(1,round(re_bar_wid*micro_per_pixel)) 0], 'c');
% 
%scatter(distance, smooth_PSTH, 10,'filled');

% figure;
% distance(PSTH == 0) = [];
% PSTH(PSTH == 0 ) = [];
% [sort_dis index] = sort(distance);
% plot(sort_dis , PSTH(index));
figure;
scatter(distance,PSTH, 10,'filled');

[sort_dist index]= sort(distance);
sort_PSTH = PSTH(index);
%sort_smooth_PSTH = smooth_PSTH(index);

figure;
plot(sort_dist,sort_PSTH);


