function d = datastrm(a,varargin)
% DATASTRM		- data object constructor for opening data recorded with MC Rack 
%
% d = datastrm(a,varargin) is a datastrm constructor for MC Rack data files of all MC Rack versions 
%                           (MC Rack version 1 and above uses the OLE Server Object contained in MCStream.dll)
%                           (MC Rack version 0 is handled by a MATLAB reader and is retained for compatibilty)
% <a> is a filename or a datastrm object or a struct containing fields of earlier datastrm versions.
% <d> is a datastrm object with the header information contained in the MCRack file.
%
% Following properties of the MCRack data file can be retrieved with getfield(d,'propertyxxx').
% Many of them come as arrays as they depend on the MCRack stream(=buffer), of which more
% than one can be contained in an MCRack data file (e.g. Trigger 1 and Spikes 1)
% Please use getstreamnumber(d,'streamname') for converting stream name to stream id, which
% must be used for indexing all stream dependent arrays.
%
% All other methodes than datastrm,nextdata,getfield,getstreamnumber,ad2muvolt in datastrm 
% directory are private or retained for compatibility and should not be used.
%
% Following properties of the datastrm object are accessible with getfield(a,'eg_prop'):
%
% filename                string
% version                 string             of the datastrm object definition in matlab
% softwareversion         string             of the MCRack version which recorded the opened data file
% filesize                double             in byte
% meatype                 string             '8x8' for MEA layout, all types of MEA's; 'nogrid' for hardware/in vivo layout
% TotalChannels           double             number of hardware channel, can be up to 128 for 'nogrid' layout
% NChannels2              double/stream      no. of channels recorded
% ChannelNames2           cell string        strings of channel definitions, 
%                         array/stream       sorted in hardware aquisition order
% HardwareChannelNames2   cell string        strings of channel definitions, 
%                         array/stream       sorted in recording order
% ChannelID2              cell with double   linear channel ID (i.e. number of channel in MCRack channels page, 
%                         array/stream       e.g. 1=#11,2=#12,..,9=#21,10=#22,...),
%                                            sorted in hardware aquisition order
% HardwareChannelID2      cell with double   hardware channel ID (=number of channel in hardware aquisition sequence),
%                         array/stream       e.g. 1=#11,2=#12,..,9=#21,10=#22,...),
%                                            sorted in recording order
% MicrovoltsPerAD2        double/stream      µV per AD unit
% MicrosecondsPerTick     double             hardware sampling period
% MillisamplesPerSecond2  double/stream      samples per second * 1000, (there will be a downsampling option 
%                                            for Filtered data in later MCRack version)
% ZeroADValue2            double/stream      zero position of the AD conversion
%
% recordingdate           double             start date and time  
%                                                  datestr(getfield(d,'recordingdate'),0) returns a formatted string
% recordingStopDate       double             stop date and time  
%                                                  datestr(getfield(d,'recordingStopDate'),0) returns a formatted string
%                                            filelength in ms
%                                                  filelength=(getfield(d,'recordingStopDate')- 
%                                                                 getfield(d,'recordingdate'))*24*3600*1000 
% sweepStartTime          0                  onset of each window of gap-free, continuous data, given in ms
% sweepStopTime           0                  end of each window of gap-free, continuous data, given in ms
%
% TimeWindow              struct             recording Time Window information (i.e. trigger conditions, extent)
%                Choice:  string             Start On Trigger, Start And Stop On Trigger, or Fixed Window
%                 Time1:  double                   in ms, depending on the Time Window selection either the 
%                                                        Window Distance or the Pre-Trigger interval
%                 Time2:  double                   in ms, depending on the Time Window selection either the 
%                                                         Window Extent, or the Post-Trigger interval with 
%                                                         Start And Stop On Trigger. 
%          StartTrigger:  string                   name of the selected starting trigger
%           StopTrigger:  string                   name of the selected stop trigger
%
% StreamCount             double             no. of data stream in the record
% StreamNames             cell str/stream    'name' of the 'instrument' used, e.g. 'Spikes 1', 'Trigger 2', 'Electrode Raw Data'
% StreamInfo              cell with          cell array of structures with stream specific information 
%                         struct/stream
%
% Case: 'spikes'
%            StreamName:  string             recorded stream/buffer
%              DataType:  string             type of recorded stream: 'analog', 'trigger, 'spikes', 'params
%            PreTrigger:  double             pre-trigger interval in ms
%           PostTrigger:  double             post-trigger interval in ms
%              DeadTime:  double             'refractory period' in ms
%                 Level:  double/channel     trigger level in µV for each channel
%                 Slope:  double/channel     detection slope: 0 for negative, 1 for positive, -1 for absolute level
%          ChannelNames:  cell str/channel   channel names sorted as in Level and Slope
%
% Case: 'params'
%            StreamName:  string             recorded stream/buffer
%              DataType:  string             type of recorded stream: 'analog', 'trigger, 'spikes', 'params
%            Parameters:  cell string        actually return values of the analysis: 'min', 'max', 'tmin', 
%                         /parameter               'tmax', 'height', 'width', 'area', 'number', 'amplitude', or 'rate' 
%       InputBufferName:  cell string        analyzed data stream 
%        NumTimeWindows:  double             no. of Time Windows averaged
%      TimeWindowChoice:  string             'Start On Trigger', 'Start And Stop On Trigger', or 'Fixed Window'			
%       TimeWindowTime1:  double             depending on the Time Window selection either the Window Distance 
%                                                  or the Pre-Trigger
%       TimeWindowTime2:  double             depending on the Time Window selection either the Window Extent, 
%                                                  or the Post-Trigger interval with 'Start And Stop On Trigger'.
%TimeWindowStartTrigger:  string             name of the selected starting trigger
% TimeWindowStopTrigger:  string             name of the selected stop trigger
%
% Case: 'trigger'
%            StreamName:  string             recorded stream/buffer
%              DataType:  string             type of recorded stream: 'analog', 'trigger, 'spikes', 'params
%             ChannelID:  double             corresponds to HardwareChannelID2 of the channel used as trigger
%              DeadTime:  double             'refractory period' in ms
%                 Level:  double             trigger level in µV for each channel
%                 Slope:  double             detection slope: 0 for negative, 1 for positive
%       InputBufferName:  'not recorded'     data stream used as trigger source
%
% Case: 'other'
%            StreamName:  string             recorded stream/buffer
%              DataType:  string             type of recorded stream: 'analog', 'trigger, 'spikes', 'params
%
% Please refer to help nextdata for information on retrieving data
%
% Author: Th. Knott, NMI Reutlingen, knott@nmi.de

% internal variables and constants
% sorterleft            double  (1  68)      used to convert hardware aquisition order to linear channel order
%                                               linear_sorted_data(sorterleft)=hardware_sorted_data
% sorterright           double  (1  68)      used to convert hardware aquisition order to linear channel order
%                                               linear_sorted_data=hardware_data(sorterright)
% SamplesPerSegment     double/stream        no. of samples per data block in the file
%

% variables retained for compatibility with MCRack V 0
% DataType                raw triggered
% fid                     -1
% BitFlipRemoveFactor     0
% id                      0
% NChannels               0							
% ChannelNames            							
% HardwareChannelNames    
% MicrovoltsPerAD         1
% ZeroADValue             2048						zero position of the AD conversion
% ChannelID               0							
% HardwareChannelID       0
% total_window_ticks      0							
% offset_to_data          0
% sweepStartPointer       0							
% windowTicksPos          0							
% triggerChannel          -1							
% spikeSize               0							
% ticks_pre_event         0							
% maxSpkPerSegmPerChanl   0							
% nSpikesPerSegement      0							
% nSpkPerSegPerChanl      0							
% HeaderVersion           1							
% fileaccess              ole						
% TriggerStreamID         double (1  2)	   ID of the data stream used as trigger source


% versioning remarks:
% - member variables without ..2 are always filled, (ThK)
% - with ..2 only by MCRack version 0 files (ThK)
% - d.ChannelNames and d.ChannelID retrieved from files recorded with MCRack v. 1.0 now 
% 	 complies with the numbering scheme fitting the MEATools indexing style. (UE 12/1/98)

% MCRack version 0: second par can be the BitFlipRemoveFactor (up to now only for spike data used)
% for removing spikes (bitflips) with peaks more than BitFlipRemoveFactor higher than left/right value
% reasonable size: 4

% Author: Th. Knott, NMI Reutlingen

d.filename='';
d.fid=-1;
datastrmStruct = [];

if nargin == 0
	a='not assigned';
elseif isa(a,'datastrm')
   d = a;
   if (~strcmp(d.fileaccess,'ole'))
   	d.fid = fopen(d.filename);
   	if d.fid == -1
   	   warning(['file ' d.filename ' does not exist']);
      end
   end;
   return;
elseif isa(a,'struct')
   % help initializing earlier versions of datastrm
   datastrmStruct=a;
	a='not assigned';
elseif isa(a,'char') & strcmp(a,'open')
   [fn path] = uigetfile('*.*','open data file');
   if (fn == 0) & (path == 0)      % 'cancel'-button pressed
     if nargout == 1 
        d = [];
     end
     return 
   end
   a = [path fn];
end

if ~strcmp(a,'not assigned')
   d.filename = a;
   d.fid = fopen(a);
   if (d.fid == -1)
      error(['file ' d.filename ' does not exist']);
   end
end

if size(varargin,2)>=1		
	d.BitFlipRemoveFactor = 1/varargin{1}; %factor for removing spikes (bitflips) with peaks 
									% more than BitFlipRemoveFactor higher than left/right value
else
	d.BitFlipRemoveFactor = 0;
end;

%general
d.meatype='8x8';
d.version='2.4.9';
d.filesize=0;
d.id=0;
d.DataType='';
d.NChannels=0;
d.NChannels2=0;
d.ChannelNames = '';
d.ChannelNames2 = '';
d.HardwareChannelNames= '';
d.HardwareChannelNames2= '';
d.MicrovoltsPerAD=1;
d.MicrovoltsPerAD2=1;
d.MicrosecondsPerTick=40;
d.ZeroADValue=2048;
d.ZeroADValue2=2048;
d.ChannelID=0;
d.ChannelID2=0;
d.HardwareChannelID=0;
d.HardwareChannelID2=0;
d.sorterleft=[31,32,30,29,24,23,16,22,15,7,14,6,21,13,5,4,12,20,3,11,2,10,19,9,18,17,28,27,25,26,34,33,35,36,41,42,49,43,50,58,51,59,44,52,60,61,53,45,62,54,63,55,46,56,47,48,37,38,40,39,65,66,67,68,1,8,57,64,69:128];
d.sorterleft(65:128) = d.sorterleft(1:64) + 68;
d.sorterright=[65,21,19,16,15,12,10,66,24,22,20,17,14,11,9,7,26,25,23,18,13,8,6,5,29,30,28,27,4,3,1,2,32,31,33,34,57,58,60,59,35,36,38,43,48,53,55,56,37,39,41,44,47,50,52,54,67,40,42,45,46,49,51,68,61,62,63,64,69:128];
d.mea8x8ChannelNames={'11'  '12'  '13'  '14'  '15'  '16'  '17'  '18'  '21'  '22'  '23'  '24'  '25'  '26'  '27'  '28'  '31'  '32'  '33'  '34'  '35'  '36'  '37'  '38'  '41'  '42'  '43'  '44'  '45'  '46'  '47'  '48'  '51'  '52'  '53'  '54'  '55'  '56'  '57'  '58'  '61'  '62'  '63'  '64'  '65'  '66'  '67'  '68'  '71'  '72'  '73'  '74'  '75'  '76'  '77'  '78'  '81'  '82'  '83'  '84'  '85'  '86'  '87'  '88'};
% with following code you get you hardchannel ID translated 
% to MEA 8x8 layout independent of MCRack source type (works only with less than 61 channels!)
% streamnr=getstreamnumber(a,'Spikes 1');
% sorterleft=getfield(a,'sorterleft');
% mea8x8ChannelNames==getfield(a,'mea8x8ChannelNames');
% hwnamesall={mea8x8ChannelNames{sorterleft(1:60)}}; 
% hwstream=getfield(a,'HardwareChannelID2');
% hwnames= hwnamesall(hwstream{streamnr})
d.total_window_ticks=0;
d.offset_to_data = 0;
d.recordingdate = 0;
d.recordingStopDate = 0;
d.sweepStartTime = 0;	     %for spikes used as segment start time
d.sweepStartPointer = 0;	  %for spikes used as segment start pointer
d.windowTicksPos = 0;
d.triggerChannel = -1;
%spikes
d.spikeSize = 0;              %code optimizations assume this not to be changed within a file
d.ticks_pre_event = 0; 
d.maxSpkPerSegmPerChanl = 0;  %upper limit for memory needed per segment while reading spikes as spikes
d.nSpikesPerSegement = 0;     %upper limit for memory needed per segment while reading spikes as sparse
d.nSpkPerSegPerChanl = 0;     %number of spike per segment per channel in 4-bit code
d.HeaderVersion=-1;
d.fileaccess='file';
d.MillisamplesPerSecond=0;
d.MillisamplesPerSecond2=0;
d.StreamCount=0;
d.StreamNames={};
d.StreamInfo={};
d.SamplesPerSegment = 0;
d.TriggerStreamID=0;
d.TimeWindow.Choice=0;
d.TimeWindow.Time1=0;
d.TimeWindow.Time2=0;
d.TimeWindow.StartTrigger=0;
d.TimeWindow.StopTrigger=0;
d.softwareversion=0;
d.TotalChannels = 64;
d.sweepStopTime = 0;	     

if ~isempty(datastrmStruct)
   structFields=fieldnames(datastrmStruct);
   for idx=1:length(structFields)
      d=setfield(d,structFields{idx},getfield(datastrmStruct,structFields{idx}));
   end
end
d = class(d,'datastrm');

if ~strcmp(a,'not assigned')
	fseek(d.fid,0,1);
	d.filesize=ftell(d.fid);
   fseek(d.fid,0,-1);
	newd=rdrawhd(d);
	if(strcmp(class(newd),'char') & strcmp(newd,'invalid file'))	%not old mcrack version
		fclose(d.fid);
		tmp.function='OpenFile';
		tmp.Filename=d.filename;
		retStruct.HeaderVersion=1;
		retStruct=mcstreammex(tmp);
		d.fid=-1;
		d.HeaderVersion=retStruct.HeaderVersion;
		d.softwareversion=retStruct.SoftwareVersion;
		d.fileaccess='ole';
		d.MillisamplesPerSecond=retStruct.MillisamplesPerSecond;
		d.MillisamplesPerSecond2=retStruct.MillisamplesPerSecond2;
		d.MicrosecondsPerTick=1000000/(d.MillisamplesPerSecond/1000);
		d.ZeroADValue2=retStruct.ZeroADValue;
		for i=1:length(retStruct.UnitsPerAD)
			if(char(retStruct.UnitSign(i))=='V')
				d.MicrovoltsPerAD2(i)=retStruct.UnitsPerAD(i)*1000000;
			else
				warning('unknown UnitSign in OLE-read file, MicrovoltsPerAD set to default');
			end
		end
		d.StreamCount=retStruct.StreamCount;
		d.StreamNames=retStruct.StreamNames;
		d.StreamInfo=retStruct.StreamInfo;
		d.SamplesPerSegment=retStruct.SamplesPerSegment;
		d.NChannels2=retStruct.ChannelCount;
		d.HardwareChannelID2=cell(d.StreamCount,1);
		d.HardwareChannelNames2=cell(d.StreamCount,1);
		d.ChannelID2=cell(d.StreamCount,1);
		d.ChannelNames2=cell(d.StreamCount,1);
		d.sweepStartTime=retStruct.SweepStartTime;
      d.sweepStopTime=retStruct.SweepStopTime;
      if retStruct.TriggerStreamID(1)>-1
			tmp=d.StreamInfo{retStruct.TriggerStreamID(1)+1};
			if ~isempty(tmp)
				d.triggerChannel=tmp.Channel;
			end
		end
      d.TriggerStreamID=retStruct.TriggerStreamID;
      tmpTW=retStruct.TimeWindow;
      d.TimeWindow.Choice=tmpTW.Choice;
      d.TimeWindow.Time1=tmpTW.Time1;
      d.TimeWindow.Time2=tmpTW.Time2;
      d.TimeWindow.StartTrigger=tmpTW.StartTrigger;
      d.TimeWindow.StopTrigger=tmpTW.StopTrigger;
		d.total_window_ticks=d.TimeWindow.Time2*(d.MillisamplesPerSecond/1000000);
      %		d.TimeWindow=retStruct.TimeWindow;


      % read the meatype if it was set with writemeatype

      switch retStruct.SourceType
      case 0
          d.meatype='nogrid';
      case 1
          d.meatype='8x8';
      case 2
          d.meatype='2x8x8';
      end

      d.TotalChannels = retStruct.TotalChannels;
		for i=1:d.StreamCount
			validChannels=find(retStruct.ChannelID(:,i)+1)+(i-1)*max(d.NChannels2);
			d.HardwareChannelID2{i}=retStruct.ChannelID(validChannels)+1;
         d.HardwareChannelNames2{i}=retStruct.ChannelNames(validChannels);
         if strcmp(d.meatype,'nogrid') 
            tmpsort = d.HardwareChannelID2{i};
            tmpsortIdx = [1:length(d.HardwareChannelID2{i})];
         else
            [tmpsort,tmpsortIdx] = sort(d.HardwareChannelID2{i});
         end
         d.ChannelNames2{i}=d.HardwareChannelNames2{i}(tmpsortIdx); 
         d.ChannelID2{i}=d.sorterleft(tmpsort)';
         if(strcmp(d.StreamNames(i),'Electrode Raw Data') | ...
					strcmp(d.StreamNames{i}(1:5),'Analog Raw Data'))
				if length(d.sweepStartTime)>1
					d.DataType='raw triggered';
					% d.total_window_ticks=retStruct.SweepLength*(d.MillisamplesPerSecond/1000000);
				else
					d.DataType='raw continous';
				end
				if(strcmp(d.StreamNames(i),'Electrode Raw Data'))
					d.ZeroADValue=d.ZeroADValue2(i);
					d.MicrovoltsPerAD=d.MicrovoltsPerAD2(i);
					d.NChannels=d.NChannels2(i);
					d.ChannelID=d.ChannelID2{i};
					d.HardwareChannelID=d.HardwareChannelID2{i};
					d.HardwareChannelNames=d.HardwareChannelNames2{i};
					d.ChannelNames=d.ChannelNames2{i};
				end
			end
		end
		tmp=retStruct.RecordingDate;
      d.recordingdate=datenum(tmp(1),tmp(2),tmp(3),tmp(4),tmp(5),tmp(6));
		tmp=retStruct.RecordingStopDate;
      d.recordingStopDate=datenum(tmp(1),tmp(2),tmp(3),tmp(4),tmp(5),tmp(6));
	   disp(['Recording date:  ' datestr(d.recordingdate,0)]);
		disp(['streams in OLE-opened file:' ])
		disp(d.StreamNames)
   else           % i.e. file recorded with old MCRack version
      d=newd;
		d.HardwareChannelID=d.ChannelID;
		d.triggerChannel=d.sorterleft(d.triggerChannel+1);                          % 31=#47 default!
      
      d=setpos(d,'sweep',1);
      d.ChannelID= d.sorterleft(d.HardwareChannelID); 		                      
      d.HardwareChannelNames=d.ChannelNames;
      d.triggerChannel=d.sorterleft(d.triggerChannel+1);                            % 31=#47 default!
      d.ChannelNames = d.HardwareChannelNames;
   end
end;
