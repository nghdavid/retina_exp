function a = setpos(d,posType,posValue);
% setpos_silent - set the file position in a datastream (datastream method)
% a = setpos_silent(d,posType,posValue) takes an datastrm object 
% and the position type ('time','sweep','segment') and the
% position value (time in ms, sweep for triggered raw date 
% and segment for spike data as integer) return value is the 
% updated datastrm.
%
% In contrast to datastrm\setpos.m does not check for some errors
% and doesn't return any warnings or messages.

if (strcmp(d.fileaccess,'ole'))
	error(['setpos up to not adapted for OLE-Object']);
end;

if not(strcmp(posType,'time') | strcmp(posType,'sweep') | strcmp(posType,'segment'))
	error('the second argument must be ''time'' or ''sweep'' or ''segment''');
end;


if d.sweepStartPointer == 0
%%%%% ab %%%%%	disp('sweep/segment indexes are needed for the first time and are now read');
	drawnow
	if strcmp(d.DataType,'spike continous')
		sorterleft=[31,32,30,29,24,23,16,22,15,7,14,6,21,13,5,4,12,20,3,11,2,10,19,9,18,17,28,27,25,26,34,33,35,36,41,42,49,43,50,58,51,59,44,52,60,61,53,45,62,54,63,55,46,56,47,48,37,38,40,39,65,66,67,68,1,8,57,64];
		tmp=sorterleft(d.ChannelID);
		sortedChannelID=[tmp setdiff([1:68],tmp)]';	%not recorded channel are appended!
		y=GetFileEntries(d.filename,d.offset_to_data,sortedChannelID,d.BitFlipRemoveFactor);
		d.sweepStartPointer = y(1,:)';
		d.sweepStartTime = ((y(2,:)*2^32+y(3,:))*d.MicrosecondsPerTick/1000)';
		d.maxSpkPerSegmPerChanl = y(4,:)';
		d.nSpikesPerSegement = y(5,:)';
		d.nSpkPerSegPerChanl = y(6,:)'; %eg. plot(bitand(y(3:8:size(y,2)),16*16*16*16*15))
	else %raw triggered up to now
		d=getfileindex(d);
	end;
end;

if strcmp(posType,'sweep') | strcmp(posType,'segment')
	if floor(posValue) > size(d.sweepStartPointer,1)
		warning(['sweep/segment ' num2str(posValue) ' is beyond file scope']);
	else
		pos=floor(posValue);	%be sure to have an integer
		fseek(d.fid,d.sweepStartPointer(pos),-1);
	end;
else
	t=find(d.sweepStartTime>=posValue);
	if isempty(t)
		warning(['time ' num2str(posValue) ' ms is beyond file scope']);
	else
		pos=t(1);
		fseek(d.fid,d.sweepStartPointer(pos),-1);
	end;
end;

a=d;
