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
    
    dv_spikes=cell(1,60);
    for j = 1:length(Spikes)    %running through each channel
        ss = Spikes{j};
        ss(ss<TimeStamps(1,1)) = [];  %delete the spikes before TimeStamps(1)
        ss(ss>TimeStamps(1,2))=[];
    
        for i = 1:length(ss)
            ss(i) = ss(i)-TimeStamps(1,1);
        end
        dv_spikes{j} = ss;
    end
    
    save([current_path,'\sort_merge_spike','\sort_merge_',file],'bin_pos','dv_spikes');
end








cd ..