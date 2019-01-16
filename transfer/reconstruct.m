%load mat file first
% clear all;
% close all;


%%
lumin=[];
lumin=a_data(2,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!
plateau_n=200;  %least number of point for plateau
last_gray = max(lumin)*0.25+min(lumin)*0.75;

% thre_up = max(lumin)*0.7+min(lumin)*0.3;
% thre_down = max(lumin)*0.3+min(lumin)*0.7;

thre_up = 35000;
thre_down = max(lumin)*0.2+min(lumin)*0.8;

for i = 1:length(lumin)
    
    if (lumin(i+30)-lumin(i))/30 > 2 && (lumin(i+100)-lumin(i))/100 < 2 && (lumin(i+70)-lumin(i))/70 > 2 && lumin(i+100) < thre_up
        diode_end = i;
        break
    end
end

for i = 1:length(lumin)
    
    if (lumin(i+50)-lumin(i))/50 > 10 && (lumin(i+100)-lumin(i))/100 > 6 && (lumin(i+10)-lumin(i))/10 > 7
        diode_start = i;
        break
    end
end

Samplingrate=20000; %fps of diode in A3


TimeStamps=zeros(1,2);
TimeStamps(1,1)=diode_start/Samplingrate;
TimeStamps(1,2)=diode_end/Samplingrate;


% TimeStamps

% delete before and after of the lumin series

off_ends_lumin=lumin;
off_ends_lumin(1:diode_start-1)=[]; %clear numbers before the diode_start
off_ends_lumin(diode_end+1-(diode_start-1):end)=[]; %clear numbers after the diode_end


figure;plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
hold on;plot(diode_end,lumin(diode_end),'g*');

%time of stimulation from diode measurement
totalTime=vpa(length(off_ends_lumin)/ Samplingrate,30);
totalTime

% 
% idealStimuli=newXarray;
idealStimuli=new_x;

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

figure;plot(off_ends_lumin); hold on;
plot(pt_delay,off_ends_lumin(pt_delay),'g*')


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
Fcount  %the length of Fcount should be the same as the length of "idealStimuli"
pt_skip=find(skippos~=0); %find how many skipped frames


% check the number of state is the same as Fcount(length of idealStimuli)
test=[];
test=find(diff(lumin_state)~=0);
NumFrames=length(test)+length(pt_delay)+1; %number of total different frames from diode measurement  %+1 is for the last frame
NumFrames-length(pt_delay)+length(pt_skip)==Fcount %check the assignment of bar position is correct: =1:success!
% figure; plot(lumin_state)
% hold on; plot(test,lumin_state(test),'ro')

% yk_spikes=[];
% for j = 1:length(Spikes)    %running through each channel
%     ss = Spikes{j};
%     ss(ss<TimeStamps(1,1)) = [];  %delete the spikes before TimeStamps(1)
%     ss(ss>TimeStamps(1,2))=[];
%     
%     for i = 1:length(ss)
%         ss(i) = ss(i)-TimeStamps(1,1);
%     end
%     yk_spikes{j} = ss;
% end
