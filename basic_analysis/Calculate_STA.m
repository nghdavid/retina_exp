%% This code calculate HMM and OU bar position STA
close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20190811';
cd(exp_folder);

mkdir STA
cd sort_merge_spike\MI
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;
unit = 1;
velocity = 0;%speed is 1, position is 0
forward = 90;%90 bins before spikes for calculating STA
backward = 90;%90 bins after spikes for calculating STA

for z =1:n_file %choose file
    
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    if (strcmp(filename(17),'H') || strcmp(filename(17),'O'))
    else
        continue
    end
    load(filename);
    name=[name];
    z
    name
    % put your stimulus here!!
    if velocity
        TheStimuli = bin_pos;
    else
        TheStimuli= bin_pos;  %recalculated bar position
    end
    time=[-forward :backward]*BinningInterval;
    % Binning
    bin=BinningInterval*10^3; %ms
    BinningTime =diode_BT;
    
    %% BinningSpike and calculate STA
    BinningSpike = zeros(60,length(BinningTime));
    analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,unit);
    sum_n = zeros(1,60);
    dis_STA = zeros(60,forward+backward+1);
    for i = 1:60  % i is the channel number
        [n,~] = hist(analyze_spikes{i},BinningTime) ;
        BinningSpike(i,:) = n ;
        sum_n(i) = sum_n(i)+ sum(BinningSpike(i,forward+1:length(BinningTime)-backward));
        for time_shift = forward+1:length(BinningTime)-backward
            dis_STA(i,:) = dis_STA(i,:) + BinningSpike(i,time_shift)*TheStimuli(time_shift-forward:time_shift+backward);
        end
        if sum_n(i)
            dis_STA(i,:) = dis_STA(i,:)/sum_n(i);
        end
        
    end
    acf = autocorr(bin_pos,100);
    corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))/60;
    if velocity
        save([exp_folder,'\STA\v_',name(12:end),'.mat'],'time','dis_STA','bin_pos','corr_time')
    else
        save([exp_folder,'\STA\pos_',name(12:end),'.mat'],'time','dis_STA','bin_pos','corr_time')
    end
end

