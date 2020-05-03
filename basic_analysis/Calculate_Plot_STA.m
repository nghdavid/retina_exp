%% This code calculate HMM and OU bar position STA
close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20200418';
exp_folder = 'D:\Leo\0409';
cd(exp_folder);
%load('different_G.mat')
%load(['predictive_channel\bright_bar.mat'])
mkdir STA
cd sort_merge_spike
all_file = subdir('*.mat');% change the type of the files which you want to select, subdir or dir.
n_file = length(all_file);
sorted = 1;
unit = 1;
forward = 90;%90 bins before spikes for calculating STA
backward = 90;%90 bins after spikes for calculating STA
%roi = [p_channel np_channel];
  roi = 11;
for z = 1:n_file
    %choose file
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load(filename);
    name=[name];
    z
    name
    if (strcmp(filename(12),'H') || strcmp(filename(12),'O')) && sorted == 0
    elseif (strcmp(filename(17),'H') || strcmp(filename(17),'O')) && sorted
    else
        continue
    end
%     try
%         load([exp_folder,'\STA\',name(12:end),'.mat'])
%     catch
        disp('Have not calculated')
        idxs = cell(1,60);
        PCA_STAs = cell(1,60);
        positive_PCAs = cell(1,60);
        negative_PCAs = cell(1,60);
        BinningTime =diode_BT;
        BinningSpike = zeros(60,length(BinningTime));
        positive_before_pos = cell(1,60);
        negative_before_pos = cell(1,60);
%     end
    TheStimuli= bin_pos;  %recalculated bar position
    acf = autocorr(TheStimuli,100);
    corr_time = interp1(acf,1:length(acf),0.5,'linear')/60;
       %%  Binning
    bin=BinningInterval*10^3; %ms
    
    STA_time=[-forward:backward]*BinningInterval;
    %% BinningSpike and calculate STA
    
    analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,unit);
    sum_n = zeros(1,60);
    dis_STA = zeros(60,forward+backward+1);
    for i = roi  % i is the channel number
        if length(analyze_spikes{i}) > 5
        [n,~] = hist(analyze_spikes{i},BinningTime) ;
        PCA_STA = zeros(1,forward+backward+1);
        BinningSpike(i,:) = n ;
        sum_n(i) = sum_n(i)+ sum(BinningSpike(i,forward+1:length(BinningTime)-backward));
        num_spike =1;
        pos_100ms = [];
        for time_shift = forward+1:length(BinningTime)-backward 
            dis_STA(i,:) = dis_STA(i,:) + BinningSpike(i,time_shift)*TheStimuli(time_shift-forward:time_shift+backward);
            for x = 1:BinningSpike(i,time_shift)
                pos_100ms = [pos_100ms;TheStimuli(time_shift-6)];
                PCA_STA(num_spike,:) = TheStimuli(time_shift-forward:time_shift+backward);
                num_spike = num_spike+1;
            end

        end
        if sum_n(i)
            dis_STA(i,:) = dis_STA(i,:)/sum_n(i);
        end
        [coeff,score,latent,tsquared,explained] = pca(PCA_STA);
        PCA_STAs{i} = PCA_STA;
        %% K means clusterin2
        score1 = score(:,1);
        score2 = score(:,2);
        idx = zeros(1,length(score));
        idx(find(score1<0)) = 1;
        idx(find(score1>=0)) = 2;
%         cluster_data = [score1,score2];%Merge PCA1 and PCA2
%         idx = kmeans(cluster_data,2);%Results of which clusters(1 or 2), and clustered into 2 groups
        idxs{i} = idx;
%         %Red represents group 1, blue represents group 2
%         scatter(score1(find(idx==1)),score2(find(idx==1)),'r');hold on
%         scatter(score1(find(idx==2)),score2(find(idx==2)),'b');
%         xlabel('Stimulus*PCA1')
%         ylabel('Stimulus*PCA2')
%         title('Results of two cluster')
%         axes(ha(2)); 
        positive_PCA = PCA_STA(find(idx==1),:);
        positive_PCAs{i} = positive_PCA;
        negative_PCA= PCA_STA(find(idx==2),:);
        negative_PCAs{i} = negative_PCA;
        positive_before_pos{i} = pos_100ms(find(idx==1));
        negative_before_pos{i} = pos_100ms(find(idx==2));
        end
    end
    save([exp_folder,'\STA\',name(12:end),'.mat'],'STA_time','dis_STA','bin_pos','corr_time','idxs','PCA_STAs','positive_PCAs','negative_PCAs','positive_before_pos','negative_before_pos','BinningSpike','TheStimuli','BinningTime','forward','backward','bin','BinningInterval','score1','score2')
end

