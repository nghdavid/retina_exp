close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20200302';
HMM_date1 = '0224';
HMM_date2 = '0225';
cd(exp_folder)
direction = 'UL_DR';
HMM_different_G = [3,4.5,7.5,12,20];
edge_different_G = [3,4.5,7.5,12,20];
mins = 5;%Length of movie length
OU_date = '0224';
OU_different_G = [3,20];
mean_lumin = 6.5;
save('different_G.mat')