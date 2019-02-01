%load mat file first
clear all
close all
%load ideal stimulation array

G=2;
Dirti='RL';

%% load bar position worksapce
% load('D:\Yiko\HMM video frame\workspace_HMM RL G5 5min Q85')
% load('\\192.168.0.100\Experiment\Retina\YiKo\video workspace Br50\workspace_OU UD G5.7 5min Q85')
load(['/Users/nghdavid/Desktop/Yiko_code/video workspace Bri25/workspace_HMM ',Dirti, ' G',num2str(G),' 5min Q85 Br045.mat']) %load workspace
%load(['/Users/nghdavid/Desktop/Yiko_code/video workspace Bri25/workspace_OU ',Dirti, ' G',num2str(G),' 10min Q85 Br045.mat']) %load workspace
clearvars -except  newYarray newXarray G_HMM a_data Spikes Infos name new_x new_y G Dirti

% name=['0426 HMM  ',Dirti,' G0',num2str(G),' 7min'];
name=['0704 HMM  ',Dirti,' G',num2str(G),' 5min'];
%name=['test0723'];
% name=['0423 PTB HMM  ',Dirti,' G0',num2str(G),' 5min Br50'];

%% load (sorted) spikes file
% load('D:\Yiko\Files for Thesis\04122018\sortch 0412OU_UD_G19_5min_offch8')
%  load(['\\192.168.0.100\Experiment\Retina\YiKo\Experiment\04142018\New folder2\0414pos2_HMM_RL_G0',num2str(G)])  %load mat file
load('/Users/nghdavid/Desktop/data/0704/0704_HMM_RL_G02_5min.mat')

% a=xlsread('/Users/nghdavid/Desktop/data/0704/0704_HMM_RL_G05_5min_spike.xlsx');
% b=[];
% Spikes={};
% for j = 1:60
%     temp = 0;
%     for i = 1:length(a)
%         if a(i,1) == j
%             temp = temp+1;
%             b(temp,j)=a(i,3);
%             Spikes{j}(1,temp) = a(i,3);
%         end
%     end
% end


