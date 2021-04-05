close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20200531';
cd(exp_folder)
load('different_G.mat')
load('predictive_channel\bright_bar.mat')
order = '0';%First or second experiment
sorted=1;
save_photo = 1;
all_or_Not = 1;%Plot all channels or not
roi = [p_channel;np_channel];
if order == '0'
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW_1Hz'];
else
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW_1Hz',order];
end
%Filename used to save(Plot HMM only)   
if sorted
    sort_directory = 'sort';
    mkdir FIG\sort
    cd sort_merge_spike\MI
else
    sort_directory = 'unsort';
    mkdir FIG\unsort
    cd merge\MI
end

%% Load data
allchannellegend = cell(1,length(OUsmooth_different_G));%Save which G
date_t_legend = {'1st','2nd'};
all_corr_t_legend = cell(1,length(OUsmooth_different_G)+length(OU_different_G));%Save HMM and OU correlation time

%Load HMM MI data and correlation time
total_fire_rate1 =[];
total_fire_rate2 =[];
for G =1:length(OUsmooth_different_G)
    firing_rate = zeros(1,60);
    HMM_former_name1 = ['sort_merge_',HMM_date1,'_OUsmooth_',direction,'_G'];
    load([HMM_former_name1,num2str(OUsmooth_different_G(G)),HMM_post_name,'.mat'])
    BinningTime =diode_BT;
    for i = 1:60 % i is the channel number
        [n,~] = hist(sorted_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        firing_rate(i) = mean(n)/BinningInterval;  
    end
    total_fire_rate1 = [total_fire_rate1;firing_rate];
    
    firing_rate = zeros(1,60);
    HMM_former_name2 = ['sort_merge_',HMM_date1,'_OUsmooth_2nd_Order',direction,'_G'];
    load([HMM_former_name2,num2str(OUsmooth_different_G(G)),HMM_post_name ,'.mat'])
    for i = 1:60 % i is the channel number
        [n,~] = hist(sorted_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        firing_rate(i) = mean(n)/BinningInterval;  
    end
    total_fire_rate2 = [total_fire_rate2;firing_rate];
end


for G =1:length(OUsmooth_different_G)
    figure
    firing_rate1 = total_fire_rate1(G,roi)';
    firing_rate2 = total_fire_rate2(G,roi)';
    bar([firing_rate1,firing_rate2])
    legend(date_t_legend)
    xlabel(num2str(roi))
    ylabel('Firing rate')
    title(['Comparison of firing rate between 1st and 2nd order G',num2str(OUsmooth_different_G(G))])
    saveas(gcf,[exp_folder,'\FIG\sort\2nd\Compare_2nd_G',num2str(OUsmooth_different_G(G)),'.tif'])
end