function a=rdrawhd(d)
% rdrawhd - Parses MCS data header vers. 1 (datastream method)
% a=rdrawhd(d) Parse MCS data header
% To use this function data-files must be open already (fid is 
% input parameter). ChannelID is incremented by 1 because the 
% first channel sampled is 0, i.e. its index in the sampling 
% sequence is 0 matlab indices, however, start with 1.

global MEAINFO
load meainfo

%-------------------------

	fseek(d.fid,0,-1);				% rewinds the data file



%----- parseHeader -------------------------

	d.offset_to_data = fread(d.fid,1,'ulong');  % offset to data. 1100
%	disp(['data section should start at ' int2str(offset_to_data) ' byte']);

	word  = fread(d.fid,1,'ushort');			% header class tag
	word  = fread(d.fid,1,'ushort');			% schema of header class
	word  = fread(d.fid,1,'ushort');			% header class name length
	str   = fread(d.fid, word, 'char');		
   str   = setstr(str)';      	     	  	% header class name. "CMRawDataHeaderInfo"
   
	switch str
		case {'CMRawDataHeaderInfo'}, d.DataType = 'raw';     %%%%% semicolon added by ab %%%%%
		case {'CMSpikeDataHeaderInfo'}, d.DataType = 'spike'; %%%%% semicolon added by ab %%%%%
		otherwise, error('invalid file at header class name')
	end

	dword = fread(d.fid,1,'ulong');			% header class version
	str   = fread(d.fid,16,'char');						% header class GUID
	dword = fread(d.fid,1,'ulong');
   timeOfDay=((dword/3600/24) - floor(dword/3600/24));
   d.recordingdate = datenum(1970,1,1) + floor(dword/3600/24) + timeOfDay;	% Datum der Messung
%%%%% ab %%%%%   disp(['Recording date:  ' datestr(d.recordingdate,0)]);

	dword = fread(d.fid,1,'ulong');			% header class version
	word  = fread(d.fid,1,'ushort');			% channel count
	if(d.DataType(1:3) == 'raw')
		word  = fread(d.fid,1,'ushort');			% segment count
	end;

%----- parseChannelFilter -------------------------

	word  = fread(d.fid,1,'ushort');			% channel filter class tag. 0xFFFF
	word  = fread(d.fid,1,'ushort');			% schema
	word  = fread(d.fid,1,'ushort'); 
	word  = fread(d.fid,1,'ushort');
	str  = fread(d.fid,word,'char');			% channel filter class name. "CChannelFilter"
	str  = setstr(str)';				% channel filter class name. "CChannelFilter"
   if str ~='CChannelFilter' error('invalid file at CChannelFilter'), end;

%----- read in mapping from selected to original channel numbers --------------------

	d.NChannels  = fread(d.fid,1,'ushort');		% no. of channels selected
   d.ChannelID = zeros(1,d.NChannels);
   
   % This would give the correct ChannelID corresponding to a linear adressing of the MEA matrix   
   %   for i=1:RACKSETUP.NChannels,                    
   %     LChannelID(i)  = 1+fread(fid1,1,'int32');                % original channel number (an dieser Darstellungsposition i, von 0 aus gezaehlt)
   %   end;
   %   d.ChannelID= MEAINFO.idxpadmat(LChannelID);

   
   for i=1:d.NChannels,				
		d.ChannelID(i)  = 1+fread(d.fid,1,'int32');	% original channelpos. in sampling sequence  (!startpos. is 0!)
	end;

%----- read in chosen names for the channels -------------------------

	nChannelNames  = fread(d.fid,1,'ushort');	% no. of channels selected
   if nChannelNames ~=d.NChannels error('can t handle #channels~=#channel names'), end;
   d.ChannelNames=cell(1,d.NChannels);
	for i  =1:d.NChannels,
      namelength = fread(d.fid,1,'int8');		% Laenge des Namens
		str   = fread(d.fid,namelength,'char');% Name selbst, read in chosen names for the channels 
		str   = rot90(setstr(str));    			% channel name
		d.ChannelNames{i} = str;
	end;
% ----- Anzeige der Kanalzuordnung, nur zur Information -------------------------
%	plotmea(d)

%----- parseDispProperty -------------------------

	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	str   = fread(d.fid,word,'char');
	str   = rot90(setstr(str));				%display property class name. "CMMEADispProperty"
	if str ~='CMMEADispProperty' error('invalid file at CMMEADispProperty'), end;
	long  = fread(d.fid,1,'long');
	long  = fread(d.fid,1,'long');
	long  = fread(d.fid,1,'long');
	long  = fread(d.fid,1,'long');
	long  = fread(d.fid,1,'long');

%----- parseUnitProperty -------------------------
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	str   = fread(d.fid,word,'char');
	str   = rot90(setstr(str));				% unit property class name. "CMMEAUnitProperty"
	if str ~='CMMEAUnitProperty' error('invalid file at CMMEAUnitProperty'), end;

	d.MicrovoltsPerAD = fread(d.fid,1,'double');		% Microvolts per AD
	d.MicrosecondsPerTick = fread(d.fid,1,'ushort');	% Microseconds per Tick
	d.ZeroADValue = fread(d.fid,1,'ushort');		% AD value for zero Microvolts

