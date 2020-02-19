cd E:\random_seed
list = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];
seed_date='0810';
num = 1;
t1 = 1000;
t2 = 3000;
for Gvalue=list
    figure(num)
    load(['E:\random_seed\',seed_date,'HMM',num2str(Gvalue),'.mat'])
    plot(newXarray(t1:t2),'r');hold on;
    load(['E:\random_seed\',seed_date,'OU',num2str(Gvalue),'.mat'])
    plot(newXarray(t1:t2),'b');hold off;
    legend('HMM','OU')
    num = num+1;
    saveas(gcf,[seed_date,'G',num2str(Gvalue),'.tif'])
end