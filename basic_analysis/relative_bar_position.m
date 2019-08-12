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
exp_folder = 'E:\0709';
cd(exp_folder)
load('data\RFcenter.mat')%Needed to run Receptive field.m first
cd sort_merge_spike\MI%Go the directory that stores HMM or OU spikes data
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;
Y =meaCenter_y;
for z =7:n_file %choose file
    xarray = [];%Store bar center x position
    yarray = [];%Store bar center y position
    
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
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
     R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];%Rotation matrix
     for k = 1:length(bin_pos)
     
         barX=bin_pos(k)-round(leftx_bd);
         barY=round(Y)-round(lefty_bd);

         Vertex = cell(2);
         Vertex{1} = [barX-bar_wid  barY-bar_le];  %V1  V4
         Vertex{2} = [barX-bar_wid  barY+bar_le];  %V2  V3
         Vertex{3} = [barX+bar_wid  barY+bar_le];
         Vertex{4} = [barX+bar_wid  barY-bar_le];
         %rotation
         for i = 1:4
             Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
         end
         middle_x = zeros(1,4);%It stores 4 corner x positions
         middle_y =zeros(1,4);%It stores 4 corner y positions
       %% Prevent out of barrier
         if theta > pi/2
                newVertex = Vertex{1};
                for i = 1:3
                    Vertex{i} = Vertex{i+1};
                end
                Vertex{4} = newVertex;
         end
         if theta == 3*pi/4 || theta == pi/4  
             if Vertex{2}(1) < 1
                 Vertex{2}(1)= 1;
             end
             if Vertex{4}(1) > mea_size_bm
                 Vertex{4}(1)  = mea_size_bm;
             end
             if Vertex{1}(2) < 1
                 Vertex{1}(2)= 1;
             end
             
             if Vertex{3}(2) > mea_size_bm
                 Vertex{3}(2)=  mea_size_bm;
             end
         end
         if Vertex{1}(1) < 1
                 Vertex{1}(1)= 1;
         end
         if Vertex{2}(1) < 1
                 Vertex{2}(1)= 1;
         end
         
       %% Find four corners positions
         for i =1:4
             middle_x(i) =  dotPositionMatrix{ round(Vertex{i}(2)), round(Vertex{i}(1))}(1);
             middle_y(i) =  dotPositionMatrix{ round(Vertex{i}(2)), round(Vertex{i}(1))}(2);
         end  
         middle_x = mean(middle_x);%Caculate center by avergering 4 corners 
         middle_y = mean(middle_y);%Caculate center by avergering 4 corners 
         xarray = [xarray middle_x];
         yarray = [yarray middle_y];
         
         
        %% Calculate relative distance
         for i = 1:60
             if sum(RFcenter(i,:)) <= 0%If no RF center, it will pass
                 continue
             end
             if theta == pi/2%UD
                 relative_pos(i,k) = middle_y-RFcenter(i,2);%Distance between RF_center and bar
             elseif theta == 0%RL
                  relative_pos(i,k) =  middle_x-RFcenter(i,1); %Distance between RF_center and bar
             elseif theta == 3*pi/4%UR_DL
                  relative_pos(i,k) = (RFcenter(i,2)-RFcenter(i,1)-middle_y+middle_x)/sqrt(2);%Use the formula that calculate shortest and vertical distance between point and line
             elseif theta == pi/4%UL_DR
                  relative_pos(i,k) = (-RFcenter(i,2)-RFcenter(i,1)+middle_y+middle_x)/sqrt(2);%Notice I assume the length of bar is infinite for simplicity
             else  
             end           
         end               
     end
     
     %% Just for check
%       for i = 1:60
%             if sum(RFcenter(i,:)) > 0
%                 figure(i)
%                 plot(relative_pos(i,:))
%             end
%        end
       absolute_pos = abs(relative_pos);%It stores abosulute distance between bars
       save([exp_folder,'\sort_merge_spike\MI\',name,'.mat'],'sorted_spikes','bin_pos','TimeStamps','reconstruct_spikes','diode_BT','BinningInterval','absolute_pos','relative_pos');
end
