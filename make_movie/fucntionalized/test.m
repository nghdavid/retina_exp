Gvalue = 2.5;
load('C:\0421 new video Br50\rn_workspace\o_rntestG025.mat')
hist(rntest)
mins = 5;
T=mins*60; %second
dt=1/60;
Time=dt:dt:T;

cutOffFreq =0.5;
HMM_Xarray = rescale(HMM_generator(T,dt,Gvalue,rntest),1,10);
OU_Xarray = rescale(OU_generator(T,dt,Gvalue,rntest),1,10);
sOU_Xarray = rescale(Smooth_OU_generator(T,dt,Gvalue,rntest,cutOffFreq),1,10);
figure; hold on
plot(HMM_Xarray);
plot(OU_Xarray);
plot(sOU_Xarray);

newXarray = 0.0*sOU_Xarray+1.0*OU_Xarray;
acf = autocorr(newXarray,100);
corr_time = find(abs(acf-0.5) == min(abs(acf-0.5)))*dt;
sOU_Xarray2 = smooth(OU_Xarray,60);
plot(sOU_Xarray2);

figure;plot(autocorr(OU_Xarray-sOU_Xarray,100))
figure;hist(OU_Xarray-sOU_Xarray+10);