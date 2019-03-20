%% This code specially transfer only A unit spikes from offlinesorter
%sorted_spikes stores all spikes in A unit. It is a 1*60(channel) cell
clear all;
close all;
current_path =pwd;
mkdir sort_merge_spike
cd merge

all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 

for m = 1:n_file
    Spikes = cell(1,60);
    if strcmp(all_file(m).name,'onoff') or strcmp(all_file(m).name,'spon')
        continue;
    end
    load(all_file(m).name);
    file = all_file(m).name(7:end);
    load([current_path,'\sort\',file]);
    
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






cd ..