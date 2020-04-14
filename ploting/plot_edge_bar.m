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
direction = 'RL';%%%%%%%%%%
if order == '0'
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
else
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW',order];
end
%Filename used to save(Plot HMM only)   
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
date_t_legend = {'Bar','Edge'};
%Load HMM MI data and correlation time
HMM_MI1 =[];
HMM_MI_shuffle1 = [];
HMM_peaks1 = [];
HMM_MI2 =[];
HMM_MI_shuffle2 = [];
HMM_peaks2 = [];
diff_peak = [];
for G =1%:length(HMM_different_G)
    HMM_former_name1 = [type,'_',HMM_date1,'_HMM_',direction,'_G'];
    %%%%
    load([HMM_former_name1,num2str(HMM_different_G(G+1)),HMM_post_name,'.mat'])
    %%%%%
    HMM_peaks1 = [HMM_peaks1;peak_times];
    HMM_MI1 = [HMM_MI1;Mutual_infos];
    HMM_MI_shuffle1 = [HMM_MI_shuffle1 ;Mutual_shuffle_infos];
    HMM_former_name2 = [type,'_',HMM_date2,'_HMM_Edge_',direction,'_G'];
    load([HMM_former_name2,num2str(edge_different_G(G)),HMM_post_name ,'.mat'])
    HMM_peaks2 = [HMM_peaks2;peak_times];
    HMM_MI2 = [HMM_MI2;Mutual_infos];
    HMM_MI_shuffle2 = [HMM_MI_shuffle2;Mutual_shuffle_infos];
end

%% Plot all channels
if all_or_Not
for G =1%:length(HMM_different_G)
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    for channelnumber=1:60 %choose file
        axes(ha(rr(channelnumber)));
            mean_MI_shuffle1 = mean(cell2mat(HMM_MI_shuffle1(G,channelnumber)));
            mutual_information1 = cell2mat(HMM_MI1 (G,channelnumber));
            mean_MI_shuffle2 = mean(cell2mat(HMM_MI_shuffle2(G,channelnumber)));
            mutual_information2 = cell2mat(HMM_MI2 (G,channelnumber));
            if channelnumber~=31
                if max(mutual_information1-mean_MI_shuffle1)<0.2 && max(mutual_information2-mean_MI_shuffle2)<0.2
                    continue;
                end
            end
            plot(time,mutual_information1-mean_MI_shuffle1,'r'); hold on;
            plot(time,mutual_information2-mean_MI_shuffle2,'b'); hold on;
            xline(0)
            xlim([ -2300 1300])
            ylim([0 inf+0.1])
            title(channelnumber)
            if channelnumber == 31
                lgd =legend(date_t_legend,'Location','northwest');
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
        HMM_filename =  ['edge_bar_',type,'_',HMM_date1,'_HMM_',direction,'_G',num2str(edge_different_G(G)),'_',num2str(mins),'min'];
        saveas(fig,[exp_folder,'\FIG\',sort_directory,'\',HMM_filename,'.tif'])
    end
end
end
