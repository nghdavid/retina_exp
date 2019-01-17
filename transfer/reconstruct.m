%load mat file first
% clear all;
% close all;


%%
lumin=[];
lumin=a_data(2,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
plateau_n=200;  %least number of point for plateau
last_gray = max(lumin)*0.25+min(lumin)*0.75;

thre_up = max(lumin)*0.7+min(lumin)*0.3;

thre_down = max(lumin)*0.2+min(lumin)*0.8;
% 
idealStimuli=newXarray;
%idealStimuli=new_x;
idealTime = length(idealStimuli)/60;

% Find when it starts
for i = 1:length(lumin)
    
    if (lumin(i+50)-lumin(i))/50 > 10 && (lumin(i+100)-lumin(i))/100 > 6 && (lumin(i+10)-lumin(i))/10 > 7
        diode_start = i;
        break
    end
end

% Find when it ends
is_complete = 0;
for i = 1:length(lumin)
    
    if (lumin(i+30)-lumin(i))/30 > 2 && (lumin(i+100)-lumin(i))/100 < 2 && (lumin(i+70)-lumin(i))/70 > 2 && lumin(i+100) < thre_up
        diode_end = i;
        is_complete = 1;
        break
    end
    
end
if is_complete == 0
    disp('There are no normal signal')
    return
end


Samplingrate=20000; %fps of diode in A3


TimeStamps=zeros(1,2);
TimeStamps(1,1)=diode_start/Samplingrate;
TimeStamps(1,2)=diode_end/Samplingrate;


% delete before and after of the lumin series

off_ends_lumin=lumin;
off_ends_lumin(1:diode_start-1)=[]; %clear numbers before the diode_start
off_ends_lumin(diode_end+1-(diode_start-1):end)=[]; %clear numbers after the diode_end
%time of stimulation from diode measurement
totalTime=vpa(length(off_ends_lumin)/ Samplingrate,30);
if abs(totalTime-idealTime)>3
    disp('The end is not normal, needed to be done again')
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
hold on;plot(diode_end,lumin(diode_end),'g*');
xlabel('time')
ylabel('lumin')
title('start and end')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


lumin_state=[];
smoothed_lumin= smooth(off_ends_lumin) ;
for jj=1:length(off_ends_lumin)
    if smoothed_lumin(jj) > thre_up
        lumin_state(jj)=3;  %highest diode value: state 3
    elseif   smoothed_lumin(jj) > thre_down &&  smoothed_lumin(jj)  < thre_up
        lumin_state(jj)=2; %middle diode value: state 2
       
    else
        lumin_state(jj)=1; %lowest diode value: state 1
    end
end

%make the first elements = 3, since when the luminance raises up, the first  element is state 3
dd=find(lumin_state==3,1);
lumin_state(1:dd)=3;



% find delay frames' timing
frame_time=[];  changept=[]; count=1; pt_delay=[];
changept=find(diff(lumin_state)~=0); %find the point that its state is about to change
for hh=1:length(changept)-1
    frame_time(count)=length(lumin_state(changept(hh)+1:changept(hh+1)))/Samplingrate; %the time period for each plateau
    count=count+1;
end
pt_delay=changept(find(frame_time>0.020));  %if the time of a plateau is too long, it meas there is a problemed frame

%Plot pt_delay points
%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(off_ends_lumin); hold on;
plot(pt_delay,off_ends_lumin(pt_delay),'g*')
xlabel('time')
ylabel('lumin')
title('pt_delay points')
%%%%%%%%%%%%%%%%%%%%%%%%%%


% assign transitioning points(ex: the points from state 2 to state 3) to other states
for hh=1:length(changept)-1
    if length(lumin_state(changept(hh)+1:changept(hh+1)))<plateau_n  %to determine whether it's transitioning point
        lumin_state(changept(hh)+1:changept(hh+1))=lumin_state(changept(hh+1)+1);  %assigning the new state to transitioning point
    end
end


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

pt_skip=find(skippos~=0); %find how many skipped frames


% check the number of state is the same as Fcount(length of idealStimuli)
test=[];
test=find(diff(lumin_state)~=0);
NumFrames=length(test)+length(pt_delay)+1; %number of total different frames from diode measurement  %+1 is for the last frame



% Previous array " stimuli_pos" is with sampling rate of mcrack, now we need to make an array with  60Hz
BinningInterval_pre=vpa(totalTime/NumFrames,40); %First: determine binning interval:
%BinningInterval_pre=totalTime/NumFrames;

% BinningInterval_pre=0.01666530878596023664891020110696074195429; %turn to double > calculation is faster
%digitsOld = digits(100);
BinningInterval = double(BinningInterval_pre) ;
diode_BT = [BinningInterval : BinningInterval : (diode_end-diode_start+1)/Samplingrate]; %binning time for diode
%[16,33,49,-----] %lack one frame, due to DataTime is not 150s



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

if NumFrames-length(pt_delay)+length(pt_skip)~=Fcount %check the assignment of bar position is correct: =1:success!
    disp('The change of ideal position is incorrect')
    return
end


%this is the number of points that has 3 states in one bin
if length(find(tog3~=0)/2) >0
    disp('the number of points that has 3 states in one bin ')
    return
end



if length(ratio3(find(ratio3<0.9 & ratio3>0.1))  )  > 0
    disp('ratio3/ problem points: ')
    disp('Ratio Error')
    return
    %3 states / if not empty, need to recalculate
end

if length(find(same_len_pos~=0)) ~=  0
    disp('ratio3/ problem points: ')
    disp('2 states Error')
    return 
end

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

%% Saving
% clearvars -except bin_pos diode_BT BinningInterval a_data Spikes yk_spikes TimeStamps  start_lum thre01 thre02 Samplingrate idealStimuli plateau_n name
% save(['merge_sortch_',name])