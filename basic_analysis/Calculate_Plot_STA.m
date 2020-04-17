%% This code calculate HMM and OU bar position STA
close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20200302';
cd(exp_folder);
load('different_G.mat')
load(['predictive_channel\bright_bar.mat'])
mkdir STA
cd sort_merge_spike\MI
all_file = subdir('*.mat');% change the type of the files which you want to select, subdir or dir.
n_file = length(all_file);
unit = 1;
forward = 90;%90 bins before spikes for calculating STA
backward = 90;%90 bins after spikes for calculating STA
roi = [p_channel np_channel];
%  roi = 15;
for z = 12:n_file
    %choose file
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load(filename);
    name=[name];
    z
    name
    try
        load([exp_folder,'\STA\',name(12:end),'.mat'])
    catch
        disp('Have not calculated')
        idxs = cell(1,60);
        PCA_STAs = cell(1,60);
        positive_PCAs = cell(1,60);
        negative_PCAs = cell(1,60);
        BinningTime =diode_BT;
        BinningSpike = zeros(60,length(BinningTime));
    end
    TheStimuli= bin_pos;  %recalculated bar position
    acf = autocorr(TheStimuli,100);
    corr_time = interp1(acf,1:length(acf),0.5,'linear')/60;
       %%  Binning
    bin=BinningInterval*10^3; %ms
    
    STA_time=[-forward :backward]*BinningInterval;
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
        for time_shift = forward+1:length(BinningTime)-backward 
            dis_STA(i,:) = dis_STA(i,:) + BinningSpike(i,time_shift)*TheStimuli(time_shift-forward:time_shift+backward);
            for x = 1:BinningSpike(i,time_shift)
                PCA_STA(num_spike,:) = TheStimuli(time_shift-forward:time_shift+backward);
                num_spike = num_spike+1;
            end   
        end
        if sum_n(i)
            dis_STA(i,:) = dis_STA(i,:)/sum_n(i);
        end
        [coeff,score,latent,tsquared,explained] = pca(PCA_STA);
        PCA_STAs{i} = PCA_STA;
        %% K means clustering
        score1 = score(:,1);
        score2 = score(:,2);
        idx = zeros(1,length(score));
        idx(find(score1<0)) = 1;
        idx(find(score1>=0)) = 2;
%         cluster_data = [score1,score2];%Merge PCA1 and PCA2
%         idx = kmeans(cluster_data,2);%Results of which clusters(1 or 2), and clustered into 2 groups
        idxs{i} = idx;
%         figure('units','normalized','outerposition',[0 0 1 1])
%         ha = tight_subplot(1,3,[.04 .04],[0.09 0.02],[.04 .04]);
%         set(ha, 'Visible', 'off');
%         set(gcf,'units','normalized','outerposition',[0 0 1 1])
%         fig =gcf;
%         fig.PaperPositionMode = 'auto';
%         fig.InvertHardcopy = 'off';
%         axes(ha(1))
%         
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
%         plot(time,mean(positive_PCA,1),'r');hold on%Red is positive_PCA
%         plot(time,mean(negative_PCA,1),'b');%Blue is negative_PCA
%         xlabel('time before spike(sec)')
%         ylabel('STA from two kinds of clusters')
%         title('STA of two different clusters using k means')
%         xline(0)
%         axes(ha(3)); 
%         plot(time,dis_STA(i,:));
%         xlabel('time before spike(sec)')
%         ylabel('STA of bar')
%         xline(0)
%         if predicitive_or_Not
%             title(['p',int2str(i)])
%         else
%             title(['np',int2str(i)])
%         end
%         legend([num2str(corr_time),' sec'])
%         scatter(score1(find(score1>0)),score2(find(score1>0)),'r');hold on
%         scatter(score1(find(score1<0)),score2(find(score1<0)),'b');
%         if save_photo
%             saveas(fig,[exp_folder,'\STA\FIG\',name(12:end),'_ch',int2str(i),'.tif'])
%         end
        end
    end
    save([exp_folder,'\STA\',name(12:end),'.mat'],'STA_time','dis_STA','bin_pos','corr_time','idxs','PCA_STAs','positive_PCAs','negative_PCAs','BinningSpike','TheStimuli','BinningTime','forward','backward','bin','BinningInterval','score1','score2')
end

