function c=segregate(d,varargin)
% segregate - extracts synchronous start and end points of fields/spike events
% c=segregate(d,varargin) Reads through spike data and extracts 
% start and end points of fields/spike events coherent on all 
% channels.
%
% Following 'segTime', the maximal allowed intervall in ms 
%     between to coherent fields can be given (default 20 ms).
% Following 'startend', the region of interest as array of 
%     two values in ms can be given (default whole file)
% Following 'minLength', the minimum length of coherent fields 
%     not to be discarded can be given (default is length of cutout).
%
% return value:
% format des return wertes: 
% ((number of segregates*68),3) Matrix with begin time, end time 
% and active channel of coherent fields sorted by channelnumber 
% (not active channels times are set to zero).

%defaults start
segTime=1; %in ms
startTime=0;
minLength=0;
endTime=d.sweepStartTime(length(d.sweepStartTime));
eventsPerSec=1;
minChannelNum=1;
%defaults end

if (d.DataType ~= 'spike continous')
	error(['segregate up to now works only on spike continous not on ' d.DataType]);
end;

if d.sweepStartPointer==0,
	evalin('base','a=setpos(a,''segment'',1)','error(''set position first with a=setpos(a...'')');
	c=0;
	warning('call last function again now (setpos war automatically called)');
	return;
end;

for iarg=1:2:size(varargin,2)
	switch lower(varargin{iarg})
		case {'segtime'},
			segTime=varargin{iarg+1};
		case {'startend'},
			startTime=varargin{iarg+1}(1);
			endTime=varargin{iarg+1}(2);
		case {'minlength'},
			minLength=varargin{iarg+1};
		case {'eventsPerSec'},
			eventsPerSec=varargin{iarg+1};
		case {'minChannelNum'},
			minChannelNum=varargin{iarg+1};
	end
end;

startSegm=max(find(d.sweepStartTime<=startTime));
endSegm	=min([find(d.sweepStartTime>endTime);length(d.sweepStartTime)]); %not to be read!

nSegments=endSegm-startSegm;
startPointer=d.sweepStartPointer(startSegm);

tmp=d.sorterleft(d.HardwareChannelID);
sortedChannelID=[tmp setdiff([1:68],tmp)]';	%not recorded channel are appended!

nChannels=68;
c=cell(nChannels,2);	   
spikeCount=zeros(nChannels,1);
memMax=round((endTime-startTime)/1000*eventsPerSec); %max eventsPerSec 
c=zeros(memMax*68,3);

fseek(d.fid,startPointer,'bof');
segCount=0;
msPerT=d.MicrosecondsPerTick/1000;
ci=1;
lastSegEnd=-5000;	%should not overlap with begin of first segment
while segCount<nSegments
	segCount=segCount+1;
	tci=0;
	tmpc=zeros(round(128*64/20),3);
	timebin = fread(d.fid, [1,2], 'ulong');				% Startzeit des Segments 
	sweepStartTime = (timebin(2)*2^32+timebin(1))*msPerT;
