% Analysis onoff experiment, by Rona
clear all
close all
clc

try
cd('D:\Leo\0807exp\data') ; % the folder of the files
catch
cd('') ; % the folder of the files    
end
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 
%%%%%%%%%%%%%%   user's setting  %%%%%%%%%%%%%%%%%%%%%%
BinningInterval=0.005;
SamplingRate=20000;
roi=[3]; %region of interest
trst=1;trnum=20; %sweep trail from trst to trend
f=10;p=100;

for m = 25
    clearvars -except all_file n_file m BinningInterval SamplingRate chst1 chend1 chst2 chend2 trst trnum f p ch roi
    file = all_file(m).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([filename]);

%     name(name=='_')='-';
 
%     load(['D:\rona\Google Drive\20160427\diode.mat']);
%     load(['C:\Users\HydroMatlab\Google ¶³ºÝµwºÐ\20160429\diode\','diode_',filename]);
%%%%%%%%%%%%%%%%%%%%%%  TimeStamps  %%%%%%%%%%%%%%%%%%%
    a_data2 = a_data(2,:);
%     a_data2 = a_data2 - a_data2(1);
%     a_data = diff(a_data);
    [~,locs]=findpeaks(diff(a_data2),'MINPEAKHEIGHT',5*std(diff(a_data2)));
     TimeStamps = (locs)/SamplingRate;
%% Spike process
%     xls=xlsread([name,'.xls']);
%     ss = [29,18,39,53,4,31,59,5,23,38,13,15,...
%         42,37,21,17,55,35,28,9,47,54,10,34,...
%         60,11,32,43,12,25,57,20,16,56,38,22,...
%         8,48,46,30,2,40,44,3,33,52,19,24,...
%         51,6,26,50,14,7,49,36,27,1,41,45];
%     Spikes=cell(1,60);
%     for j = 1:max(xls(:,1))
%             temp = 0;
%         for i = 1:length(xls)
%             if xls(i,1) == j
%                 temp = temp+1;
%                 Spikes{ss(j)}(1,temp) = xls(i,2);
%             end
%         end
%     end    
%%%%%%%%%%%%%%%%%%%%%%%%%%  Binning  %%%%%%%%%%%%%%%%%%%%%%%%
% TimeStamps=TimeStamps-2;
    TimeStamps2=TimeStamps(1:4:length(TimeStamps)); 
    if length(TimeStamps2)<=(trst+trnum-1)
        trnum = length(TimeStamps2)-trst+1;
    end
    trend=trst+trnum-1;
 
    DataTime = (TimeStamps2(2) - TimeStamps2(1));

    cut_spikes = seperate_trials(Spikes,TimeStamps2(trst:trend));    

    BinningTime = [ 0 : BinningInterval : DataTime];
    
        %%%%%% a3 %%%%%%%%%
    x1 = 0:BinningInterval:DataTime-BinningInterval;
    y1=zeros(1,length(x1)); 
    y1(1:2/BinningInterval)=0.18; %(unit:nA)
    y1(4/BinningInterval:6/BinningInterval)=0.18; %(unit:nA)
    y1(8/BinningInterval:10/BinningInterval)=0.18; %(unit:nA)
        
    y1=a_data(1,TimeStamps(1)*20000:TimeStamps(4)*20000);
    x1=1/20000:1/20000:length(y1)/20000;
    %%%% pick diode's timestamps %%%%%% 
%     [~,locs_a2]=findpeaks(diff(a2),'MINPEAKHEIGHT',5*std(diff(a2)));
%     analog_loc = (locs_a2)/1000; 
%     TimeStamps_a2 = analog_loc;
%    
%     [b,a] = butter(2,10/1000,'low'); % set butter filter
%     callumin_filter = filter(b,a,callumin);
%     
%     x1 = 0.004:0.001:DataTime;
%     y1=callumin_filter(TimeStamps_a2(1)*1000:TimeStamps_a2(4)*1000)';    
    
%%%%%%%%%%%%%%%%%%%%%%%%%  Plot Different Trials   %%%%%%%%%%%%%%%%% 
%     if length(TimeStamps2)<=18
%         sweepend=length(TimeStamps2);
%     else
%         sweepend=24;
%     end
    sweepend=trend;
    figure(2);hold on
    set(gcf,'position',[150,30,1024,900])
    h = subplot(sweepend+1,1,1);
    
    for sweepindex=1:sweepend-1
        TimeStampsSweep=TimeStamps2(sweepindex:sweepindex+1); % forcus on which trails 
        cut_spikes = seperate_trials(Spikes,TimeStampsSweep);      
        for i = 1:60
            [n,xout] = hist(cut_spikes{i},BinningTime) ;
            BinningSpike(sweepindex,i,:) = n ;
        end
        subplot(sweepend+1,1,sweepindex);hold on
%         plot(BinningTime,squeeze(sum(BinningSpike(sweepindex,ch,:),2)));
        plot(BinningTime,squeeze(sum(BinningSpike(sweepindex,roi,:),2)));
    end     
        
    subplot(sweepend+1,1,sweepindex+1);
    plot(x1,y1,'r');
    samexaxis('abc','xmt','on','ytac','join','yld',1) % function need ''parseArgs'' function, from matlab center
%     ylim([min(y1)-0.01,max(y1)+0.01]);
    set(get(h,'title'),'string',[name,'  ch',num2str(roi)]);
    
    saveas(gcf,[name,'_trials.jpg'],'jpg');
    saveas(gcf,[name,'_trials.fig'],'fig');  

 %%%%%%%%%%%%%%%%% raster plot %%%%%%%%%%%%%%%%%%%
    BinningSpike2 = squeeze(sum(BinningSpike(trst:trend-1,:,:),1));
    figure(1);hold on
    imagesc(BinningTime,[1:60],BinningSpike2);
    title([name,'(sum over ',sprintf('%.0f',length(TimeStamps2)),' trails) ']);  
    xlabel('t(s)');ylabel('channel');
    colorbar;
    saveas(gcf,[name,'_raster.jpg'],'jpg')
    saveas(gcf,[name,'_raster.fig'],'fig')    
     
%%%%%%%%%%%%%  get peaks  %%%%%%%%%%%%%%%%%%%%%   
%     SB1=sum(BinningSpike(chst1:chend1,:),1)/trnum;  
%     [spks,slocs]=findpeaks(SB1,'minpeakdistance',floor(DataTime/BinningInterval/f),'MINPEAKHEIGHT',p);    
% 
%     if isempty(slocs)
%         slocstime=NaN;
%     end
%     slocstime=(slocs-1)*BinningInterval; 
     
%%%%%%%%%%%%%%%%%%%%%%%%%  Plot histogram   %%%%%%%%%%%%%%%%%        
    figure(3)
    subplot(6,1,2:5); 
    plot(BinningTime,sum(BinningSpike2(roi,:),1)/length(roi)); 
%     title([name,'   Ch',num2str(chst1),' to ',num2str(chend1),sprintf('\n'),' PeakTime(s)=',sprintf('%8.3f',slocstime),sprintf('\n')]);
%     ylabel('firing rate per 5ms');
    subplot(6,1,6);
    plot(x1,y1,'r');
    samexaxis('abc','xmt','on','ytac','join','yld',1) % function need ''parseArgs'' function, from matlab center
    xlabel('t(s)');
   
    saveas(gcf,[name,'_hist.jpg'],'jpg')
    saveas(gcf,[name,'_hist.fig'],'fig')

%     save(filename,'x','y','chst1','chend1','slocstime', '-append'); % save data into original dat
%     catch
%         [msgstr,msgerr] = lasterr;
%         disp([msgstr,msgerr])
%     end
end