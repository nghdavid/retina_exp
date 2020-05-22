close all;
clear all;
colors = lines(4);
filterWindow = .8; % 800 ms filters
samplingRate = 60; % in Hz
tbin = 1/samplingRate;
filterLen = ceil(filterWindow*samplingRate);
nBins = 15;
StimuSN = 6;
code_folder = pwd;
exp_folder = 'E:\20200418';
cd(exp_folder);
mkdir linear_decoding
load(['predictive_channel\bright_bar.mat'])
cd ([exp_folder,'\sort_merge_spike\MI'])
all_file = subdir('*.mat');% change the type of the files which you want to select, subdir or dir.
n_file = length(all_file);
roi = [p_channel,np_channel];

for z =8%1:n_file %choose file
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([directory,filename]);
    name=[name];
    z
    name
   
    BinningTime =diode_BT;
    stimFrames =bin_pos;
    spikeCounts = zeros(length(roi),length(BinningTime));
    nCells = 0;
    for channel = roi
        nCells = nCells+1;
        [n,~] = hist(sorted_spikes{channel},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        spikeCounts(nCells,:) = n;
    end
    
    %% Reconstruction of trajectory

    [shift_reconstrFrames,originalFrames,Filter] = getLinearPopulationFilterShift(spikeCounts, stimFrames, filterLen);
    [reconstrFrames,reconstrStimBins,populationFilter] = getLinearPopulationFilter(spikeCounts, stimFrames, filterLen);
    
    %Cross correlation
    cc = mean((reconstrFrames-mean(reconstrFrames)).*(stimFrames(reconstrStimBins)-mean(stimFrames(reconstrStimBins)))/(std(stimFrames(reconstrStimBins))*std(reconstrFrames)))
    cc_shift = mean((shift_reconstrFrames-mean(shift_reconstrFrames)).*(originalFrames-mean(originalFrames))/(std(originalFrames)*std(shift_reconstrFrames)))
    figure;%Shift reconstruction
    plot(originalFrames);hold on
    plot(shift_reconstrFrames)
    %% Time-shifted Mutual information between trajectory and reconstruction of trajectory
    bin=BinningInterval*10^3; %ms
    backward=ceil(15000/bin);
    forward=ceil(15000/bin);
    time=[-backward*bin:bin:forward*bin];
    %shift MI
    shift_isi2 = binning(originalFrames,'pos',StimuSN);
    shift_reconstruct = binning(shift_reconstrFrames,'pos',StimuSN);
    shift_information = MIfunc(shift_reconstruct,shift_isi2,BinningInterval,backward,forward);
    %original MI
    isi2 = binning(stimFrames(reconstrStimBins),'pos',StimuSN);
    reconstruct = binning(reconstrFrames,'pos',StimuSN);
    information = MIfunc(reconstruct,isi2,BinningInterval,backward,forward);
    
    %Plot shift MI and original MI
    figure
    plot(time,information,'r');hold on
    plot(time,shift_information,'b');
    xline(0)
    xlim([ -2300 1300])
    ylim([0 inf+0.1])
    xlabel('time shift')
    ylabel('MI')
    legend('original','shift')
%     saveas(gcf,[exp_folder,'\linear_decoding\MI_',name(12:end),'.tif'])
end