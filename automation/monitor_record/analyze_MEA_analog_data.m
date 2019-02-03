function[a_data,Infos] = analyze_MEA_data(filename,save_data,comment,experimenter,analog_type,r_interval)
% experimenter is default as the first folder in the directory, if not,
% please type in manually

%main


file = strcat(filename);
AllDataInfo =datastrm(file) ;


%infos
filename = getfield(AllDataInfo,'filename');
    Infos.filename = filename;

SamplingRate = getfield(AllDataInfo,'MillisamplesPerSecond2');
    Infos.SamplingRate = SamplingRate(1)/1000;

NChannels = getfield(AllDataInfo,'NChannels2');
NChannels = max(NChannels);
    Infos.NChannels = NChannels;
if NChannels~=60;   disp('WARNING, strange NChannels');  end;

datetime = getfield(AllDataInfo,'recordingdate');
Infos.RecordingDate = [datestr(datetime,0)];
if ~exist('experimenter','var') 
    temp = strfind(filename,'\');
    experimenter = filename(temp(1)+1:temp(2)-1);
elseif strcmp(experimenter,'auto')
    temp = strfind(filename,'\');
    experimenter = filename(temp(1)+1:temp(2)-1);
end
    Infos.experimenter = experimenter;


if ~exist('comment','var')
    comment='';
end
    Infos.comment = comment;
if ~exist('r_interval','var')
    r_interval = 0;
end
t1=getfield(AllDataInfo,'sweepStartTime');
t2=getfield(AllDataInfo,'sweepStopTime') ;
    Infos.t_start = t1;
    Infos.t_stop  = t2;

%main process
[TimeStamps,a_data,a_data_all] = Analog_time(AllDataInfo);   % get trig_time, need: AllDataInfo, t1,t2, filename_length, save trig_time into .mat


%save, defalt: save data
if ~exist('save_data','var')
    save_data=1;
end


if nargin>=5
    if strcmp(analog_type,'all')
        a_data = a_data_all;
    elseif strcmp(analog_type,'A1')
        a_data = a_data_all(1,:);
    elseif strcmp(analog_type,'A2')
        if size(a_data_all,1) == 1
            a_data = a_data_all(1,:);
        elseif size(a_data_all,1) >= 2
            a_data = a_data_all(2,:);
        end
    elseif strcmp(analog_type,'A3')
        if size(a_data_all,1) == 1
            a_data = a_data_all(1,:);
        elseif size(a_data_all,1) >= 2
            a_data = a_data_all(end,:);
        end
    end
end


if save_data==1
    n = [filename(1:end-4),'.mat'];
    save(n,'TimeStamps','a_data','Infos')
end
end

%%
function[TimeStamps,a_data2,a_data]=Analog_time(AllDataInfo)
    t1=getfield(AllDataInfo,'sweepStartTime');
    t2=getfield(AllDataInfo,'sweepStopTime') ;
    SamplingRate = getfield(AllDataInfo,'MillisamplesPerSecond2');
    SamplingRate = SamplingRate(1)/1000;
%     if nargin <2
%         read_interval = t2-t1+1;
%     elseif nargin <3
%         A_channel_number = 2;
%     end
    disp('getting analog data')

    TimeStamps = [];

%     for i = t1 : read_interval : t2-1
%         if i+read_interval-1 <= t2-1
%             StartStopVector = [i , i+read_interval-1];
%         else
    StartStopVector = [t1 , t2];
%         end
    AllData = nextdata(AllDataInfo,'startend',StartStopVector,'originorder','on' ,'streamname','Analog Raw Data');
    a_data = AllData.data;
    if size(a_data,1)==1              %only find one analog channel, possibly cause by the setting in MC_rack
        a_data2 = a_data(1,:);
    else
        a_data2 = a_data(2,:);
    end
    a_data2 = a_data2 - a_data2(1);

    disp('analog data completed')

end

