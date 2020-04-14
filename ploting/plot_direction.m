close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20200306';
cd(exp_folder)
load('different_G.mat')
type = 'pos';
order = '0';%First or second experiment
sorted=1;
save_photo = 1;
all_or_Not = 1;%Plot all channels or not
if order == '0'
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
else
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW_',order];
end
HMM_filename =  ['direction_',type,'_',HMM_date1,'_HMM_G4.5_',num2str(mins),'min_Br50_Q100_ch']; %Filename used to save(Plot HMM only)   
if sorted
    sort_directory = 'sort';
    mkdir FIG\sort
    cd MI\sort
else
    sort_directory = 'unsort';
    mkdir FIG\unsort
    cd MI\unsort
end

%% Load data
allchannellegend = cell(1,4);%Save which G
corr_t_legend = cell(1,4);%Save HMM correlation time
all_corr_t_legend = cell(1,4);%Save HMM and OU correlation time

%Load HMM MI data and correlation time
HMM_MI =[];
HMM_MI_shuffle = [];
HMM_peaks = [];
num = 1;
for direct = {'UD','RL','UR_DL','UL_DR'}
    HMM_former_name = [type,'_',HMM_date1,'_HMM_',cell2mat(direct),'_G'];
    if strcmp(cell2mat(direct),direction)
        HMM_post_name = [HMM_post_name,'_pre'];
    else
        HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
    end
    load([HMM_former_name,'4.5',HMM_post_name ,'.mat'])
    HMM_peaks = [HMM_peaks;peak_times];
    HMM_MI = [HMM_MI;Mutual_infos];
    HMM_MI_shuffle = [HMM_MI_shuffle ;Mutual_shuffle_infos];
    allchannellegend{num} = [cell2mat(direct)];
    all_corr_t_legend{num} = [cell2mat(direct)];
    corr_t_legend{num} = [cell2mat(direct)];
    num = num + 1;
end

%% Plot all channels
if all_or_Not
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    for channelnumber=1:60 %choose file
        axes(ha(rr(channelnumber)));
        %Plot HMM
        for G =1:4
            mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(G,channelnumber)));
            mutual_information = cell2mat(HMM_MI(G,channelnumber));
            if channelnumber~=31
            if max(mutual_information-mean_MI_shuffle)<0.1
                break;
            end
            end
            plot(time,mutual_information-mean_MI_shuffle); hold on; %,'color',cc(z,:));hold on
            xlim([ -2300 1300])
            ylim([0 inf+0.1])
            title(channelnumber)
        end
        if channelnumber == 31
            lgd =legend(corr_t_legend,'Location','northwest');
            lgd.FontSize = 11;
            legend('boxoff')
        end
        hold off;
    end
    %Save fig
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig =gcf;
    fig.PaperPositionMode = 'auto';
    fig.InvertHardcopy = 'off';
    if save_photo
        filename =  ['direction_',type,'_',HMM_date1,'_HMM_G4.5_',num2str(mins),'min'];
        saveas(fig,[exp_folder,'\FIG\',sort_directory,'\',filename,'.tif'])
    end
end
%% Plot single channel
close all;
for channelnumber= direction_roi 
     figure(channelnumber)
     for  d =1:4
        mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(d,channelnumber)));
        mutual_information = cell2mat(HMM_MI (d,channelnumber));hold on;
        %Plot HMM with different line
        if d >=4
            plot(time,smooth(mutual_information-mean_MI_shuffle)); 
        elseif d >2
            plot(time,smooth(mutual_information-mean_MI_shuffle),'k:'); 
        else
            plot(time,smooth(mutual_information-mean_MI_shuffle),'.'); 
        end
        xlim([ -2300 1300])
        ylim([0 inf+0.1])
     end
     grid on  
     lgd =legend(corr_t_legend,'Location','northwest');
     lgd.FontSize = 11;
     legend('boxoff')
     hold off;
     if save_photo
         saveas(gcf,[exp_folder,'\FIG\',sort_directory,'\',HMM_filename,int2str(channelnumber),'.tif'])
     end
end
% figure(100)
% std_peaks = std(mean_peaks,0,2);
% means_peaks = mean(mean_peaks,2);
% errorbar([1.08,0.8,0.4833,0.32,0.18],means_peaks ,std_peaks,'o','color','k')
% xlabel('Correlation time (sec)')
% ylabel('Peak time shift (ms)')
