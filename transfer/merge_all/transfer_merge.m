exp_folder = 'D:\Leo\0417exp';
load([exp_folder, '\data\all_merge_all_pick_unit_a.mat'])
channel = [12,13,14,15,16,17,21,22,23,24,25,26,27,28,31,32,33,34,35,36,37,38,41,42,43,44,45,46,47,48,51,52,53,54,55,56,57,58,61,62,63,64,65,66,67,68,71,72,73,74,75,76,77,78,82,83,84,85,86,87];
merge_Spikes = cell(1,60);
for h=1:60
    adch_channel = eval(['adch_',int2str(channel(h))]);
    merge_Spikes{h} = adch_channel (:,2);
end
cd(exp_folder)
mkdir sort
fileID = fopen([exp_folder, '\playmovie\all_list.txt'],'r');
formatSpec = '%c';
txt = textscan(fileID,'%s','delimiter','\n'); 
num_files = length(txt{1});
cutrange = zeros(1,num_files+1);

for i = 1:num_files
    load([exp_folder, '\data\', txt{1}{i},'.mat']);
    cutrange(i+1) = cutrange(i) + size(a_data,2);
end

cutrange=cutrange./20000;

for i = 1:num_files
    Spikes = cell(1,60);
    for j = 1:60
        spike=find(merge_Spikes{j}>cutrange(i) & merge_Spikes{j}<cutrange(i+1));
        Spikes{j} = merge_Spikes{j}(spike)-cutrange(i);
    end
    save([exp_folder,'\sort\',txt{1}{i},'.mat'],'Spikes')
end


fclose(fileID);