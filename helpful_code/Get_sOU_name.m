function [former_name,post_name,filename] = Get_sOU_name(exp_folder,stimulus,type,order,frequency)
cd(exp_folder)
load('different_G.mat')
if strcmp(stimulus,'OUsmooth')
     former_name = [type,'_',OUsmooth_date,'_',stimulus,'_Bright_',direction,'_G',num2str(OUsmooth_G)];
     post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW_'];
     filename =  [type,'_',OUsmooth_date,'_',stimulus,'_',direction,'_',num2str(length(OUsmooth_different_frequency)),'f_',num2str(mins),'min_Q100_',num2str(frequency),'Hz_',order,'_ch']; %Filename used to save(Plot OU only)   
end
end