close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20200306';
cd(exp_folder)
mkdir predictive_channel
type = 'bright_bar';
% type = 'dark_bar';
% type = 'edge';
p_channel = [];
np_channel = [1,7,8,14,15,16,22,23,27,28,30,33,44,45,46,48,51,52,53,54,57,59,60];
save(['predictive_channel\',type,'.mat'],'p_channel','np_channel')
