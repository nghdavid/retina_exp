function c = nextraw(d,startTime,endTime,varargin);
% nextraw - calls nextsweep to read in continous raw (datastream method)
% c = nextraw(d,startTime,endTime,varargin) 
% return value is a cell with sweepStartTimes (ms) and sweepValues (AD values)


if (strcmp(d.fileaccess,'ole'))
	if isempty(varargin)
		a=nextdata(d,'startend',[startTime,endTime]);
	else
      tmp={'startend',[startTime,endTime],varargin{:}};
		a=nextdata(d,tmp{:});     
	end
	c.sweepStartTime=startTime;
	c.sweepValues=a.data;
   c.startend = [startTime,endTime];
	return;
end;

if(~strcmp(class(d),'datastrm'))
	error('first argument must be a datastrm object');
end;
rawData=strcmp(getfield(d,'DataType'),'raw continous');
if ~rawData
	error(['nextraw works only on raw continous not on ' d.DataType]);
end;

startSweep=max(find(d.sweepStartTime<=startTime));
endSweep	=min([find(d.sweepStartTime>endTime);length(d.sweepStartTime)+1])-1;

nSweeps=endSweep-startSweep+1;

segCount=0;
msPerT=d.MicrosecondsPerTick/1000;
c.sweepStartTime=startTime;
c.sweepValues=[];
c.startend=[startTime,endTime];
d=setpos(d,'sweep',startSweep);
while segCount<nSweeps
	startT= max([0;startTime-d.sweepStartTime(startSweep+segCount)]);
	endT= min([1536;endTime-d.sweepStartTime(startSweep+segCount)]);
	segCount=segCount+1;
	if isempty(varargin)
		cneu=nextsweep(d,startT,endT);
	else
		cneu=nextsweep(d,startT,endT,varargin);
	end
	c.sweepValues=[c.sweepValues,cneu.sweepValues];
end;

