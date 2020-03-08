function analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,unit)
    analyze_spikes = cell(1,60);
    complex_channel = [];
    if unit == 0
        fileID = fopen([exp_folder, '\Analyzed_data\unit_a.txt'],'r');
        formatSpec = '%c';
        txt = textscan(fileID,'%s','delimiter','\n');
        for m = 1:size(txt{1}, 1)
            complex_channel = [complex_channel str2num(txt{1}{m}(1:2))];
        end
    end
    for i = 1:60  % i is the channel number
        analyze_spikes{i} =[];
        if unit == 0
            if any(complex_channel == i)
                unit_a = str2num(txt{1}{find(complex_channel==i)}(3:end));
                for u = unit_a
                    analyze_spikes{i} = [analyze_spikes{i} sorted_spikes{u,i}'];
                end
            else
                analyze_spikes{i} = [analyze_spikes{i} sorted_spikes{1,i}'];
            end
        else
            for u = unit
                analyze_spikes{i} = [analyze_spikes{i} sorted_spikes{u,i}'];
            end
        end
    analyze_spikes{i} = sort(analyze_spikes{i});
end