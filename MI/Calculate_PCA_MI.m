clear all;
code_folder = pwd;
sorted =1;
exp_folder = 'E:\20200418';
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
for z = 1:n_file %choose file
    PCA_Mutual_infos = cell(6,60);
    PCA_Mutual_shuffle_infos = cell(6,60);
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
    StimuSN=6; %number of stimulus states
    isix = binning(bin_pos,'pos',StimuSN);
    isiv = binning(bin_pos,'v',StimuSN);
    isii = StimuSN*(isix)+isiv;
    
    %% Predictive information
    backward=ceil(15000/bin);
    forward=ceil(15000/bin);
    time=[-backward*bin:bin:forward*bin];
    for channelnumber= roi
        channelnumber
        Blue_Neurons = Blue_BinningSpike(channelnumber,:);  %for single channel
        Red_Neurons = Red_BinningSpike(channelnumber,:);  %for single channel
        Neurons = BinningSpike(channelnumber,:);
        
        [B_MIx B_MIv B_Redundancy] = PIfunc(Blue_Neurons,isix,isiv,BinningInterval,backward,forward);
        B_MIxv = MIfunc(Blue_Neurons,isii,BinningInterval,backward,forward);
        B_pos_Mutual_infos{channelnumber} = B_MIx;
        B_v_Mutual_infos{channelnumber} = B_MIv;
        B_joint_Mutual_infos{channelnumber} = B_MIxv;
        B_Redun_Mutual_infos{channelnumber} = B_Redundancy;
        
        [R_MIx R_MIv R_Redundancy] = PIfunc(Red_Neurons,isix,isiv,BinningInterval,backward,forward);
        R_MIxv = MIfunc(Red_Neurons,isii,BinningInterval,backward,forward);
        R_pos_Mutual_infos{channelnumber} = R_MIx;
        R_v_Mutual_infos{channelnumber} = R_MIv;
        R_joint_Mutual_infos{channelnumber} = R_MIxv;
        R_Redun_Mutual_infos{channelnumber} = R_Redundancy;
        
        [MIx MIv Redundancy] = PIfunc(Neurons,isix,isiv,BinningInterval,backward,forward);
        MIxv = MIfunc(Neurons,isii,BinningInterval,backward,forward);
        pos_Mutual_infos{channelnumber} = MIx;
        v_Mutual_infos{channelnumber} = MIv;
        joint_Mutual_infos{channelnumber} = MIxv;
        Redun_Mutual_infos{channelnumber} = Redundancy;
        
        %% shuffle MI
        %             sNeurons=[];
        %             r=randperm(length(Blue_Neurons));
        %             BlueNeurons_shuffle= zeros(1,length(Blue_Neurons));
        %             RedNeurons_shuffle= zeros(1,length(Red_Neurons));
        %             for j=1:length(r)
        %                 BlueNeurons_shuffle(j)=Blue_Neurons(r(j));
        %                 RedNeurons_shuffle(j)=Red_Neurons(r(j));
        %             end
        %             Blue_information_shuffle = MIfunc(BlueNeurons_shuffle,isi2,BinningInterval,backward,forward);
        %             Red_information_shuffle = MIfunc(RedNeurons_shuffle,isi2,BinningInterval,backward,forward);
        %             PCA_Mutual_infos{1+3*(ttt-1),channelnumber} = Blue_information;
        %             PCA_Mutual_shuffle_infos{1+3*(ttt-1),channelnumber} = Blue_information_shuffle;
        %             PCA_Mutual_infos{2+3*(ttt-1),channelnumber} = Red_information;
        %             PCA_Mutual_shuffle_infos{2+3*(ttt-1),channelnumber} = Red_information_shuffle;
        %             load([exp_folder,'\MI\sort\',type,'_',name,'.mat'])
        %             PCA_Mutual_infos{3+3*(ttt-1),channelnumber} = Mutual_infos{channelnumber}';
        %             PCA_Mutual_shuffle_infos{3+3*(ttt-1),channelnumber} = Mutual_shuffle_infos{channelnumber}';
    end
    
    save([exp_folder,'\STA\MI\',name,'.mat'],'STA_time','dis_STA','bin_pos','corr_time','idxs','PCA_STAs','positive_PCAs',...
        'negative_PCAs','time','Redun_Mutual_infos','joint_Mutual_infos','v_Mutual_infos','pos_Mutual_infos','R_Redun_Mutual_infos',...
        'R_joint_Mutual_infos','R_v_Mutual_infos','R_pos_Mutual_infos','B_Redun_Mutual_infos','B_joint_Mutual_infos','B_pos_Mutual_infos',...
        'B_v_Mutual_infos','positive_before_pos','negative_before_pos','corr_time')
end
