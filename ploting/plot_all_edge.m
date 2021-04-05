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
save_photo = 1;
reverse = 1;
HMM_or_Not = 1;
sOU_or_Not = 0;
frequency = 0.5;
OU_or_Not = 1;%Plot OU or not
all_or_Not = 1;%Plot all channels or not
 load('predictive_channel\edge.mat')
roi = [p_channel,np_channel];
load('predictive_channel\reverse_edge.mat')
roi = [roi ,p_channel,np_channel];
roi = unique(roi);
% roi = [5,6,11,12,19,20,28,29,30,37,38,46,52,53,54,56,59,60];%[2,3,5,6,7,8,9,10,11,12,17,18,19,20,22,24,25,26,28,29,30,32,33,36,37,38,46,52,53,54,56];
if sorted
    sort_directory = 'sort';
else
    sort_directory = 'unsort';
end
MI_directory = [exp_folder,'\MI\',sort_directory];
%% Load data
%Load HMM MI data and correlation time
if HMM_or_Not
    [HMM_former_name,HMM_post_name,HMM_filename] = Get_Edge_name(exp_folder,'HMM',type,order,0,0);
    [reverse_HMM_former_name,reverse_HMM_post_name,reverse_HMM_filename] = Get_Edge_name(exp_folder,'HMM',type,order,0,1);
    [MI,MI_shuffle,peaks,corr_t_legend,time] = Read_different_G(MI_directory,'HMM',HMM_different_G,HMM_former_name,HMM_post_name);
    [reverse_MI,reverse_MI_shuffle,reverse_peaks,reverse_corr_t_legend,time] = Read_different_G(MI_directory,'HMM',HMM_different_G,reverse_HMM_former_name,reverse_HMM_post_name);
    filename = HMM_filename;
end
if sOU_or_Not
    [sOU_former_name,sOU_post_name,sOU_filename] = Get_Edge_name(exp_folder,'OUsmooth',type,order,frequency,0);
    [MI,MI_shuffle,peaks,corr_t_legend,time] = Read_different_G(MI_directory,'OUsmooth',OUsmooth_different_G,sOU_former_name,sOU_post_name);
    [reverse_sOU_former_name,reverse_sOU_post_name,reverse_sOU_filename] = Get_Edge_name(exp_folder,'OUsmooth',type,order,frequency,1);
    [reverse_MI,reverse_MI_shuffle,reverse_peaks,reverse_corr_t_legend,time] = Read_different_G(MI_directory,'OUsmooth',OUsmooth_different_G,reverse_sOU_former_name,reverse_sOU_post_name);
    filename = sOU_filename;
end
%Load OU MI data and correlation time
if OU_or_Not
    [OU_former_name,OU_post_name,OU_filename] = Get_Edge_name(exp_folder,'OU',type,order,0,0);
    [OU_MI,OU_MI_shuffle,OU_peaks,OU_corr_t_legend,time] = Read_different_G(MI_directory,'OU',OU_different_G,OU_former_name,OU_post_name);
    [reverse_OU_former_name,reverse_OU_post_name,reverse_OU_filename] = Get_Edge_name(exp_folder,'OU',type,order,0,1);
    [reverse_OU_MI,reverse_OU_MI_shuffle,reverse_OU_peaks,reverse_OU_corr_t_legend,time] = Read_different_G(MI_directory,'OU',OU_different_G,reverse_OU_former_name,reverse_OU_post_name);
end
all_corr_t_legend = [corr_t_legend,OU_corr_t_legend];

%% Plot single channel
close all;
mean_peaks = zeros(length(HMM_different_G),length(roi));
for channelnumber= roi 
     figure('units','normalized','outerposition',[0 0 1 1])
     subplot(1,2,1)
%      ha = tight_subplot(1,2,[.04 .04],[0.09 0.02],[.04 .04]);
%      set(ha, 'Visible', 'off');
%      set(gcf,'units','normalized','outerposition',[0 0 1 1])
%      fig =gcf;
%      fig.PaperPositionMode = 'auto';
%      fig.InvertHardcopy = 'off';
%      axes(ha(1));
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
     title(num2str(channelnumber))
     xlabel('time shift')
     ylabel('MI')
     if OU_or_Not
       all_t_legend = {all_corr_t_legend{1:6},all_corr_t_legend{10}};
       lgd =legend(all_t_legend,'Location','northwest');
     else
       lgd =legend(HMM_corr_t_legend,'Location','northwest');
     end
     lgd.FontSize = 11;
     legend('boxoff')
     hold off;
     subplot(1,2,2)
%      axes(ha(2));
     for   G =1:length(HMM_different_G)
        reverse_mean_peaks(G,find(roi==channelnumber)) = reverse_peaks(G,channelnumber);
        reverse_mean_MI_shuffle = mean(cell2mat(reverse_MI_shuffle(G,channelnumber)));
        reverse_mutual_information = cell2mat(reverse_MI (G,channelnumber));hold on;
        %Plot HMM with different line
        if G >=4
            plot(time,smooth(reverse_mutual_information-reverse_mean_MI_shuffle)); 
        elseif G >2
            plot(time,smooth(reverse_mutual_information-reverse_mean_MI_shuffle),'k:'); 
        else
            plot(time,smooth(reverse_mutual_information-reverse_mean_MI_shuffle),'.'); 
        end
        xlim([ -2300 1300])
        ylim([0 inf+0.1])
     end
     %Plot OU
     if OU_or_Not
         for   G =[1,5]%1:length(OU_different_G)
            reverse_mean_MI_shuffle = mean(cell2mat(reverse_OU_MI_shuffle(G,channelnumber)));
            reverse_mutual_information = cell2mat(reverse_OU_MI (G,channelnumber));hold on;
            plot(time,smooth(reverse_mutual_information-reverse_mean_MI_shuffle),'-.'); 
            xlim([ -1300 1300])
            ylim([0 inf+0.1])
         end
     end
     grid on
     title(num2str(channelnumber))
     xlabel('time shift')
     ylabel('MI')
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
         saveas(gcf,[exp_folder,'\FIG\',sort_directory,'\all_',filename,int2str(channelnumber),'.tif'])
     end
end