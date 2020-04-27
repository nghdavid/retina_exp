function [totalInfo, freqBins, infoDensity, stimDensity, reconstrDensity, errorDensity] = calcMutualInformation(stimFrames, reconstrFrames, filterLen, tbin)
% calcMutualInformation - calculate mutual information between stimulus and reconstruction
% adopted from Warland, Reinagel & Meister, 1997, "Decoding visual information from a population of retinal ganglion cells"
%   stimFrames: 2 x T array of motion steps in x- and y-direction
%   reconstrFrames: array of reconstructed motion steps of same size as 'stimFrames'
%   filterLen: filter length in bins
%   tbin: size of a time bin in seconds

% Determine stimulus, reconstruction and reconstruction error in frequency domain
% by calculating the Fourier transform of segments of length 'filterLen'
nDims = size(stimFrames, 1);
nSegments = floor(size(stimFrames, 2)/filterLen);
NFFT = filterLen;

stimFFT = zeros(nDims, nSegments, NFFT);
reconstrFFT = zeros(nDims, nSegments, NFFT);
errorFFT = zeros(nDims, nSegments, NFFT);
for k = 1:nSegments
    stimFFT(:, k, :) = fft(stimFrames(:, (k-1)*filterLen+1:k*filterLen), NFFT, 2);
    reconstrFFT(:, k, :) = fft(reconstrFrames(:, (k-1)*filterLen+1:k*filterLen), NFFT, 2);
    errorFFT(:, k, :) = fft(reconstrFrames(:, (k-1)*filterLen+1:k*filterLen) - stimFrames(:, (k-1)*filterLen+1:k*filterLen), NFFT, 2);
end

% take average across segments
stimDensity = squeeze(mean(power(abs(stimFFT(:, :, 1:NFFT/2+1))/NFFT, 2), 2));
reconstrDensity = squeeze(mean(power(abs(reconstrFFT(:, :, 1:NFFT/2+1))/NFFT, 2), 2));
errorDensity = squeeze(mean(power(abs(errorFFT(:, :, 1:NFFT/2+1))/NFFT, 2), 2));

% one-sided power spectra
stimDensity(:, 2:end-1) = 2*stimDensity(:, 2:end-1);
reconstrDensity(:, 2:end-1) = 2*reconstrDensity(:, 2:end-1);
errorDensity(:, 2:end-1) = 2*errorDensity(:, 2:end-1);

infoDensity = log2(stimDensity./errorDensity);
totalInfo = sum(infoDensity(:))/(NFFT*tbin);
freqBins = (0:(NFFT/2))/(NFFT*tbin);
end
