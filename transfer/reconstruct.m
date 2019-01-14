%load mat file first
% clear all;
% close all;


%%
lumin=[];
lumin=a_data(2,:);   %Careful: cant subtract a value to the lumin series, or the correspondent  Spike time would be incorrect!

last_gray = max(lumin)*0.25+min(lumin)*0.75;

thre_up = max(lumin)*0.7+min(lumin)*0.3;
thre_down = max(lumin)*0.3+min(lumin)*0.7;

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
idealStimuli=[];

TimeStamps=zeros(1,2);
TimeStamps(1,1)=diode_start/Samplingrate;
TimeStamps(1,2)=diode_end/Samplingrate;
TimeStamps




% delete before and after of the lumin series

off_ends_lumin=lumin;
off_ends_lumin(1:diode_start-1)=[]; %clear numbers before the diode_start
off_ends_lumin(diode_end+1-(diode_start-1):end)=[]; %clear numbers after the diode_end

%time of stimulation from diode measurement
%totalTime=vpa(length(off_ends_lumin)/ Samplingrate,30);
totalTime=vpa(length(off_ends_lumin)/ Samplingrate,30);
totalTime

% start_lum=3.5*10^4; %81*10^4;


%find stimulation period
% diode_start=find(lumin>=start_lum,1);
% 
% diode_start=find(lumin>=start_lum);
% tempp=find(lumin<=start_lum);
% diode_end=tempp(end);
figure;plot(lumin)
hold on; plot(diode_start,lumin(diode_start),'r*');
hold on;plot(diode_end,lumin(diode_end),'g*');
% plot
figure;plot(off_ends_lumin)
% hold on; plot(diode_start,lumin(diode_start),'r*');
% hold on;plot(diode_end,lumin(diode_end),'b*');
