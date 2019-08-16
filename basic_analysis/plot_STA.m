close all;
clear all;
code_folder = pwd;
load('boundary_set.mat')
<<<<<<< Updated upstream
exp_folder = 'E:\20190709';
=======
exp_folder = 'D:\Leo\0807exp';
>>>>>>> Stashed changes
cd(exp_folder)
cd STA
mkdir FIG
display_channel = [1:60];
%Tina orientation
rr =[9,17,25,33,41,49,...
          2,10,18,26,34,42,50,58,...
          3,11,19,27,35,43,51,59,...
          4,12,20,28,36,44,52,60,...
          5,13,21,29,37,45,53,61,...
          6,14,22,30,38,46,54,62,...
          7,15,23,31,39,47,55,63,...
            16,24,32,40,48,56];
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
    for channelnumber=1:60
<<<<<<< Updated upstream
        if sum(abs(dis_STA(channelnumber,:))) <= 0
=======
        if sum(dis_STA(channelnumber,:)) == 0
>>>>>>> Stashed changes
            disp(['channel ',int2str(channelnumber),' does not have RF center'])
            continue
        end
        axes(ha(rr(channelnumber)));
        plot(time,dis_STA(channelnumber,:)*micro_per_pixel,'LineWidth',2,'LineStyle','-');hold on;
        grid on
        %Y axis is um
        title(channelnumber)
    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    saveas(fig,['FIG\',name,'.tiff'])
    saveas(gcf,['FIG\',name,'.fig'])
end
% 
%  for i = display_channel  % i is the channel number
%       if sum(TheStimuli(i,:)) <= 0
%             disp(['channel ',int2str(i),'does not have RF center'])
%             continue
%     end
%     figure(i)
%     plot(time,dis_STA(i,:)*micro_per_pixel)
%     title(['channel ',int2str(i),' distance STA'])
%     xlabel('time')
%     ylabel('relative position (um)')
%  end