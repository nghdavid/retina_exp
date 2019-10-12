function tf = isfield(s,f)
%ISFIELD True if field is in structure array.
%   F = ISFIELD(S,'field') returns true if 'field' is the name of a field
%   in the structure array S.
%
%   See also GETFIELD, SETFIELD, FIELDNAMES.


if isa(s,'struct') | isa(s, 'datastrm') 
  tf = any(strcmp(fieldnames(s),f));
else
  tf = logical(0);
end


