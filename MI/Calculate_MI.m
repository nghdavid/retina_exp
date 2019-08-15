clear all;
code_folder = pwd;
exp_folder = 'D:\Leo\0813exp';
cd(exp_folder);
mkdir MI
cd MI
type = 'pos'; %'abs', 'pos', 'v'
sorted = 0;
unit = 1;
if sorted
    mkdir sort
    cd ([exp_folder,'\sort_merge_spike'])
    all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
    n_file = length(all_file) ;
else
    mkdir unsort
    cd ([exp_folder,'\merge'])
    all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
    n_file = length(all_file) ;
end
cd(code_folder);

for z =1:n_file %choose file
    Mutual_infos = cell(1,60);
    Mutual_shuffle_infos = cell(1,60);
    
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    if (strcmp(filename(12),'H') || strcmp(filename(12),'O')) && sorted == 0
    elseif (strcmp(filename(17),'H') || strcmp(filename(17),'O')) && sorted
    else
        continue
    end
    
    load([directory,filename]);
    
    name=[name];
    z
    name
    
    
    % put your stimulus here!!
    if strcmp(type,'abs')
        TheStimuli=absolute_pos;  %recalculated bar position
    elseif strcmp(type,'pos')
        TheStimuli=bin_pos;
    elseif strcmp(type,'v')
        TheStimuli=diff(bin_pos);
        TheStimuli = ([0 TheStimuli] + [TheStimuli 0]) /2;
    end
    
    % Binning
    bin=BinningInterval*10^3; %ms
    BinningTime =diode_BT;
    
    StimuSN=30; %number of stimulus states
    if strcmp(type,'abs')
        nX=sort(TheStimuli,2);
        abin=length(nX)/StimuSN;
        isi2 = zeros(60,length(TheStimuli));
        for k = 1:60
            if sum(absolute_pos(k,:))>0
                intervals=[nX(k,1:abin:end) inf]; % inf: the last term: for all rested values
                for jj=1:length(TheStimuli)
                    isi2(k,jj) = find(TheStimuli(k,jj)<=intervals,1);
                end
            end
        end
    else
        nX=sort(TheStimuli);
        abin=length(nX)/StimuSN;
        intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
        temp=0; isi2=[];
        for jj=1:length(TheStimuli)
            temp=temp+1;
            isi2(temp) = find(TheStimuli(jj)<=intervals,1);
        end
    end
    %% BinningSpike
    BinningSpike = zeros(60,length(BinningTime));
    analyze_spikes = cell(1,60);
    if sorted
        for i = 1:60  % i is the channel number
            analyze_spikes{i} =[];
            for u = unit
                analyze_spikes{i} = [analyze_spikes{i} sorted_spikes{u,i}'];
            end
            analyze_spikes{i} = sort(analyze_spikes{i});
        end
    else
        analyze_spikes = reconstruct_spikes;
    end
    for i = 1:60  % i is the channel number
        [n,~] = hist(analyze_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        BinningSpike(i,:) = n ;
    end
    %% Predictive information
    backward=ceil(15000/bin);
    forward=ceil(15000/bin);
    time=[-backward*bin:bin:forward*bin];
    
    for channelnumber=1:60
        
        Neurons = BinningSpike(channelnumber,:);  %for single channel
        if strcmp(type,'abs')
            if sum(absolute_pos(channelnumber,:))>0
                information = MIfunc(Neurons,isi2(channelnumber,:),BinningInterval,backward,forward);
            else
                Mutual_infos{channelnumber} = zeros(1,length(time));
                Mutual_shuffle_infos{channelnumber} =zeros(1,length(time));;
                continue
            end
        else
            information = MIfunc(Neurons,isi2,BinningInterval,backward,forward);
        end
        %% shuffle MI
        sNeurons=[];
        r=randperm(length(Neurons));
        for j=1:length(r)
            sNeurons(j)=Neurons(r(j));
        end
        Neurons_shuffle=sNeurons;
        
        if strcmp(type,'abs')
            information_shuffle = MIfunc(Neurons_shuffle,isi2(channelnumber,:),BinningInterval,backward,forward);
        else
            information_shuffle = MIfunc(Neurons_shuffle,isi2,BinningInterval,backward,forward);
        end
        
        Mutual_infos{channelnumber} = information;
        Mutual_shuffle_infos{channelnumber} = information_shuffle;
        
    end
    acf = autocorr(bin_pos,100);
    corr_time = find(abs(acf-0.5) == min(abs(acf-0.5)))/60;
    if sorted
        save([exp_folder,'\MI\sort\', type,'_',name(12:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos', 'corr_time')
    else
        save([exp_folder,'\MI\unsort\', type,'_',name(7:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos', 'corr_time')
    end
    

end