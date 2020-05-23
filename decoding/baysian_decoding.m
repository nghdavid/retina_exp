close all;
clear all;
exp_folder = 'E:\20200418';
cd(exp_folder);
load(['predictive_channel\bright_bar.mat'])
cd ([exp_folder,'\sort_merge_spike\MI'])
all_file = subdir('*.mat');% change the type of the files which you want to select, subdir or dir.
n_file = length(all_file);
roi = [p_channel,np_channel];

for z =1:n_file %choose file
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
        [n,~] = hist(sorted_spikes{channel},BinningTime);  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        spikeCounts(nCells,:) = n;
    end

lag=0;
bin_pos = rescale(bin_pos,0,15);
numBin=length(bin_pos); %Number of datapoints
yTrain=bin_pos(lag+1:numBin)'; %Kinematic training data
sTrain=spikeCounts(:,1:numBin-lag)'; %Neural training data
sTrain=[sTrain ones(numBin-lag,1)]; %Add vector of ones for baseline
f=inv(sTrain'*sTrain)*sTrain'*yTrain; %Create linear filter

yCenter=[0.5:1:14.5]; %Discrete set of positions
numNeuron=size(spikeCounts,1); %Number of neurons
for n=1:numNeuron %Loop over all neurons
coeff(n,:)=glmfit(yTrain,sTrain(:,n),'poisson'); %Fit the encoding model
sFit(n,:)=exp(coeff(n,1)+coeff(n,2)*yCenter); %Predict firing rate
end


sTest=[spikeCounts(:,1:numBin-lag)' ones(numBin-lag,1)]; %Test neural data
yActual=bin_pos(lag+1:numBin); %Actual test kinematics
yFit= sTest*f; %Predicted test kinematics

for t=1:length(sTest) %Loop over all trials
frTemp=sTest(t,1:numNeuron); %Select spike counts for one time bin
prob=poisspdf(repmat(frTemp',1,15),sFit); %Prob. of each count given position
probSgivenY(t,:)=prod(prob); %Prob. of all counts given position
end

probY=histc(yTrain,[0:15]); %Histrogram of position values
probY=probY(1:15)/sum(probY(1:15)); %Convert to a probability
for t=1:length(sTest)
probYgivenS(t,:)=probSgivenY(t,:).*probY'; %P(YjS) is proportional to P(SjY)P(Y)
[temp maxInd]=max(probYgivenS(t,:)); %Find index of maximum
mapS(t)=yCenter(maxInd); %Find position with highest P(SjY)
end
% figure;
% plot(mapS);hold on
% plot(yTrain)
corrcoef(mapS,yTrain)


yDiff=diff(yTrain); %Compute error term
% figure;
% histogram(yDiff)
yDiffEdge=[-15.5:15.5]; %Define edges
% yDiffEdge=[-1.5:0.1:1.5]; %Define edges
%  yDiffEdge=[min(yDiff)*4:(max(yDiff)-min(yDiff))/30*4:max(yDiff)*4]; %Define edges
% yHist = histcounts(yDiff,31);
yHist=histc(yDiff,yDiffEdge); %Compute histogram
probDiffY=yHist(1:31)/sum(yHist); %Convert to probability
% bar([-15:15],probDiffY); %Plot probability

origin_hist = histcounts(bin_pos,15);
origin_hist=origin_hist/sum(origin_hist);
probTemp=conv(probDiffY,origin_hist); %Convolve last estimate with error term
%Trim out the middle
probPriorY(1,:)=probTemp(16:30)/sum(probTemp(16:30));

probPostY(1,:)=probPriorY(1,:).*probSgivenY(1,:); %Combine prior with neural data
probPostY(1,:)=probPostY(1,:)/sum(probPostY(1,:)); %Normalize probabilities
bayesY(1)=sum(probPostY(1,:).*yCenter); %Bayesian estimate of position

%Recursive Bayesian decoder
for t=2:length(sTest)
%Convolve last estimate with error term for prior
probTemp=conv(probPostY(t-1,:),probDiffY);
probPriorY(t,:)=probTemp(16:30)/sum(probTemp(16:30));
%Combine prior with neural data for the posterior
probPostY(t,:)=probPriorY(t,:).*probSgivenY(t,:);
probPostY(t,:)=probPostY(t,:)/sum(probPostY(t,:));
%Convert distribution to a single estimate of position
bayesY(t)=sum(probPostY(t,:).*yCenter);
end
% figure;
% plot(bayesY);hold on
% plot(yTrain)
% corrcoef(bayesY,yTrain)
clear bayesY mapS
end