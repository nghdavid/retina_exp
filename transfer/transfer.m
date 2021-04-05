%cd('0704');
clear all
code_folder = pwd;
exp_folder = 'D:\Leo\0503';
cd(exp_folder)
cd data
all_file = dir('*.mcd') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 
for m = [46]% n_file]
    clearvars -except all_file n_file m code_folder exp_folder
    file = all_file(m).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    cd(code_folder)
    %filename = [exp_folder,'\data\',filename];
    %[Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data([pwd,'\',filename],1,'','david','all',210000);%If your ram is not enough, run this line
    
    stimulus_type = 'WF';
    [num, status] = str2num(filename(1))
    if status
        stimulus_type = 'MB';
    end
    %[Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data([exp_folder,'\data\',filename],1,'','david','all', stimulus_type);%%If your ram is enough, run this line
    [Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data_OLED([exp_folder,'\data\',filename],1,'','david','all', 10^5); %about 2.5G
    %%analyze_MEA_data(filename,save_data,comment,experimenter,analog_type,r_interval)
    %save_data = 1 means save data
    %analog_type sets to 'all'
    %r_interval is the interval that calculates std,if none,it calculate total interval
end
c = 0;
for i = 1:60
    c = c+ size(Spikes{i});
end
c