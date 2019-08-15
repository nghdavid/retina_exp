% Calculated MI for continuos changing intensity stimulation , by Rona
close all
clear all;
code_folder = pwd;
exp_folder = 'D:\Leo\0807exp';
cd(exp_folder);
mkdir MI
cd MI
sorted = 0;
unit = 1;
if sorted
    mkdir sort
    cd ([exp_folder,'\sort'])
    all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
    n_file = length(all_file) ;
else
    mkdir unsort
    cd ([exp_folder,'\data'])
    all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
    n_file = length(all_file) ;
end
cd(code_folder);



SamplingRate=20000;
roi = [1:60];

for z =1:n_file
    Mutual_infos = cell(1,60);
    Mutual_shuffle_infos = cell(1,60);
    
    
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    if strcmp(filename(1),'H') || strcmp(filename(1),'O')
    else
        continue
    end
    load([directory(1:end-5),'data\',filename]);
    load([directory,filename]);
    name(name=='_')='-';
    bin=10;  BinningInterval = bin*10^-3;
    %backward=ceil(1000/bin); forward=ceil(1000/bin);
    %%  TimeStamps  %%%%%%%%%%%%%%%%%%%
    %     if size(a_data,1)==1              %only find one analog channel, possibly cause by the setting in MC_rack
    %         a_data2 = a_data(1,:);
    %     else
    %         a_data2 = a_data(2,:);
    %     end
    %     [~,locs]=findpeaks(diff(a_data2),'MINPEAKHEIGHT',5*std(diff(a_data2)));
    %     analog_loc = (locs)/SamplingRate;
    %     TimeStamps = analog_loc;
    %
    % TimeStamps =[TimeStamps_H(1):TimeStamps_N(end)]
    if length(TimeStamps)==1
        TimeStamps(2)=TimeStamps(1)+200;
    end
    
    %% diode as isi2
    %    load(['E:\google_rona\20170502\diode\diode_',filename]);
    %      [~,locs_a2]=findpeaks(diff(diff(a2)),'MINPEAKHEIGHT',5*std(diff(diff(a2))));
    %      TimeStamps_a2 = (locs_a2)/SamplingRate;
    %
    % %     [b,a]=butter(2,60/20000,'low');
    % %     a_data2=filter(b,a,callumin)';
    % %     a_data2=eyf;
    %     isi = callumin_filter(TimeStamps_a2(1)*20000:TimeStamps_a2(end)*20000);
    % %     figure(z);autocorr(isi,100000);
    %% state of light intensity  of change rate %%%
    [b,a] = butter(2,50/20000,'low'); % set butter filter
    a_data2 = filter(b,a,a_data(3,:));
    isi = a_data2(TimeStamps(1)*20000:TimeStamps(length(TimeStamps))*20000);% figure;plot(isi);
    if strcmp(type,'wf') %for whole field stimuli
        isi2=[];
        states=8;
        X=isi;
        nX = sort(X);
        abin = length(nX)/states;
        intervals = [nX(1:abin:end) inf];
        temp=0;
        for jj = 1:BinningInterval*SamplingRate:length(X)
            temp=temp+1;
            isi2(temp) = find(X(jj)<intervals,1)-1; % stimulus for every 50ms
        end
        %TheStimuli= absolute_pos;  %recalculated bar position
    elseif strcmp(type,'wfv')  %for change rate of whole field stimuli
        [b,a] = butter(2,50/20000,'low'); % set butter filter
        a_data2 = filter(b,a,a_data(3,:));
        isi = a_data2(TimeStamps(1)*20000:TimeStamps(length(TimeStamps))*20000);% figure;plot(isi);
        isi3=[];isi4=[];
        isi = isi(1:BinningInterval*SamplingRate:length(isi))
        isi=diff(isi);
        isi = ([0 isi] + [isi 0]) /2;
        isi2=[];
        states=8;
        X=isi;
        nX = sort(X);
        abin = length(nX)/states;
        intervals = [nX(1:abin:end) inf];
        temp=0;
        for jj = 1:length(X)
            temp=temp+1;
            isi2(temp) = find(X(jj)<intervals,1)-1; % stimulus for every 50ms
        end
    end
    %% Spike process
    BinningSpike = zeros(60,length(BinningTime));
    analyze_spikes = cell(1,60);
    if sorted
        for i = 1:60  % i is the channel number
            analyze_spikes{i} =[];
            for u = unit
                analyze_spikes{i} = [analyze_spikes{i} Spikes{u,i}'];
            end
            analyze_spikes{i} = sort(analyze_spikes{i});
        end
        Spikes = analyze_spikes;
    else
    end
    
    BinningTime = [TimeStamps(1) : BinningInterval : TimeStamps(end)];
    BinningSpike = zeros(60,length(BinningTime));
    for i = 1:60
        [n,xout] = hist(Spikes{i},BinningTime) ;
        BinningSpike(i,:) = n ;
    end
    % [n,out] = hist(TimeStamps,BinningTime);
    % Stimuli = n;
    BinningSpike(:,1) = 0;BinningSpike(:,end) = 0;% figure;plot(BinningTime,sum(BinningSpike),BinningTime,10*Stimuli,'o')
    %     figure;imagesc(BinningTime,[1:60],BinningSpike)
    
    %% Mutual Information
    %% Predictive information
    backward=ceil(15000/bin);
    forward=ceil(15000/bin);
    time=[-backward*bin:bin:forward*bin];
    
    for channelnumber=1:60
        
        Neurons = BinningSpike(channelnumber,:);  %for single channel
        if absolute
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
        
        if absolute
            information_shuffle = MIfunc(Neurons_shuffle,isi2(channelnumber,:),BinningInterval,backward,forward);
        else
            information_shuffle = MIfunc(Neurons_shuffle,isi2,BinningInterval,backward,forward);
        end
        
        Mutual_infos{channelnumber} = information;
        Mutual_shuffle_infos{channelnumber} = information_shuffle;
        
    end
    if sorted
        save([exp_folder,'\MI\sort', type,'_',name,'.mat'],'time','Mutual_infos','Mutual_shuffle_infos')
    else
        save([exp_folder,'\MI\unsort', type,'_',name,'.mat'],'time','Mutual_infos','Mutual_shuffle_infos')
    end
end
