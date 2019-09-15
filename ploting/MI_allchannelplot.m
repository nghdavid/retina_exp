close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20190709';
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
    load([filename]);
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    set(ha, 'Visible', 'off');
    for channelnumber=1:60
        if max(Mutual_infos{channelnumber}-mean(Mutual_shuffle_infos{channelnumber}))<0.1
            continue;
        end
        Mutual_infos{channelnumber} = smooth(Mutual_infos{channelnumber});
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

    close(gcf)
end


