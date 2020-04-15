close all;
clear all;
%code_folder = pwd;
exp_folder = 'D:\Leo\0409';
cd(exp_folder)
mkdir Analyzed_data
cd Analyzed_data

set_number = 1;
name = '5G_BB_sOU'; %start with Independant variables and then the controlled ones
filename = '5G_BB_sOU_properties';
direction = 'RL';
HMM_former_name = ['pos_0224_OUsmooth_',direction, '_G'];
HMM_post_name = '_5min_Q100_6.5mW_1Hz';
OU_former_name = ['pos_0224_OU_', direction, '_G'];
OU_post_name = '_5min_Q100_6.5mW';
OU_different_G = [2.5,4.5,9,12,20];
HMM_different_G = [2.5,4.5,9,12,20];
save([num2str(set_number), ';', name, '.mat']);

set_number = 2;
name = '5G_BB_HMM'; %start with Independant variables and then the controlled ones
filename = '5G_BB_HMM_properties';
direction = 'RL';
HMM_former_name = ['pos_0224_HMM_',direction, '_G'];
HMM_post_name = '_5min_Q100_6.5mW_1Hz';
OU_former_name = ['pos_0224_OU_', direction, '_G'];
OU_post_name = '_5min_Q100_6.5mW';
OU_different_G = [2.5,4.5,9,12,20];
HMM_different_G = [2.5,4.5,9,12,20];
save([num2str(set_number), ';', name, '.mat']);

set_number = 3;
name = '5G_BB_sOU_0.3covered'; %start with Independant variables and then the controlled ones
filename = '5G_BB_sOU__0.3covered_properties';
direction = 'RL';
HMM_former_name = ['pos_0224_OUsmooth_',direction, '_G'];
HMM_post_name = '_5min_Q100_6.5mW_1Hz_0.3covered';
OU_former_name = ['pos_0224_OU_', direction, '_G'];
OU_post_name = '_5min_Q100_6.5mW';
OU_different_G = [2.5,4.5,9,12,20];
HMM_different_G = [2.5,4.5,9,12,20];
save([num2str(set_number), ';', name, '.mat']);

set_number = 4;
name = '5G_BB_sOU_0.15covered'; %start with Independant variables and then the controlled ones
filename = '5G_BB_sOU__0.15covered_properties';
direction = 'RL';
HMM_former_name = ['pos_0224_OUsmooth_',direction, '_G'];
HMM_post_name = '_5min_Q100_6.5mW_1Hz_0.15covered';
OU_former_name = ['pos_0224_OU_', direction, '_G'];
OU_post_name = '_5min_Q100_6.5mW';
OU_different_G = [2.5,4.5,9,12,20];
HMM_different_G = [2.5,4.5,9,12,20];
save([num2str(set_number), ';', name, '.mat']);

set_number = 5;
name = '3coverage_BB_sOU'; %start with things to compare and then the controls
filename = '3coverage_BB_sOU_properties';
direction = 'RL';
HMM_former_name = ['pos_0224_OUsmooth_',direction, '_G'];
HMM_middle_name = '_5min_Q100_6.5mW_1Hz';
coverages = [0 0.15 0.3 ];
OU_former_name = ['pos_0224_OU_', direction, '_G'];
OU_post_name = '_5min_Q100_6.5mW';
save([num2str(set_number), ';', name, '.mat']);