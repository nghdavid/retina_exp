function[Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data(filename,save_data,comment,experimenter,analog_type,r_interval)
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

% directory = filename(1:temp(end));

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

if r_interval ~=0
    [Spikes]=get_spikes(AllDataInfo,r_interval); % call data from AllDataInfo, get spike0(=spike_location)   , save spikttime into.mat
else
    [Spikes]=get_spikes(AllDataInfo); % call data from AllDataInfo, get spike0(=spike_location)   , save spikttime into.mat
end
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
    save(n,'Spikes','TimeStamps','a_data','Infos')
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
%     a_data = diff(a_data);
    [~,locs]=findpeaks(diff(a_data2),'MINPEAKHEIGHT',5*std(diff(a_data2)));
    analog_loc = (locs)/SamplingRate;
    TimeStamps = cat(2,TimeStamps, analog_loc);
%     end
    disp('analog data completed')

end


%%
function[spikes] = get_spikes(AllDataInfo,read_interval)
t1=getfield(AllDataInfo,'sweepStartTime');
t2=getfield(AllDataInfo,'sweepStopTime') ;
SamplingRate = getfield(AllDataInfo,'MillisamplesPerSecond2');
SamplingRate = SamplingRate(1)/1000;
if nargin < 2
    read_interval = t2-t1+1;
elseif nargin <3
    
end
spikes = cell(1,60);


streamnames = getfield(AllDataInfo,'StreamNames');

for name_ind = 1:length(streamnames)
    if strcmp(streamnames{name_ind},'Electrode Raw Data 1')
        streamname = streamnames{name_ind};
    elseif strcmp(streamnames{name_ind},'Electrode Raw Data')
        streamname = streamnames{name_ind};
    end
end

layout = [21,19,16,15,12,10,24,22,...
          20,17,14,11, 9, 7,26,25,...
          23,18,13, 8, 6, 5,29,30,...
          28,27, 4, 3, 1, 2,32,31,...
          33,34,57,58,60,59,35,36,...
          38,43,48,53,55,56,37,39,...
          41,44,47,50,52,54,40,42,...
          45,46,49,51];


for i = t1 : read_interval : t2-1
disp ( [num2str(i),'/',num2str(t2)])
tic
%read data with given read_interval
if i + read_interval-1 < t2-1
    StartStopVector = [i , i+read_interval-1];
else
    StartStopVector = [i , t2-1];
end
if strcmp(streamname,'Electrode Raw Data 1')
    AllData = nextdata(AllDataInfo,'startend',StartStopVector,...
              'originorder','on' ,'streamname','Electrode Raw Data 1');
    rawdata = AllData.data ;
    [vdata, ~] = ad2muvolt(AllDataInfo, rawdata', 'Electrode Raw Data 1'); % rescale vdata(uV) , tvals(us)
    clear rawdata
    vdata = reshape(vdata,60,[length(vdata)/60]);
elseif strcmp(streamname,'Electrode Raw Data')
    AllData = nextdata(AllDataInfo,'startend',StartStopVector,'originorder','on' ,'streamname','Electrode Raw Data'); % call data, the 60 channels
    rawdata = AllData.data ;
    [vdata, ~] = ad2muvolt(AllDataInfo, rawdata, 'Electrode Raw Data'); 
    clear rawdata
end
for channel_index = 1:60 
    data = vdata(layout(channel_index),:) ; 
    [b,a] = butter(2,200/10000,'high'); % set butter filter
    FilterData = filter(b,a,data);
    
    %%% peak detecttion
    std_data = std(FilterData) ;
    [~,locs] = findpeaks(-FilterData,'MINPEAKHEIGHT', std_data *5);
    
    spikes{channel_index} = [spikes{channel_index},(i/1000*SamplingRate+locs)/SamplingRate];
end

toc
end
end



