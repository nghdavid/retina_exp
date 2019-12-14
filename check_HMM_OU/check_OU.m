clear all;
load(['C:\calibration\','20191115v','\boundary_set.mat'])
list = [2.5 3 4.3 4.5 5.3 6.3 6.5 7.5 9 12 20];
seed_date='0810';
seed_directory_name = [seed_date,' new video Br50\rn_workspace'];
cd(['C:\',seed_directory_name]);%New seed for HMM movie
all_file = dir('*.mat');%Load random seed
fps =60;  %freq of the screen flipping
T=5*60; %second
dt=1/fps;
T=dt:dt:T;
corr_times = [];

%% Run each many Gamma value
for Gvalue=list
    %% OU parameter and video name
    G_OU = Gvalue; % damping / only G will influence correlation time
    D_OU = 2700000; %dynamical range
    file = all_file(find(list==Gvalue)).name;
    [~, name, ext] = fileparts(file);
    filename = [name,ext];
    load(['C:\',seed_directory_name,'\',filename]);
    name=[name];
    name
    Gvalue
    x = zeros(1,length(T));
    x(1,1)=0; % since the mean value of damped eq is zero
    for uu = 1:length(T)-1
          x(uu+1) = (1-dt*G_OU/(2.12)^2)*x(uu)+sqrt(dt*D_OU)*rntest(uu);
    end
    %Normalize to proper moving range
    
    nrx=abs((rightx_bd-leftx_bd-2*bar_wid)/(max(x)-min(x)));
    x2=x*nrx;
    x3=x2+leftx_bd+bar_wid-min(x2);%rearrange the boundary values
    newXarray=round(x3); 
    acf = autocorr(newXarray,100);
    corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))/60;
    corr_times = [corr_times corr_time];
    disp(['The correlation time is ',num2str(corr_time),' second'])
    cd ('E:\random_seed')
    save([seed_date,'OU',num2str(Gvalue),'.mat'],'newXarray')  
end   