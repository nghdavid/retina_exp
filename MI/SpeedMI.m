clear all;
code_folder = pwd;
sorted = 1;
exp_folder = 'E:\0709';
cd(exp_folder);
mkdir MI
cd MI
if sorted
    mkdir sort
    cd ([exp_folder,'\sort_merge_spike\MI'])
    all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
    n_file = length(all_file) ;
else
    mkdir unsort
    cd ([exp_folder,'\merge\MI'])
    all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
    n_file = length(all_file) ;
end
cd(code_folder);

for z =2:n_file %choose file
    Mutual_infos = cell(1,60);
    Mutual_shuffle_infos = cell(1,60);
    
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([directory,filename]);
    name=[name];
    z
    name


    % put your stimulus here!!
    TheStimuli=diff(bin_pos);  %recalculated bar position

    % Binning
    bin=BinningInterval*10^3; %ms
    BinningTime =diode_BT;

    StimuSN=30; %number of stimulus states
    nX=sort(TheStimuli);
    abin=length(nX)/StimuSN;
    intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
    temp=0; isi2=[];
    for jj=1:length(TheStimuli)
        temp=temp+1;
        isi2(temp) = find(TheStimuli(jj)<=intervals,1);
    end 

    %% BinningSpike
    BinningSpike = zeros(60,length(BinningTime));
    if sorted
        for i = 1:60  % i is the channel number
            [n,~] = hist(sorted_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
            BinningSpike(i,:) = n ;
        end
    else
         for i = 1:60  % i is the channel number
            [n,~] = hist(reconstruct_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
            BinningSpike(i,:) = n ;
        end
    end
    
    BinningSpike(:,1) = [];
    %% Predictive information
    backward=ceil(15000/bin); 
    forward=ceil(15000/bin);
    time=[-backward*bin:bin:forward*bin];
    
    for channelnumber=1:60

        Neurons = BinningSpike(channelnumber,:);  %for single channel
        information = MIfunc(Neurons,isi2,BinningInterval,backward,forward);
        
        %% shuffle MI
        sNeurons=[];
        r=randperm(length(Neurons));
        for j=1:length(r)            
            sNeurons(j)=Neurons(r(j));
        end
        Neurons_shuffle=sNeurons;

        information_shuffle = MIfunc(Neurons_shuffle,isi2,BinningInterval,backward,forward);

        
        Mutual_infos{channelnumber} = information;
        Mutual_shuffle_infos{channelnumber} = information_shuffle;

    end
    if sorted
        save([exp_folder,'\MI\sort\speed_',name(12:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos')
    else
        save([exp_folder,'\MI\unsort\speed_',name(7:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos')
    end
end