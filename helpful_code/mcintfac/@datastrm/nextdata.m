function c = nextdata(d,varargin);
% NEXTDATA   - read data from an MCRack OLE Object opened with datastrm.m
%     c = nextdata(D,'streamname','Spikes 1','startend',[0 1000]); 
% retrieves data from the specified stream in the object <D>.
%
% In this help section we will use 'D' for the current datastream object.
%
% Optional parameters (parameter value paires):
% streamname   string	   stream to access
% startend     double(2,1) start and stop time for retrieving in ms
% originorder   string     'on' or 'off', with the default 'off' the data channels 
%                          are sorted in linear MEA order as channels are in MCRack 
%                          buffer page, when in datasource/Channels Page MEA Type 
%                          is selected.
%                          In the linear MEA order data come as (64,x) array.
%                          With 'originorder' 'on' data channels come in (hardware) order 
%                          of recording and only recorded channel are returned.
%                          
%                          Please use 'originorder' 'on' when you work with linear channel layout ('nogrid' 'plain').
%                          For data from MC Rack V1.4 and higher this 'originorder' 'on' is set
%                          by default for linear channel layout.
%                          !!!!! IMPORTANT !!!!!
%                          If you use MEA layout ('8x8'), please set 'originorder' 'on' for all streams derived
%                          from Analog Raw Data.
%
% warning      string      'on' or 'off', higher level routines can supress warnings here
%
% hardwarechannelid
%              double      hardware channel id; for 'spikes' streams only, data of only one 
%                          channel can be retrieved fast
% channelid    double      linear channel id; for 'spikes' streams only, data of only one 
%                          channel can be retrieved fast, overrides hardwarechannelid
% timesonly    string      'on' or 'off', read out only spike time points and no spike 
%                          data when 'on' (c.spiketimes filled, c.spikevalues empty) 
%                          only valid for spikes, works with and without channelid set
% eventtimes  double(n,1)  get events (spike data) to corresponding time points,
%                          only valid for spikes, works only with channelid set,
%                          spikes are sorted ascendingly, startend is ignored
%
% To access triggered data, please use the sweep starting times you find in the property 
% sweepStartTime or first retrieve the triggers event of the whole file to get the 
% sweep starting times.
%
% sample code:
%     sweeptimes = getfield(D,'sweepStartTime');
%     timeWindow = getfield(D,'TimeWindow');
%     startend = [sweeptimes(sweepindex) sweeptimes(sweepindex)+timeWindow.Time2];
%     nextdata(...,'startend',startend,...);
%
% Please use 
%     data = ad2muvolt(D,data); 
% to convert 'analog' and 'spikes' data from AD-values to µV. Times are generally given in ms. 
%
% You can build arrays with time data in ms for 'analog' data using 
%     ticks = 1000/getfield(D,'MicrosecondsPerTick'); 
%     timedata = [start_ms*ticks:end_ms*ticks]/ticks;
%
% 'params' data are in 
%     V (min,max,height,amplitude), 
%     ms (tmin,tmax,width), 
%     ms*V (area), 
%     Hz (rate), 
%     number is without unit
%
% nextdata generally retrieves data in multi channel format. 
%     Use the linear channel index (#12=2,#21=9; as in ChannelID2/ChannelNames2 pairs) 
%     on nextdata return values for accessing single channel data fetched with originorder off.
%     With originorder on (eg. used, when non MEA data are recorded) use 
%     hardware linear channel index (#01=1,#02=2; as in HardwareChannelID2/HardwareChannelNames2 pairs)
%
% Examples for plotting single channel data:
% 'analog' sample: plot(timedata, c.data(channelnumber,:));    % c.data is a double array
% 'spikes' sample: 
%          spiketimes = c.spiketimes{channelnumber,:};         % c.spiketimes is a cell array
%          plot(spiketimes[1:end-1],diff(spiketimes,1),'*');   % inter spike interval plot
% 'params' sample: plot(c.min(channelnumber,:));               % c.min and others are double arrays
% 
%
% (c) Th. Knott



if (~strcmp(d.fileaccess,'ole'))
	error('nextdata works only with data from MCRack OLE Object')
end;
% pvpmod(varargin);
%***********
cfg.startend=[0 100];
cfg.streamname='Electrode Raw Data';
cfg.sorterleft=getfield(d,'sorterleft')-1;
cfg.originorder='off';
cfg.warning='on';
cfg.ChunkNumber=-1;	%if chunk >-1 then data of one chunk will be read in 
					%low level format (2 bytes on harddisk = 1 value)
					%chunk size (means 128 ms or greater) and format depends on stream type. 
					%Use chunks only for debugging!
cfg.channelid=[]; %read out data only for one specified channel (linear channel id), works only for spikes,
%								overrides hardwarechannelid!               
cfg.hardwarechannelid=[]; %read out data only for one specified channel (hardward channel id), works only for spikes
cfg.timesonly='off'; %read out only time points, only valid for spikes
cfg.eventtimes=[]; %read out spike to corresponding time points
cfg.eventtimesrange=(d.MicrosecondsPerTick/1000/2)*1.1; % accurracy in ms for time points to be found:
                                                        % half tick plus 10 percent (unnecessary with MC_Rack 1.64.0)
%***********

fields=[char(fieldnames(cfg))];
fields=[fields blanks(size(fields,1))']';
fields=fields(:)';
for idx=1:2:size(varargin, 2)
  if isempty(findstr(fields,[varargin{idx} ' ']))
    warning(['trying unknown option in nextdata:' varargin{idx}]);
  end;
  cfg = setfield(cfg, varargin{idx}, varargin{idx+1});
end

if ~isempty(cfg.channelid)
   cfg.hardwarechannelid=d.sorterright(cfg.channelid(1));
end
cfg=rmfield(cfg,'channelid');
if ~isempty(cfg.hardwarechannelid) 
   if strcmp(cfg.streamname(1:6),'Spikes')
      cfg.originorder='on';
      cfg.hardwarechannelid=cfg.hardwarechannelid-1;
   else
      warning(['channelid option in nextdata works only on spikes']);
		cfg=rmfield(cfg,'hardwarechannelid');
   end
else
	cfg=rmfield(cfg,'hardwarechannelid');
end
if strcmp(cfg.timesonly,'on')
   cfg.timesonly = 1;
else
   cfg.timesonly = 0;
end

msPerTick=d.MicrosecondsPerTick/1000;
if isempty(cfg.eventtimes) 
	cfg=rmfield(cfg,'eventtimes');
   cfg.startend=round(cfg.startend/msPerTick)*msPerTick;
elseif ~isfield(cfg,'hardwarechannelid')
	cfg=rmfield(cfg,'eventtimes');
   error(['eventtimes option in nextdata works only with channelid set']);
else
   cfg.eventtimes=sort(cfg.eventtimes);
   cfg.eventtimes=round(cfg.eventtimes/msPerTick)*msPerTick;
   cfg.startend=[cfg.eventtimes(1)-cfg.eventtimesrange*2 cfg.eventtimes(1)+100]; %end is ignored
end


cfg.StreamNumber = getstreamnumber(d,cfg.streamname)-1;
if cfg.StreamNumber < 0
	if strcmp(cfg.warning,'on')
		cfg.streamname
		warning('Stream not contained in file');
	end
	c.data=[];
	c.startend=cfg.startend;
	return
end

if ((d.TotalChannels>64) | ~isempty(find(d.HardwareChannelID2{cfg.StreamNumber+1}>64)) | ...
      strcmp(d.meatype, 'nogrid'))
	cfg.originorder='on';	%for more than 64 Channels, MEA layout makes no sense
end;

if strcmp(cfg.originorder,'on')
	cfg=rmfield(cfg,'sorterleft');
else
   if strcmp(cfg.streamname,'Analog Raw Data')
      cfg.sorterleft = [[1:60] 1 2 3 4]-1; %default should be 'originorder' 'on' also for MEA layout as 
                                             %all Streams derived from Analog Raw Data lead to crashes
   end
end;

if cfg.ChunkNumber > -1
	cfg.function='GetChunk';
	c=MCStreamMEX(cfg);
	return;
end


cfg.function='GetFromTo';
c=mcstreammex(cfg);
if strcmp(cfg.originorder,'off')
	cNum=64;
	if strcmp(cfg.streamname,'Analog Raw Data')
		cNum=4;
	end
else
	cNum=d.NChannels2(getstreamnumber(d,cfg.streamname));
end

if (strcmp(cfg.streamname,'Analog Raw Data') | strcmp(cfg.streamname,'Electrode Raw Data') | strcmp(cfg.streamname,'Digital Data') | ~isempty(findstr(cfg.streamname,'Filtered Data'))) 
   c.data = [reshape(c.data,cNum,length(c.data)/cNum)];
end

c.startend=cfg.startend;
