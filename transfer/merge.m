clear all;
close all;

lelay_correction = 0.0071;

code_folder = pwd;
exp_folder = 'D:\Leo\0225';
videoworkspace = '\\192.168.0.100\Experiment\Retina\2020Videos\0219v\videoworkspace\';
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
    data_name = name;
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
    elseif strcmp(name(6),'C') || strcmp(name(1),'t')
        type = 'Checker';
    else
        type = 'else';
    end
    
    pass = 0;
    cd(code_folder)
    pass = reconstruct(exp_folder,type,name,workspace_name,videoworkspace, lelay_correction);
    if pass
        disp([name,'  passes'])
    else
        disp([name,'  not passes'])
    end
end



