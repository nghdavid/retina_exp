function [reconstrFrames,reconstrStimBins,filter] = getLinearPopulationFilter(spikeCounts, stimFrames, filterLen)
% getLinearPopulationReadout - get reconstruction from population responses, training bins are the first 70%
% adopted from Warland, Reinagel & Meister, 1997, "Decoding visual information from a population of retinal ganglion cells"
%   spikeCounts: N x T array of spike counts of N cells
%   stimFrames: 2 x T array of motion steps in x- and y-direction
%   filterLen: filter length in bins
%   reconstrFrames is reconstruced trajectory
%   reconstrStimBins is time binnings
trainFrac = 1; % fraction used for training the decoder
nCells = size(spikeCounts, 1);
nDims = size(stimFrames, 1);
stimLen = size(spikeCounts, 2);%Length of stimulus
totalFilterLen = filterLen*nCells+1;%Length of all cell filter

%% Assign training bins
trainBins = 1:floor(stimLen*trainFrac);
trainLen = numel(trainBins)-filterLen;
trainStim = stimFrames(1, trainBins);
trainResp = spikeCounts(:, trainBins);
%% Reshape spike count matrices into response fragments of filter length
trainR = zeros(trainLen, totalFilterLen);
for k = 1:trainLen
	trainR(k, :) = [1, reshape(trainResp(:, k:k+filterLen-1)', 1, [])];
end
reconstrStimBins = trainBins(1:trainLen);

%% Calculate filter and reconstruction
filter = (trainR'*trainR)^(-1)*(trainR'*trainStim(:, 1:trainLen)');
reconstrFrames = (trainR*filter)';
end