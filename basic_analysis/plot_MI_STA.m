close all;
clear all;
% set(0,'DefaultFigureVisible','off')
code_folder = pwd;
exp_folder = 'E:\20200302';
save_photo = 1;
cd(exp_folder);
load('oled_boundary_set.mat')
load('RGC.mat')
load('different_G.mat')
load('predictive_channel\bright_bar.mat')
mkdir STA\FIG
cd STA\MI
all_file = subdir('*.mat');% change the type of the files which you want to select, subdir or dir.
n_file = length(all_file);
unit = 1;
forward = 90;%90 bins before spikes for calculating STA
backward = 90;%90 bins after spikes for calculating STA
roi = [p_channel,np_channel];
%  roi = 1;
for z = 1:n_file
    %choose file
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load(filename);
    name=[name];
    z
    name
    direction = Get_direction(name);
    if strcmp(direction,'UL_DR') || strcmp(direction,'UR_DL')
        micro_per_pixel_long = micro_per_pixel*sqrt(2);
    else
        micro_per_pixel_long = micro_per_pixel;
    end
    for i = roi
        if isempty(positive_PCAs{i}) || isempty(negative_PCAs{i})
            continue
        end
        
        figure('units','normalized','outerposition',[0 0 1 1])
        ha = tight_subplot(1,3,[.04 .04],[0.09 0.02],[.04 .04]);
        set(ha, 'Visible', 'off');
        set(gcf,'units','normalized','outerposition',[0 0 1 1])
        fig =gcf;
        fig.PaperPositionMode = 'auto';
        fig.InvertHardcopy = 'off';
        axes(ha(1));
        if sum(RGCs{i}.center_RF) >0
            newXpos = Monitor2DCoor2BarCoor(RGCs{i}.center_RF(2),RGCs{i}.center_RF(1),direction,'OLED');
            plot(STA_time,(mean(positive_PCAs{i},1)-newXpos)*micro_per_pixel_long,'r-.');hold on%Red is positive_PCA
            plot(STA_time,(mean(negative_PCAs{i},1)-newXpos)*micro_per_pixel_long,'b-.');%Blue is negative_PCA
        else
            plot(STA_time,(mean(positive_PCAs{i},1)-400)*micro_per_pixel_long,'r');hold on%Red is positive_PCA
            plot(STA_time,(mean(negative_PCAs{i},1)-400)*micro_per_pixel_long,'b');%Blue is negative_PCA
        end
        xlabel('time before spike(sec)')
        ylabel('STA from two kinds of clusters')
        title('STA of two different clusters using k means')
        xline(0)
        axes(ha(2)); 
        if sum(RGCs{i}.center_RF) >0
            plot(STA_time,(dis_STA(i,:)-newXpos)*micro_per_pixel_long,'k-.');
        else
            plot(STA_time,(dis_STA(i,:)-400)*micro_per_pixel_long);
        end
        xlabel('time before spike(sec)')
        ylabel('STA of bar')
        xline(0)
        if ismember(i,p_channel)
            title(['p',int2str(i)])
        elseif ismember(i,np_channel)
            title(['np',int2str(i)])
        end
        legend([num2str(corr_time),' sec'])
        axes(ha(3));
        plot(time,smooth(PCA_Mutual_infos{1,i}-mean(PCA_Mutual_shuffle_infos{1,i})),'b');hold on
        plot(time,smooth(PCA_Mutual_infos{2,i}-mean(PCA_Mutual_shuffle_infos{2,i})),'r');
        plot(time,smooth(PCA_Mutual_infos{3,i}-mean(PCA_Mutual_shuffle_infos{3,i})),'k');
        
        xline(0)
        xlim([ -2300 1300])
        ylim([0 inf+0.1])
        xlabel('time shift')
        ylabel('MI')
        legend('Only blue','Only red','Original')
        if save_photo
            saveas(fig,[exp_folder,'\STA\FIG\',name,'_ch',int2str(i),'.tif'])
        end
    end
end