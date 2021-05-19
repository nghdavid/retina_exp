function [MI,peaks,corr_t_legend,time] = Read_different_frequency(exp_folder,stimulus,different_frequency,former_name,post_name)
    cd(exp_folder)
    MI =[];
    MI_shuffle = [];
    peaks = [];
    corr_t_legend = cell(1,length(different_frequency));%Save HMM correlation time
    for f =1:length(different_frequency)
    load([former_name,post_name,num2str(different_frequency(f)),'Hz.mat'])
    peaks = [peaks;peak_times];
    MI = [MI;Mutual_infos];
    corr_t_legend{f} = [num2str(different_frequency(f)),'Hz'];
end