function a=setfield(d,name,value)
% setfield - sets any field in datastream objects (datastream method)
% a=setfield(d,name,value) sets the field <name> in the 
% datastream object <s> to the value <value>.
%
% See Also: datastrm\GETFIELD

v=version;

if str2num(v(1:3))>=6.5
   d.(name)=value;
else
   eval(['d.' name '=value;']);
end;
a=d;

