cd('0704');
all_file = dir('*.mcd') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 

for m = 9:12
    clearvars -except all_file n_file m
    file = all_file(m).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    [Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data([pwd,'\',filename],1,'','david','all',210000);
end