num_repeat = 4;
channel_number = 18:21;
BinningInterval = 1/60;  %s
name = 'sort_merge_0319_HMM_UD_G3_7min_Br50_Q100_';
path = 'unit_a\sort_merge_spike\';
load([path,name,int2str(1),'.mat'])
BinningTime = diode_BT;
total_spikes = zeros(60,length(diode_BT),num_repeat);
for j = 1:num_repeat
    load([path,name,int2str(j),'.mat'])
    
    % Binning
    
    BinningSpike = zeros(60,length(BinningTime));
    for i = 1:60 % i is the channel number
        [n,~] = hist(sorted_spikes{i},BinningTime) ;
        BinningSpike(i,:) = n ;
    end 
    total_spikes(:,:,j) = BinningSpike;
end
figure('units','normalized','outerposition',[0 0 1 1])
ha = tight_subplot(length(channel_number),1,[.1 .01],[0.05 0.05],[.02 .01]);
j = 1;
for i = channel_number
    axes(ha(j));  
    imagesc(BinningTime,1:num_repeat,reshape(total_spikes(i,:,:),[length(channel_number),length(BinningTime)]));
    xlabel('time(s)');  
    ylabel('trials');
    title(['channel ',int2str(i)])
    j = j + 1;
end