%%
lumin=[];
lumin=a_data(3,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
figure;plot(lumin);

Samplingrate=20000; %fps of diode in A3
idealStimuli=[];
% idealStimuli=new_x;
idealStimuli=newXarray;


%setting for parameters
start_lum=3.442*10^4; %81*10^4;
plateau_n=80;  %least number of point for plateau
thre01=3.445*10^4; %cut from low to middle state
thre02=3.47*10^4; %cut from middle to high state

%if has brief pump before the video start: set a value for that
lumin(1:200000)=3.43*10^4;
%  %lumin(6300000:end)=3.47*10^4;
% figure;plot(lumin);

%find stimulation period
diode_start=find(lumin>=start_lum,1);
tempp=find(lumin<=start_lum);
diode_end=tempp(end);

% plot
figure;plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
hold on;plot(diode_end,lumin(diode_end),'r*');

% figure;plot(lumin(5*Samplingrate:7*Samplingrate)); hold on; plot(diode_start-5*Samplingrate,lumin(diode_start),'r*')
% figure;plot(lumin(length(lumin)-25*Samplingrate:length(lumin)-23.7*Samplingrate)); hold on; plot(diode_end-(length(lumin)-25*Samplingrate),lumin(diode_end),'r*')

%% Cut the spike time from the start and final diode timing
TimeStamps=zeros(1,2);
TimeStamps(1,1)=diode_start/Samplingrate;
TimeStamps(1,2)=diode_end/Samplingrate;
TimeStamps

yk_spikes=[];
for j = 1:length(Spikes)    %running through each channel
    ss = Spikes{j};
    ss(ss<TimeStamps(1,1)) = [];  %delete the spikes before TimeStamps(1)
    ss(ss>TimeStamps(1,2))=[];
    
    for i = 1:length(ss)
        ss(i) = ss(i)-TimeStamps(1,1);
    end
    yk_spikes{j} = ss;
end


% delete before and after of the lumin series
off_ends_lumin=[];
off_ends_lumin=lumin;
off_ends_lumin(1:diode_start-1)=[]; %clear numbers before the diode_start
off_ends_lumin(diode_end+1-(diode_start-1):end)=[]; %clear numbers after the diode_end

%time of stimulation from diode measurement
%totalTime=vpa(length(off_ends_lumin)/ Samplingrate,30);
totalTime=length(off_ends_lumin)/ Samplingrate;
totalTime

% assign state number 1,2,3 to three luminance state
% figure;hist(lumin,10)
lumin_state=[];
smoothed_lumin= smooth(off_ends_lumin) ;
for jj=1:length(off_ends_lumin)
    if smoothed_lumin(jj) > thre02
        lumin_state(jj)=3;  %highest diode value: state 3
    elseif   smoothed_lumin(jj) > thre01 &&  smoothed_lumin(jj)  < thre02
        lumin_state(jj)=2; %middle diode value: state 2
    else
        lumin_state(jj)=1; %lowest diode value: state 1
    end
end
%make the first elements = 3, since when the luminance raises up, the first  element is state 3
dd=find(lumin_state==3,1);
lumin_state(1:dd)=3;


figure; plot(off_ends_lumin)
den=0.9*(max(off_ends_lumin)-min(off_ends_lumin))/(max(lumin_state)-min(lumin_state));
lumin_state02=lumin_state*den;
hold on; plot(lumin_state02-mean(lumin_state02)+mean(off_ends_lumin)-0.2)

% find delay frames' timing
frame_time=[];  changept=[]; count=1; pt_delay=[];
changept=find(diff(lumin_state)~=0); %find the point that its state is about to change
for hh=1:length(changept)-1
    frame_time(count)=length(lumin_state(changept(hh)+1:changept(hh+1)))/Samplingrate; %the time period for each plateau
    count=count+1;
end
pt_delay=changept(find(frame_time>0.020));  %if the time of a plateau is too long, it meas there is a problemed frame

figure;plot(off_ends_lumin); hold on;
plot(pt_delay,off_ends_lumin(pt_delay),'g*')

% for i=1:length(pt_delay)
%     figure;plot([length(off_ends_lumin(1:pt_delay(i)-Samplingrate/4)):length(off_ends_lumin(1:pt_delay(i)+Samplingrate/4))] , off_ends_lumin(pt_delay(i)-Samplingrate/4 :pt_delay(i)+Samplingrate/4)); hold on;
%     plot(pt_delay(i),off_ends_lumin(pt_delay(i)),'g*')
% end

% find transition number of point - not finished
% qwq=[];
% lumin3=diff(off_ends_lumin); lumin3(length(lumin3)+1)=0;
% qwq=find(off_ends_lumin>thre01 & off_ends_lumin<thre02 & lumin3>0);
% figure;plot(off_ends_lumin(1:10*Samplingrate));
% hold on; plot(qwq(1:50000),off_ends_lumin(qwq(1:50000)),'*')

% assign transitioning points(ex: the points from state 2 to state 3) to other states
for hh=1:length(changept)-1
    if length(lumin_state(changept(hh)+1:changept(hh+1)))<plateau_n  %to determine whether it's transitioning point
        lumin_state(changept(hh)+1:changept(hh+1))=lumin_state(changept(hh+1)+1);  %assigning the new state to transitioning point
    end
end

% % plot
% figure; plot(off_ends_lumin)
% recal=0.8*lumin_state*(max(off_ends_lumin)-min(off_ends_lumin))/(max(lumin_state)-min(lumin_state));
% recal02=recal-mean(recal) +mean(off_ends_lumin)-0.02;
% % hold on; plot(recal)
% hold on; plot(recal02)



% for i=1:length(pt_delay)
%     figure;plot([length(off_ends_lumin(1:pt_delay(i)-Samplingrate/4)):length(off_ends_lumin(1:pt_delay(i)+Samplingrate/4))] , off_ends_lumin(pt_delay(i)-Samplingrate/4 :pt_delay(i)+Samplingrate/4));
%     hold on; plot([length(recal02(1:pt_delay(i)-Samplingrate/4)):length(recal02(1:pt_delay(i)+Samplingrate/4))] , recal02(pt_delay(i)-Samplingrate/4 :pt_delay(i)+Samplingrate/4))
%     hold on;plot(pt_delay(i),off_ends_lumin(pt_delay(i)),'g*')
% end

% assign bar position to every number in lumin_state(1,2,3)
stimuli_pos=[]; %the bar position value corresponding to the states of diode
Fcount=1; %counting for the idealStimuli
stimuli_pos(1)=idealStimuli(1);
skippos=zeros(1,length(lumin_state));

for uu=2:length(lumin_state)
    Ptbefore=lumin_state(uu-1);
    Pt=lumin_state(uu);
    if Pt-Ptbefore == 0  %if they are the same state
        stimuli_pos(uu)=idealStimuli(Fcount);
    elseif Pt-Ptbefore == -1 || Pt-Ptbefore==2 %normal transition
        Fcount=Fcount+1;
        stimuli_pos(uu)=idealStimuli(Fcount);
    elseif Pt-Ptbefore == 1 || Pt-Ptbefore== -2 %skipped frame
        Fcount=Fcount+2;
        skippos(uu)=1;
        stimuli_pos(uu)=idealStimuli(Fcount);
    end
end
Fcount  %the length of Fcount should be the same as the length of "idealStimuli"
pt_skip=find(skippos~=0); %find how many skipped frames

% % plot
figure; plot(lumin_state)
%hold on; plot(stimuli_pos*0.01-3.5);
hold on; plot(pt_skip,lumin_state(pt_skip),'g*')
%hold on;plot(pt_delay,lumin_state(pt_delay),'g*')

% check the number of state is the same as Fcount(length of idealStimuli)
test=[];
test=find(diff(lumin_state)~=0);
NumFrames=length(test)+length(pt_delay)+1; %number of total different frames from diode measurement  %+1 is for the last frame
NumFrames-length(pt_delay)+length(pt_skip)==Fcount %check the assignment of bar position is correct: =1:success!
% figure; plot(lumin_state)
% hold on; plot(test,lumin_state(test),'ro')



% Previous array " stimuli_pos" is with sampling rate of mcrack, now we need to make an array with  60Hz
%BinningInterval_pre=vpa(totalTime/NumFrames,40); %First: determine binning interval:
BinningInterval_pre=totalTime/NumFrames;
BinningInterval_pre         %symbolic form is more precise  %dont use 1/60
% BinningInterval_pre=0.01666530878596023664891020110696074195429; %turn to double > calculation is faster
%digitsOld = digits(100);
BinningInterval = double(BinningInterval_pre) ;
diode_BT = [BinningInterval : BinningInterval : (diode_end-diode_start+1)/Samplingrate]; %binning time for diode
%[16,33,49,-----] %lack one frame, due to DataTime is not 150s
length(diode_BT)

bin_pos=[]; %the result we want
tog3=[];
pt_per_frame=BinningInterval*Samplingrate; %number of diode points in one frame
same_len_pos=[];
ratio3=[]; count=1; %ratio3 calculate the ratio for 3 states in one bin

for hj= 1:length(diode_BT) %length is same as BinningTime for Spikes %8534:8539 %8457:8461
    numT=diode_BT(hj)*Samplingrate; %the corresponding number of point to timing in diode_BT
    C=[];
    C = unique(stimuli_pos(round(numT-pt_per_frame)+1:round(numT)),'stable'); %unique number in one frame
    %     hj
    %     C
    if length(C)==1
        bin_pos(hj)=C;
    elseif length(C)==2
        pt1n=length(find(stimuli_pos(round(numT-pt_per_frame)+1:round(numT))==C(1))); %number of first number
        pt2n=length(find(stimuli_pos(round(numT-pt_per_frame)+1:round(numT))==C(2)));
        if pt1n==pt2n
            bin_pos(hj)=C(2);
            same_len_pos(hj)= 1;
        elseif pt1n > pt2n
            bin_pos(hj)=C(1);
        elseif pt1n < pt2n
            bin_pos(hj)=C(2);
        end
    elseif length(C) ==3
        %             tog3(round(numT-pt_per_frame)+1:round(numT))=1;
        tog3(round(numT-pt_per_frame))=1;
        tog3(round(numT))=1;
        pt1n=length(find(stimuli_pos(round(numT-pt_per_frame)+1:round(numT))==C(1))); %number of first number
        pt2n=length(find(stimuli_pos(round(numT-pt_per_frame)+1:round(numT))==C(2)));
        pt3n=length(find(stimuli_pos(round(numT-pt_per_frame)+1:round(numT))==C(3)));
        err=max([pt1n, pt2n, pt3n]);
        if length(err)~=1
            hj
            break
        end
        if err==pt1n  %assign the value that has the most numbers
            bin_pos(hj)=C(1);
        elseif err==pt2n
            bin_pos(hj)=C(2);
        elseif err==pt3n
            bin_pos(hj)=C(3);
        end
        
        sumtemp=pt1n+pt2n+pt3n;
        ratio3(count,1:3)=[pt1n pt2n pt3n]./sumtemp;  %ration between these 3 values
        count=count+1;
        
    else
        bin_pos(hj)=-5;
    end
end
length(find(tog3~=0)/2) %this is the number of points that has 3 states in one bin

disp('ratio3/ problem points: ')
ratio3(find(ratio3<0.9 & ratio3>0.1))  %3 states / if not empty, need to recalculate
length(find(same_len_pos~=0))  % 2 states / if not zero, need to recalculate
%Fcount == ???? == Numframe?
%% Saving
clearvars -except bin_pos diode_BT BinningInterval a_data Spikes yk_spikes TimeStamps  start_lum thre01 thre02 Samplingrate idealStimuli plateau_n name
save(['merge_sortch_',name])




%% some plotting
% plot regions that ahs 3 states in one bin
% figure; plot(off_ends_lumin)
% recal=0.8*lumin_state*(max(off_ends_lumin)-min(off_ends_lumin))/(max(lumin_state)-min(lumin_state));
% recal02=recal-mean(recal) +mean(off_ends_lumin)-0.02+70;
% hold on; plot(recal02)
% % hold on;plot(pt_delay,off_ends_lumin(pt_delay),'g*')
% oao=3.49*10^4*ones(1,length(find(tog3~=0)));
% hold on; plot(find(tog3~=0),oao,'b*')

%plot
% figure; plot(off_ends_lumin)
% hold on; plot(recal02)
% hold on;plot(pt_delay,off_ends_lumin(pt_delay),'g*')
% temp=[];
% temp=mean(recal02)*ones(1,length(diode_BT));
% hold on;plot(diode_BT,temp,'b*' )
%
% xtemp=find(tog3~=0);
% ytemp=[];
% ytemp=mean(off_ends_lumin)*ones(1,length(xtemp));
% hold on; plot(xtemp,ytemp,'ro')

% plot
% figure; autocorr(bin_pos,500)
% saveas(gcf, ['Autocorrelation bin_pos',name],'fig');
% figure; autocorr(idealStimuli,500)

% figure; plot(bin_pos);
% hold on; plot(idealStimuli));

%% transfer to ccd frame
% ccd_fps=120;
% diode_select=154431; %value before cut before and after
%
% diodeT=(diode_select-diode_start)/Samplingrate;
% through_frame=diodeT*ccd_fps;
% ccd_startframe=249;
% targer_frame=ccd_startframe+through_frame;
%
% targer_frame
