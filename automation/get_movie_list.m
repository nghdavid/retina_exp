close all;
clear all;
code_folder = pwd;

exp_folder = 'D:\0304v\videos\HMM';
cd(exp_folder)

all_file = dir('*.avi') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ; 
fileID = fopen('movie_list.txt','w');
for m = 1:n_file
    v = VideoReader(all_file(m).name);
    fprintf(fileID,all_file(m).name)
    fprintf(fileID,' ')
    fprintf(fileID,num2str(ceil(v.Duration)))
    fprintf(fileID,'\r\n')
    
end
fclose(fileID);