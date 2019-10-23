function a = setpos(d,posType,posValue);
% setpos - set the file position in a datastream (datastream method)
% a = setpos(d,posType,posValue) takes an datastrm object and 
% the position type ('time','sweep','segment') and the
% position value (time in ms, sweep for triggered raw date 
% and segment for spike data as integer) return value is the 
% updated datastrm.

if (strcmp(d.fileaccess,'ole'))
	if not(strcmp(posType,'sweep'))
		error(['with OLE-Object the second argument for setpos must be ''sweep''']);
	end
else
	if not(strcmp(posType,'time') | strcmp(posType,'sweep') | strcmp(posType,'segment'))
		error('the second argument for setpos must be ''time'' or ''sweep'' or ''segment''');
	end
end

if (strcmp(d.fileaccess,'ole'))
	a=d;
	if posValue > length(d.sweepStartTime)
		warning(['sweep ' num2str(posValue) ' is beyond file scope']);
		return
	end
	tmp.function='SetSweepNumber';
	tmp.SweepNumber=posValue;
	test=mcstreammex(tmp);
	return
end

if d.sweepStartPointer == 0
	disp('now reading sweep/segment indexes');
	drawnow
	if strcmp(d.DataType,'spike continous')
		tmp=d.sorterleft(d.HardwareChannelID);
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
