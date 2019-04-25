clear all;
close all;

code_folder = pwd;
exp_folder = 'D:\Leo\0417exp';
cd(exp_folder)
cd playmovie
fileID = fopen('playmovie/list.txt','r');

formatSpec = '%c';
txt = textscan(fileID,'%s','delimiter','\n'); 
num_files = length(txt{1});

merge_ID = fopen('playmovie/merge_list.txt','r');
formatSpec = '%c';
merge_txt = textscan(merge_ID,'%s','delimiter','\n'); 
cd ..
mkdir merge


for m = 1:num_files
    name = txt{1}{m};
    workspace_name = merge_txt{1}{m};
    if length(name) < 6
        disp([name,' has an error or it is spontaneous'])
        continue;
    end
    if strcmp(name(6),'H')
        type = 'HMM';
        
    elseif strcmp(name(6),'O')
        type = 'OU';

    elseif strcmp(name(6),'s')
        type = 'short_HMM';
    elseif strcmp(name(6),'R')
        type = 'Reveral';
    elseif strcmp(name(6),'C')
        type = 'Checker';
    else
        type = 'else';
   
        
    end
    
    pass = 0;
    cd(code_folder)
    pass = reconstruct(exp_folder,type,name,workspace_name);
    if pass
        disp([name,'  passes'])
    else
        disp([name,'not passes'])
    end

end


load('D:\Leo\0327exp\data\0304_Reversal_moving_RL_Br50_Q100.mat');
