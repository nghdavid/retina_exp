clear all;
load(['C:\calibration\','20191115v','\boundary_set.mat'])
list = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];%Gamma value complete list
seed_date='0810';
seed_directory_name = [seed_date,' new video Br50\rn_workspace'];
cd(['C:\',seed_directory_name]);%New seed for HMM movie
all_file = dir('*.mat');%Load random seed
fps =60;  %freq of the screen flipping
T=5*60; %second
dt=1/fps;
T=dt:dt:T;
corr_times = [];
for Gvalue=list
    %% HMM parameter and video name
    G_HMM =Gvalue; %damping / only G will influence correlation time
    D_HMM = 2700000; %dynamical range
    omega =G_HMM/2.12; %omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
    %Random number files ( I specifically choose some certain random seed series)
    file = all_file(find(list==Gvalue)).name;
    [~, name, ext] = fileparts(file);
    filename = [name,ext];
    load(['C:\',seed_directory_name,'\',filename]);
    name=[name];
    name
    Gvalue
    
    %% HMM trajectory 
    Xarray = zeros(1,length(T));
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    Vx = zeros(1,length(T));
    %Use rntest(t)!!!
    for t = 1:length(T)-1
        Xarray(t+1) = Xarray(t) + Vx(t)*dt;
        Vx(t+1) = (1-G_HMM*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D_HMM)*rntest(t);
    end
    nrx=abs((rightx_bar-leftx_bar-2*bar_wid)/(max(Xarray)-min(Xarray)));
    Xarray2=Xarray*nrx;
    Xarray3=Xarray2+leftx_bar+bar_wid-min(Xarray2);%rearrange the boundary values
    newXarray=round(Xarray3);
    acf = autocorr(newXarray,100);
    corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))/60;
    corr_times = [corr_times corr_time];
    disp(['The correlation time is ',num2str(corr_time),' second'])
    cd ('E:\random_seed')
    save([seed_date,'HMM',num2str(Gvalue),'.mat'],'newXarray')  
end