%------------------------- -------------------------

	dword = fread(d.fid,1,'ulong');
	dword = fread(d.fid,1,'ulong');
	dword = fread(d.fid,1,'ulong');
	dword = fread(d.fid,1,'ulong');
	dword = fread(d.fid,1,'ulong');
	word  = fread(d.fid,1,'ushort');

%----- parseViewProperty -------------------------

	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	str   = fread(d.fid,word,'char');
	str   = rot90(setstr(str));				%view property class name. "CViewProperty"
	if str ~='CViewProperty' error('invalid file at CViewProperty'), end;

	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');

	dword = fread(d.fid,1,'ulong');
	dword = fread(d.fid,1,'ulong');
	dword = fread(d.fid,1,'ulong');

%----- parseMEALayout -------------------------

	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	str   = fread(d.fid,word,'char');
	str   = rot90(setstr(str));				% unit property class name. "CMCLayout"
	if str ~='CMCLayout' error('invalid file at CMCLayout'), end;

%----- read in positions of electrodes -------------------------

	word  = fread(d.fid,1,'ushort');	% electrode count. 64

	for i = 1:word,

		int  = fread(d.fid,1,'int');			% x coordinate of electrode point
		int  = fread(d.fid,1,'int');			% y coordinate of electrode point

	end;

%----- read in names for the electrodes -------------------------

	word  = fread(d.fid,1,'ushort');
	ChannelNames_original = '';
	for i = 1:word,

		byte  = fread(d.fid,1,'int8');			% Laenge des Namens
		str   = fread(d.fid,byte,'char');
		str   = rot90(setstr(str));			% electrode name (original wie im MEA Layout)
		ChannelNames_original = str2mat(ChannelNames_original, str);

	end;

%----- read in bounding rect of electrode layout -------------------------

	int  = fread(d.fid,1,'int');
	int  = fread(d.fid,1,'int');
	int  = fread(d.fid,1,'int');
	int  = fread(d.fid,1,'int');

%----- parseTriggerProperty -------------------------

	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	str   = fread(d.fid,word,'char');
	str   = rot90(setstr(str));				% unit property class name. "CMMEATriggerProperty"
	if str ~='CMMEATriggerProperty' error('invalid file at CMMEATriggerProperty'), end;
	int  = fread(d.fid,1,'int');				% Trigger? 1=Trig,0=

	if int==1
		d.DataType = [d.DataType,' triggered'];
	elseif int == 0
		d.DataType = [d.DataType,' continous'];
	else error('invalid file at triggered/continous switch')
	end;

	int  = fread(d.fid,1,'int');		% pre trigger extent in ticks, wrong its in ms
	pretriggerticks = int;
%%%%% ab %%%%%   disp(['pretriggerticks = ' num2str(pretriggerticks)]);	
     d.ticks_pre_event = pretriggerticks;
	d.windowTicksPos = ftell(d.fid);
	int  = fread(d.fid,1,'int');		% total window extent in ticks, wrong its in ms
	if(strcmp(d.DataType,'raw continous'))
		d.total_window_ticks=1536*25;
	else
%%%%% ab %%%%%   	   disp(['total_window_ms = ' num2str(int)]);
	   d.total_window_ticks = int/(d.MicrosecondsPerTick/1000);
	end;
   
   int  = fread(d.fid,1,'int');		%trigger level chosen in uV
	triggerleveluV = int;

	int  = fread(d.fid,1,'int');		% trigger level suggested in uV
	int  = fread(d.fid,1,'int');		% slope? 0=positive 1=negative
	d.triggerChannel = fread(d.fid,1,'int');		% hardware trigger channel 
	int  = fread(d.fid,1,'int');		% level display: 0=Don't display, 1=Triangle only, 2=Triangle and line
	int  = fread(d.fid,1,'int');		% trigger time display: 0=Don't display, 1=Triangle only, 2=Triangle and line
	
	dword = fread(d.fid,1,'ulong');	% color level display
	dword = fread(d.fid,1,'ulong');	% color trigger time display
%	dword = fread(d.fid,1,'ulong');	% sweep time

%----- parseFilter -------------------------

	dword = fread(d.fid,1,'ulong');		% ?????

	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');

	str   = fread(d.fid,word,'char');

	str   = rot90(setstr(str));			%unit property class name. "CMFilter"
	if str ~='CMFilter' error('invalid file at CMFilter'), end;

	word  = fread(d.fid,1,'ushort');		% window size (in ticks) = 2^word (Filterbreite in Tickmarks)
	filter_width_us = d.MicrosecondsPerTick * word;	% window width in us
%%%%% ab %%%%%	disp(['filter window width = ' num2str(filter_width_us) ' us'])

	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');


% -------- read rest of file header specific for analog data files ------------------------------

	word  = fread(d.fid,1,'ushort');
	word  = fread(d.fid,1,'ushort');		% evtl. fuer aeltere Daten auskommentieren ue 17.7.97

	str   = fread(d.fid,word,'char');

	str   = rot90(setstr(str));			%unit property class name. "CMRawDataStreamPointer"

	if (d.DataType(1:3) == 'raw')
		if str ~='CMRawDataStreamPointer' error('invalid file at CMRawDataStreamPointer'), end;
	else
		if str ~='CMSpikeStreamPointer' error('invalid file at CMSpikeStreamPointer'), end;
	end;
   
  	if d.offset_to_data~=ftell(d.fid) error('invalid file: offset_to_data not correct'), end;

%%%%% ab %%%%%	disp(['this file contains ' d.DataType])

   a=d;
	drawnow;
