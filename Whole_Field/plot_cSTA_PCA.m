%% Code for plotting PCA1 and PCA2 and STA
close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20190825';
cd(exp_folder);
cd Analyzed_data\PCA
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;
for z =2%1:n_file
    file = all_file(z).name;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([filename]);
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .03],[0.07 0.02],[.02 .02]);
    set(ha, 'Visible', 'off');
    for channelnumber = 1:60
        if isempty(total_coeff{channelnumber})
            continue
        end
        %% Plotting
        axes(ha(rr(channelnumber)));
        plot(time,total_coeff{channelnumber}(:,1),'b');hold on;%Blue is first principle component
        if size(total_coeff{channelnumber},2) >=2
            plot(time,total_coeff{channelnumber}(:,2),'r');%Red is second principle component
        end
        STA = mean(total_STA{channelnumber},1);
        yyaxis right%Right tick is for STA
        plot(time,(STA-min(STA))/(max(STA)-min(STA))*2-1,'k')%Plot STA(black)
        grid on
        xlim([-0.5 0])
        title(channelnumber)
    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig =gcf;
    fig.PaperPositionMode = 'auto';
    fig.InvertHardcopy = 'off';
%     saveas(fig,['FIG\',name,'.tif'])
%     saveas(fig,['FIG\',name,'.fig'])

end
