close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20200306';
cd(exp_folder)
load('different_G.mat')
edge_different_G = [4.3,9];
save('different_G.mat')
