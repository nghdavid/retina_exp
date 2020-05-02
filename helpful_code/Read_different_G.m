function [MI,MI_shuffle,peaks,corr_t_legend,time] = Read_different_G(exp_folder,stimulus,different_G,former_name,post_name)
    cd(exp_folder)
    MI =[];
    MI_shuffle = [];
    peaks = [];
    corr_t_legend = cell(1,length(different_G));%Save HMM correlation time
    for G =1:length(different_G)
    load([former_name,num2str(different_G(G)),post_name ,'.mat'])
    peaks = [peaks;peak_times];
    MI = [MI;Mutual_infos];
    MI_shuffle = [MI_shuffle ;Mutual_shuffle_infos];
    if strcmp(stimulus,'OUsmooth')
         corr_t_legend{G} = ['sOU-',num2str(corr_time),' sec'];
    else
        corr_t_legend{G} = [stimulus,'-',num2str(corr_time),' sec'];
    end
end