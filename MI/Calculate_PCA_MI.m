clear all;
code_folder = pwd;
sorted =1;
exp_folder = 'E:\20200306';
cd(exp_folder);
absolute =0;
cd ([exp_folder,'\STA'])
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
n_file = length(all_file) ;
sort_directory = 'sort';
cd(code_folder);
roi = 28;
for z = 6%1:n_file %choose file
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
    
    
    for i = roi
        num_spike = 1;
        idx = idxs{i};
        if ~isempty(idx)
            for time_shift = forward+1:length(BinningTime)-backward
                for x = 1:BinningSpike(i,time_shift)
                    if idx(num_spike) == 1
                        %Red is 1, Blue is 2
                        BinningSpike(i,time_shift) = BinningSpike(i,time_shift) -1;
                    end
                    num_spike = num_spike+1;
                end
            end
        end
    end
    % Binning
    StimuSN=30; %number of stimulus states
    if absolute
        nX=sort(TheStimuli,2);
        abin=length(nX)/StimuSN;
        isi2 = zeros(60,length(TheStimuli));
        for k = roi
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
    %% Predictive information
    backward=ceil(15000/bin); 
    forward=ceil(15000/bin);
    time=[-backward*bin:bin:forward*bin];
    MI_peak=zeros(1,60);
    ind_peak=zeros(1,60);
    peak_times = zeros(1,60)-1000000;
    P_channel = [];
    N_channel = [];
    for channelnumber= roi
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
    corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))/60;
%     if absolute 
%         save([exp_folder,'\MI\',sort_directory,'\abs_',name(12:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos','P_channel','N_channel','peak_times', 'MI_peak', 'corr_time')
%     else
%         save([exp_folder,'\MI\',sort_directory,'\pos_',name(12:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos','P_channel','N_channel','peak_times', 'MI_peak', 'corr_time')
%     end
end
plot(time,smooth(information-mean(information_shuffle)),'r');hold on
load([exp_folder,'\MI\sort\pos_',name,'.mat'])
plot(time,smooth(Mutual_infos{roi}-mean(Mutual_shuffle_infos{roi})),'b');
xline(0)
xlim([ -2300 1300])
ylim([0 inf+0.1])