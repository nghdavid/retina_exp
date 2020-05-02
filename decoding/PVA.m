close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20200418';
cd(exp_folder);
load('RGC.mat')%Needed to run Receptive field.m first

cd ([exp_folder,'\sort_merge_spike\MI'])
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;
for z =1:n_file %choose file
    
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([directory,filename]);
    name=[name];
    z
    name
    BinningTime =diode_BT;
    BinningSpike = zeros(60,length(BinningTime));
    RF_center = zeros(1,60);
    RF_channel = [];
    direction = Get_direction(name);
    for channel = 1:60
        [n,~] = hist(sorted_spikes{channel},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        BinningSpike(channel,:) = n;
        if sum(RGCs{channel}.center_RF) >0 %&& RGCs{channel}.flicker_onoff_index<0
%              RGCs{channel}.flicker_onoff_index
            RF_center(channel) = Monitor2DCoor2BarCoor(RGCs{channel}.center_RF(1),RGCs{channel}.center_RF(2),direction,'OLED');
    %         RF_center(channel)
            RF_channel = [RF_channel,channel];
        end
    end
    average_position = zeros(1,length(BinningTime));
    for t = 1:length(BinningTime)
    num_spike = 0;
    for channel = RF_channel
            average_position(t) = average_position(t) + RF_center(channel)*BinningSpike(channel,t);
            num_spike = num_spike+BinningSpike(channel,t);

    end
    if num_spike ~= 0
    average_position(t) = average_position(t)/num_spike;
    elseif num_spike == 0 && t>1
        average_position(t) = average_position(t-1);
    end
    end
    figure;
    plot(BinningTime,bin_pos);hold on
    plot(BinningTime,average_position)
    corrcoef(bin_pos,average_position)
end