close all
clear all
load('D:\Leo\0620exp\merge\merge_0415_short_HMM_RL_G4.3_15min_Br50_Q100.mat')
type = 'RL';
load('boundary_set.mat')
load('channel_pos.mat')
stimulus_length = TimeStamps(2)-TimeStamps(1);
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
for k = channel_number  % i is the channel number
    for j = 1:trial_num
        for m = 1:length(analyze_spikes{k});
            if analyze_spikes{k}(m) < (start_frame(j)+trial_length(j))/fps && analyze_spikes{k}(m) > start_frame(j)/fps
                trial_spikes{j,k} = [trial_spikes{j,k}  analyze_spikes{k}(m)-start_frame(j)/fps];
            end
        end
        %trial_spikes{j,k} = trial_spikes{j,k} - 1/fps;
    end
end

display_trial = find(trial_length == mode(trial_length));
length(display_trial)
%for ploting
%ha = tight_subplot(length(display_trial),1,[.1 .01],[0.05 0.05],[.02 .01]);
PSTH =zeros(8, mode(trial_length));
smooth_PSTH = null(1,1);
distance = [];
for j = 1:length(display_trial)
    BinningTime = [BinningInterval/2 : BinningInterval : trial_length(display_trial(j))/fps-BinningInterval/2];
    BinningSpike = zeros(60,length(BinningTime));
    dis = zeros(8,length(BinningTime));
    spike_dis = zeros(2,length(BinningTime),60);
    for k = channel_number % i is the channel number
        num_spike =  length(analyze_spikes{k});
        if num_spike /stimulus_length > 0.3 %Cells with a low firing rate for checkerbox(<0.3HZ) were not considered
            isi = diff(trial_spikes{display_trial(j),k});
            ave_isi = (isi(1:end-1)+isi(2:end))/2;
            [n,~] = hist(trial_spikes{display_trial(j),k},BinningTime);
            BinningSpike(k,:) = n;
        end
    end
    
    %for UD
    %spike_dis(1,:,k)  = n;
    %channel_pos(k,:) = RFcenter(k,:);
    if strcmp(type,'UD')
        UD_spikes = get_UD(BinningSpike);
        for m = 1:length(BinningTime)
            kk = 0;
            for k = [55 47 39 31 23 15 7 1];
                framestep = floor(m*BinningInterval*fps)+1;
                kk = kk+1;
                dis(kk, m) = (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), framestep)-meaCenter_x);
                %spike_dis(2,m,k)= (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
                
            end
        end
        PSTH = cat(2, PSTH, UD_spikes);
        distance = cat(2, distance, dis(1:8,:));
    elseif  strcmp(type,'RL')
        RL_spikes = get_RL(BinningSpike);
        for m = 1:length(BinningTime)
            kk = 0;
            for k = [14 6 5 4 3 2 1 7];
                framestep = floor(m*BinningInterval*fps)+1;
                kk = kk+1;
                dis(kk, m) = (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), framestep)-meaCenter_x);
                %spike_dis(2,m,k)= (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
                
            end
        end
        PSTH = PSTH + RL_spikes;
        %distance = cat(2, distance, dis(1:8,:));
    elseif  strcmp(type,'UR_DL')
        for m = 1:length(BinningTime)
            framestep = floor(m*BinningInterval*fps)+1;
            dis(k, m) = (-channel_pos(k,1)+ channel_pos(k,2)+meaCenter_x-meaCenter_y)/sqrt(2) - (trial_pos(display_trial(j), framestep)- meaCenter_x);
            %spike_dis(2,m,k)= (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
        end
    elseif  strcmp(type,'UL_DR')
        for m = 1:length(BinningTime)
            framestep = floor(m*BinningInterval*fps)+1;
            dis(k, m) = (channel_pos(k,1)+channel_pos(k,2)-meaCenter_y-meaCenter_x)/sqrt(2) - (trial_pos(display_trial(j), framestep)- meaCenter_x);
            %spike_dis(2,m,k)= (channel_pos(k,1)-meaCenter_x) - (trial_pos(display_trial(j), m)-meaCenter_x + re_bar_wid);
        end
    end
    %         plot(dis(k,1:length(BinningTime)),BinningSpike(k,1:length(BinningTime))/BinningInterval,'k');
    %         hold on;
    
    %     PSTH = [PSTH BinningSpike(k,1:length(BinningTime))];
    %     %smooth_PSTH =  [smooth_PSTH smooth(BinningSpike(k,1:length(BinningTime)),10)'];
    %     distance = [distance dis(k,1:length(BinningTime))];
    %     sum_n(k) = sum_n(k)+ sum(BinningSpike(k,91:length(BinningTime)-90));
    %     for i = 91:length(BinningTime)-90
    %         dis_STA(k,:) = dis_STA(k,:) + BinningSpike(k,i)*dis(k, i-90:i+90);
    %     end
end

for kk =1:8
    figure(kk);
%     scatter(dis(kk,:),PSTH(kk,:), 10,'filled');
%     [sort_dist index]= sort(dis(kk,:));
%     sort_PSTH = PSTH(kk,index);
%     figure(kk+20);
%     plot(sort_dist,sort_PSTH);
%     figure(kk+40);
    plot(dis(kk,:)/max(abs(dis(kk,:)))*max(PSTH(kk,:)));hold on
    plot(PSTH(kk,:));hold on
    
end

norPSTH = zeros(8, mode(trial_length));
for kk = 1:8
    if mean(PSTH(kk,:)) == 0
        norPSTH(kk,:) = 0;
    else
        norPSTH(kk,:) = PSTH(kk,:)/ max(PSTH(kk,:));
    end
end
peak_pos = [];
for i = 1:length(PSTH)
    if sum( PSTH(:,i)) == 0
        peak_pos = [peak_pos NaN];
    else
        index = find(norPSTH(:,i)' == max( norPSTH(:,i)));
        peak_pos = [peak_pos mean(index)];
    end
end
figure(100);
%scatter (1:600, peak_pos , 10,'filled' );hold on
plot (peak_pos);hold on
plot (-dis(1,:)*micro_per_pixel/200+1);hold on




%sort_smooth_PSTH = smooth_PSTH(index);



%
%scatter(distance, smooth_PSTH, 10,'filled');
% distance(find(PSTH == 0)) = [];
% PSTH(find(PSTH == 0)) = [];
% figure;
% distance(PSTH == 0) = [];
% PSTH(PSTH == 0 ) = [];
% [sort_dis index] = sort(distance);
% plot(sort_dis , PSTH(index));
