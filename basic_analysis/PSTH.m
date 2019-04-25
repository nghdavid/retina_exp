
num_repeat = 4;
channel_number = 18:21;
BinningInterval = 1/60;  %s
name = 'sort_merge_0319_HMM_UD_G20_7min_Br50_Q100_';
path = 'unit_a\sort_merge_spike\';
figure('units','normalized','outerposition',[0 0 1 1])

ha = tight_subplot(num_repeat,1,[.1 .01],[0.05 0.05],[.02 .01]);
for j = 1:num_repeat
    
    load([path,name,int2str(j),'.mat'])
    % Binning
    
    BinningTime = diode_BT;
    BinningSpike = zeros(60,length(BinningTime));
    for i = 1:60 % i is the channel number
        [n,~] = hist(sorted_spikes{i},BinningTime) ;
        BinningSpike(i,:) = n ;
    end 
    
    axes(ha(j)); 
    imagesc(BinningTime,channel_number,BinningSpike(channel_number,:));
    title([name,int2str(j)])
    colorbar
    set(gca,'fontsize',12)
    xlabel('time(s)');  
    ylabel('channel ID');
    
end
saveas(gcf,[name,'.tiff'])
saveas(gcf,[name,'.fig'])