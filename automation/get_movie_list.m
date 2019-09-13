%% This code can search all experiment movie and get movie names and movie length(sec).
%It exports all names and all length to movie_list.txt
close all;
clear all;
code_folder = pwd;

movie_folder = 'D:\0304v\videos\HMM';%Go to directory that save stimulus movie
cd(movie_folder)

all_file = dir('*.avi') ; % Get all avi file
n_file = length(all_file) ; 
%Open txt file
fileID = fopen('movie_list.txt','w');
%Search all avi
for m = 1:n_file
    v = VideoReader(all_file(m).name);
    fprintf(fileID,all_file(m).name)%Get name
    fprintf(fileID,' ')%Space
    fprintf(fileID,num2str(ceil(v.Duration)))%Get length time
    fprintf(fileID,'\r\n')%Change line
end
fclose(fileID);