if sweepStartTime >383145
test='go';
end
	segmentsamples = fread(d.fid,1,'ushort');	% no. of samples in segment. 3200 (always)
																		%2 mal? warum?
	timebin = fread(d.fid, [1,2], 'ulong');				% Startzeit des Sweeps (binär)
	sweepStartTime = (timebin(2)*2^32+timebin(1))*msPerT;
	segmentsamples = fread(d.fid,1,'ushort');	% no. of samples in segment. 3200 (always)
	if segmentsamples ~= 3200
		error('unexpected data-file structure, value segmentsamples2 is not valid (~=3200)')
	end;
	lokNChannel = fread(d.fid,1,'ulong');					% number of spike lists in segment (immer 64, je Kanal 1)
	if lokNChannel ~= 64
		error('unexpected data-file structure, value nChannels is not valid (~=64)')
	end;
	lokSpkCnt=0;
	for i1=1:lokNChannel													% Kanal nummer (0-63) in der ausgewählten Reihenfolge, 
		%read in spike list										  also gewählte Kanäle zuerst, dann alle nicht gewählten mit Einträgen von 0 Spikes!!!
		nSpikes = fread(d.fid,1,'ulong');			% number of spikes in list (i.e. spikes auf diesem Kanal in diesem Segment)
		for i2=1:nSpikes,											% spike number
			%read in spike:
			timebin = fread(d.fid, [1,2], 'ulong');		% Startzeit des Sweeps (binär)
			spiketime = (timebin(2)*2^32+timebin(1))*msPerT;		% reformat to ms 
			ticks_pre_event  = fread(d.fid,1,'ushort');	%ticks pre event
			spikeSize  = fread(d.fid,1,'ushort');			% window size in ticks, i.e. # of samples in this trace
			tmp= fread(d.fid,[1,spikeSize],'short');	% spikevalues
			if (spikeSize/2==floor(spikeSize/2))
				pFac=0;
			else
				pFac=+1;
			end;  
			peak = tmp(ticks_pre_event-1+pFac:ticks_pre_event+1+pFac)-d.ZeroADValue;
			if ~d.BitFlipRemoveFactor | ...
							( abs(peak(2))*d.BitFlipRemoveFactor < abs(peak(1)) ...
								  & abs(peak(2))*d.BitFlipRemoveFactor < abs(peak(3)) )	%remove peak if very sharp
				lokSpkCnt=lokSpkCnt+1;
				tci=tci+1;
				tmpc(tci,1)= spiketime-ticks_pre_event*msPerT; % spike begin
				tmpc(tci,2)= tmpc(tci,1)+spikeSize*msPerT; % spike end
				tmpc(tci,3)= sortedChannelID(i1); % channel number
			end;
		end;
	end;
	if lokSpkCnt
		tmpc=tmpc(1:tci,:);
		tmpc=sortrows(tmpc,1);
		tmpSegIdx=find((tmpc(2:tci,1)-tmpc(1:tci-1,1)) > (segTime+spikeSize*msPerT));
%tmpSegIdx
		tmpSegStartIdx=[1;tmpSegIdx+1]; %all beginnings of segregats
		tmpSegEndIdx=[tmpSegIdx;tci]; %all ends of segregats
		minSegTimes=tmpc(tmpSegStartIdx,1);
		beginSeg=1;
		if lastSegEnd > minSegTimes(1)-segTime;
			%endzeit des letzten segregat für alle Kanäle hochsetzen, neue Kanäle hinzunehmen
			for i1=1:lokNChannel
				chan1Exist=(c((ci-1)*68+i1,3)==i1);
				chan2Idx=find(tmpc(tmpSegStartIdx(1):tmpSegEndIdx(1)-1,3)==i1);
				if chan2Idx & chan1Exist
					c((ci-1)*68+i1,2)=max(tmpc(chan2Idx,2));
				elseif chan2Idx
					c((ci-1)*68+i1,1)=min(tmpc(chan2Idx,1));
					c((ci-1)*68+i1,2)=max(tmpc(chan2Idx,2));
					c((ci-1)*68+i1,3)=i1;
				end;
			end;
			beginSeg=2;
		end;

		for is=beginSeg:length(tmpSegStartIdx)
			if sum(c((ci-1)*68+1:ci*68,3)./[1:68]') < minChannelNum
				ci=ci-1;
			end;
			tmpc2=zeros(68,3);
			for i1=1:lokNChannel
				chanIdx=find(tmpc(tmpSegStartIdx(is):tmpSegEndIdx(is),3)==i1);
				if chanIdx
					tmpc2(i1,1)=min(tmpc(tmpSegStartIdx(is)+chanIdx-1,1));
					tmpc2(i1,2)=max(tmpc(tmpSegStartIdx(is)+chanIdx-1,2));
					tmpc2(i1,3)=i1;
				end;
			end;
			c(ci*68+1:(ci+1)*68,:)=tmpc2;
			ci=ci+1;
		end;
		lastSegEnd=max(c((ci-1)*68+1:ci*68,2));

	end;
end;

c=c(1:ci*68,:);