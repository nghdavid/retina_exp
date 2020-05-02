close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20200418';
cd(exp_folder)
load('different_G.mat')
type = 'pos';
order = '1';%First or second experiment
sorted=1;
save_photo = 1;
OU_or_Not = 1;%Plot OU or not
all_or_Not = 1;%Plot all channels or not
roi = [9,17,24,25,33,40,41,43,49,50,51,52,57,58,59];
[HMM_former_name,HMM_post_name,HMM_filename] = Get_HMM_OU_name(exp_folder,'HMM',type,order,0);
[OU_former_name,OU_post_name,OU_filename] = Get_HMM_OU_name(exp_folder,'OU',type,order,0);
[OUsmooth1_former_name,OUsmooth1_post_name,OUsmooth1_filename] = Get_HMM_OU_name(exp_folder,'OUsmooth',type,order,0.5);
[OUsmooth2_former_name,OUsmooth2_post_name,OUsmooth2_filename] = Get_HMM_OU_name(exp_folder,'OUsmooth',type,order,1);
if sorted
    sort_directory = 'sort';
else
    sort_directory = 'unsort';
end
MI_directory = [exp_folder,'\MI\',sort_directory];
%% Load data
%Load HMM MI data and correlation time
[HMM_MI,HMM_MI_shuffle,HMM_peaks,HMM_corr_t_legend,~] = Read_different_G(MI_directory,'HMM',HMM_different_G,HMM_former_name,HMM_post_name);
[sOU1_MI,sOU1_MI_shuffle,sOU1_peaks,sOU1_corr_t_legend,~] = Read_different_G(MI_directory,'OUsmooth',OUsmooth_different_G,OUsmooth1_former_name,OUsmooth1_post_name);
[sOU2_MI,sOU2_MI_shuffle,sOU2_peaks,sOU2_corr_t_legend,~] = Read_different_G(MI_directory,'OUsmooth',OUsmooth_different_G,OUsmooth2_former_name,OUsmooth2_post_name);
[OU_MI,OU_MI_shuffle,OU_peaks,OU_corr_t_legend,time] = Read_different_G(MI_directory,'OU',OUsmooth_different_G,OU_former_name,OU_post_name);
for channelnumber = roi 
     for G =1:length(HMM_different_G)
        figure('units','normalized','outerposition',[0 0 1 1])
        HMM_mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(G,channelnumber)));
        HMM_mutual_information = cell2mat(HMM_MI (G,channelnumber));
        sOU1_mean_MI_shuffle = mean(cell2mat(sOU1_MI_shuffle(G,channelnumber)));
        sOU1_mutual_information = cell2mat(sOU1_MI (G,channelnumber));
        sOU2_mean_MI_shuffle = mean(cell2mat(sOU2_MI_shuffle(G,channelnumber)));
        sOU2_mutual_information = cell2mat(sOU2_MI (G,channelnumber));
        OU_mean_MI_shuffle = mean(cell2mat(OU_MI_shuffle(G,channelnumber)));
        OU_mutual_information = cell2mat(OU_MI (G,channelnumber));
        plot(time,smooth(HMM_mutual_information-HMM_mean_MI_shuffle),'r');hold on;
        plot(time,smooth(sOU1_mutual_information-sOU1_mean_MI_shuffle),'b');
        plot(time,smooth(sOU2_mutual_information-sOU2_mean_MI_shuffle),'k');
        plot(time,smooth(OU_mutual_information-OU_mean_MI_shuffle),':');
        xlim([ -2300 1300])
        ylim([0 inf+0.1])
        title(['ch',num2str(channelnumber),' G',num2str(HMM_different_G(G))])
        legend(HMM_corr_t_legend{G},sOU1_corr_t_legend{G},sOU2_corr_t_legend{G},OU_corr_t_legend{G})
        if save_photo
            filename = ['sOU_comparison_G',num2str(HMM_different_G(G)),'_ch',num2str(channelnumber)];
            saveas(gcf,[exp_folder,'\FIG\',sort_directory,'\',filename,'.tif'])
        end
     end

end
