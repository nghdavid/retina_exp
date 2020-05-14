function [reconstrFrames, reconstrStimBins, filter] = getLinearPopulationReadout(spikeCounts, stimFrames, filterLen)
% getLinearPopulationReadout - get reconstruction from population responses, training bins are the first 70%
% adopted from Warland, Reinagel & Meister, 1997, "Decoding visual information from a population of retinal ganglion cells"
%   spikeCounts: N x T array of spike counts of N cells
%   stimFrames: 2 x T array of motion steps in x- and y-direction
%   filterLen: filter length in bins

trainFrac = 0.7; % fraction used for training the decoder
nCells = size(spikeCounts, 1);
nDims = size(stimFrames, 1);
stimLen = size(spikeCounts, 2);
totalFilterLen = filterLen*nCells+1;

% assign training and test bins
trainBins = 1:floor(stimLen*trainFrac);
testBins = (floor(stimLen*trainFrac)+1):stimLen;

trainLen = numel(trainBins)-filterLen;
testLen = numel(testBins)-filterLen;

trainStim = stimFrames(:, trainBins);

trainResp = spikeCounts(:, trainBins);
testResp = spikeCounts(:, testBins);

% reshape spike count matrices into response fragments of filter length
trainR = zeros(trainLen, totalFilterLen);
testR = zeros(testLen, totalFilterLen);
for k = 1:trainLen
	trainR(k, :) = [1, reshape(trainResp(:, k:k+filterLen-1)', 1, [])];
end
for k = 1:testLen
    testR(k, :) = [1, reshape(testResp(:, k:k+filterLen-1)', 1, [])];
end

% calculate filter and reconstruction
reconstrStimBins = testBins(1:testLen);
filter = (trainR'*trainR)^(-1)*(trainR'*trainStim(:, 1:trainLen)');
reconstrFrames = (testR*filter)';
end
