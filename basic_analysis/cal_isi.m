spike = sorted_spikes{27}'.*0.001;
inter = diff(spike);
pre = inter(1,1:length(inter)-1);
post = inter(2:end);
figure;
scatter(pre,post)
xlabel('pre isi(sec)');ylabel('post isi(sec)');
set(gca,'xscale','log')
set(gca,'yscale','log')