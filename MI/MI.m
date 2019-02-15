clear all
%close all
cd('D:\Yiko\Files for Thesis\04122018\merge sortch offch8 OU') ;  % the folder of the files
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
n_file = length(all_file) ; 
cc=hsv(11); %for color chosen
ch_inf=[];
ch_inf2=[];


count=1;
for channelnumber=[58]
 h3=figure;
% title('HMM RL G05 channel36  MI(a)+MI(b)')
for z =1:n_file
file = all_file(z).name ;
[pathstr, name, ext] = fileparts(file);
directory = [pathstr,'\'];
filename = [name,ext];
load([filename]);
name=[name];
z
name

% put your stimulus here!!
TheStimuli=bin_pos;  %recalculated bar position

% velocity
% HMM
% for i=1:length(newXarray)-1
%     v(i)=(newXarray(i+1)-newXarray(i))/17; %17ms
% end
% TheStimuli= v;

%OU
% for i=1:length(new_y)-1
%     v(i)=(new_y(i+1)-new_y(i))/17; %17ms
% end
% TheStimuli= v; 


% Binning
bin=BinningInterval*10^3; %ms
BinningTime =diode_BT;


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
%figure; hist(isi2,StimuSN);
% title(name);

%% BinningSpike
BinningSpike = zeros(60,length(BinningTime));
for i = 1:60  % i is the channel number
    [n,~] = hist(yk_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
    BinningSpike(i,:) = n ;
end

%% Predictive information
backward=ceil(15000/bin); 
forward=ceil(15000/bin);
n = channelnumber;
Neurons = BinningSpike(n,:);  %for single channel
%Neurons = sum(BinningSpike(1:60,:));  %calculate population MI

% Neurons=isi2;

dat=[];informationp=[];temp=backward+2;
    for i=1:backward+1 %past(t<0)
        x=Neurons((i-1)+forward+1:length(Neurons)-backward+(i-1))';
        y=isi2(forward+1:length(isi2)-backward)';
        dat{i}=[x,y];
%       norm = sum(x)/ length(x); %normalize: bits/spike
        norm = BinningInterval; %bits/second

        [N,C]=hist3(dat{i},[max(Neurons)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
        px=sum(N,1)/sum(sum(N)); % x:stim
        py=sum(N,2)/sum(sum(N)); % y:word
        pxy=N/sum(sum(N));
        temp2=[];
        for j=1:length(px)
            for k=1:length(py)
              temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
            end
        end
        temp=temp-1;
        informationp(temp)=nansum(temp2(:));
        corrp(temp)=sum(x.*y);
    end  

    dat=[];informationf=[];temp=0;sdat=[];
    for i=1:forward
        x = Neurons(forward+1-i:length(Neurons)-backward-i)';
        y = isi2(forward+1:length(isi2)-backward)';
        dat{i}=[x,y];
%       norm = sum(x)/ length(x); %normalize: bits/spike
        norm = BinningInterval; %bits/second

        [N,C]=hist3(dat{i},[max(Neurons)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
        px=sum(N,1)/sum(sum(N)); % x:stim
        py=sum(N,2)/sum(sum(N)); % y:word
        pxy=N/sum(sum(N));
        temp2=[];
        for j=1:length(px)
            for k=1:length(py)
                temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
            end
        end
        temp=temp+1;
        informationf(temp)=nansum(temp2(:)); 
        corrf(temp)=sum(x.*y);
    end
    
information=[informationp informationf];
   
%% shuffle MI
sNeurons=[];
r=randperm(length(Neurons));
for j=1:length(r)            
    sNeurons(j)=Neurons(r(j));
end
Neurons_shuffle=sNeurons;

dat=[];information_shuffle_p=[];temp=backward+2;
    for i=1:backward+1 %past(t<0)
        x=Neurons_shuffle((i-1)+forward+1:length(Neurons_shuffle)-backward+(i-1))';
        y=isi2(forward+1:length(isi2)-backward)';
        dat{i}=[x,y];
%       norm = sum(x)/ length(x); %normalize
        norm = BinningInterval;
 
        [N,C]=hist3(dat{i},[max(Neurons_shuffle)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
        px=sum(N,1)/sum(sum(N)); % x:stim
        py=sum(N,2)/sum(sum(N)); % y:word
        pxy=N/sum(sum(N));
        temp2=[];
        for j=1:length(px)
            for k=1:length(py)
              temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
            end
        end
        temp=temp-1;
        information_shuffle_p(temp)=nansum(temp2(:));
        corrp(temp)=sum(x.*y);
    end  

    dat=[];information_shuffle_f=[];temp=0;sdat=[];
    for i=1:forward
        x = Neurons_shuffle(forward+1-i:length(Neurons_shuffle)-backward-i)';
        y = isi2(forward+1:length(isi2)-backward)';
        dat{i}=[x,y];
%       norm = sum(x)/ length(x); %normalize
        norm = BinningInterval;

        [N,C]=hist3(dat{i},[max(Neurons_shuffle)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
        px=sum(N,1)/sum(sum(N)); % x:stim
        py=sum(N,2)/sum(sum(N)); % y:word
        pxy=N/sum(sum(N));
        temp2=[];
        for j=1:length(px)
            for k=1:length(py)
                temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
            end
        end
        temp=temp+1;
        information_shuffle_f(temp)=nansum(temp2(:)); 
        corrf(temp)=sum(x.*y);
    end
    
information_shuffle=[information_shuffle_p, information_shuffle_f];


time=[-backward*bin:bin:forward*bin];
plot(time,information-information_shuffle); hold on; %,'color',cc(z,:));hold on
% plot(time,smooth(information-information_shuffle)); hold on; %,'color',cc(z,:));hold on
% plot(time,information); hold on; %,'color',cc(z,:));hold on
xlabel('delta t (ms)');ylabel('MI (bits/second)( minus shuffled)');
set(gca,'fontsize',12); hold on
% % plot(time,information-information_shuffle,'color',cc(z,:),'LineWidth',1.5,'DisplayName',sprintf(name)); hold on
% plot(time,information,'color',cc(z,:),'LineWidth',1.5,'DisplayName',sprintf(name)); hold on
% set(h3, 'Position', [1500 250 630 630]);

legend('-DynamicLegend');
legend('show')
lgd = legend('G04','G076','G19');

xlim([ -backward*bin backward*bin])
ylim([0 inf])
title([name,' channel ',num2str(channelnumber)]) 

end
count=count+1;
% name='sort1 unit1 0412 HMM 4dir G05';
% saveas(gcf,[name,' channel ',num2str(channelnumber),' longer time'],'fig');

end





