%%Transfer

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

%%merge
clear all;
close all;
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 
mkdir merge
for m = 1:n_file
    file = all_file(m).name;
    [pathstr, name, ext] = fileparts(file);
    if length(name) < 6
        disp([name,' has an error or it is spontaneous'])
        continue;
    end
    if strcmp(name(6),'H')
        type = 'HMM';
        if strcmp(name(12),'D')
          Dir= name(10:13);
        else
          Dir= name(10:11);
        end
        Gamma = name(length(name)-1:end);
    elseif strcmp(name(6),'O')
        type = 'OU';
        if strcmp(name(11),'D')
          Dir= name(9:12);
        else
          Dir= name(9:10);
        end
        Gamma = name(length(name)-1:end);
    else
        disp([name,' has an error or it is onoff'])
        continue;
    end
    pass = reconstruct(pwd,type,Dir,Gamma,name);


end


%%transfer_spike
clear all;
close all;
current_path =pwd;
mkdir sort_merge_spike
cd merge
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 
channel = [12,13,14,15,16,17,21,22,23,24,25,26,27,28,31,32,33,34,35,36,37,38,41,42,43,44,45,46,47,48,51,52,53,54,55,56,57,58,61,62,63,64,65,66,67,68,71,72,73,74,75,76,77,78,82,83,84,85,86,87];
for m = 1:n_file
    Spikes = cell(1,60);
    load(all_file(m).name);
    file = all_file(m).name(7:end);
    load([current_path,'\sort\',file]);
    for h=1:60
        adch_channel = eval(['adch_',int2str(channel(h))]);
        Spikes{h} = adch_channel (:,2);
    end
    
    sorted_spikes=cell(1,60);
    for j = 1:length(Spikes)    %running through each channel
        ss = Spikes{j};
        ss(ss<TimeStamps(1,1)) = [];  %delete the spikes before TimeStamps(1)
        ss(ss>TimeStamps(1,2))=[];
    
        for i = 1:length(ss)
            ss(i) = ss(i)-TimeStamps(1,1);
        end
        sorted_spikes{j} = ss;
    end
    
    save([current_path,'\sort_merge_spike','\sort_merge_',file],'sorted_spikes','bin_pos','TimeStamps','reconstruct_spikes','diode_BT','BinningInterval');
end
cd ..