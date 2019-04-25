for channelnumber=1:60
figure;
plot(time,Mutual_infos{channelnumber}-Mutual_shuffle_infos{channelnumber}); hold on; %,'color',cc(z,:));hold on

xlabel('delta t (ms)');ylabel('MI (bits/second)( minus shuffled)');
set(gca,'fontsize',12); hold on

 

xlim([ -3000 3000])
ylim([0 inf])
title(['channel ',num2str(channelnumber)]) 



end





