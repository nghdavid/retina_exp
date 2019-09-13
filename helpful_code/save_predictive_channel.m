close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20190825';
cd(exp_folder)
mkdir predictive_channel
direction = 'RL';
HMM_different_G = [3,4.5,7.5,12,20];
mins = 7;
order = '1';
date = '0602';
filename =  [date,'_HMM_',direction,'_',num2str(length(HMM_different_G )),'G_',num2str(mins),'min_Br50_Q100_',order,'.mat'];

p_channel = [51,52,57];
np_channel = [];

save(['predictive_channel\',filename],'p_channel','np_channel')
