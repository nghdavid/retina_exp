%Load calculated MI first(Need to run Calculate_MI.m first to get)
cd unit_a\sort_merge_spike\MI
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
        
for z =1:n_file

    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([filename]);
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.03 .01],[0.02 0.02],[.01 .01]);
    for channelnumber=1:60
        axes(ha(rr(channelnumber))); 
        plot(time,Mutual_infos{channelnumber},'LineWidth',2,'LineStyle','-');

        xlim([ -1300 1300])
        ylim([0 inf+0.1])
        title(channelnumber)

    end
    saveas(gcf,[name,'.tiff'])
    saveas(gcf,[name,'.fig'])

end


