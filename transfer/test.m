clear all;
close all;
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 



for m = 1:16
    file = all_file(m).name;
    [pathstr, name, ext] = fileparts(file);
    if strcmp(name(6),'H')
        type = 'HMM';
        if strcmp(name(12),'D')
          Dir= name(10:13);
        else
          Dir= name(10:11);
        end
        Gamma = name(length(name)-1:end);
    elseif strcmp(name(6),'O')
        type = 'OU';
        if strcmp(name(11),'D')
          Dir= name(9:12);
        else
          Dir= name(9:10);
        end
        Gamma = name(length(name)-1:end);
    else
        disp([name,'has an error'])
%         continue
    end
    pass = reconstruct(pwd,type,Dir,Gamma);


end



