function filter = getFilter(spikeCounts, stimFrames, filterLen)
% getFilter - get linear filter (spike-triggered average)
% see also Chichilnisky, 2001, "A simple white noise analysis of neuronal light responses"
%   spikeCounts: 1 x T array of spike counts
%   stimFrames: 2 x T array of motion steps in x- and y-direction, or 1 x T array for only one direction
%   filterLen: number of filter bins L

nDims = size(stimFrames, 1);
stimLen = size(stimFrames, 2);
totalFilterLen = nDims*filterLen;

effectiveStimLen = stimLen - filterLen;

% reshape stimulus into matrix of stimulus fragments of size 'stimFragmentLen'
stimMatrix = zeros(effectiveStimLen, totalFilterLen);
for k = 1:effectiveStimLen
    stimMatrix(k, :) = reshape(stimFrames(:, k:k+filterLen-1)', [], 1)';
end
filter = (spikeCounts(filterLen+1:end)*stimMatrix)/sum(spikeCounts);
end
