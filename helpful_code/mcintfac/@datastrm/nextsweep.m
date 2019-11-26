function a = nextsweep(d,varargin);
% nextsweep - reads the next sweep (datastream method)
% a = nextsweep(d,varargin) takes an datastrm object and 
% starttime / endtime (within sweep) as optional 2. and 3. parameter
%
% optional 4. and further parameters: 
% 'hold' for holding file position (don't move to next sweep)
% 'originorder' for not sorting channels in 8x8 mea configuration
% return value is a cell with sweepStartTime (ms) and sweepValues (AD values)

rawData=(strcmp(d.DataType,'raw triggered'));
rawData=rawData|(strcmp(getfield(d,'DataType'),'raw continous'));
if ~rawData	
	error(['nextsweep works only on raw continous and raw triggered not on ' d.DataType]);
end;

%default configuration
returnunit='AD';
hold=0;
fill68=1;
%default configuration end
originorder='off';
sweeplength=(d.MicrosecondsPerTick*d.total_window_ticks)/1000;
if size(varargin,2)==0
   startTime=0;
   endTime=sweeplength;
elseif size(varargin,2)==2
   startTime=varargin{1};
   endTime	=min(varargin{2},sweeplength);
elseif size(varargin,2)>=3
	startTime=varargin{1};
   endTime	=min(varargin{2},sweeplength);
   for i=3:2:size(varargin,2)
		switch lower(varargin{i})
			case {'returnunit'},
				returnunit=varargin{i+1};
			case {'hold'},
				hold=strcmp(lower(varargin{i+1}),'on');
			case {'originorder'},
				fill68=~strcmp(lower(varargin{i+1}),'on');
				originorder=lower(varargin{i+1});
		end
	end
else error('nextsweep takes 1, 3 or more parameters');
end

if (strcmp(d.fileaccess,'ole'))
   msPerTick=getfield(d,'MicrosecondsPerTick')/1000;
	if strcmp(getfield(d,'DataType'),'raw continous')
		error('please use nextdata for raw continous');
	end
	tmp.function='GetSweepNumber';
	test=mcstreammex(tmp);
	if test.SweepNumber>length(d.sweepStartTime)
		error('end of file reached')
	end
	a.sweepStartTime=d.sweepStartTime(test.SweepNumber);
   endTime=endTime-rem(endTime,msPerTick);
   startTime=startTime-rem(startTime,msPerTick);
   startend=[startTime endTime]+a.sweepStartTime;
	if ~hold
		tmp.function='SetSweepNumber';
		tmp.SweepNumber=test.SweepNumber+1;
		test=mcstreammex(tmp);
   end
   spikestream=getstreamnumber(d,'Spikes 1');
   if (spikestream > 0)
      sinfo=getfield(d,'StreamInfo');
      pre=sinfo{spikestream}.PreTrigger;
      post=sinfo{spikestream}.PostTrigger; %not used
		ce=zeros(64,(endTime-startTime+post)/msPerTick)+d.ZeroADValue;
      cs=nextdata(d,'streamname','Spikes 1','originorder','off','startend',startend,'warning','off');
      for ic=1:64
         spkt=cs.spiketimes{ic};
         spkv=cs.spikevalues{ic};
         for is=1:length(spkt)
            spkstart=max(round((spkt(is)-pre-startend(1))/msPerTick),1);
            ce(ic,[spkstart:spkstart+size(spkv,1)-1])=spkv(:,is)';
         end
      end
	   a.sweepValues = ce(:,1:(endTime-startTime)/msPerTick);
   else
		ce=nextdata(d,'streamname','Electrode Raw Data','originorder',originorder,'startend',startend,'warning','off');
	   ca=nextdata(d,'streamname','Analog Raw Data','sorterleft',[[1:60] 1 2 3 4]-1,'originorder',originorder,'startend',startend,'warning','off');
      if(size(ca.data,2)==0)
         % catches an error in MCRACK 1.29 
         ca.data=zeros(4,size(ce.data,2));
      end;
	   a.sweepValues = [ce.data;ca.data];
   end
   
   
	if(returnunit=='uV' | returnunit=='µV' | returnunit=='uv')
		a.sweepValues = (a.sweepValues-d.ZeroADValue) * d.MicrovoltsPerAD;	% auf uV umrechnen
	elseif(returnunit=='mV' | returnunit=='mv')
		a.sweepValues = (a.sweepValues-d.ZeroADValue) * (d.MicrovoltsPerAD/1000);	% auf mV umrechnen
	elseif(returnunit=='V' | returnunit=='v')
		a.sweepValues = (a.sweepValues-d.ZeroADValue) * (d.MicrovoltsPerAD/1000000);	% auf V umrechnen
	end;
   a.startend = [startTime,endTime];
	return
end

if ftell(d.fid)==d.filesize
	error('end of file reached')
end;

startPos=ceil(startTime*1000/d.MicrosecondsPerTick);		% in ticks
endPos=floor(endTime*1000/d.MicrosecondsPerTick);	 		% in ticks

% ---- some preparations ------------------------------------------------------------------------------------------
if fill68
	sweepValues = zeros(68, endPos-startPos)+d.ZeroADValue;		% accelerates the actual reading process
	sortedChannelID=d.sorterleft(d.HardwareChannelID)';
else
	sweepValues = zeros(d.NChannels, endPos-startPos)+d.ZeroADValue;		% accelerates the actual reading process
	sortedChannelID=[1:d.NChannels];
end;
% ---- read analog data ------------------------------------------------------------------------------------------


origPos=ftell(d.fid);
samplecounter = 0;
started=0;
while samplecounter < d.total_window_ticks
	lastPos=ftell(d.fid);
	timebin = fread(d.fid, [1,2], 'ulong');			% Startzeit des Sweeps (binär)
	if samplecounter == 0
		sweepStartTime = (timebin(2)*2^32+timebin(1))*d.MicrosecondsPerTick/1000;
	end;
	nSamples = fread(d.fid, 1, 'ushort');				% Anzahl der samples pro Kanal
   switch started
	   case 0
		   if samplecounter+nSamples>startPos
            fseek(d.fid,(startPos-samplecounter)*d.NChannels*2,0);			% go ahead
				if samplecounter+nSamples>=endPos
	            started=2;
					sweepValues(sortedChannelID,1:endPos-startPos) ...
						= fread(d.fid, [d.NChannels,endPos-startPos], 'ushort');
					fseek(d.fid,(samplecounter+nSamples-endPos)*d.NChannels*2,0);			% go ahead
				else
	            started=1;
					sweepValues(sortedChannelID,1:samplecounter+nSamples-startPos) ...
						= fread(d.fid, [d.NChannels,samplecounter+nSamples-startPos], 'ushort');
				end;
         else
				fseek(d.fid,nSamples*d.NChannels*2,0);			% go ahead
			end;
      case 1
		   if samplecounter+nSamples<endPos
				sweepValues(sortedChannelID,samplecounter-startPos+1: ...
						samplecounter+nSamples-startPos) ...
					= fread(d.fid, [d.NChannels,nSamples], 'ushort');
         else
	         started=2;
				sweepValues(sortedChannelID,samplecounter-startPos+1:endPos-startPos) ...
					= fread(d.fid, [d.NChannels,endPos-samplecounter], 'ushort');
				fseek(d.fid,(samplecounter+nSamples-endPos)*d.NChannels*2,0);			% go ahead
			end;
      case 2
			fseek(d.fid,nSamples*d.NChannels*2,0);			% go ahead
	end;
	samplecounter = samplecounter + nSamples;
	if (ftell(d.fid)-lastPos)~=((nSamples*d.NChannels*2)+10)
		error('illogical in nextsweep.m or corrupted file');
	end;
%	disp(['samplecounter: ' int2str(samplecounter) ', #Samples = ' int2str(nSamples)])
%  disp(['pos ' num2str(ftell(d.fid))]);
end;

if hold
	fseek(d.fid,origPos-ftell(d.fid),0);
end;

% ------- Spannungen in µV umrechnen ----------------------------------------------

if(returnunit=='uV' | returnunit=='µV' | returnunit=='uv')
	sweepValues = (sweepValues-d.ZeroADValue) * d.MicrovoltsPerAD;	% auf uV umrechnen
elseif(returnunit=='mV' | returnunit=='mv')
	sweepValues = (sweepValues-d.ZeroADValue) * (d.MicrovoltsPerAD/1000);	% auf mV umrechnen
elseif(returnunit=='V' | returnunit=='v')
	sweepValues = (sweepValues-d.ZeroADValue) * (d.MicrovoltsPerAD/1000000);	% auf V umrechnen
end;

a.sweepStartTime = sweepStartTime;
a.sweepValues = sweepValues;
a.startend = [startTime,endTime];
