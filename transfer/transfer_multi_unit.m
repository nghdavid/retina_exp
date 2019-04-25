%% This code specially transfer all unit spikes from offlinesorter
%sorted_spikes stores all spikes in all unit. It is a 1*60(channel) cell
%sorted_unit_spikes stores each spike in each unit. It is a num_units*60(channel) cell

clear all;
close all;
current_path =pwd;

%%%%%%%%%%%%%%%%%%%%%
mkdir multi_unit_merge_spike
cd multi_unit_merge
%%%%%%%%%%%%%%%%%%%%%

all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 
channel = [12,13,14,15,16,17,21,22,23,24,25,26,27,28,31,32,33,34,35,36,37,38,41,42,43,44,45,46,47,48,51,52,53,54,55,56,57,58,61,62,63,64,65,66,67,68,71,72,73,74,75,76,77,78,82,83,84,85,86,87];

for m = 1:n_file
    Spikes = cell(1,60);% It stores all spikes in all unit
    load(all_file(m).name);
    file = all_file(m).name(7:end);
    load([current_path,'\sort\',file]);
    num_unit = zeros(1,60);
    for h=1:60
        adch_channel = eval(['adch_',int2str(channel(h))]);
        num_unit(h) = max(adch_channel (:,2));
        Spikes{h} = adch_channel (:,3);
    end
    sorted_spikes=cell(1,60);%It stores all spikes in all unit
    for j = 1:length(Spikes)    %running through each channel
        ss = Spikes{j};
        ss(ss<TimeStamps(1,1)) = [];  %delete the spikes before TimeStamps(1)
        ss(ss>TimeStamps(1,2))=[];
    
        for i = 1:length(ss)
            ss(i) = ss(i)-TimeStamps(1,1);
        end
        sorted_spikes{j} = ss;
    end
    
    
    unit_spikes  = cell(max(num_unit),60);% It stores each spike in each unit
    for h=1:60
        adch_channel = eval(['adch_',int2str(channel(h))]);
        for i = 1:size(adch_channel,1)
            unit_spikes{adch_channel(i,2),h} = [unit_spikes{adch_channel(i,2),h},adch_channel(i,3)];   
        end
    end
    
    
    sorted_unit_spikes = cell(max(num_unit),60);% It stores each spike in each unit
    for i = 1:max(num_unit)
        for j = 1:length(unit_spikes)    %running through each channel
            if isempty(unit_spikes{i,j})
               continue; 
            end
            ss = unit_spikes{i,j};
            ss(ss<TimeStamps(1,1)) = [];  %delete the spikes before TimeStamps(1)
            ss(ss>TimeStamps(1,2))=[];

            for k = 1:length(ss)
                ss(k) = ss(k)-TimeStamps(1,1);
            end
            sorted_unit_spikes{i,j} = ss;
        end
        
    end
    
    save([current_path,'\multi_unit_merge_spike','\multi_unit_merge_',file],'sorted_spikes','bin_pos','TimeStamps','reconstruct_spikes','diode_BT','BinningInterval','sorted_unit_spikes');
end








cd ..