function streamnumber=getstreamnumber(d,streamname);
% getstreamnumber - returns streamnumber of streamname (datastream method)
% streamnumber=getstreamnumber(d,streamname) returns streamnumber of 
% streamname <streamname> in the datastream object <d> (MATLAB-index, C-index+1).

streamnumber = -1;
for i=1:length(d.StreamNames)
	if strcmp(streamname,d.StreamNames{i})
		streamnumber=i;
		break;
	end;
end;
