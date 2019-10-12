function a = getfileindex(d);
% getfileindex - generate an index of entries in datastream objects (datastrm method)
% a = getfileindex(d) takes a datastrm object <d> and 
% and makes an index of entries (filepositions).

fseek(d.fid,d.offset_to_data,-1);

nSweep=floor((d.filesize-d.offset_to_data+1)/(d.total_window_ticks*d.NChannels*2));
				%nSweep is only a estimate!!
d.sweepStartTime = zeros(nSweep,1);
d.sweepStartPointer = zeros(nSweep,1);
i=0;
while ftell(d.fid)<d.filesize
	i=i+1;
	samplecounter = 0;
	while samplecounter < d.total_window_ticks
		timebin = fread(d.fid, [1,2], 'ulong');			% Startzeit des Sweeps (binär)
		if isempty(timebin)
			i=i-1;
			break;
		end;
		if samplecounter == 0
			d.sweepStartTime(i) = (timebin(2)*2^32+timebin(1))*d.MicrosecondsPerTick/1000;
			d.sweepStartPointer(i) = ftell(d.fid)-8;
		end;
		nSamples = fread(d.fid, 1, 'ushort');				% Anzahl der samples pro Kanal
		if isempty(nSamples)
			i=i-1;
			break;
		end;
		fseek(d.fid,nSamples*d.NChannels*2,0);
		samplecounter=samplecounter+nSamples;
	end;
end;
d.sweepStartTime = d.sweepStartTime(1:i);
d.sweepStartPointer = d.sweepStartPointer(1:i);

fseek(d.fid,d.offset_to_data,-1);
a=d;