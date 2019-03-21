clear all;
close all;

fileID = fopen('list.txt','r');
formatSpec = '%c';
txt = textscan(fileID,'%s','delimiter','\n'); 
num_files = length(txt{1});

merge_ID = fopen('merge_list.txt','r');
formatSpec = '%c';
merge_txt = textscan(merge_ID,'%s','delimiter','\n'); 
mkdir merge


for m = 1:num_files
    name = txt{1}{m};
    if length(name) < 6
        disp([name,' has an error or it is spontaneous'])
        continue;
    end
    if strcmp(name(6),'H')
        type = 'HMM';
        
    elseif strcmp(name(6),'O')
        type = 'OU';
        
    
    else
        disp([name,' has an error or it is onoff'])
        continue;
    end
    
    workspace_name = merge_txt{1}{m};
    pass = reconstruct(pwd,type,name,workspace_name);
    if pass
        disp([name,'  passes'])
    else
        disp([name,'not passes'])
    end

end



