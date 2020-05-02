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
all_file = subdir('*.mat'); % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;
roi = [p_channel,np_channel];
for z =20%1:n_file %choose file
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
    
    %% Cell filters and nonlinearities
    filters = zeros(nCells, filterLen);
    NLrates = zeros(nCells, nBins);
    NLbins = zeros(nCells, nBins);
    for cellIdx = 1:nCells
        filters(cellIdx, :) = getFilter(spikeCounts(cellIdx, :), stimFrames, filterLen);
        [NLrates(cellIdx, :), NLbins(cellIdx, :)] = getNL(spikeCounts(cellIdx, :), stimFrames, filters(cellIdx, :), tbin, nBins);
    end
    
    %% Reconstruction of trajectory
%   [reconstrFrames, reconstrStimBins, populationFilter] = getLinearPopulationReadout(spikeCounts, stimFrames, filterLen);
    [reconstrFrames,reconstrStimBins,populationFilter] = getLinearPopulationFilter(spikeCounts, stimFrames, filterLen);
    %Cross correlation
    cc = mean((reconstrFrames-mean(reconstrFrames)).*(stimFrames(reconstrStimBins)-mean(stimFrames(reconstrStimBins)))/(std(stimFrames(reconstrStimBins))*std(reconstrFrames)));
    
    fullfig
    takeFrames = 7000:9000;
    plot(BinningTime(reconstrStimBins(takeFrames)), reconstrFrames(takeFrames), 'k', 'linewidth', 1.5);hold on
    plot(BinningTime(reconstrStimBins(takeFrames)), stimFrames(reconstrStimBins(takeFrames)),'color', [.7, .7, .7]);
    xlim([min(BinningTime(reconstrStimBins(takeFrames))),max(BinningTime(reconstrStimBins(takeFrames)))])
    title(['Cross correlation is ',num2str(cc)])
    saveas(gcf,[exp_folder,'\linear_decoding\',name(12:end),'.tif'])
  %%
  
    %% Mutual information between trajectory and reconstruction of trajectory in different frequency
    [totalInfo, freqBins, infoDensity, stimDensity, reconstrDensity, errorDensity] = calcMutualInformation(stimFrames(reconstrStimBins), reconstrFrames, filterLen, tbin);
    fullfig
    subplot(1,2,1)
    plot(linspace(0, samplingRate/2, numel(infoDensity)), infoDensity, 'k', 'linewidth', 1.5);
    xlim([0, 10]);
    xlabel('Frequency (Hz)');
    title('Information density');
    
    %% Time-shifted Mutual information between trajectory and reconstruction of trajectory
    bin=BinningInterval*10^3; %ms
    backward=ceil(15000/bin);
    forward=ceil(15000/bin);
    time=[-backward*bin:bin:forward*bin];
    isi2 = binning(stimFrames(reconstrStimBins),'pos',StimuSN);
    reconstruct = binning(reconstrFrames,'pos',StimuSN);
    information = MIfunc(reconstruct,isi2,BinningInterval,backward,forward);
    subplot(1,2,2)
    plot(time,information);
    xline(0)
    xlim([ -2300 1300])
    ylim([0 inf+0.1])
    xlabel('time shift')
    ylabel('MI')
    saveas(gcf,[exp_folder,'\linear_decoding\MI_',name(12:end),'.tif'])
end