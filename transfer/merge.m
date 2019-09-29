clear all;
close all;

code_folder = pwd;
exp_folder = 'D:\20190916';
cd(exp_folder)
cd playmovie
fileID = fopen('playmovie/all_list.txt','r');


txt = textscan(fileID,'%s','delimiter','\n'); 
num_files = length(txt{1})-1;

merge_ID = fopen('playmovie/merge_list.txt','r');
merge_txt = textscan(merge_ID,'%s','delimiter','\n'); 
cd ..
mkdir merge


for m = 1:num_files
    name = txt{1}{m+1};
    workspace_name = merge_txt{1}{m};
    if length(name) < 6
        disp([name,' has an error or it is spontaneous'])
        continue;
    end
    if length(name)>13
        if strcmp(name(9:13),'ONOFF')
            continue;
        elseif strcmp(name(6:12),'Grating')
            continue;
        end
    end
    if length(name)>17
        if strcmp(name(14:18),'OnOff')
            continue;
        end
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
    elseif  strcmp(name(1:2),'cs')
        continue
    else
        type = 'else';
   
        
    end
    
    
    cd(code_folder)
    pass = reconstruct(exp_folder,type,name,workspace_name);
    if pass
        disp([name,'  passes'])
    else
        disp([name,'not passes'])
    end

end



