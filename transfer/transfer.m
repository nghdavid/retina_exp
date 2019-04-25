%cd('0704');
all_file = dir('*.mcd') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 

for m = 1:n_file
    clearvars -except all_file n_file m
    file = all_file(m).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    %[Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data([pwd,'\',filename],1,'','david','all',210000);%If your ram is not enough, run this line
    [Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data([pwd,'\',filename],1,'','david','all');%%If your ram is enough, run this line
    
    %%analyze_MEA_data(filename,save_data,comment,experimenter,analog_type,r_interval)
    %save_data = 1 means save data
    %analog_type sets to 'all'
    %r_interval is the interval that calculates std,if none,it calculate total interval
end