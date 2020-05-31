close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20200526';
cd(exp_folder)
load('different_G.mat')
type = 'pos';
order = '0';%First or second experiment
sorted=1;
save_photo = 0;
reverse = 1;
HMM_or_Not = 1;
sOU_or_Not = 0;
frequency = 0.5;
OU_or_Not = 1;%Plot OU or not
all_or_Not = 1;%Plot all channels or not
% load('predictive_channel\bright_bar.mat')
% roi = [p_channel,np_channel];
roi = [5,6,11,12,19,20,28,29,30,37,38,46,52,53,54,56,59,60];%[2,3,5,6,7,8,9,10,11,12,17,18,19,20,22,24,25,26,28,29,30,32,33,36,37,38,46,52,53,54,56];
if sorted
    sort_directory = 'sort';
else
    sort_directory = 'unsort';
end
MI_directory = [exp_folder,'\MI\',sort_directory];
%% Load data
%Load HMM MI data and correlation time
if HMM_or_Not
    [HMM_former_name,HMM_post_name,HMM_filename] = Get_Edge_name(exp_folder,'HMM',type,order,0,reverse);
    [MI,MI_shuffle,peaks,corr_t_legend,time] = Read_different_G(MI_directory,'HMM',HMM_different_G,HMM_former_name,HMM_post_name);
    filename = HMM_filename;
end
if sOU_or_Not
    [sOU_former_name,sOU_post_name,sOU_filename] = Get_Edge_name(exp_folder,'OUsmooth',type,order,frequency,reverse);
    [MI,MI_shuffle,peaks,corr_t_legend,time] = Read_different_G(MI_directory,'OUsmooth',OUsmooth_different_G,sOU_former_name,sOU_post_name);
    filename = sOU_filename;
end
%Load OU MI data and correlation time
if OU_or_Not
    [OU_former_name,OU_post_name,OU_filename] = Get_Edge_name(exp_folder,'OU',type,order,0,reverse);
    [OU_MI,OU_MI_shuffle,OU_peaks,OU_corr_t_legend,time] = Read_different_G(MI_directory,'OU',OU_different_G,OU_former_name,OU_post_name);
end
all_corr_t_legend = [corr_t_legend,OU_corr_t_legend];

%% Plot all channels
if all_or_Not
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    for channelnumber=1:60 %choose file
        axes(ha(rr(channelnumber)));
        %Plot HMM
        for G =1:length(HMM_different_G)
            mean_MI_shuffle = mean(cell2mat(MI_shuffle(G,channelnumber)));
            mutual_information = cell2mat(MI(G,channelnumber));
            if channelnumber~=31
            if max(mutual_information-mean_MI_shuffle)<0.1
                continue;
            end
            else
                lgd =legend(corr_t_legend,'Location','northwest');
                lgd.FontSize = 11;
                legend('boxoff')
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
        saveas(fig,[exp_folder,'\FIG\',sort_directory,'\',filename(1:end-5),'.tif'])
    end
end

%% Plot single channel
close all;
mean_peaks = zeros(length(HMM_different_G),length(roi));
for channelnumber= roi 
     figure(channelnumber)
     for   G =1:length(HMM_different_G)
        mean_peaks(G,find(roi==channelnumber)) = peaks(G,channelnumber);
        mean_MI_shuffle = mean(cell2mat(MI_shuffle(G,channelnumber)));
        mutual_information = cell2mat(MI (G,channelnumber));hold on;
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
         for   G =[1,5]%1:length(OU_different_G)
            mean_MI_shuffle = mean(cell2mat(OU_MI_shuffle(G,channelnumber)));
            mutual_information = cell2mat(OU_MI (G,channelnumber));hold on;
            plot(time,smooth(mutual_information-mean_MI_shuffle),'-.'); 
            xlim([ -1300 1300])
            ylim([0 inf+0.1])
         end
     end
     grid on
     
     if OU_or_Not
       all_t_legend = {all_corr_t_legend{1:6},all_corr_t_legend{10}};
       lgd =legend(all_t_legend,'Location','northwest');
     else
       lgd =legend(HMM_corr_t_legend,'Location','northwest');
     end
     lgd.FontSize = 11;
     legend('boxoff')
     hold off;
     if save_photo
         saveas(gcf,[exp_folder,'\FIG\',sort_directory,'\',filename,int2str(channelnumber),'.tif'])
     end
end