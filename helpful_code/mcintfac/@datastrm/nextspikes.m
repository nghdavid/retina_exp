function c=nextspikes(d,outputType,varargin)
% nextspikes - reads in spike data (datastream method)
% c=nextspikes(datastrn,outputType,varargin) reads in spike data according 
% to outputType spike: spikes (i.e. 64-cell array with spikes on each channel)
% timevalue: times(ms)/values of raw data, eliminating overlapping spike data,
% raw data: spike data filled with zeros to desired raw data array
%
% Optional arguments: start and end time of desired data (up to now times 
% will automatically be aligned with enclosing 128ms-segment borders). If 
% no intervall is choosen, the next segment is given.

%configuration
rawdata=0;
%configuration end

if (strcmp(outputType,'raw data'))
	rawdata=1;
	outputType='timevalue';
end


if (~strcmp(d.DataType,'spike continous'))
%a=setfield(a,'DataType','spike continous');   
	error(['nextspikes up to now works only on spike continous not on ' d.DataType]);
end
if (~strcmp(outputType,'spike') & ~strcmp(outputType,'timevalue'))
	error('second argument must begin with spike, timevalue or raw data');
end

if ~(strcmp(d.fileaccess,'ole')) & (d.sweepStartPointer==0),
	evalin('base','a=setpos(a,''segment'',1)','error(''set position first with a=setpos(a...'')');
	c=0;
	warning('call last function again now (setpos war automatically called)');
	return;
end

channelSel=ones(68,1);
if size(varargin,2)==0		%no intervall choosen, just take next segement
	startSegm=min(find(d.sweepStartPointer>=ftell(d.fid)));
	endSegm	=startSegm+1;	%not to be read!
elseif size(varargin,2)>=2
   startTime=varargin{1};
   endTime	=varargin{2};
   if ~(strcmp(d.fileaccess,'ole'))
      startSegm=max(max(find(d.sweepStartTime<=startTime))-1,1); %begin 1 segment earlier and end 1 later
      endSegm	=min([find(d.sweepStartTime>endTime);length(d.sweepStartTime)])+1; %not to be read!
   end
	if size(varargin,2)==3
		channelSel=zeros(68,1);
		channelSel(varargin{3})=1;
	end
	if size(varargin,2)>3
		error('nextspikes takes 2,4 or 5 parameters');
	end
else error('nextspikes takes 2,4 or 5 parameters');
end

if (strcmp(d.fileaccess,'ole'))
   spikestream=getstreamnumber(d,'Spikes 1');
   if (spikestream > 0) & rawdata
      msPerTick=getfield(d,'MicrosecondsPerTick')/1000;
      sinfo=getfield(d,'StreamInfo');
      pre=sinfo{spikestream}.PreTrigger;
      post=sinfo{spikestream}.PostTrigger; %not used
      ce=zeros(64,(endTime-startTime+post)/msPerTick)+d.ZeroADValue;    
      cs=nextdata(d,'streamname','Spikes 1','originorder','off','startend',[startTime endTime],'warning','off');
      for ic=1:64
         spkt=cs.spiketimes{ic};
         spkv=cs.spikevalues{ic};
         for is=1:length(spkt)
            spkstart=max(round((spkt(is)-pre-startTime)/msPerTick),1);
            ce(ic,[spkstart:spkstart+size(spkv,1)-1])=spkv(:,is)';
         end
      end
		c.spiketimes=[];
		c.spikevalues=ce;
      c.startend=[startTime endTime];
      return;
   else   
      error(['nextspikes can only return outputType raw data for OLE-Object read spikes']);
   end
end

nSegments=endSegm-startSegm;
startPointer=d.sweepStartPointer(startSegm);

tmp=d.sorterleft(d.HardwareChannelID);
sortedChannelID=[tmp setdiff([1:68],tmp)]';	%not recorded channel are appended!

nChannels=68;
c=cell(nChannels,2);	   
spikeCount=zeros(nChannels,1);
for i1=1:nChannels
	%highest rate channel defines memory use!
	maxMem=0;
	if channelSel(sortedChannelID(i1))
		maxMem=sum(d.maxSpkPerSegmPerChanl(startSegm:endSegm-1));
	end
	if (strcmp(outputType,'spike'))
		c{i1,1}=zeros(maxMem,1); 				%spiketimes
		c{i1,2}=zeros(maxMem,d.spikeSize);	%spikevalues
	else %timevalue
		c{i1,1}=zeros(maxMem*(d.spikeSize+2),1);	%times
		c{i1,2}=zeros(maxMem*(d.spikeSize+2),1);	%values
	end
end
lastSpikeEnd=ones(68,1)*d.sweepStartTime(startSegm);

