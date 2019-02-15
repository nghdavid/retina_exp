cd G:\Leo\0214%Go to the directory that you want to save

mkdir picture
all_file = dir('*.mcd') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 

for m = 1:n_file
    clearvars -except all_file n_file m
    file = all_file(m).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    if exist([pwd,'\',name,'.mat'])
        continue
    end
    
    %[Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data([pwd,'\',filename],1,'','david','all',210000);%If your ram is not enough, run this line
    [a_data,Infos] = analyze_MEA_analog_data([pwd,'\',filename],1,'','david','all');%The function that only transfer adata part of mcd file
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if length(a_data)/20000 > 400%Remember to check HMM video length
        type = 'HMM';
    elseif length(a_data)/20000 > 280%Remember to check OU video length
         type = 'OU';
     else
        disp([name,' has an error or it is too short'])
        continue;
    end
    pass = mea_reconstruct(pwd,type,name,a_data);%Test whether adata can be reconstructed
end