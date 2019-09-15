close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20190721';
cd(exp_folder)
type = 'v';
direction = 'UD';
HMM_different_G = [3,4.5,7.5,12,20];
mins = 7;%Length of movie length
date = '0602';%Date of movie
order = '1';%First or second experiment
sorted=1;
save_photo = 1;
OU_different_G = [2.45,10.5];
OU_or_Not = 1;%Plot OU or not
all_or_Not = 1;%Plot all channels or not
roi = [];
HMM_former_name = [type,'_',date,'_HMM_',direction,'_G'];
HMM_post_name = ['_',num2str(mins),'min_Br50_Q100_',order];
HMM_filename =  [type,'_',date,'_HMM_',direction,'_',num2str(length(HMM_different_G )),'G_',num2str(mins),'min_Br50_Q100_',order,'_ch']; %Filename used to save(Plot HMM only)   
OU_filename =  [type,'_',date,'_HMMandOU_',direction,'_',num2str(length(HMM_different_G )),'G_',num2str(mins),'min_Br50_Q100_',order,'_ch'];%Filename used to save(Plot HMM and OU)   
OU_former_name = [type,'_','0319_OU_',direction,'_G'];
OU_post_name = '_5min_Br50_Q100';%Load calculated MI first(Need to run Calculate_MI.m first to get)
if sorted
    cd MI\sort
else
    cd MI\unsort
end

%% Load data
allchannellegend = cell(1,length(HMM_different_G));%Save which G
corr_t_legend = cell(1,length(HMM_different_G));%Save HMM correlation time
all_corr_t_legend = cell(1,length(HMM_different_G)+length(OU_different_G));%Save HMM and OU correlation time

%Load HMM MI data and correlation time
HMM_MI =[];
HMM_MI_shuffle = [];
HMM_peaks = [];
for G =1:length(HMM_different_G) 
    load([HMM_former_name,num2str(HMM_different_G(G)),HMM_post_name ,'.mat'])
    HMM_peaks = [HMM_peaks;peak_times];
    HMM_MI = [HMM_MI;Mutual_infos];
    HMM_MI_shuffle = [HMM_MI_shuffle ;Mutual_shuffle_infos];
    allchannellegend{G} = ['G', num2str(HMM_different_G(G))];
    all_corr_t_legend{G} = [num2str(corr_time),' sec'];
    corr_t_legend{G} = [num2str(corr_time),' sec'];
end
%Load OU MI data and correlation time
if OU_or_Not
    OU_MI =[];
    OU_MI_shuffle = [];
    for     G =1:length(OU_different_G) 
        load([OU_former_name,num2str(OU_different_G(G)),OU_post_name ,'.mat'])

        OU_MI = [OU_MI;Mutual_infos];
        OU_MI_shuffle = [OU_MI_shuffle ;Mutual_shuffle_infos];
        all_corr_t_legend{G+length(HMM_different_G)} = ['OU-', num2str(corr_time),' sec'];
    end
end

%% Plot all channels
if all_or_Not
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    for channelnumber=1:60 %choose file
        axes(ha(rr(channelnumber)));
        %Plot HMM
        for G =1:length(HMM_different_G)
            mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(G,channelnumber)));
            mutual_information = cell2mat(HMM_MI (G,channelnumber));
            if channelnumber~=31
            if max(mutual_information-mean_MI_shuffle)<0.1
                continue;
            end
            else
                plot(time,mutual_information-mean_MI_shuffle); hold on; %,'color',cc(z,:));hold on
                xlim([ -2300 1300])
                ylim([0 100])
                continue;
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
    if OU_or_Not
        saveas(fig,[exp_folder,'\FIG\sort\',OU_filename(1:end-3),'.tif'])
    else
        saveas(fig,[exp_folder,'\FIG\unsort\',HMM_filename(1:end-3),'.tif'])
    end
    end
end
%% Plot single channel
mean_peaks = zeros(length(HMM_different_G),length(roi));
for channelnumber= roi 
     figure(channelnumber)
     for   G =1:length(HMM_different_G)
        mean_peaks(G,find(roi==channelnumber)) = HMM_peaks(G,channelnumber);
        mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(G,channelnumber)));
        mutual_information = cell2mat(HMM_MI (G,channelnumber));hold on;
        %Plot HMM with different line
        if G >=4
            plot(time,smooth(mutual_information-mean_MI_shuffle)); 
        elseif G >2
            plot(time,smooth(mutual_information-mean_MI_shuffle),'k:'); 
        else
            plot(time,smooth(mutual_information-mean_MI_shuffle),'.'); 
        end
        xlim([ -2300 1300])
        ylim([0 inf+0.1])
     end
     %Plot OU
     if OU_or_Not
         for   G =1:length(OU_different_G)
            mean_MI_shuffle = mean(cell2mat(OU_MI_shuffle(G,channelnumber)));
            mutual_information = cell2mat(OU_MI (G,channelnumber));hold on;
            plot(time,smooth(mutual_information-mean_MI_shuffle),'-.'); 
            xlim([ -1300 1300])
            ylim([0 inf+0.1])
         end
     end
     grid on
     
     if OU_or_Not
       lgd =legend(all_corr_t_legend,'Location','northwest');
     else
       lgd =legend(corr_t_legend,'Location','northwest');
     end
     lgd.FontSize = 11;
     legend('boxoff')
     hold off;
     if save_photo
         if sorted
            if OU_or_Not
                saveas(fig,[exp_folder,'\FIG\sort\',OU_filename,int2str(channelnumber),'.tif'])
            else
                saveas(fig,[exp_folder,'\FIG\sort\',HMM_filename,int2str(channelnumber),'.tif'])
            end
         else
            if OU_or_Not
                saveas(fig,[exp_folder,'\FIG\unsort\',OU_filename,int2str(channelnumber),'.tif'])
            else
                saveas(fig,[exp_folder,'\FIG\unsort\',HMM_filename,int2str(channelnumber),'.tif'])
            end
         end
     end
end
% figure(100)
% std_peaks = std(mean_peaks,0,2);
% means_peaks = mean(mean_peaks,2);
% errorbar([1.08,0.8,0.4833,0.32,0.18],means_peaks ,std_peaks,'o','color','k')
% xlabel('Correlation time (sec)')
% ylabel('Peak time shift (ms)')
