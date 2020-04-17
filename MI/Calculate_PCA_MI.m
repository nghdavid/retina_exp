clear all;
code_folder = pwd;
sorted =1;
exp_folder = 'E:\20200306';
cd(exp_folder);
load('predictive_channel\bright_bar.mat')
mkdir STA
cd ([exp_folder,'\STA'])
mkdir MI
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
n_file = length(all_file) ;
sort_directory = 'sort';
cd(code_folder);
roi = [p_channel,np_channel];
% roi = 42;
for z = 1:n_file %choose file
    PCA_Mutual_infos = cell(2,60);
    PCA_Mutual_shuffle_infos = cell(2,60);
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([directory,filename]);
    name=[name];
    z
    name
    if strcmp(name(1:3),'pos')
        continue
    end
    Red_BinningSpike = BinningSpike;
    Blue_BinningSpike = BinningSpike;
    for i = roi
        num_spike = 1;
        idx = idxs{i};
        if ~isempty(idx)
        for time_shift = forward+1:length(BinningTime)-backward
            for x = 1:BinningSpike(i,time_shift)
                %Red is 1, Blue is 2
                if idx(num_spike) == 1
                    Blue_BinningSpike(i,time_shift) = Blue_BinningSpike(i,time_shift) -1;
                elseif idx(num_spike) == 2
                    Red_BinningSpike(i,time_shift) = Red_BinningSpike(i,time_shift) -1;
                end
                num_spike = num_spike+1;
            end
        end
        end
    end
    
    % Binning
    StimuSN=30; %number of stimulus states
    nX=sort(TheStimuli);
    abin=length(nX)/StimuSN;
    intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
    temp=0; isi2=[];
    for jj=1:length(TheStimuli)
        temp=temp+1;
        isi2(temp) = find(TheStimuli(jj)<=intervals,1);
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
        Blue_Neurons = Blue_BinningSpike(channelnumber,:);  %for single channel
        Red_Neurons = Red_BinningSpike(channelnumber,:);  %for single channel
        Blue_information = MIfunc(Blue_Neurons,isi2,BinningInterval,backward,forward);
        Red_information = MIfunc(Red_Neurons,isi2,BinningInterval,backward,forward);
        
        %% shuffle MI
        sNeurons=[];
        r=randperm(length(Blue_Neurons));
        BlueNeurons_shuffle= zeros(1,length(Blue_Neurons));
        RedNeurons_shuffle= zeros(1,length(Red_Neurons));
        for j=1:length(r)            
            BlueNeurons_shuffle(j)=Blue_Neurons(r(j));
            RedNeurons_shuffle(j)=Red_Neurons(r(j));
        end
        Blue_information_shuffle = MIfunc(BlueNeurons_shuffle,isi2,BinningInterval,backward,forward);
        Red_information_shuffle = MIfunc(RedNeurons_shuffle,isi2,BinningInterval,backward,forward);
        PCA_Mutual_infos{1,channelnumber} = Blue_information;
        PCA_Mutual_shuffle_infos{1,channelnumber} = Blue_information_shuffle;
        PCA_Mutual_infos{2,channelnumber} = Red_information;
        PCA_Mutual_shuffle_infos{2,channelnumber} = Red_information_shuffle;
        PCA_Mutual_infos{1,channelnumber} = smooth(PCA_Mutual_infos{1,channelnumber});
        PCA_Mutual_infos{2,channelnumber} = smooth(PCA_Mutual_infos{2,channelnumber});
        load([exp_folder,'\MI\sort\pos_',name,'.mat'])
        PCA_Mutual_infos{3,channelnumber} = Mutual_infos{channelnumber};
        PCA_Mutual_shuffle_infos{3,channelnumber} = Mutual_shuffle_infos{channelnumber};
        
%         plot(time,smooth(Blue_information-mean(Blue_information_shuffle)),'b');hold on
%         plot(time,smooth(Red_information-mean(Red_information_shuffle)),'r');
%         plot(time,smooth(Mutual_infos{channelnumber}-mean(Mutual_shuffle_infos{channelnumber})),'k');
%         xline(0)
%         xlim([ -2300 1300])
%         ylim([0 inf+0.1])
    end
    save([exp_folder,'\STA\MI\',name,'.mat'],'STA_time','dis_STA','bin_pos','corr_time','idxs','PCA_STAs','positive_PCAs','negative_PCAs','time','PCA_Mutual_infos','PCA_Mutual_shuffle_infos','corr_time')

end
