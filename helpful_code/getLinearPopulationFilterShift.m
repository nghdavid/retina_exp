function [reconstrFrames,originalFrames,filter] = getLinearPopulationFilterShift(spikeCounts, stimFrames, filterLen)
% getLinearPopulationFilterShift - get reconstruction from population
% responses with shifting 
% adopted from Warland, Reinagel & Meister, 1997, "Decoding visual information from a population of retinal ganglion cells"
%   spikeCounts: N x T array of spike counts of N cells
%   stimFrames: 2 x T array of motion steps in x- and y-direction
%   filterLen: filter length in bins

trainFrac = 1; % fraction used for training the decoder
nCells = size(spikeCounts,1);
nDims = size(stimFrames,1);
BinningInterval =1/60;
bin=BinningInterval*10^3; %ms
backward=ceil(1000/bin);
forward=ceil(1500/bin);
short_stimFrames = stimFrames(forward+1:length(stimFrames)-backward);
stimLen = length(short_stimFrames);%Length of stimulus

% assign training and test bins
trainBins = 1:floor(stimLen*trainFrac);
trainLen = stimLen-filterLen;
time=[-backward*bin:bin:forward*bin];
total_trainR = ones(trainLen,1);

%% Find best trainR by shifting two series and merge them into total_trainR

for n = 1:nCells
    cc_b = zeros(1,backward+1);%Record past cross correlation
    cc_f = zeros(1,forward);%Record future cross correlation
    
    % Past part
    for i=1:backward+1
        spike = spikeCounts(n,(i-1)+forward+1:length(spikeCounts)-backward+(i-1));
        trainR = zeros(trainLen, filterLen+1);
        for k = 1:trainLen
            trainR(k, :) = [1, spike(:, k:k+filterLen-1)];
        end
        filter = (trainR'*trainR)^(-1)*(trainR'*short_stimFrames(1:trainLen)');
        reconstrFrames = (trainR*filter)';
        cc_b(i) = mean((reconstrFrames-mean(reconstrFrames)).*(short_stimFrames(1:trainLen)-mean(short_stimFrames(1:trainLen)))/(std(short_stimFrames(1:trainLen))*std(reconstrFrames)));
    end
    % Future part
    for i=1:forward
        spike = spikeCounts(n,(forward+1-i:length(spikeCounts)-backward-i));
        trainR = zeros(trainLen, filterLen+1);
        for k = 1:trainLen
            trainR(k, :) = [1, spike(:, k:k+filterLen-1)];
        end
        filter = (trainR'*trainR)^(-1)*(trainR'*short_stimFrames(1:trainLen)');
        reconstrFrames = (trainR*filter)';
        cc_f(i) = mean((reconstrFrames-mean(reconstrFrames)).*(short_stimFrames(1:trainLen)-mean(short_stimFrames(1:trainLen)))/(std(short_stimFrames(1:trainLen))*std(reconstrFrames)));
    end
%      figure
%      plot(time,[flip(cc_b) cc_f])

    % Campare past and future
    if max(cc_b) > max(cc_f)
        disp('past')
        max(cc_b)
        i=find(cc_b==max(cc_b));
        spike = spikeCounts(n,(i-1)+forward+1:length(spikeCounts)-backward+(i-1));
    else
        disp('future')
        max(cc_f)
        i=find(cc_f==max(cc_f));
        spike = spikeCounts(n,(forward+1-i:length(spikeCounts)-backward-i));
    end
    trainR = zeros(trainLen, filterLen);
    for k = 1:trainLen
        trainR(k, :) = [spike(:, k:k+filterLen-1)];
    end
    total_trainR = [total_trainR,trainR];%Merge all trainR
end

% Calculate total filter and reconstruct them
filter = (total_trainR'*total_trainR)^(-1)*(total_trainR'*short_stimFrames(1:trainLen)');
reconstrFrames = (total_trainR*filter)';
originalFrames = short_stimFrames(1:trainLen);
end