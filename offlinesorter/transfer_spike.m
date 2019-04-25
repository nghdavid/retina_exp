function Spikes = transfer_spike(filename)
    %filename = '/Users/nghdavid/Desktop/sys/spike_example.mat';

    load(filename);
    Spikes = cell(1,60);

    channel = [12,13,14,15,16,17,21,22,23,24,25,26,27,28,31,32,33,34,35,36,37,38,41,42,43,44,45,46,47,48,51,52,53,54,55,56,57,58,61,62,63,64,65,66,67,68,71,72,73,74,75,76,77,78,82,83,84,85,86,87];
    for h=1:60
        Spikes{h} = eval(['ch_',int2str(channel(h))]);
    end
end