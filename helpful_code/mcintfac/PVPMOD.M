function pvpmod(x)
% PVPMOD             - evaluate parameter/value pairs
% pvpmod(x), where x is a cell array with an even number of cells, assigns
% the value x(i+1) to the parameter defined by the string x(i) in the
% calling workspace. This is useful to evaluate  <varargin> contents in an
% mfile, e.g. to change default settings  of any variable initialized
% before pvpmod(x) is called. 
% Alternatively, <x> can be a structure where the fieldnames will become
% variable names and the field contents will become the contents of the new
% variables.
%
% Example
% assume x is a cell array of parameter/value pairs such as used to modify
% plots. Then
% x = {'fontname', 'helvetica', 'fontsize', 8};
% pvpmod(varargin) 
% will create variables with names created from x{1:2:end} with the
% corresponding values x{2:2:end} in the calling workspace 
%
% (c) U. Egert 1998

%############################################
% this loop is assigns the parameter/value pairs in x to the calling
% workspace.

if ~isempty(x)
    if length(x)==1 & isstruct(x{1})
        x=x{1};
        allfields=fieldnames(x);
        for k = 1:length(allfields)
            assignin('caller', allfields{k}, x.allfields{k});
        end;
    elseif mod(length(x),2)==0
        for k = 1:2:size(x,2)
            assignin('caller', x{k}, x{k+1});
        end;
    else
        error('pvpmod needs either a structure or a cellarray with parameter/value pairs')
    end;
end;
%############################################

