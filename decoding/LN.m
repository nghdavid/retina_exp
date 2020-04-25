% parameters for linear filters and CCA analysis
close all;
clear all;
colors = lines(4);
NLfitType = 'u';
filterWindow = .8; % 800 ms filters
filterWindow2 = 2; % 2 second segments for CCA
samplingRate = 60; % in Hz
tbin = 1/samplingRate;
filterLen = ceil(filterWindow*samplingRate);
filterLen2 = ceil(2*samplingRate);
nBins = 15;
code_folder = pwd;
exp_folder = 'E:\20200418';
cd(exp_folder);
load('RGC.mat')%Needed to run Receptive field.m first
load(['predictive_channel\bright_bar.mat'])
cd ([exp_folder,'\sort_merge_spike\MI'])
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;
roi = [p_channel,np_channel];

for z =8%1:n_file %choose file
    cd('C:\Users\nghdavid\Documents\GitHub\AnalysisForDSPopulationCodes')
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([directory,filename]);
    name=[name];
    z
    name
   
    BinningTime =diode_BT;
    stimFrames =bin_pos;%rescale(bin_pos,-1,1);
    spikeCounts = zeros(length(roi),length(BinningTime));
    nCells = 0;
    for channel = roi
        nCells = nCells+1;
        [n,~] = hist(sorted_spikes{channel},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        spikeCounts(nCells,:) = n;
    end
    
    % cell filters and nonlinearities (Fig. 5)
    filters = zeros(nCells, filterLen);
    NLrates = zeros(nCells, nBins);
    NLbins = zeros(nCells, nBins);
    for cellIdx = 1:nCells
        filters(cellIdx, :) = getFilter(spikeCounts(cellIdx, :), stimFrames, filterLen);
        [NLrates(cellIdx, :), NLbins(cellIdx, :)] = getNL(spikeCounts(cellIdx, :), stimFrames, filters(cellIdx, :), tbin, nBins);
    end
%      [reconstrFrames, reconstrStimBins, populationFilter] = getLinearPopulationReadout(spikeCounts, stimFrames, filterLen);
     [reconstrFrames,reconstrStimBins,populationFilter] = getLinearPopulationFilter(spikeCounts, stimFrames, filterLen);
    [totalInfo, freqBins, infoDensity, stimDensity, reconstrDensity, errorDensity] = calcMutualInformation(stimFrames(reconstrStimBins), reconstrFrames, filterLen, tbin);
    figure
    takeFrames = 1:5000;
    plot(BinningTime(reconstrStimBins(takeFrames)), reconstrFrames(takeFrames), 'k', 'linewidth', 1.5);
    hold on
    gaussKernel = exp(-(-5:5).^2/9);
    gaussKernel = gaussKernel/sum(gaussKernel);
%     plot(BinningTime(reconstrStimBins(takeFrames)), conv(stimFrames(reconstrStimBins(takeFrames)), gaussKernel, 'same'), 'color', [.7, .7, .7]);
    plot(BinningTime(reconstrStimBins(takeFrames)), stimFrames(reconstrStimBins(takeFrames)), 'color', [.7, .7, .7]);
    figure;
    plot(linspace(0, samplingRate/2, numel(infoDensity)), infoDensity, 'k', 'linewidth', 1.5);
    xlim([0, 10]);
    xlabel('Frequency (Hz)');
    title('Information density');
    
    bin=BinningInterval*10^3; %ms
    backward=ceil(15000/bin);
    forward=ceil(15000/bin);
%     takeFrames = 1:5000;
%     gaussKernel = exp(-(-5:5).^2/9);
%     gaussKernel = gaussKernel/sum(gaussKernel);
%     plot(BinningTime(reconstrStimBins(takeFrames)), reconstrFrames(1, takeFrames), 'k', 'linewidth', 1.5);
%     hold on
%     plot(BinningTime(reconstrStimBins(takeFrames)), conv(stimFrames(1, reconstrStimBins(takeFrames)), gaussKernel, 'same'), 'color', [.7, .7, .7]);
% LN model (Fig. 5)
%     PoissonSpikeCounts = LNmodel(stimFrames(1, :), filters(:, 1:filterLen), NLbins(1, :), NLrates(1, :), NLfitType, max(spikeCounts(:)));
%     simFilters = zeros(nCells, filterLen);
%     simNLrates = zeros(nCells, nBins);
%     simNLbins = zeros(nCells, nBins);
%     for cellIdx = 1:nCells
%         simFilters(cellIdx, :) = getFilter(PoissonSpikeCounts(cellIdx, :), stimFrames(1, :), filterLen);
%         [simNLrates(cellIdx, :), simNLbins(cellIdx, :)] = getNL(PoissonSpikeCounts(cellIdx, :), stimFrames(1, :), simFilters(cellIdx, :), tbin, nBins);
%     end
%     [simReconstrFrames, simReconstrStimBins, simPopulationFilter] = getLinearPopulationReadout(PoissonSpikeCounts, stimFrames(1, :), filterLen);
%     for cellIdx = 1:nCells
%         figure;
%         subplot(1,2,1);
%         plot(-filterWindow+tbin:tbin:0, filters(cellIdx, :), 'color', colors(3, :), 'linewidth', 1.5);
%         xlim([-filterWindow, 0]);
%         title(['Filter - cell ', int2str(cellIdx)]);
%         xlabel('Time (s)');
%         legend('x-dir.', 'y-dir.', 'Location', 'northwest');
%         subplot(1,2,2);
%         plot(NLbins(cellIdx, :), NLrates(cellIdx, :), 'k', 'linewidth', 1.5);
%         ylim([0 10]);
%         ylabel('Average response (Hz)');
%         title(['Nonlinearity - cell ', int2str(cellIdx)]);
%     end
end