close all;
clear all;
code_folder = pwd;
exp_folder = 'E:\20190721';
cd(exp_folder)
HMM_former_name = '0602_HMM_UD_G';
HMM_post_name = '_7min_Br50_Q100_1';
HMM_different_G = [3,4.5,7.5,12,20];
roi = [5,6,13,52,59];
sorted=1;
save_photo = 1;
filename =  '0602_HMM_UD_5G_7min_Br50_Q100_1_ch';                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
OU_former_name = '0319_OU_RL_G';
OU_post_name = '_5min_Br50_Q100';
OU_different_G = [2.45,10.5];
OU_or_Not = 0;
all_or_Not = 1;
%Load calculated MI first(Need to run Calculate_MI.m first to get)
if sorted
    cd STA
else
    cd STA
end
rr =[9,17,25,33,41,49,...
          2,10,18,26,34,42,50,58,...
          3,11,19,27,35,43,51,59,...
          4,12,20,28,36,44,52,60,...
          5,13,21,29,37,45,53,61,...
          6,14,22,30,38,46,54,62,...
          7,15,23,31,39,47,55,63,...
            16,24,32,40,48,56];

HMM_STA =[];

for  G =1:length(HMM_different_G) 
    load([HMM_former_name,num2str(HMM_different_G(G)),HMM_post_name ,'.mat'])
    HMM_STA = [HMM_STA;dis_STA];
end

if OU_or_Not
    OU_STA =[];
    for   G =1:length(OU_different_G) 
        load([OU_former_name,num2str(OU_different_G(G)),OU_post_name ,'.mat'])
        OU_STA = [OU_STA;dis_STA];
    end
end

%% Plot all channels
if all_or_Not
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);


for channelnumber=1:60 %choose file
    axes(ha(rr(channelnumber))); 
    for G =1:length(HMM_different_G)
        plot(time,HMM_STA ((G-1)*60+channelnumber,:)); hold on; %,'color',cc(z,:));hold on
    end
    hold off;
end
end

%% Plot single channel
mean_peaks = zeros(length(HMM_different_G),length(roi));
for channelnumber= roi 
     figure(channelnumber)
     for   G =1:length(HMM_different_G)
        if G >=4
            plot(time,HMM_STA ((G-1)*60+channelnumber,:)); hold on;
        elseif G >2
            plot(time,HMM_STA ((G-1)*60+channelnumber,:),'k:'); hold on;
        else
            plot(time,HMM_STA ((G-1)*60+channelnumber,:),'.'); hold on;
        end
     end
     if OU_or_Not
         for   G =1:length(OU_different_G)
            plot(time,HMM_STA ((G-1)*60+channelnumber,:),'-.'); hold on;
         end
     end
     grid on
     
     if OU_or_Not
        lgd =legend('1.08sec','0.8sec','0.4833sec','0.32sec','0.18sec','OU-1.1167sec','OU-0.27sec','Location','northwest');
     else
        lgd =legend('1.08sec','0.8sec','0.4833sec','0.32sec','0.18sec','Location','northwest');
     end
     lgd.FontSize = 11;
     legend('boxoff')
     hold off;
     if save_photo
         if sorted
            saveas(gcf,[exp_folder,'\STA\FIG\',filename,int2str(channelnumber),'.tif'])
         else
            saveas(gcf,[exp_folder,'\STA\FIG\',filename,int2str(channelnumber),'.tif'])
         end
     end
end

