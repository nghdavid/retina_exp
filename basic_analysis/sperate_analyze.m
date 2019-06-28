%variables that you can and should tune
load('D:\Leo\0620exp\sort_merge_spike\sort_merge_0415_short_HMM_RL_G4.3_15min_Br50_Q100_re.mat')
%load('D:\Leo\0620exp\sort_merge_spike\sort_merge_0502Rona_short_HMM_G4.3_15min_Br50_Q100_re.mat')
%load('D:\Leo\0620exp\merge\merge_0502Rona_short_HMM_G4.3_15min_Br50_Q100_re.mat')
%load('D:\Leo\0620exp\merge\merge_0415_short_HMM_RL_G4.3_15min_Br50_Q100_re.mat')


%clear all;
trial_num =30;
fps = 60;
display_trial = 1:30;
analyze_spikes = reconstruct_spikes;
%analyze_spikes = sorted_spikes;
%
% analyze_spikes = Spikes;
 analyze_spikes{31}=[];
% for i = 1:60
%     analyze_spikes{i} =analyze_spikes{i} - 17.8 ;
% end
% bin_pos = newXarray;
channel_number = 1:60;



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
for i = 1:length(bin_pos)
    if bin_pos(i) > 0
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
% start_frame = 0:30;
% start_frame = 1800*start_frame+1;
trial_spikes = cell(trial_num,60);
for k = 1:60  % i is the channel number
    for j = 1:trial_num
        trial_spikes{j,k} = null(100,1);
    end
end
for k = 1:60  % i is the channel number
    for j = 1:trial_num
        for m = 1:length(analyze_spikes{k});
            if analyze_spikes{k}(m) < (start_frame(j)+trial_length(j))/fps && analyze_spikes{k}(m) > start_frame(j)/fps
                trial_spikes{j,k} = [trial_spikes{j,k}  analyze_spikes{k}(m)-start_frame(j)/fps];
            end
        end
        trial_spikes{j,k} = trial_spikes{j,k} - 1/fps;
    end
end

%for ploting
figure;
%ha = tight_subplot(length(display_trial)+1,1,[0 0],[0.05 0.05],[.02 .01]);
%BinningSpike = zeros(60,length(BinningTime),trial_num);

for j = 1:length(display_trial)
    BinningInterval = 1/60;  %s
    BinningTime = [BinningInterval : BinningInterval : trial_length/fps];
    BinningSpike = zeros(60,length(BinningTime));
    %sub_Spikes = cell(60,1);
    s = zeros(1,length(BinningTime));
    for k = 1:60 % i is the channel number
        [n,~] = hist(trial_spikes{display_trial(j),k},BinningTime) ;
        BinningSpike(k,:) = n ;
        s = s+n;
%                 sub_Spikes{k} = trial_spikes{display_trial(j),k};
%         %         if analyze_spikes == sorted_spikes
%         %             sub_Spikes{k} = sub_Spikes{k}'
%         %         end
%                 if isempty(sub_Spikes{k})==1
%                     sub_Spikes{k}=0;
%                 end
    end
    %axes(ha(j));
    subplot(length(display_trial)+1,1,j);
    %imagesc(BinningTime,channel_number,BinningSpike(channel_number,:));
    bar(BinningTime, s*BinningInterval);
    %plot(BinningTime, s*BinningInterval);
%         LineFormat.Color = [0.3 0.3 0.3];
%         plotSpikeRaster(sub_Spikes,'PlotType','vertline','LineFormat',LineFormat);
%         hold on;
    
end
%axes(ha(length(display_trial)+1));
subplot(length(display_trial)+1,1,length(display_trial)+1);
plot([1:trial_length(1)]/60, trial_pos(1, 1:trial_length(1)),'r');
samexaxis('abc','xmt','on','ytac','join','yld',1)