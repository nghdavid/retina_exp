function a = getpos(d,posType);
% getpos - return the current position of the datastrm object (datastrm method)
% a = getpos(d,posType) takes an datastrm object and the position type ('time','sweep','segment')
% return value is the current position of the datastrm object

if (strcmp(d.fileaccess,'ole'))
	error([mfilename ' not yet adapted for OLE-Object']);
end;

if (nargin == 1)
  posType = 'sweep';
end

if strcmp(posType,'sweep') | strcmp(posType,'segment')
  a = find(d.sweepStartPointer == ftell(d.fid));
else % posType == 'time'
  a = d.sweepStartTime(find(d.sweepStartPointer == ftell(d.fid)));
end