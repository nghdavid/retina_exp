 clear all
% close all
cc=hsv(10);
cd('\\192.168.0.100\Experiment\Retina\YiKo\Experiment\04262018\New folder') ; % the folder of the files
all_file = subdir('*.mcd') ; %Michael's "analyze_MEA_data" must use "subdir"!!!
n_file = length(all_file) ; 
bit = all_file.bytes;
checksize = find(bit<100000);
 for m = 1:n_file
    file = all_file(m).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    name=[name];
       
   [Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data([directory,filename],1,'','Yiko','all',10000);  %(filename,save_data,comment,experimenter)
%      [Spikes,TimeStamps,a_data,Infos] = analyze_MEA_data_yiko([directory,filename],1,'','Yiko','all',10000);  %(filename,save_data,comment,experimenter)
  
   % This "analyze_MEA_data" function will automactically save all four parameters first.
 end