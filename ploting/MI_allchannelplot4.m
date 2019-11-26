%% This code plot four MI(pos, abs, speed, pos&v) in same picture
%Position is red
%Speed is blue
%Absolute is black
%Position and speed is yellow
close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20190709';
cd(exp_folder)
load('rr.mat')
sorted =1;
%Load calculated MI first(Need to run Calculate_MI.m and speedMI.m first to get)
if sorted
    cd MI\sort
else
    cd MI\unsort
end
mkdir FIG
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
n_file = length(all_file) ;
   
for z =1:n_file
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    if name(1) ~= 'p'|| name(5) == 'v'
        continue
    end
    name
    %Load data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(['v_',name(5:end),ext])
    speed_MI = Mutual_infos;
    speed_MI_shuffle = Mutual_shuffle_infos;
    load(['absolute_',name(5:end),ext])
    absolute_MI = Mutual_infos;
    absolute_MI_shuffle = Mutual_shuffle_infos;
    load(['pos&v_',name(5:end),ext])
    pos_v_MI = Mutual_infos;
    pos_v_MI_shuffle = Mutual_shuffle_infos;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load([name,ext])
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    for channelnumber=1:60
        if max(Mutual_infos{channelnumber}-mean(Mutual_shuffle_infos{channelnumber}))<0.1
            continue;
        end
        Mutual_infos{channelnumber} = smooth(Mutual_infos{channelnumber});
        axes(ha(rr(channelnumber))); 
        
        plot(time,smooth(Mutual_infos{channelnumber}-mean(Mutual_shuffle_infos{channelnumber})),'r');hold on;
        plot(time,smooth(speed_MI{channelnumber}-mean(speed_MI_shuffle{channelnumber})),'b-');
        plot(time,smooth(pos_v_MI{channelnumber}-mean(pos_v_MI_shuffle{channelnumber})),'g.');
        if sum(absolute_MI{channelnumber}) ~= 0
            plot(time,smooth(absolute_MI{channelnumber}-mean(absolute_MI_shuffle{channelnumber})),'k.');
        end
        hold off;
         if ismember(channelnumber,P_channel)
            set(gca,'Color',[0.8 1 0.8])
        elseif ismember(channelnumber,N_channel)
            set(gca,'Color',[0.8 0.8 1])
         else
         end    
        grid on
        xlim([ -2300 1300])
        ylim([0 inf+0.1])
        title(channelnumber)

    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig =gcf;
    fig.PaperPositionMode = 'auto';
    fig.InvertHardcopy = 'off';
    saveas(fig,['FIG\four_mix_',name,'.tif'])
    saveas(fig,['FIG\four_mix_',name,'.fig'])

end


