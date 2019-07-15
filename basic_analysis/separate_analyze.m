close all;
clear all;
code_folder = pwd;


exp_folder = 'E:\0709';
displaychannel = 1:60;%Choose which channel to display
cd(exp_folder)

%% For unsorted spikes
load('merge\merge_0502Rona_short_HMM_G4.3_15min_Br50_Q100.mat')
analyze_spikes = reconstruct_spikes;

%% For sorted spikes
% load('sort_merge_spike\sort_merge_merge_0502Rona_short_HMM_G4.3_15min_Br50_Q100.mat')
% analyze_spikes = sorted_spikes;

trial_num =30;
fps = 60;
display_trial = 1:30;
 analyze_spikes{31}=[];
channel_number = 1:60;

%% Trial seperation
on_ornot = 0;
start_frame = zeros(trial_num+1,1);%Record start time of each trial 
trial_length = zeros(trial_num,1);%Record number of each trial frame  
trial_num_counter = 1;%Record which trial it is now
start_frame(trial_num+1,1) = length(bin_pos);
trial_pos = zeros(trial_num,ceil(length(bin_pos)/trial_num));%Record postions in each trial
for i = 1:length(bin_pos)
    if bin_pos(i) > 0%Has stimulus
        if on_ornot ~= 1%Trial starts
            start_frame(trial_num_counter) = i;
        end
        on_ornot = 1;
        trial_pos(trial_num_counter, i+1-start_frame(trial_num_counter)) = bin_pos(i);
    else%Dark
        if on_ornot
            trial_length(trial_num_counter) = i - start_frame(trial_num_counter);%i is end of trial, so end minus start is number of each trial frame  
            trial_num_counter =trial_num_counter+1;%Change trial
        end
        on_ornot = 0;
    end
end

trial_spikes = cell(trial_num,60);
for k = 1:60  % i is the channel number
    for j = 1:trial_num
        trial_spikes{j,k} = null(100,1);
        for m = 1:length(analyze_spikes{k});
            if analyze_spikes{k}(m) < (start_frame(j)+trial_length(j))/fps && analyze_spikes{k}(m) > start_frame(j)/fps
                trial_spikes{j,k} = [trial_spikes{j,k}  analyze_spikes{k}(m)-start_frame(j)/fps];
            end
        end
        trial_spikes{j,k} = trial_spikes{j,k} - 1/fps;
    end
end

%% Plot
figure;

ha = tight_subplot(length(display_trial)+1,1,[0 0],[0.05 0.01],[.02 .01]);

for j = 1:length(display_trial)
    BinningInterval = 1/60;  %s
    BinningTime = [BinningInterval : BinningInterval : trial_length/fps];
    BinningSpike = zeros(60,length(BinningTime));
    sub_Spikes = cell(60,1);
    s = zeros(1,length(BinningTime));
    for k = 1:60 % k is the channel number
        [n,~] = hist(trial_spikes{display_trial(j),k},BinningTime) ;
        BinningSpike(k,:) = n ;
    end
    axes(ha(j));
    %bar(BinningTime, sum(BinningSpike,1));
    %imagesc(BinningTime,channel_number,BinningSpike(channel_number,:));
    plot(BinningTime, sum(BinningSpike,1));
end
axes(ha(length(display_trial)+1));
plot(BinningTime, trial_pos(1, 1:trial_length(1)),'r');
samexaxis('abc','xmt','on','ytac','join','yld',1)

cd(code_folder)