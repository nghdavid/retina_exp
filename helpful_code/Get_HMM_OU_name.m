function [former_name,post_name,filename] = Get_HMM_OU_name(exp_folder,stimulus,type,order,frequency)
cd(exp_folder)
load('different_G.mat')
if strcmp(stimulus,'HMM')
    former_name = [type,'_',HMM_date1,'_',stimulus,'_',direction,'_G'];
    if order == '0'
        post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
    else
        post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW_',order];
    end
    filename =  [type,'_',HMM_date1,'_',stimulus,'_',direction,'_',num2str(length(HMM_different_G )),'G_',num2str(mins),'min_Q100_',order,'_ch']; %Filename used to save(Plot HMM only)   
elseif strcmp(stimulus,'OUsmooth')
     former_name = [type,'_',OU_date,'_',stimulus,'_',direction,'_G'];
     post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW_',num2str(frequency),'Hz'];
     filename =  [type,'_',OU_date,'_',stimulus,'_',direction,'_',num2str(length(OUsmooth_different_G )),'G_',num2str(mins),'min_Q100_',num2str(frequency),'Hz_',order,'_ch']; %Filename used to save(Plot OU only)   
elseif strcmp(stimulus,'OU')
    former_name = [type,'_',OU_date,'_',stimulus,'_',direction,'_G'];
    post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
    filename =  [type,'_',OU_date,'_',stimulus,'_',direction,'_',num2str(length(OU_different_G )),'G_',num2str(mins),'min_Q100_',order,'_ch']; %Filename used to save(Plot smooth only)
end
end