function [NLrates, NLbins] = getNL(spikeCounts, stimFrames, filter, tbin, nBins)
% getNL - estimate nonlinearity of LN model, _NLrates_ are in Hz
% see also Chichilnisky, 2001, "A simple white noise analysis of neuronal light responses"
%   spikeCounts: 1 x T array of spike counts
%   stimFrames: 2 x T array of motion steps in x- and y-direction, or 1 x T array for only one direction
%   filter: 1 x 2L array of concatenated motion filters of length L in x- and y-direction, or 1 x L array for only one direction
%	tbin: time bin size in seconds
%	nBins: number of nonlinearity bins, NLrates 

if nargin < 4
	tbin = .03;
end
if nargin < 5
	nBins = 15;
end
nDims = size(stimFrames, 1);
stimLen = size(stimFrames, 2);
totalFilterLen = size(filter, 2);
filterLen = totalFilterLen/nDims;
spikeCounts = spikeCounts(filterLen:end);

effectiveStimLen = stimLen - filterLen;
nBinValues = ceil(effectiveStimLen/nBins);

% reshape stimulus into matrix of stimulus fragments of size 'stimFragmentLen'
stimMatrix = zeros(effectiveStimLen, totalFilterLen);
for k = 1:effectiveStimLen
    stimMatrix(k, :) = reshape(stimFrames(:, k:k+filterLen-1)', [], 1)';
end

filterNorm = sqrt(sum(filter.*filter));
stimFiltered = stimMatrix*filter'/filterNorm;
[stimFiltSorted, sortIdx] = sort(stimFiltered);
NLbins = zeros(1, nBins);
NLrates = zeros(1, nBins);
NLbinRanges = [1:nBinValues:effectiveStimLen, effectiveStimLen];
for k = 1:nBins
	NLbins(k) = mean(stimFiltSorted(NLbinRanges(k):NLbinRanges(k+1)));
	NLrates(k) = mean(spikeCounts(sortIdx(NLbinRanges(k):NLbinRanges(k+1))))/tbin;
end
end
