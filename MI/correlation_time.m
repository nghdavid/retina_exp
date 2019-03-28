%% Code that calculate correlation time
%auto mutual information for stimulus
T=7*60; %second
TheStimuli = bin_pos; 
Neurons =  TheStimuli; 

%% Binning
fps=1/60;
multiple_value=1;
DataTime=T;
BinningInterval = DataTime/length(TheStimuli); %s
bin=BinningInterval*10^3; %ms

%% cut Stimulus State _ equal probability of each state (different interval range)
StimuSN=30; %number of stimulus states
nX=sort(TheStimuli);
abin=length(nX)/StimuSN;
intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
temp=0; isi2=[];
for jj=1:length(TheStimuli)
    temp=temp+1;
    isi2(temp) = find(TheStimuli(jj)<=intervals,1);
end 
% figure; hist(isi2,StimuSN);
% title(name);


%% Predictive information
backward=ceil(3000/bin); forward=ceil(3000/bin);
information = MIfunc(Neurons,isi2,BinningInterval,backward,forward);
norm = BinningInterval; %bits/second


   
%% shuffle MI
sNeurons=[];
r=randperm(length(Neurons));
for j=1:length(r)            
    sNeurons(j)=Neurons(r(j));
end
Neurons_shuffle=sNeurons;

information_shuffle = MIfunc(Neurons_shuffle,isi2,BinningInterval,backward,forward);    

    
t=[-backward*bin:bin:forward*bin];

information = information - mean(information_shuffle);
peak_MI = max(information);
half_MI = peak_MI/2;
time = 0.1;
while true
    time = time + 1;
    half_time = t(find(abs(information-half_MI)<time));
    if ~isempty(half_time)
       break; 
    end
end

half_time