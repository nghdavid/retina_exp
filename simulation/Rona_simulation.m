%% Load data and get HMM intensity
clear all;
close all;
SamplingRate = 20000;
bin = 5;  BinningInterval = bin*10^-3;  %ms
load('E:\20190124\20190124_OU_tau=0.1_sort_unit1 .mat')
[b,a] = butter(2,50/20000,'low'); % set butter filter
a_data2 = filter(b,a,a_data(3,:));
isi = a_data2(TimeStamps(1)*20000:TimeStamps(length(TimeStamps))*20000);%figure;plot(isi);
inten = downsample(isi,SamplingRate*BinningInterval);
%% Load cSTA data
load('E:\20190124\sort\cSTA_1.mat')

channel_number = 24;
STA = cSTA(channel_number,1:201);
time = [-1000:5:0];
figure(10);plot(time,STA)
%% Temporal convolution
temporal =zeros(1,length(inten)-length(STA));

for t = 1:length(inten)-length(STA)
    temporal(t) = sum(inten(t:t+length(STA)-1).*STA);
end


TheStimuli = inten(length(STA)+1:end);
StimuSN=8; %number of stimulus states
nX=sort(TheStimuli);
abin=length(nX)/StimuSN;
intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
temp=0; isi2=[];
for jj=1:length(TheStimuli)
    temp=temp+1;
    isi2(temp) = find(TheStimuli(jj)<=intervals,1);
end
bin=BinningInterval*10^3; %ms
TheStimuli = temporal;
backward=ceil(15000/bin); 
forward=ceil(15000/bin);
BinningInterval =1;
nX=sort(TheStimuli);
abin=length(nX)/StimuSN;
intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
temp=0; Neurons=[];
for jj=1:length(TheStimuli)
    temp=temp+1;
    Neurons(temp) = find(TheStimuli(jj)<=intervals,1);
end

figure(2)
plot(1:length(isi2),isi2,'b');hold on
plot(1:length(isi2),Neurons,'r');hold off
set(gcf,'units','normalized','outerposition',[0 0 1 1])



dat=[];informationp=[];temp=backward+2;
for i=1:backward+1 %past(t<0)
    x = Neurons((i-1)+forward+1:length(Neurons)-backward+(i-1))';
    y = isi2(forward+1:length(isi2)-backward)';
    dat{i}=[x,y];
    norm=BinningInterval;

    [N,C]=hist3(dat{i},[max(Neurons)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
    px=sum(N,1)/sum(sum(N)); 
    py=sum(N,2)/sum(sum(N)); 
    pxy=N/sum(sum(N));
    temp2=[];
    for j=1:length(px)
        for k=1:length(py)
          temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
        end
    end
    temp=temp-1;
    informationp(temp)=nansum(temp2(:));

end  

dat=[];informationf=[];temp=0;sdat=[];
for i=1:forward
    x =Neurons(forward+1-i:length(Neurons)-backward-i)';
    y = isi2(forward+1:length(isi2)-backward)';
    dat{i}=[x,y];
    norm=BinningInterval;

    [N,C]=hist3(dat{i},[max(Neurons)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
    px=sum(N,1)/sum(sum(N)); 
    py=sum(N,2)/sum(sum(N)); 
    pxy=N/sum(sum(N));
    temp2=[];
    for j=1:length(px)
        for k=1:length(py)
            temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
        end
    end
    temp=temp+1;
    informationf(temp)=nansum(temp2(:));

end

figure(9)
information=[informationp informationf];
time=[-backward:forward];
plot(time,information);
xlabel('time shift')
ylabel('MI(bits)')
grid on;