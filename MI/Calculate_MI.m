clear all;
code_folder = pwd;
%exp_folder = 'D:\Leo\1012exp';
exp_folder_cell = {'D:\Leo\0229', 'D:\Leo\1219exp' ,'D:\Leo\1017exp'};
type_folder_cell = {'pos', 'v', 'pos&v'};%'abs', 'pos', 'v', 'pos&v'.
for ttt = 2:3
for eee = 1
exp_folder = exp_folder_cell{eee};
cd(exp_folder);
mkdir MI
cd MI
type = type_folder_cell{ttt}; 
sorted = 0;
unit = 0; %unit = 0 means using 'unit_a' which is writen down while picking waveform in Analyzed_data.


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
        x=bin_pos;
        TheStimuli = [ 0 x 0 0 0 0 0 0 0]-9*[0 0 x 0 0 0 0 0 0]+45*[0 0 0 x 0 0 0 0 0]-45*[0 0 0 0 0 x 0 0 0]+9*[0 0 0 0 0 0 x 0 0]-1*[0 0 0 0 0 0 0 x 0];
        TheStimuli = TheStimuli(5:end-4);
    end
    
    % Binning
    bin=BinningInterval*10^3; %ms
    BinningTime =diode_BT;
    
    StimuSN=9; %number of stimulus states
    if strcmp(type,'abs')
        nX=sort(TheStimuli,2);
        abin=length(nX)/StimuSN;
        isi2 = zeros(60,length(TheStimuli));
        for k = 1:60
            if sum(absolute_pos(k,:))>0
                intervals=[nX(k,abin:abin:end) inf]; % inf: the last term: for all rested values
                for jj=1:length(TheStimuli)
                    isi2(k,jj) = find(TheStimuli(k,jj)<=intervals,1);
                end
            end
        end
    elseif strcmp(type,'pos') || strcmp(type,'v')
        nX=sort(TheStimuli);
        abin=length(nX)/StimuSN;
        intervals=[nX(abin:abin:end) inf]; % inf: the last term: for all rested values
        temp=0; isi2=[];
        for jj=1:length(TheStimuli)
            isi2(jj) = find(TheStimuli(jj)<=intervals,1);
        end
    elseif strcmp(type,'pos&v')
        TheStimuli = zeros(2, length(bin_pos));
        TheStimuli(1,:)=bin_pos;
        x = bin_pos;
        v = [ 0 x 0 0 0 0 0 0 0]-9*[0 0 x 0 0 0 0 0 0]+45*[0 0 0 x 0 0 0 0 0]-45*[0 0 0 0 0 x 0 0 0]+9*[0 0 0 0 0 0 x 0 0]-1*[0 0 0 0 0 0 0 x 0];
        TheStimuli(2,:) = v(5:end-4);
        nX1=sort(TheStimuli(1,:));
        nX2=sort(TheStimuli(2,:));
        abin=length(nX1)/StimuSN;
        intervals1=[nX1(abin:abin:end) inf]; % inf: the last term: for all rested values
        abin=length(nX2)/StimuSN;
        intervals2=[nX2(abin:abin:end) inf]; % inf: the last term: for all rested values
        temp=0; isi3=[]; isi2=[];
        for jj=1:length(TheStimuli)
            isi3(1,jj) = find(TheStimuli(1,jj)<=intervals1,1);
            isi3(2,jj) = find(TheStimuli(2,jj)<=intervals2,1);
        end
        isi2 = StimuSN*(isi3(1,:)-1) + isi3(2,:);
    end
    
    %% BinningSpike
    BinningSpike = zeros(60,length(BinningTime));
    analyze_spikes = cell(1,60);
    if sorted
        analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,unit);
    else
        analyze_spikes = reconstruct_spikes;
    end
    for i = 1:60  % i is the channel number
        [n,~] = hist(analyze_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        BinningSpike(i,:) = n ;
    end
    %% Predictive information & find peak of MI
    backward=ceil(15000/bin);
    forward=ceil(15000/bin);
    time=[-backward*bin:bin:forward*bin];
    MI_peak=zeros(1,60);
    ind_peak=zeros(1,60);
    peak_times = zeros(1,60)-1000000;
    P_channel = [];
    N_channel = [];
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
        
        %find peaks
        if max(Mutual_infos{channelnumber}-mean(Mutual_shuffle_infos{channelnumber}))<0.1
            continue;
        end
        Mutual_infos{channelnumber} = smooth(Mutual_infos{channelnumber});
        [MI_peak(channelnumber), ind_peak(channelnumber)] = max(Mutual_infos{channelnumber}); % MI_peak{number of data}{number of channel}
        if (time(ind_peak(channelnumber)) < -1000) || (time(ind_peak(channelnumber)) > 1000) % the 100 points, timeshift is 1000
            MI_peak(channelnumber) = NaN;
            ind_peak(channelnumber) = NaN;
        end
        % ======= exclude the MI that is too small ===========
        pks_1d=ind_peak(channelnumber);
        peaks_ind=pks_1d(~isnan(pks_1d));
        peaks_time = time(peaks_ind);
        % ============ find predictive cell=============
        if peaks_time>=0
            P_channel=[P_channel channelnumber];
        elseif peaks_time<0
            N_channel=[N_channel channelnumber];
        end
        if length(peaks_time)>0
            peak_times(channelnumber) = peaks_time;
        end
    end
    acf = autocorr(bin_pos,100);
    corr_time = find(abs(acf-0.5) == min(abs(acf-0.5)))/60;
    if sorted
        save([exp_folder,'\MI\sort\', type,'_',name(12:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos','P_channel','N_channel','peak_times', 'MI_peak', 'corr_time')
    else
        save([exp_folder,'\MI\unsort\', type,'_',name(7:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos','P_channel','N_channel','peak_times', 'MI_peak', 'corr_time')
    end
    
    
end

end
end