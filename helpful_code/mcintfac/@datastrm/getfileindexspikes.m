function a=getfileindexspikes(d)
% getfileindexspikes - get the file indexes of all segments (datastrm method)
%
% Usage:
% a=getfileindexspikes(d)

error('getfileindexspikes code is now in MEX file GetFileEntries');

disp('segment indexes are needed for the first time and are now read');
drawnow;

fseek(d.fid,d.offset_to_data,-1);
i=0;
segmentPointer=zeros(56250,1); %enough for 2 hours
segmentStartTime=zeros(56250,1);
maxSpkPerSegmPerChanl=zeros(56250,1);
nPointsPerSegement=zeros(56250,1);

while ftell(d.fid)<d.filesize
	i=i+1;
	segmentPointer(i)=ftell(d.fid);
	timebin = fread(d.fid, [1,2], 'ulong');				% Startzeit des Sweeps (binär)
	sweepStartTime = (timebin(2)*2^32+timebin(1))*d.MicrosecondsPerTick/1000;
	segmentsamples = fread(d.fid,1,'ushort');	% no. of samples in segment. 3200 (always)
	timebin = fread(d.fid, [1,2], 'ulong');				% Startzeit des Sweeps (binär)
	segmentStartTime(i) = (timebin(2)*2^32+timebin(1))*d.MicrosecondsPerTick/1000;
	segmentsamples = fread(d.fid,1,'ushort');	% no. of samples in segment. 3200 (always)
	if segmentsamples ~= 3200
		error('unexpected data-file structure, value segmentsamples is not valid (~=3200)')
	end;
	nChannels = fread(d.fid,1,'ulong');					% number of spike lists in segment (immer 64, je Kanal 1)
	if nChannels ~= 64
		error('unexpected data-file structure, value end1 is not valid (~=64)')
	end;
	for i1=1:nChannels											% Kanal nummer (0-63) in der ausgewählten Reihenfolge, 
		%read in spike list								  also gewählte Kanäle zuerst, dann alle nicht gewählten mit Einträgen von 0 Spikes!!!
		nSpikes = fread(d.fid,1,'ulong');		% number of spikes in list (i.e. spikes auf diesem Kanal in diesem Segment)
		if nSpikes>0
			timebin = fread(d.fid, [1,2], 'ulong');	
			d.ticks_pre_event = fread(d.fid,1,'ushort');	%ticks pre event
			d.spikeSize  = fread(d.fid,1,'ushort');		% window size in ticks, i.e. # of samples in this trace
			fseek(d.fid,nSpikes*(d.spikeSize*2)+(nSpikes-1)*(8+2+2),0);
			if (nSpikes>maxSpkPerSegmPerChanl(i))
				maxSpkPerSegmPerChanl(i)=nSpikes;
			end;
			nPointsPerSegement(i) = nPointsPerSegement(i) + nSpikes*d.spikeSize;
		end;
	end; 
end;
d.sweepStartTime = segmentStartTime(1:i);
d.sweepStartPointer = segmentPointer(1:i);
d.maxSpkPerSegmPerChanl = maxSpkPerSegmPerChanl(1:i);
d.nPointsPerSegement = nPointsPerSegement(1:i);
fseek(d.fid,d.offset_to_data,-1);
a=d;