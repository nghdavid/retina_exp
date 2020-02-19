clear all;
code_folder = pwd;
exp_folder = 'F:\test';
cd(exp_folder)
mkdir merge
cd data
all_file = dir('*.mcd') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 
for m = 1:n_file
    clearvars -except all_file n_file m code_folder exp_folder
    file = all_file(m).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    
    [Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data([exp_folder,'\data\',filename],1,'','david','all');%%If your ram is enough, run this line
end
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 


for m = 1:n_file
    
    file = all_file(m).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    pass = reconstruct(exp_folder,'HMM',name,name);
    if pass
        disp([name,'  passes'])
    else
        disp([name,'not passes'])
    end

end

cd(exp_folder);
mkdir MI
cd MI
mkdir unsort
cd ([exp_folder,'\merge'])
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;

for z =1:n_file %choose file
    Mutual_infos = cell(1,60);
    Mutual_shuffle_infos = cell(1,60);
    type = 'pos';
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    
    load([directory,filename]);
    
    name=[name];
    z
    name
    % put your stimulus here!!
    TheStimuli=bin_pos;
    % Binning
    bin=BinningInterval*10^3; %ms
    BinningTime =diode_BT;
    StimuSN=30; %number of stimulus states
    nX=sort(TheStimuli);
    abin=length(nX)/StimuSN;
    intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
    temp=0; isi2=[];
    for jj=1:length(TheStimuli)
        isi2(jj) = find(TheStimuli(jj)<=intervals,1);
    end
    %% BinningSpike
    BinningSpike = zeros(60,length(BinningTime));
    analyze_spikes = reconstruct_spikes;
    for i = 1:60  % i is the channel number
        [n,~] = hist(analyze_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        BinningSpike(i,:) = n ;
    end
    %% Predictive information & find peak of MI
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
    save([exp_folder,'\MI\unsort\', type,'_',name(7:end),'.mat'],'time','Mutual_infos','Mutual_shuffle_infos')
    
end

cd(exp_folder)
load('rr.mat')
cd MI\unsort
mkdir FIG
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
n_file = length(all_file);        
for z =1:n_file
    file = all_file(z).name;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([filename]);
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    set(ha, 'Visible', 'off');
    for channelnumber=1:60
        if max(Mutual_infos{channelnumber}-mean(Mutual_shuffle_infos{channelnumber}))<0.1
            continue;
        end
        Mutual_infos{channelnumber} = smooth(Mutual_infos{channelnumber});
        axes(ha(rr(channelnumber))); 
        plot(time,Mutual_infos{channelnumber},'LineWidth',2,'LineStyle','-');hold on;
        plot(time,smooth(Mutual_shuffle_infos{channelnumber}),'LineWidth',2,'LineStyle','-');hold off;
        grid on
        xlim([ -2300 1300])
        ylim([0 inf+0.1])
        title(channelnumber)
    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig =gcf;
    fig.PaperPositionMode = 'auto';
    fig.InvertHardcopy = 'off';
    saveas(fig,['FIG\',name,'.tif'])
    saveas(fig,['FIG\',name,'.fig'])
    close(gcf)
end