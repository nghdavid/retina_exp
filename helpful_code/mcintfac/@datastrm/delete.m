function d = delete(a)
%datastrm destructor (not necessary)

if (strcmp(a.fileaccess,'ole'))
	tmp.function='CloseFile';
	mcstreammex(tmp);
	return;
else
	fclose(a.fid);
end;
clear a;
