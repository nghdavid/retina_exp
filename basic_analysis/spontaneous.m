%% spontaneous

% Binning
BinningInterval = 1/100;  %s
BinningTime = [0 : BinningInterval : length(a_data)/20000];
BinningSpike = zeros(60,length(BinningTime));
for i = 1:60  % i is the channel number
    [n,~] = hist(Spikes{i},BinningTime) ;
    BinningSpike(i,:) = n ;
end 
figure; imagesc(BinningTime,[1:60],BinningSpike);
title('Spontaneous   /  BinningInterval=10ms')
colorbar
set(gca,'fontsize',12)
xlabel('time(s)');  
ylabel('channel ID');
% saveas(gcf, ['Spontanrous  BinningInterval=10ms'],'fig');