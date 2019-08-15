%% This code calculate relative bar position by substracting RF center and bin_pos
% It add two new variables absolute_pos and relative_pos to original data
% It add them by overwriting them
% relative_pos is a 60*length(bin_pos) matrix
% It stores relative distance between bar and RF center
%absolute_pos is abosolute distance of relative_pos
close all;
clear all;
code_folder = pwd;
load('calibrate_pt.mat')%Load dotPositionMatrix
load('screen_brightness.mat')%Load screen_brightness
load('boundary_set.mat')
exp_folder = 'D:\Leo\0807exp';
cd(exp_folder)
load('data\RFcenter.mat')%Needed to run Receptive field.m first
cd sort_merge_spike%Go the directory that stores HMM or OU spikes data
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;

for z =1%1:n_file %choose file
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    if (strcmp(filename(17),'H') || strcmp(filename(17),'O') || strcmp(filename(16),'D'))
    else
        continue
    end
    load([filename]);
    relative_pos = zeros(60,length(bin_pos));
    name=[name];
    z
    name
    
    %% Recognize HMM or OU, also directions
    if strcmp(name(17),'H')
        type = 'HMM';
        if strcmp(name(24),'D')
            direction = name(21:25);
            if strcmp(direction,'UL_DR')
                theta = pi/4;
            else
                theta = 3*pi/4;
            end
        else
            direction = name(21:22);
            if strcmp(direction,'RL')
                theta = 0;
            else
                theta = pi/2;
            end
        end
    elseif strcmp(name(17),'O')
        type = 'OU';
        if strcmp(name(23),'D')
            direction = name(20:24);
            if strcmp(direction,'UL_DR')
                theta = pi/4;
            else
                theta = 3*pi/4;
            end
        else
            direction = name(20:21);
            if strcmp(direction,'RL')
                theta = 0;
            else
                theta = pi/2;
            end
        end
    else
        disp('Not MI')
        continue
    end
    
    %% Find out four corners and average them
    
    for k = 1:60
        if sum(RFcenter(k,:)) <= 0%If no RF center, it will pass
            continue
        end
        if strcmp(direction,'UD')
            relative_pos(k,:) = (RFcenter(k,2)-meaCenter_y) - (bin_pos(:)-meaCenter_x);
        elseif  strcmp(direction,'RL')
            relative_pos(k,:)= (RFcenter(k,1)-meaCenter_x) - (bin_pos(:)-meaCenter_x);
        elseif  strcmp(direction,'UR_DL')
            relative_pos(k,:)= (-RFcenter(k,1)+ RFcenter(k,2)+meaCenter_x-meaCenter_y)/sqrt(2) - (bin_pos(:)- meaCenter_x);
        elseif  strcmp(direction,'UL_DR')
           relative_pos(k,:) = (RFcenter(k,1)+RFcenter(k,2)-meaCenter_x-meaCenter_y)/sqrt(2) - (bin_pos(:)- meaCenter_x);
        end
    end
    
    
    %% Just for check
%           for i = 58
%                 if sum(RFcenter(i,:)) > 0
%                     %figure(i)
%                     plot(relative_pos(i,:)); hold on 
%                 end
%            end
    absolute_pos = abs(relative_pos);%It stores abosulute distance between bars
    save([exp_folder,'\sort_merge_spike\',name,'.mat'],'sorted_spikes','bin_pos','TimeStamps','reconstruct_spikes','diode_BT','BinningInterval','absolute_pos','relative_pos');
end
