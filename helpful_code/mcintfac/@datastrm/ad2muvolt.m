function [vdata, tvals] = ad2muvolt(a, addata, streamname);
% ad2muvolt - converts MCRack ADC values into microvolt values (datastrm method)
%
% [vdata, tvals] = ad2muvolt(a, addata, streamname) returns an array <vdata> 
% of size(addata) with values converted from <addata> with the conversion 
% factors given in the structure <a> which must contain the fields 
% <a.ZeroADValue> and <a.MicrovoltsPerAD> such as in datastream objects 
% or the RACKSETUP variable used with other MCRacks datasets. <tvals> is a 
% time vector of the length of a row of <addata> based on <a.MicrosecondsPerTick>.
%
% If <streamname> is given conversion will be based on the parameters for
% that datastream. 
%
% NOTE: addata MUST NOT be a cell array!
%
% U. Egert 3/98


if iscell(addata)
   error('addata MUST NOT be a cell array!');
end;

if strmatch('ole', getfield(a,'fileaccess')),
   if nargin==2
      sn = getfield(a, 'StreamNames');
      s = [strmatch('Spikes', sn) strmatch('Electrode Raw Data', sn)];
      
      s=s(find(s>0));
      if length(s)>1
         warning('found more than one datastream, please indicate the one to use for conversion')
         return
      end
   else
      s=getstreamnumber(a,streamname);
   end;
   
   ZAD = a.ZeroADValue2(s);
   MpAD = a.MicrovoltsPerAD2(s);
   
   vdata = (addata - ZAD) * MpAD;
   tvals = a.MicrosecondsPerTick * [1:size(addata,2)];
else
   
   ZAD = a.ZeroADValue;
   MpAD = a.MicrovoltsPerAD;
   
   vdata = (addata - ZAD) * MpAD;
   tvals = a.MicrosecondsPerTick * [1:size(addata,2)];
end;


