% Contents of z:\mfiles\meatools\mcintfac\@datastrm
%
%           function for general use
%   ad2muvolt          - ad2muvolt - converts MCRack ADC values into microvolt values (datastrm method)
%   datastrm           - - data object constructor for opening data recorded with MC Rack 
%   display            - Command window display
%   getfield           - getfield - returns any datastream fields content (datastrm method)
%   getpos             - getpos - return the current position of the datastrm object (datastrm method)
%   getstreamnumber    - getstreamnumber - returns streamnumber of streamname (datastream method)
%   isfield            - True if field is in structure array.
%   nextdata           - - read data from an MCRack OLE Object opened with datastrm.m
%   nextraw            - nextraw - calls nextsweep to read in continous raw (datastream method)

%   nextsweep          - nextsweep - reads the next sweep (datastream method)
%   setfield           - setfield - sets any field in datastream objects (datastream method)
%   setpos             - setpos - set the file position in a datastream (datastream method)
%
%           retained for compatibility (not for general use)
%   delete             - datastrm destructor (not necessary)
%   getfileindex       - getfileindex - generate an index of entries in datastream objects (datastrm method)
%   getfileindexspikes - getfileindexspikes - get the file indexes of all segments (datastrm method)
%   plotmea            - plotmea- plot the channels in this recording (datastream method)
%   rdrawhd            - rdrawhd - parses MCS data header (version 1) (datastream method)
%   rdrawhd_silent     - rdrawhd - Parses MCS data header vers. 1 (datastream method)
%   segregate          - segregate - extracts synchronous start and end points of fields/spike events
%   setid              - setid - not used, retained for compatibility
%   setpos_silent      - setpos_silent - set the file position in a datastream (datastream method)
%   contents           - Contents of z:\mfiles\meatools\mcintfac\@datastrm
%   datastrm22         - DATASTRM		- data object constructor for opening data recorded with MC Rack 
