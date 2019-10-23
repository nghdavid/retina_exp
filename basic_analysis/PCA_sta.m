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

forward = 90;%30 bins before spikes for calculating STA
backward = 90;%30 bins after spikes for calculating STA

for z =12%:n_file %choose file
    
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
    acf = autocorr(bin_pos,100);
    corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))/60;
    % put your stimulus here!!
    TheStimuli=relative_pos;  %recalculated bar position
    time=[-forward :backward]*BinningInterval;
    % Binning
    bin=BinningInterval*10^3; %ms
    BinningTime =diode_BT;
    
    %% BinningSpike and calculate STA
    BinningSpike = zeros(60,length(BinningTime));
    analyze_spikes = cell(1,60);
    
    for i = 1:60  % i is the channel number
        analyze_spikes{i} =[];
        for u = unit
            analyze_spikes{i} = [analyze_spikes{i} sorted_spikes{u,i}'];
        end
        analyze_spikes{i} = sort(analyze_spikes{i});
    end

    total_STA = cell(1,60);
    for i = 1:60  % i is the channel number
        [n,~] = hist(analyze_spikes{i},BinningTime) ;
        BinningSpike(i,:) = n ;
        dis_STA = zeros(sum(n),forward+backward+1);
        num_spike =1;
        for time_shift = forward+1:length(BinningTime)-backward
            if BinningSpike(i,time_shift) ~= 0
                for num = 1:BinningSpike(i,time_shift)
                    dis_STA(num_spike,:) = TheStimuli(i,time_shift-forward:time_shift+backward);
                    num_spike = num_spike+1;
                end
            end
        end
        total_STA{i} = dis_STA;
    end
    
    %save([exp_folder,'\STA\',name(12:end),'.mat'],'time','dis_STA','relative_pos','corr_time')
end
for i = [25]
    [coeff,score,latent] = pca(total_STA{i});
    
    figure(i)
    plot(time,coeff(:,1));hold on;
    plot(time,coeff(:,2));
    figure(i+100)
    scatter(score(:,1),score(:,2))
    axis equal
    mu = mean(total_STA{i});
    nComp = 1;
    Xhat = score(:,1:nComp) * coeff(:,1:nComp)';
    Xhat = bsxfun(@plus, Xhat, mu);

end
figure(i)
for i =1:200
    
    plot(time,Xhat(i,:));hold on
end