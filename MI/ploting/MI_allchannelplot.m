close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20190811';
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
%Tina orientation
rr =[9,17,25,33,41,49,...
          2,10,18,26,34,42,50,58,...
          3,11,19,27,35,43,51,59,...
          4,12,20,28,36,44,52,60,...
          5,13,21,29,37,45,53,61,...
          6,14,22,30,38,46,54,62,...
          7,15,23,31,39,47,55,63,...
            16,24,32,40,48,56];
        
for z =18%1:n_file
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([filename]);
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
        
        plot(time,Mutual_infos{channelnumber},'LineWidth',2,'LineStyle','-');hold on;
        plot(time,smooth(Mutual_shuffle_infos{channelnumber}),'LineWidth',2,'LineStyle','-');hold off;
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
    saveas(fig,['FIG\',name,'.tif'])
    saveas(fig,['FIG\',name,'.fig'])
    if sorted
            save([exp_folder,'\MI\sort\',filename],'time','Mutual_infos','Mutual_shuffle_infos','P_channel','N_channel','peak_times')
    else
            save([exp_folder,'\MI\unsort\',filename],'time','Mutual_infos','Mutual_shuffle_infos','P_channel','N_channel','peak_times')
    end
    close(gcf)
end


