function display(d)
% Command window display


disp(' ');

if d.fid>0 & ~strcmp(d.fileaccess,'ole')
   tmp={'filename'
      'fileaccess'  
      'fid'   
      'version'
      'filesize'
      'DataType'
      'MicrovoltsPerAD'
      'ZeroADValue'
      'MicrosecondsPerTick'
      'NChannels'
      'ChannelID'
      'HardwareChannelID'
      'ChannelNames'
      'HardwareChannelNames'
      'total_window_ticks'
      'offset_to_data'
      'recordingdate'
      'sweepStartTime'
      'sweepStartPointer'
      'windowTicksPos'
      'triggerChannel'
      'spikeSize'
      'ticks_pre_event'
      'BitFlipRemoveFactor'
   		};
   
   for i=1:size(tmp,1);
	   entry = eval(['d.' tmp{i}]);
      if (isa(entry, 'double') & (length(entry) == 1)) | isa(entry, 'char')
         disp([tmp{i} blanks(24-length(tmp{i})) num2str(entry)]);
      else
         disp([tmp{i} blanks(24-length(tmp{i})) class(entry) ...
               '  (' num2str(size(entry)) ')']);
      end
   end   
      
	disp(' ');   
   try
	   disp([d.filename '  ' datestr(d.recordingdate, 1) ...
            '  (' num2str(ftell(d.fid)) ' / ' num2str(d.filesize) ')']);
   catch
		warning([d.filename '  ' datestr(d.recordingdate, 1) ' must be opened for reading']);
   end
else
   tmp={'filename'
   	'fileaccess'
		'version'
      'softwareversion'
      'meatype'
		'filesize'
		'MicrovoltsPerAD2'
		'MicrosecondsPerTick'
		'MillisamplesPerSecond2'
		'ZeroADValue'
		'ZeroADValue2'
      'TotalChannels'
      'NChannels2'
		'ChannelNames2'
		'HardwareChannelNames2'
		'ChannelID2'
		'HardwareChannelID2'
		'recordingdate'
		'recordingStopDate'
		'sweepStartTime'
      'sweepStopTime'
		'StreamCount'
		'StreamNames'
		'StreamInfo'
		'TriggerStreamID'
      'TimeWindow'
      };
   for i=1:size(tmp,1);
	   entry = eval(['d.' tmp{i}]);
      if (isa(entry, 'double') & (length(entry) == 1)) | isa(entry, 'char')
         disp([tmp{i} blanks(24-length(tmp{i})) num2str(entry)]);
      else
         disp([tmp{i} blanks(24-length(tmp{i})) class(entry) ...
               '  (' num2str(size(entry)) ')']);
      end
   end   
      
end
