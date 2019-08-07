close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20190719';
cd(exp_folder)
HMM_former_name = '0602_HMM_UD_G';
HMM_post_name = '_7min_Br50_Q100_1';
HMM_different_G = [3,4.5,7.5];

OU_former_name = '0319_OU_UD_G';
OU_post_name = '_5min_Br50_Q100';
OU_different_G = [2.45,10.5];
%Load calculated MI first(Need to run Calculate_MI.m first to get)
cd MI\unsort
rr =[9,17,25,33,41,49,...
          2,10,18,26,34,42,50,58,...
          3,11,19,27,35,43,51,59,...
          4,12,20,28,36,44,52,60,...
          5,13,21,29,37,45,53,61,...
          6,14,22,30,38,46,54,62,...
          7,15,23,31,39,47,55,63,...
            16,24,32,40,48,56];

HMM_MI =[];
HMM_MI_shuffle = [];
for     G =1:length(HMM_different_G) 
    load([HMM_former_name,num2str(HMM_different_G(G)),HMM_post_name ,'.mat'])
    
    HMM_MI = [HMM_MI;Mutual_infos];
    HMM_MI_shuffle = [HMM_MI_shuffle ;Mutual_shuffle_infos]; 
end

OU_MI =[];
OU_MI_shuffle = [];
for     G =1:length(OU_different_G) 
    load([OU_former_name,num2str(OU_different_G(G)),OU_post_name ,'.mat'])
    
    OU_MI = [OU_MI;Mutual_infos];
    OU_MI_shuffle = [OU_MI_shuffle ;Mutual_shuffle_infos]; 
end
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);


for channelnumber=1:60 %choose file
    axes(ha(rr(channelnumber))); 
    
    for     G =1:length(HMM_different_G)
        
        mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(G,channelnumber)));
        mutual_information = cell2mat(HMM_MI (G,channelnumber));
        if channelnumber~=31
         if max(mutual_information)-min(mutual_information)<0.2 
            continue;
        end
        if max(mutual_information-mean_MI_shuffle)<0.1
            continue;
        end
        else
            plot(time,mutual_information-mean_MI_shuffle); hold on; %,'color',cc(z,:));hold on
            xlim([ -2300 1300])
            ylim([0 100])
            continue;
        end
        plot(time,mutual_information-mean_MI_shuffle); hold on; %,'color',cc(z,:));hold on
        xlim([ -2300 1300])
        ylim([0 inf+0.1])

    end
    
    if channelnumber == 31
    lgd =legend('G3','G4.5','G7.5','Location','north');
    lgd.FontSize = 11;
    legend('boxoff')
    end
    
    hold off;
    
end
% [25,33,34]
%[52,53,57,58,59,60]
for channelnumber=[52,53,57,58,59,60]
          figure(channelnumber)
     for   G =1:length(HMM_different_G)
        mean_MI_shuffle = mean(cell2mat(HMM_MI_shuffle(G,channelnumber)));
        mutual_information = cell2mat(HMM_MI (G,channelnumber));hold on;
        plot(time,smooth(mutual_information-mean_MI_shuffle)); 
        xlim([ -2300 1300])
        ylim([0 inf+0.1])
     end
     for   G =1:length(OU_different_G)
        mean_MI_shuffle = mean(cell2mat(OU_MI_shuffle(G,channelnumber)));
        mutual_information = cell2mat(OU_MI (G,channelnumber));hold on;
        plot(time,smooth(mutual_information-mean_MI_shuffle),':'); 
        xlim([ -1300 1300])
        ylim([0 inf+0.1])
     end
      lgd =legend('1.08sec','0.8sec','0.4833sec','OU-1.1167sec','OU-0.27sec','Location','northwest');
     lgd.FontSize = 11;
     legend('boxoff')
     hold off;
end