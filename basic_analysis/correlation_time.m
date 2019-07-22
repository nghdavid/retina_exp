%% Code that calculate correlation time
%load merge data first
acf = autocorr(bin_pos,100);
corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))/60;
disp(['The correlation time is ',num2str(corr_time),' second'])
