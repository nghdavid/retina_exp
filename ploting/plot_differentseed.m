close all;
clear all;
load('rr.mat')
code_folder = pwd;
exp_folder = 'E:\20200306';
cd(exp_folder)
load('different_G.mat')
type = 'pos';
order = '0';%First or second experiment
sorted=1;
save_photo = 1;
all_or_Not = 1;%Plot all channels or not

if order == '0'
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW'];
else
    HMM_post_name = ['_',num2str(mins),'min_Q100_',num2str(mean_lumin),'mW_',order];
end
%Filename used to save(Plot HMM only)   
if sorted
    sort_directory = 'sort';
    mkdir FIG\sort
    cd MI\sort
else
    sort_directory = 'unsort';
    mkdir FIG\unsort
    cd MI\unsort
    
end

%% Load data
allchannellegend = cell(1,length(HMM_different_G));%Save which G
date_t_legend = {HMM_date1,HMM_date2};
all_corr_t_legend = cell(1,length(HMM_different_G)+length(OU_different_G));%Save HMM and OU correlation time

%Load HMM MI data and correlation time
HMM_MI1 =[];
HMM_MI_shuffle1 = [];
HMM_peaks1 = [];
HMM_MI2 =[];
HMM_MI_shuffle2 = [];
HMM_peaks2 = [];
diff_peak = [];
for G =1:length(HMM_different_G) 
    HMM_former_name1 = [type,'_',HMM_date1,'_HMM_',direction,'_G'];
    load([HMM_former_name1,num2str(HMM_different_G(G)),HMM_post_name,'.mat'])
    HMM_peaks1 = [HMM_peaks1;peak_times];
    HMM_MI1 = [HMM_MI1;Mutual_infos];
    HMM_MI_shuffle1 = [HMM_MI_shuffle1 ;Mutual_shuffle_infos];
    HMM_former_name2 = [type,'_',HMM_date2,'_HMM_',direction,'_G'];
    load([HMM_former_name2,num2str(HMM_different_G(G)),HMM_post_name ,'.mat'])
    HMM_peaks2 = [HMM_peaks2;peak_times];
    HMM_MI2 = [HMM_MI2;Mutual_infos];
    HMM_MI_shuffle2 = [HMM_MI_shuffle2;Mutual_shuffle_infos];
end

%% Plot all channels
if all_or_Not
for G =1:length(HMM_different_G)
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    for channelnumber=1:60 %choose file
        axes(ha(rr(channelnumber)));
            mean_MI_shuffle1 = mean(cell2mat(HMM_MI_shuffle1(G,channelnumber)));
            mutual_information1 = cell2mat(HMM_MI1 (G,channelnumber));
            mean_MI_shuffle2 = mean(cell2mat(HMM_MI_shuffle2(G,channelnumber)));
            mutual_information2 = cell2mat(HMM_MI2 (G,channelnumber));
            if channelnumber~=31
                if max(mutual_information1-mean_MI_shuffle1)<0.3 || max(mutual_information2-mean_MI_shuffle2)<0.3
                    continue;
                end
            end
            plot(time,mutual_information1-mean_MI_shuffle1,'r'); hold on;
            plot(time,mutual_information2-mean_MI_shuffle2,'b'); hold on; 
            xlim([ -2300 1300])
            ylim([0 inf+0.1])
            title(channelnumber)
            if channelnumber == 31
                lgd =legend(date_t_legend,'Location','northwest');
                lgd.FontSize = 11;
                legend('boxoff')
            end
            if abs(HMM_peaks1(G,channelnumber)) >1000 || abs(HMM_peaks2(G,channelnumber)) >1000
            else
                diff_peak = [diff_peak,(HMM_peaks1(G,channelnumber) - HMM_peaks2(G,channelnumber))];
            end
            
        hold off;
    end
    %Save fig
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig =gcf;
    fig.PaperPositionMode = 'auto';
    fig.InvertHardcopy = 'off';
    
    if save_photo
        HMM_filename =  ['diff_',type,'_',HMM_date1,'_',HMM_date2,'_HMM_',direction,'_G',num2str(HMM_different_G(G)),'_',num2str(mins),'min'];
        saveas(fig,[exp_folder,'\FIG\',sort_directory,'\',HMM_filename,'.tif'])
    end
end
end

%% Histogram of difference between two peaks
figure(100)
histogram(diff_peak,20)
xlabel('Difference (ms)')
ylabel('Number')
filename =  ['diff_',type,'_',HMM_date1,'_',HMM_date2,'_HMM_',direction,'_',num2str(mins),'min'];
saveas(gcf,[exp_folder,'\FIG\',sort_directory,'\',filename,'.tif'])