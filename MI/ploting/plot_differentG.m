cd G:\0215\sort_merge_spike\MI\HMM_RL
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
n_file = length(all_file) ;


for channelnumber=1%:60 %choose file
    h3=figure;
    for     z =1:n_file 
        file = all_file(z).name ;
        [pathstr, name, ext] = fileparts(file);
        directory = [pathstr,'\'];
        filename = [name,ext];
        load([filename]);
         
        plot(time,Mutual_infos{channelnumber}-Mutual_shuffle_infos{channelnumber}); hold on; %,'color',cc(z,:));hold on

        xlabel('delta t (ms)');ylabel('MI (bits/second)( minus shuffled)');
        set(gca,'fontsize',12); hold on

        legend('-DynamicLegend');
        legend('show')
        lgd = legend('G20','G3','G9');

        xlim([ -15000 15000])
        ylim([0 inf])
        title(['channel ',num2str(channelnumber)]) 

    end
    
    
end