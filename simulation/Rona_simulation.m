%% Load data and get HMM intensity
clear all;
close all;
exp_folder = 'E:\20190124';
cd(exp_folder)
SamplingRate = 20000;
bin = 10;  BinningInterval = bin*10^-3;  %s
HMM_different_G = [2.5,5,10,30];
HMM_former_name = '20190124_HMM_G';
HMM_post_name = '_sort_unit1';
OU_different_G = [0.1,0.6,1,1.8];
OU_former_name = '20190124_OU_tau=';
OU_post_name = '_sort_unit1';
[b,a] = butter(2,50/20000,'low'); % set butter filter
OU_or_Not = 0;
%% Load cSTA data
load('sort\cSTA_1.mat')

channel_number = 24;
STA = cSTA(channel_number,1:201);
t = [-1000:5:0];
figure(10);plot(t,STA)
if OU_or_Not
    different_G = OU_different_G;
else
    different_G = HMM_different_G;
end

%% Binning spike

% for G = different_G
G = 2.5;
%clearvars -except SamplingRate bin BinningInterval HMM_different_G G exp_folder HMM_former_name HMM_post_name a b STA time OU_or_Not
close all
if OU_or_Not
    load([OU_former_name,num2str(G),OU_post_name,'.mat']);
else
    load([HMM_former_name,num2str(G),HMM_post_name,'.mat']);
end
BinningTime = [TimeStamps(1) : BinningInterval : TimeStamps(end)];
[BinningSpike,~] = hist(Spikes{channel_number},BinningTime) ;  
a_data2 = filter(b,a,a_data(3,:));
isi = a_data2(TimeStamps(1)*20000:TimeStamps(length(TimeStamps))*20000);%figure;plot(isi);
inten = downsample(isi,SamplingRate*BinningInterval);

%% Temporal convolution
temporal =zeros(1,length(inten)-length(STA));

for t = 1:length(inten)-length(STA)
    temporal(t) = sum(inten(t:t+length(STA)-1).*STA);
end

norm_temporal = (temporal*2/(max(temporal)-min(temporal)));
norm_temporal = norm_temporal - min(norm_temporal)-1;


%% Nonlinear part
figure(3)
norm_temporal = norm_temporal.*-1;
plot(norm_temporal);hold on
%cumulative normal distribution with ~intuitivie parameters:
%alpha is maximum conductance
%beta is sensitivity of NL to genSignal
%gamma determines where the threshold/shoulder is
%epsilon shifts the whole thing up or down
%takes as input weighted sum (i.e. (aX + y)), where a is scale factor for x
epsilon = 0;
alpha = 4;
beta = 3;
a =1;
S =0;
gamma = -0.8;
C = -5:0.1:5;
res=alpha*normcdf(beta.*(a.*norm_temporal + S) + gamma,0,1)+epsilon;
%res=alpha*normcdf(beta.*(a.*C + S) + gamma,0,1)+epsilon;
%plot(C,res)
%% Calculate MI
TheStimuli =inten(length(STA)+1:end);
StimuSN=30; %number of stimulus states
nX=sort(TheStimuli);
abin=length(nX)/StimuSN;
intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
temp=0; isi2=[];
for jj=1:length(TheStimuli)
    temp=temp+1;
    isi2(temp) = find(TheStimuli(jj)<=intervals,1);
end

TheStimuli = norm_temporal;
StimuSN=alpha+1; %number of stimulus states
backward=ceil(15000/bin); 
forward=ceil(15000/bin);
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
information=[informationp informationf];
mkdir MI

figure(9)
information=[informationp informationf];
time=[-backward:forward];
plot(time,information);
xlabel('time shift')
ylabel('MI(bits)')
grid on;
set(gcf,'units','normalized','outerposition',[0 0 1 1])
fig =gcf;
fig.PaperPositionMode = 'auto';
fig.InvertHardcopy = 'off';
% if OU_or_Not
%     save([exp_folder,'\MI\',OU_former_name,num2str(G),OU_post_name,'.mat'],'time','information')
%     saveas(gcf,[exp_folder,'\MI\',OU_former_name,num2str(G),OU_post_name,'.tif'])
%     saveas(gcf,[exp_folder,'\MI\',OU_former_name,num2str(G),OU_post_name,'.fig'])
% else
%     save([exp_folder,'\MI\',HMM_former_name,num2str(G),HMM_post_name,'.mat'],'time','information')
%     saveas(gcf,[exp_folder,'\MI\',HMM_former_name,num2str(G),HMM_post_name,'.tif'])
%     saveas(gcf,[exp_folder,'\MI\',HMM_former_name,num2str(G),HMM_post_name,'.fig'])
% end
%end