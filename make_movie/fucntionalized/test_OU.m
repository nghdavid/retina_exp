dt=1/60;
T=300;
T=dt:dt:T;
load('C:\0421 new video Br50\rn_workspace\o_rntestG03.mat');%New seed for HMM movie
Gvalue = 20;
Xarray = OU_generator(T,dt,Gvalue,rntest);
Smooth_Xarray = Smooth_OU_generator(T,dt,Gvalue,rntest);
plot(T,Xarray,'b');hold on
plot(T,Smooth_Xarray,'r')
xlim([0 30])

acf = autocorr(Xarray,100);
corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))/60;
disp(['The correlation time is ',num2str(corr_time),' second'])

acf = autocorr(Smooth_Xarray,100);
corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))/60;
disp(['The correlation time is ',num2str(corr_time),' second'])