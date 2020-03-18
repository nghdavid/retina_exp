close all;
clear all;
name = 'HMM_UR_DL_G4.5_5min_Q100_6.5mW';
exp_folder = 'D:\Leo\0229';
channel_number = [25 32]; %2 element only for now. 1st for N, 2nd for P.
tolerance = 1/60; %s
sorted = 0;
unit = 0;
analyze_spikes = cell(1,60);
if sorted
    load([exp_folder, '\sort_merge_spike\sort_merge_0224_', name,'.mat'])
    load([exp_folder, '\MI\sort\pos_0224_', name,'.mat'])
    analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,unit);
else
    load([exp_folder, '\merge\merge_0224_', name,'.mat'])
    load([exp_folder, '\MI\unsort\pos_0224_', name,'.mat'])
    analyze_spikes = reconstruct_spikes;
end


%% plot original MI
figure(1);
for k = channel_number
    plot(time,smooth(Mutual_infos{k}),'LineWidth',1.5,'LineStyle',':');hold on;
    xlabel('\deltat (ms)');ylabel('MI (bits/second)');
    xlim([ -1500 1500])
    %ylim([0 inf] )
    %set(gca,'fontsize',12 , 'xtick', [0], 'ytick', []); hold on
    set(gca,'fontsize',12 ); hold on
    grid on
    title([strrep(name,'_',' '), ' [', num2str(channel_number), ']']);
end 



%% remove sharing spike and plot the removed, sharing, and original spike
for j = 1:length(channel_number)
    sub_Spikes{j} = analyze_spikes{channel_number(j)};
    if isempty(sub_Spikes{j})==1
        sub_Spikes{j}=0;
    end
    %sub_Spikes{j} = sub_Spikes{j}';
end
null_index_1 = [];
null_index_2 = [];
%There may be a better way to search
for m = 1:length(sub_Spikes{1})
    for n = 1:length(sub_Spikes{2})
        if abs(sub_Spikes{1}(m)-sub_Spikes{2}(n)) < tolerance
            null_index_1 = [null_index_1 m];
            null_index_2 = [null_index_2 n];
        end
    end
end
null_index_1 = unique(null_index_1);
null_index_2 = unique(null_index_2);
sub_Spikes{3} = sub_Spikes{1}(null_index_1); %sharing N
sub_Spikes{4} = sub_Spikes{2}(null_index_2); %sharing P
sub_Spikes{5} = sub_Spikes{1}; %original N
sub_Spikes{6} = sub_Spikes{2}; %original P
sub_Spikes{5}(null_index_1) = []; 
sub_Spikes{6}(null_index_2) = []; 
figure;
LineFormat.Color = [0.3 0.3 0.3];
plotSpikeRaster(sub_Spikes,'PlotType','vertline','LineFormat',LineFormat);
hold on;
set(gca, 'ytick', 1:6)  
set(gca, 'yticklabel', {'Original N','Original P','sharing N','sharing P','removed N','removed P'}) 
oN = length(analyze_spikes{channel_number(1)});
oP = length(analyze_spikes{channel_number(2)});
s_analyze_spikes{channel_number(1)} = analyze_spikes{channel_number(1)}(null_index_1);
s_analyze_spikes{channel_number(2)} = analyze_spikes{channel_number(2)}(null_index_2);
analyze_spikes{channel_number(1)}(null_index_1) = [];
analyze_spikes{channel_number(2)}(null_index_2) = [];
cN = length(analyze_spikes{channel_number(1)});
cP = length(analyze_spikes{channel_number(2)});
cN/oN 
cP/oP 

%% calculate and plot  MI of removed spike

TheStimuli=bin_pos;
bin=BinningInterval*10^3; %ms
BinningTime =diode_BT;

StimuSN=30; %number of stimulus states
nX=sort(TheStimuli);
abin=length(nX)/StimuSN;
intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
temp=0; isi2=[];
for jj=1:length(TheStimuli)
    temp=temp+1;
    isi2(temp) = find(TheStimuli(jj)<=intervals,1);
end

    %% BinningSpike
BinningSpike = zeros(60,length(BinningTime));
for  j = channel_number  % i is the channel number
    [n,~] = hist(analyze_spikes{j},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
    BinningSpike(j,:) = n ;
end

    %% Predictive information
backward=ceil(15000/bin);
forward=ceil(15000/bin);
time=[-backward*bin:bin:forward*bin];
figure(1);
for j = channel_number
    
    Neurons = BinningSpike(j,:);  %for single channel
    information = MIfunc(Neurons,isi2,BinningInterval,backward,forward);
    plot(time,smooth(information),'LineWidth',1.5,'LineStyle','-');hold on;
    set(gca,'fontsize',12); hold on
    %         legend('-DynamicLegend');
    %         legend('show')
    %lgd = legend(['Original N'],['Original P'], ['removed N'],['removed P']);
end




% TheStimuli=bin_pos;
% bin=BinningInterval*10^3; %ms
% BinningTime =diode_BT;
% 
% StimuSN=30; %number of stimulus states
% nX=sort(TheStimuli);
% abin=length(nX)/StimuSN;
% intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
% temp=0; isi2=[];
% for jj=1:length(TheStimuli)
%     temp=temp+1;
%     isi2(temp) = find(TheStimuli(jj)<=intervals,1);
% end

    %% BinningSpike
BinningSpike = zeros(60,length(BinningTime));
for  j = channel_number  % i is the channel number
    [n,~] = hist(s_analyze_spikes{j},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
    BinningSpike(j,:) = n ;
end

    %% Predictive information
backward=ceil(15000/bin);
forward=ceil(15000/bin);
time=[-backward*bin:bin:forward*bin];
figure(1);
for j = channel_number
    
    Neurons = BinningSpike(j,:);  %for single channel
    information = MIfunc(Neurons,isi2,BinningInterval,backward,forward);
    plot(time,smooth(information),'LineWidth',1.5,'LineStyle','--');hold on;
    %plot(time,smooth(Mutual_shuffle_infos{j}),'LineWidth',1.5,'LineStyle','-');hold on;
    xlim([ -1500 1500])
    set(gca,'fontsize',12); hold on
    lgd = legend(['Original N'],['Original P'], ['removed N'],['removed P'], ['sharing N'],['sharing P']);
end

cd(exp_folder)
mkdir FIG
mkdir FIG cfNP
saveas(gcf,[exp_folder, '\FIG\cfNP\', name,'[', strrep(num2str(channel_number), '  ', '_'), '].tiff'])
    
    
    
    
    
    
    
    
