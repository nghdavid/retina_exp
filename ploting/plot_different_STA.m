close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20200418';
cd(exp_folder)
mkdir STA\FIG
load('oled_boundary_set.mat')
load('different_G.mat')
load('rr.mat')
load('RGC.mat')%Needed to run Receptive field.m first
order = '1';%First or second experiment
type = 'pos';
sorted=1;
save_photo = 1;
OU_or_Not = 1;%Plot OU or not
all_or_Not = 0;%Plot all channels or not
HMM_former_name = [HMM_date1,'_HMM_',direction,'_G'];
if order == '0'
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
else
%     HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW_',order];
    HMM_post_name = ['_',num2str(mins),'min_Q100_6.5mw_',order];
end
HMM_filename =  [HMM_date1,'_HMM_',direction,'_',num2str(length(HMM_different_G )),'G_',num2str(mins),'min_Br50_Q100_',order,'_ch']; %Filename used to save(Plot HMM only)   
OU_filename =  ['HMMandOU_',direction,'_',num2str(length(HMM_different_G )),'G_',num2str(mins),'min_Br50_Q100_',order,'_ch'];%Filename used to save(Plot HMM and OU)   
OU_former_name = [OU_date,'_OU_',direction,'_G'];
% OU_post_name = ['_5min_Q100_',num2str(mean_lumin),'mW'];
OU_post_name = ['_5min_Q100_6.5mw'];
allchannellegend = cell(1,length(HMM_different_G));%Save which G
corr_t_legend = cell(1,length(HMM_different_G));%Save HMM correlation time
all_corr_t_legend = cell(1,length(HMM_different_G)+length(OU_different_G));%Save HMM and OU correlation time
%% Load predictive or nonpredictive channel and set roi
%If you don't have saved this data, just comment these sentences
%And set roi for yourself
load(['predictive_channel\bright_bar.mat'])

roi = [p_channel,np_channel];

% roi = [5,6,13,52,59];%Channel you want to display

%% Load STA data
if strcmp(direction,'UL_DR') || strcmp(direction,'UR_DL')
     micro_per_pixel_long = micro_per_pixel*sqrt(2);
else
     micro_per_pixel_long = micro_per_pixel;
end

cd STA
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
        if sum(RGCs{channelnumber}.center_RF) > 0%If has RF center, it will plot different color
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
     if sum(RGCs{channelnumber}.center_RF) >0
        channelnumber
        newXpos = Monitor2DCoor2BarCoor(RGCs{channelnumber}.center_RF(1),RGCs{channelnumber}.center_RF(2),direction,'OLED')
     end
     for G =1:length(HMM_different_G)
         
        %Plot HMM with different line
        if G >=4
            if sum(RGCs{channelnumber}.center_RF) >0
                plot(STA_time,(HMM_STA ((G-1)*60+channelnumber,:)-newXpos)*micro_per_pixel_long,'.'); hold on;
            else
                plot(STA_time,(HMM_STA ((G-1)*60+channelnumber,:)-meaCenter_x)*micro_per_pixel_long,'.'); hold on;
            end
%             plot(STA_time(2:end),diff(HMM_STA ((G-1)*60+channelnumber,:))); hold on;
        elseif G >2
            if sum(RGCs{channelnumber}.center_RF) >0
                plot(STA_time,(HMM_STA ((G-1)*60+channelnumber,:)-newXpos)*micro_per_pixel_long,'k:'); hold on;
            else
                plot(STA_time,(HMM_STA ((G-1)*60+channelnumber,:)-meaCenter_x)*micro_per_pixel_long,'k:'); hold on;
            end
%             plot(STA_time(2:end),diff(HMM_STA ((G-1)*60+channelnumber,:)),'k:'); hold on;
        else
            if sum(RGCs{channelnumber}.center_RF) >0
                plot(STA_time,(HMM_STA ((G-1)*60+channelnumber,:)-newXpos)*micro_per_pixel_long); hold on;
            else
                plot(STA_time,(HMM_STA ((G-1)*60+channelnumber,:)-meaCenter_x)*micro_per_pixel_long); hold on;
            end
%             plot(time(2:end),diff(HMM_STA ((G-1)*60+channelnumber,:)),'.');hold on;
        end
     end
     if OU_or_Not
         for   G =[1,5]%1:length(OU_different_G)
            if sum(RGCs{channelnumber}.center_RF) >0
                plot(STA_time,(OU_STA ((G-1)*60+channelnumber,:)-newXpos)*micro_per_pixel_long,'-.'); hold on;
            else
                plot(STA_time,(OU_STA ((G-1)*60+channelnumber,:)-meaCenter_x)*micro_per_pixel_long,'-.'); hold on;
            end
%             plot(time(2:end),diff(OU_STA ((G-1)*60+channelnumber,:)),'-.'); hold on;
         end
     end
     grid on
     
     if OU_or_Not
       all_t_legend = {all_corr_t_legend{1:6},all_corr_t_legend{10}};
       lgd =legend(all_t_legend,'Location','northwest');
     else
       lgd =legend(corr_t_legend,'Location','northwest');
     end
     lgd.FontSize = 11;
     legend('boxoff')
     %Label predicitive or not
     if ismember(channelnumber,p_channel)
         title(['p',int2str(channelnumber)])
     elseif ismember(channelnumber,np_channel)
         title(['np',int2str(channelnumber)])
     end
     xlabel('time relative to spike (second)')
     if sum(RGCs{channelnumber}.center_RF) > 0%If has RF center, it will plot different color
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
        if OU_or_Not
            saveas(fig,[exp_folder,'\STA\FIG\',OU_filename,int2str(channelnumber),'.tif'])
        else
            saveas(fig,[exp_folder,'\STA\FIG\',HMM_filename,int2str(channelnumber),'.tif'])
        end
     end
end