fseek(d.fid,startPointer,'bof');
segCount=0;
msPerT=d.MicrosecondsPerTick/1000;
while segCount<nSegments
	segCount=segCount+1;
	timebin = fread(d.fid, [1,2], 'ulong');				% Startzeit des Segments 
	sweepStartTime = (timebin(2)*2^32+timebin(1))*msPerT;

	segmentsamples = fread(d.fid,1,'ushort');	% no. of samples in segment. 3200 (always)
																		%2 mal? warum?
	timebin = fread(d.fid, [1,2], 'ulong');				% Startzeit des Sweeps (binär)
	sweepStartTime = (timebin(2)*2^32+timebin(1))*msPerT;
	segmentsamples = fread(d.fid,1,'ushort');	% no. of samples in segment. 3200 (always)
	if segmentsamples ~= 3200
		error('unexpected data-file structure, value segmentsamples2 is not valid (~=3200)')
	end
	lokNChannel = fread(d.fid,1,'ulong');					% number of spike lists in segment (immer 64, je Kanal 1)
	if lokNChannel ~= 64
		error('unexpected data-file structure, value nChannels is not valid (~=64)')
	end
	for i1=1:lokNChannel													% Kanal nummer (0-63) in der ausgewählten Reihenfolge, 
		%read in spike list										  also gewählte Kanäle zuerst, dann alle nicht gewählten mit Einträgen von 0 Spikes!!!
		nSpikes = fread(d.fid,1,'ulong');			% number of spikes in list (i.e. spikes auf diesem Kanal in diesem Segment)
		for i2=1:nSpikes,											% spike number
			%read in spike:
			timebin = fread(d.fid, [1,2], 'ulong');		% Startzeit des Sweeps (binär)
			spiketime = (timebin(2)*2^32+timebin(1))*msPerT;		% reformat to ms 
			ticks_pre_event  = fread(d.fid,1,'ushort');	%ticks pre event
			spikeSize  = fread(d.fid,1,'ushort');			% window size in ticks, i.e. # of samples in this trace
			tmp= fread(d.fid,[1,spikeSize],'short');	%spikevalues
			if (spikeSize/2==floor(spikeSize/2))
				pFac=0;
			else
				pFac=+1;
			end
			peak = tmp(ticks_pre_event-1+pFac:ticks_pre_event+1+pFac)-d.ZeroADValue;
			if channelSel(sortedChannelID(i1)) & ...
				(~d.BitFlipRemoveFactor | ...
							( abs(peak(2))*d.BitFlipRemoveFactor < abs(peak(1)) ...
								  & abs(peak(2))*d.BitFlipRemoveFactor < abs(peak(3)) ) )	%remove peak if very sharp
				if (strcmp(outputType,'spike'))
					spikeCount(i1)=spikeCount(i1)+1;
					c{sortedChannelID(i1),1}(spikeCount(i1))=spiketime;														%spiketimes
					c{sortedChannelID(i1),2}(spikeCount(i1),1:spikeSize)= tmp;	%spikevalues
				else %timevalue
					spkStartTick=round(((spiketime-d.sweepStartTime(startSegm))/msPerT)-ticks_pre_event+1); %round for heavens sake
					ticksSinceLast=round(((spiketime-lastSpikeEnd(i1))/msPerT)-ticks_pre_event+1); %round for heavens sake
					if ticksSinceLast>2 & spikeCount(i1)>1	 %set two adjacent zero values for drawing!
						c{sortedChannelID(i1),1}(spikeCount(i1)+1)=lastSpikeEnd(i1)+msPerT;
						c{sortedChannelID(i1),2}(spikeCount(i1)+1)=d.ZeroADValue;
						c{sortedChannelID(i1),1}(spikeCount(i1)+2)=d.sweepStartTime(startSegm)+(spkStartTick-1)*msPerT;
						c{sortedChannelID(i1),2}(spikeCount(i1)+2)=d.ZeroADValue;
						spikeCount(i1)=spikeCount(i1)+2;
					end
					if ticksSinceLast<1	
						ticksInPrevSegm=abs(ticksSinceLast)+1;
						spkStartTick=spkStartTick+ticksInPrevSegm;
						tmp=tmp(ticksInPrevSegm+1:spikeSize); %throw away overlap
						spikeSize=spikeSize-ticksInPrevSegm;
					end
					c{sortedChannelID(i1),1}(spikeCount(i1)+1:spikeCount(i1)+spikeSize)= ...
							d.sweepStartTime(startSegm)+[spkStartTick:spkStartTick+spikeSize-1]*msPerT;	%times
					c{sortedChannelID(i1),2}(spikeCount(i1)+1:spikeCount(i1)+spikeSize)= tmp;				%values
					spikeCount(i1)=spikeCount(i1)+spikeSize;
					lastSpikeEnd(i1)=c{sortedChannelID(i1),1}(spikeCount(i1));
				end
			end
		end
	end
end

for i1=1:nChannels
	c{sortedChannelID(i1),1}=c{sortedChannelID(i1),1}(1:spikeCount(i1),:); 	%spiketimes, sized as needed
	c{sortedChannelID(i1),2}=c{sortedChannelID(i1),2}(1:spikeCount(i1),:);	%spikevalues, sized as needed
end

newc.spiketimes={c{:,1}};
newc.spikevalues={c{:,2}};
newc.startend=[(startSegm-1) (endSegm-1)]*128;

if rawdata
	%fill timevalue data with zeros
	minT=startTime;
	maxT=endTime;
	maxTick=ceil((maxT-minT)*1000/d.MicrosecondsPerTick);
	val=zeros(sum(channelSel),maxTick)+d.ZeroADValue;
	count=0;
	for i1=1:nChannels
      if channelSel(i1) 
         count=count+1;
         tmpT=newc.spiketimes{i1};
         minIdx=min(find(tmpT>=minT));
         maxIdx=max(find(tmpT<(maxT-d.MicrosecondsPerTick/1000/2)));
         if ~isempty(minIdx)& ~isempty(maxIdx)
            idxT=round((tmpT-startTime)*1000/d.MicrosecondsPerTick)+1;
            idxT=idxT(minIdx:maxIdx);
            val(count,idxT)=newc.spikevalues{i1}(minIdx:maxIdx)';
         end
      end
   end
	newc.spiketimes=[];
	newc.spikevalues=val;
	newc.startend=[startTime endTime];
end

c=newc;

return;

