%% This code plot three MI(pos, abs, speed) in same picture
%Position is red
%Speed is blue
%Absolute is black
close all;
clear all;
code_folder = pwd;
load('rr.mat')
exp_folder = 'D:\Leo\0823exp';
cd(exp_folder)
sorted =1;
%Load calculated MI first(Need to run Calculate_MI.m first to get)
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
    if name(1) == 'p' | name(1) == 'a' 
        continue
    end
    
    name = name(3:end)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(['v_',name,ext])
    speed_MI = Mutual_infos;
    speed_MI_shuffle = Mutual_shuffle_infos;
    load(['pos&v_',name,ext])
    absolute_MI = Mutual_infos;
    absolute_MI_shuffle = Mutual_shuffle_infos;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(['pos_',name,ext])
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    MI_peak=zeros(1,60);
    ind_peak=zeros(1,60);
    peak_times = zeros(1,60)-1000000;
    P_channel = [];
    N_channel = [];
    
    for channelnumber=1:60
        if max(Mutual_infos{channelnumber}-mean(Mutual_shuffle_infos{channelnumber}))<0.1
            continue;
        end
        Mutual_infos{channelnumber} = smooth(Mutual_infos{channelnumber});
        [MI_peak(channelnumber), ind_peak(channelnumber)] = max(Mutual_infos{channelnumber}); % MI_peak{number of data}{number of channel}
        if (time(ind_peak(channelnumber)) < -1000) || (time(ind_peak(channelnumber)) > 1000) % the 100 points, timeshift is 1000
            MI_peak(channelnumber) = NaN;
            ind_peak(channelnumber) = NaN;
        end
    % ======= exclude the MI that is too small ===========
        
       
       
        pks_1d=ind_peak(channelnumber);
        peaks_ind=pks_1d(~isnan(pks_1d));
        peaks_time = time(peaks_ind); 
        % ============ find predictive cell=============

        
       
        if peaks_time>=0
            P_channel=[P_channel channelnumber];
        elseif peaks_time<0
             N_channel=[N_channel channelnumber];
        end
        if length(peaks_time)>0
            peak_times(channelnumber) = peaks_time;
        end
        axes(ha(rr(channelnumber))); 
        
        plot(time,smooth(Mutual_infos{channelnumber}-mean(Mutual_shuffle_infos{channelnumber})),'r');hold on;
        plot(time,smooth(speed_MI{channelnumber}-mean(speed_MI_shuffle{channelnumber})),'b-');
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
    saveas(fig,['FIG\three_mix_',name,'.tif'])
    saveas(fig,['FIG\three_mix_',name,'.fig'])

end


