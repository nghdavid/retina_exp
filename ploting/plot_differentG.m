close all;
clear all;
code_folder = pwd;
exp_folder = 'D:\Leo\0229';
cd(exp_folder)
XOwf =1;
XOdark = 0;
direction = 'UR_DL';
sorted =0;
if XOwf
    HMM_former_name = 'pos_0224_HMM_wf_G';
    HMM_post_name = ['_5min_Q100']; 
    OU_former_name = 'pos_0224_OU_wf_G';
    OU_post_name = ['_5min_Q100'];
    OU_different_G = [3 7.5];
    name = '5G_WF'
elseif XOdark
    HMM_former_name = ['pos_0224_HMM_Dark_',direction, '_G'];
    HMM_post_name = '_5min_Q100_6.5mW_100';
    OU_former_name = ['pos_0224_OU_Dark_', direction, '_G'];
    OU_post_name = '_5min_Q100_6.5mW_100';
    OU_different_G = [3 7.5];
    name = '5G_DB'
else
    HMM_former_name = ['pos_0224_HMM_',direction, '_G'];
    HMM_post_name = '_5min_Q100_6.5mW';
    OU_former_name = ['pos_0224_OU_', direction, '_G'];
    OU_post_name = '_5min_Q100_6.5mW';
    OU_different_G = [3 7.5];
    name = '5G_BB'
end
HMM_different_G = [2.5,4.5,9,12,20];
%Load calculated MI first(Need to run Calculate_MI.m first to get)
if sorted
%     load([exp_folder, '\Analyzed_data\sort\0821_Gollish_OnOff_0.8.mat']);
%     load([exp_folder, '\Analyzed_data\sort\csta.mat'])
    cd MI\sort
else
%     load([exp_folder, '\Analyzed_data\unsort\0821_Gollish_OnOff_0.8.mat']);
%     load([exp_folder, '\Analyzed_data\unsort\csta.mat'])
    cd MI\unsort
end
rr =[9,17,25,33,41,49,...
    2,10,18,26,34,42,50,58,...
    3,11,19,27,35,43,51,59,...
    4,12,20,28,36,44,52,60,...
    5,13,21,29,37,45,53,61,...
    6,14,22,30,38,46,54,62,...
    7,15,23,31,39,47,55,63,...
    16,24,32,40,48,56];

HMM_MI =[];
HMM_MI_shuffle = [];
allchannellegend = cell(1,length(HMM_different_G));
corr_t_legend = cell(1,length(HMM_different_G)+length(OU_different_G));
t_corr_serie =[];
time_serie = cell(length(HMM_different_G)+length(OU_different_G),1);
for     G =1:length(HMM_different_G)
    load([HMM_former_name,num2str(HMM_different_G(G)),HMM_post_name ,'.mat'])
    
    HMM_MI = [HMM_MI;Mutual_infos];
    HMM_MI_shuffle = [HMM_MI_shuffle ;Mutual_shuffle_infos];
    allchannellegend{G} = ['G', num2str(HMM_different_G(G))];
    corr_t_legend{G} = num2str(corr_time);
    t_corr_serie = [t_corr_serie corr_time];
    time_serie{G} = time;
end

OU_MI =[];
OU_MI_shuffle = [];
for     G =1:length(OU_different_G)
    load([OU_former_name,num2str(OU_different_G(G)),OU_post_name ,'.mat'])
    
    OU_MI = [OU_MI;Mutual_infos];
    OU_MI_shuffle = [OU_MI_shuffle ;Mutual_shuffle_infos];
    corr_t_legend{G+length(HMM_different_G)} = ['OU-', num2str(corr_time)];
    time_serie{G+length(HMM_different_G)} = time;
