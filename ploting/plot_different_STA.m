close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20190811';
cd(exp_folder)
load('rr.mat')
load('Analyzed_data\RFcenter.mat')%Needed to run Receptive field.m first
direction = 'RL';
HMM_different_G = [3,4.5,7.5,12,20];
mins = 7;%Length of movie length
date = '0602';%Date of movie
order = '1';%First or second experiment
sorted=1;
save_photo = 0;
OU_different_G = [2.45,10.5];
OU_or_Not = 1;%Plot OU or not
all_or_Not = 0;%Plot all channels or not
HMM_former_name = [date,'_HMM_',direction,'_G'];
HMM_post_name = ['_',num2str(mins),'min_Br50_Q100_',order];
HMM_filename =  [date,'_HMM_',direction,'_',num2str(length(HMM_different_G )),'G_',num2str(mins),'min_Br50_Q100_',order,'_ch']; %Filename used to save(Plot HMM only)   
OU_filename =  [date,'_HMMandOU_',direction,'_',num2str(length(HMM_different_G )),'G_',num2str(mins),'min_Br50_Q100_',order,'_ch'];%Filename used to save(Plot HMM and OU)   
OU_former_name = ['0319_OU_',direction,'_G'];
OU_post_name = '_5min_Br50_Q100';

allchannellegend = cell(1,length(HMM_different_G));%Save which G
corr_t_legend = cell(1,length(HMM_different_G));%Save HMM correlation time
all_corr_t_legend = cell(1,length(HMM_different_G)+length(OU_different_G));%Save HMM and OU correlation time
%% Load predictive or nonpredictive channel and set roi
%If you don't have saved this data, just comment these sentences
%And set roi for yourself
predicitive_or_Not = 0;
load(['predictive_channel\',HMM_filename(1:end-3),'.mat'])
if predicitive_or_Not
    roi = p_channel;
else
    roi = np_channel;
end

%Set roi
% roi = [5,6,13,52,59];%Channel you want to display

%% Load STA data
if sorted
    cd STA
    mkdir FIG
else
    cd STA
    mkdir FIG
end

%Load HMM STA data and correlation time
HMM_STA =[];
for  G =1:length(HMM_different_G) 
    load([HMM_former_name,num2str(HMM_different_G(G)),HMM_post_name ,'.mat'])
    HMM_STA = [HMM_STA;dis_STA];
    allchannellegend{G} = ['G', num2str(HMM_different_G(G))];
    all_corr_t_legend{G} = [num2str(corr_time),' sec'];
    corr_t_legend{G} = [num2str(corr_time),' sec'];
end
%Load OU STA data and correlation time
if OU_or_Not
    OU_STA =[];
    for   G =1:length(OU_different_G) 
        load([OU_former_name,num2str(OU_different_G(G)),OU_post_name ,'.mat'])
        OU_STA = [OU_STA;dis_STA];
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
            plot(time,HMM_STA ((G-1)*60+channelnumber,:)); hold on;
        end
        %Plot OU 
        if OU_or_Not
         for   G =1:length(OU_different_G)
            plot(time,OU_STA ((G-1)*60+channelnumber,:),'-.'); hold on;
         end
        end
        if sum(RFcenter(channelnumber,:)) > 0%If has RF center, it will plot different color
            set(gca,'Color',[0.9 0.9 0.9])
        end
        title(channelnumber)
        hold off;
    end
    %Save fig
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig =gcf;
    fig.PaperPositionMode = 'auto';
    fig.InvertHardcopy = 'off';
    if save_photo
    if OU_or_Not
        saveas(fig,[exp_folder,'\STA\FIG\',OU_filename(1:end-3),'.tif'])
    else
        saveas(fig,[exp_folder,'\STA\FIG\',HMM_filename(1:end-3),'.tif'])
    end
    end
end

%% Plot single channel
for channelnumber= roi 
     figure(channelnumber)
     for G =1:length(HMM_different_G)
        %Plot HMM with different line
        if G >=4
            plot(time,HMM_STA ((G-1)*60+channelnumber,:)); hold on;
        elseif G >2
            plot(time,HMM_STA ((G-1)*60+channelnumber,:),'k:'); hold on;
        else
            plot(time,HMM_STA ((G-1)*60+channelnumber,:),'.'); hold on;
        end
     end
     if OU_or_Not
         for   G =1:length(OU_different_G)
            plot(time,OU_STA ((G-1)*60+channelnumber,:),'-.'); hold on;
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
     %Label predicitive or not
     if exist('predicitive_or_Not') 
          if predicitive_or_Not%predictive channel
              title(['p',int2str(channelnumber)])
          else%non-predictive channel
              title(['np',int2str(channelnumber)])
          end
     else%If does not have predictive channel
          title(channelnumber)
     end
     xlabel('time relative to spike (second)')
     if sum(RFcenter(channelnumber,:)) > 0%If has RF center, it will plot different color
        set(gca,'Color',[0.9 0.9 0.9])
        ylabel('Distance relative to RF center')
     else%Does not have RF center
        ylabel('Distance relative to electrode')
     end
     hold off;
     %Save photo
     set(gcf,'units','normalized','outerposition',[0 0 1 1])
     fig =gcf;
     fig.PaperPositionMode = 'auto';
     fig.InvertHardcopy = 'off';
     if save_photo
         if sorted
            if OU_or_Not
                saveas(fig,[exp_folder,'\STA\FIG\',OU_filename,int2str(channelnumber),'.tif'])
            else
                saveas(fig,[exp_folder,'\STA\FIG\',HMM_filename,int2str(channelnumber),'.tif'])
            end
         else
            if OU_or_Not
                saveas(fig,[exp_folder,'\STA\FIG\',OU_filename,int2str(channelnumber),'.tif'])
            else
                saveas(fig,[exp_folder,'\STA\FIG\',HMM_filename,int2str(channelnumber),'.tif'])
            end
         end
     end
end

