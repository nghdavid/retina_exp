function field=getfield(d,name, idx)
% getfield - returns any datastream fields content (datastrm method)
% field = getfield(d,name, idx) returns the content
% of the field <name> in the datastream object <d>
%
% If <name> has more than one elements these can
% be indexed with <idx>, which must be a cell array
% of integers.
%
% Example
% If 'MCRackdatafile.0000' were a file with 2 datastreams
% e.g. 'Spikes 1' and 'Trigger 1', then
%
% d = datastrm('MCRackdatafile.0000');
% SN = getfield(d, 'StreamNames', {1}); 
%
% will return the first of the stream names only.

ds = struct(d);
if nargin==3 & iscell(idx), 
    idx = [idx{:}];
end;

v=version;
if str2num(v(1:3)) >= 6.5
        if nargin == 3
           field = ds.(name)(idx);
        else
           field = ds.(name);
        end;
else
        if nargin == 3
           field = getfield(ds, name, idx);
        else
           field = getfield(ds, name);
        end;
end;