end
figure('IntegerHandle', 'off', 'units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);

MI_peak=zeros(length(HMM_different_G),60);
ind_peak=zeros(length(HMM_different_G),60);
for channelnumber=1:60 %choose file
    axes(ha(rr(channelnumber)));
    
    for     G =1:length(HMM_different_G)
        
        
        mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(G,channelnumber)));
        mutual_information = cell2mat(HMM_MI (G,channelnumber));
        if channelnumber~=31
            if max(mutual_information-mean_MI_shuffle)<0.1
                continue;
            else
                plot(time_serie{G},mutual_information-mean_MI_shuffle); hold on; %,'color',cc(z,:));hold on
                xlim([ -2300 1300])
                ylim([0 inf+0.1])
                title(channelnumber);
            end
        else
            %             plot(time,mutual_information-mean_MI_shuffle); hold on; %,'color',cc(z,:));hold on
            %             xlim([ -1500 2000])
            %             ylim([0 100])
            %             lgd =legend(allchannellegend,'Location','north');
            %             lgd.FontSize = 11;
            %             legend('boxoff')
        end
    end
    
    hold off;
    saveas(gcf,['FIG\',name,'.tif'])
    
    
end
%find MI peak
for channelnumber=1:60 %choose file
    for     G =1:length(HMM_different_G)
        HMM_MI{G,channelnumber} = smooth(HMM_MI{G,channelnumber});
        [MI_peak(G,channelnumber), ind_peak(G,channelnumber)] = max(HMM_MI{G,channelnumber}); % MI_peak{number of data}{number of channel}
        if (time(ind_peak(G,channelnumber)) < -1000) || (time(ind_peak(G,channelnumber)) > 1000) % the 100 points, timeshift is 1000
            MI_peak(G,channelnumber) = NaN;
            ind_peak(G,channelnumber) = NaN;
        end
        % ======= exclude the MI that is too small ===========
        pks_1d=ind_peak(G,channelnumber);
        peaks_ind=pks_1d(~isnan(pks_1d));
        peaks_time = time(peaks_ind);
    end
end
% [25,33,34]
%[52,53,57,58,59,60]
%% Chose by hand and plot single channels
MI_width = zeros(5,60);
for channelnumber=1:60%
    if sum(isnan(MI_peak(:,channelnumber))) == 0
        figure(channelnumber)
        for   G =1:length(HMM_different_G)
            mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(G,channelnumber)));
            baseline = mean_MI_shuffle + std(cell2mat(HMM_MI_shuffle(G,channelnumber)));
            mutual_information = cell2mat(HMM_MI (G,channelnumber)) ;hold on;
            %calculate MI_width by seeing MI curve as a Gaussian distribution. So the unit of MI_width would be ms.
            mean_MI_distr = 0;
            sq_MI_distr = 0;
            for j = 1:length(mutual_information)
                if mutual_information(j) > baseline
                    mean_MI_distr =  mean_MI_distr+j*(mutual_information(j)-baseline)/sum(mutual_information); 
                    sq_MI_distr =sq_MI_distr+ j^2*(mutual_information(j)-baseline)/sum(mutual_information);
                end
            end
            MI_width(G, channelnumber) =sqrt (sq_MI_distr-mean_MI_distr^2);
                
            plot(time_serie{G},smooth(mutual_information- mean_MI_shuffle ),'LineWidth',1.5,'LineStyle','-');
            xlim([ -2300 1300])
            ylim([0 inf+0.1])
        end
        for   G =1:length(OU_different_G)
            mean_MI_shuffle = mean(cell2mat(OU_MI_shuffle(G,channelnumber)));
            mutual_information = cell2mat(OU_MI (G,channelnumber));hold on;
            plot(time_serie{G+length(HMM_different_G)},smooth(mutual_information - mean_MI_shuffle ),'LineWidth',1.5,'LineStyle',':');
            xlim([ -1300 1300])
            ylim([0 inf+0.1])
            
        end
        title(channelnumber);
        xlabel('\deltat (ms)');ylabel('MI (bits/second)');
        set(gca,'fontsize',12 ); hold on
        lgd =legend(corr_t_legend,'Location','northwest');
        lgd.FontSize = 11;
        legend('boxoff')
        grid on
        hold off;
        %
        figure(channelnumber+100)
        plot(t_corr_serie,time(ind_peak(:,channelnumber )),'-o','MarkerIndices',1:length(t_corr_serie),'LineWidth',1.5)
        xlabel('t_c_o_r_r (ms)');ylabel('t_s_h_i_f_t (ms)');
        title(channelnumber);
        set(gca,'fontsize',12 );
        %
        figure(channelnumber+200)
        plot(t_corr_serie,MI_peak(:,channelnumber ),'-o','MarkerIndices',1:length(t_corr_serie),'LineWidth',1.5)
        xlabel('t_c_o_r_r (ms)');ylabel('MI peak (bits/second)');
        title(channelnumber);
        set(gca,'fontsize',12 );
         %
        figure(channelnumber+300)
        plot(t_corr_serie,MI_width(:, channelnumber),'-o','MarkerIndices',1:length(t_corr_serie),'LineWidth',1.5)
        xlabel('t_c_o_r_r (ms)');ylabel('MI width (time)');
        title(channelnumber);
        set(gca,'fontsize',12 );
        
        
    end
end