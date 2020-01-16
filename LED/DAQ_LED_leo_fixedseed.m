function DAQ_LED_leo_fixedseed(stimu, G_tau, mean_lumin,seeddate)
%G_tau and seeddate has to be existed
ddd=date;
diode_path_cal=['D:\leo\stimulus saving\',ddd,'\calibration'];
load([diode_path_cal,'\calibration',ddd])
load(['D:\0930v\videoworkspace\0421_HMM_RL_G',num2str(G_tau),'_5min_Br50_Q100.mat'])
%clearvars -except rate volt lumin_filter stimu G_tau true_lumin mean_lumin
daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_out.write(0);

% load('E:\rona\20160318\map');
%%%%%%%%%%%%% step3:calibration %%%%%%%%%%%%%%%%%%%
x=volt;
y=(lumin_filter)';
z=(true_lumin)';
mean_lumin = 1;
%% Signal %%%%%%%%%%%%%%%%%
    %% ONOFF
if stimu == 'oo'
    repeat = 40; 
    on_t = 0.5; %s
    off_t = 0.5; %s
    mean_t = 1.5; %s
    period = (2*mean_t+on_t+off_t);
    mean_i = mean_lumin;
    i_offset =0.4*mean_i;
    at = 3;%adaptation time
    ey = zeros; 
    a2 = -0.1*ones;
    ey(1:at*rate)=mean_i;
    for j = (0:repeat-1) % how many a2 in a trial
        ey( (at+period*j)*rate+1 : (at+period*j+on_t)*rate ) = mean_i+i_offset;
        ey( (at+period*j+on_t)*rate+1 : (at+period*j+mean_t+on_t)*rate ) = mean_i;
        ey( (at+period*j+mean_t+on_t)*rate+1 : (at+period*j+mean_t+on_t+off_t)*rate ) = mean_i-i_offset;
        ey( (at+period*j+mean_t+on_t+off_t)*rate+1 : (at+period*j+2*mean_t+on_t+off_t)*rate ) = mean_i;
        a2( (at+period*j)*rate+1 : (at+period*j+on_t)*rate ) = 1;
        a2( (at+period*j+on_t)*rate+1 : (at+period*j+mean_t+on_t)*rate ) = -0.1;
        a2( (at+period*j+mean_t+on_t)*rate+1 : (at+period*j+mean_t+on_t+off_t)*rate ) = 1;
        a2( (at+period*j+mean_t+on_t+off_t)*rate+1 : (at+period*j+2*mean_t+on_t+off_t)*rate ) = -0.1;
    end
    x1 = 1:length(ey);
    figure;plot(x1,ey);hold on; plot(x1,a2)
    
    ss = ['_Gonoff_'];
    %% ContrastSTA
elseif stimu == 'cs'
    T = 180; %nth in sec
    unit = 1/30;  %time step unit in ~ms
    steps = T/unit;
    r=0.08;
    %d = r*(rand(1,steps)-0.5);  %intensity
    at=30;
    m=mean_lumin;
    d = m*0.3*(randn(1,steps));  %intensity
    ey1=[];ey=[];ey0=[];
    for i=1:steps
        ey1(round(rate*unit*(i-1)+1) : round(rate*unit*i))=m+d(i);
    end
    ey1(ey1 > 1.95*mean_lumin) = 1.95*mean_lumin;
    ey1(ey1 < 0.05*mean_lumin) = 0.05*mean_lumin;
    ey0=m*ones(1,at*rate);%REST
    ey=[ey0 ey1]; 
    figure;plot(ey);
    a2=[0*ones(1,at*rate) ey1];
    ss = ['_cSTA_'];
%% intensity:HMM    
elseif stimu == 'hm'
%     load('G:\Rona\noise\normalnoise.mat');
    G_tau = 3;
    mean_lumin = 10;
    rate = 10000;
    Tot = 300;  
    dt = 50*10^-3; 
    dtau = 50*10^-3; %step width 
    T = dtau:dtau:Tot;
    G = G_tau; % damping  
    w = G/(2*1.06);%w = G/(2w)=1.06;  
    D = 4; %dynamical range
    at = 30;
%     r = 0.14;%if G= 10 normal r =0.1
    m = mean_lumin;

    a2=[];ey=[];ey1=[];
    for i = 1:length(newXarray)/3
        temp(i) = newXarray(i*3) +newXarray(i*3-1) +newXarray(i*3-2);
    end
    temp = 0.3*m/std(temp)*temp;
    temp = temp-mean(temp)+m; % X is the final stimuX
    X = temp;
    X(X > 1.95*mean_lumin) = 1.95*mean_lumin;
    X(X < 0.05*mean_lumin) = 0.05*mean_lumin;
    std(X)/m
    temp2=repmat(X,rate*dtau,1);
    %temp2 = interp1(newXarray,1:Tot*rate/length(newXarray):Tot*rate,1:length(newXarray),'spline');
    ey1=temp2(:)';

    ey0=m*ones(1,at*rate);%REST
    ey=[ey0 ey1];
    a2=zeros(1,length(ey));
    a2(at*rate:(at+1)*rate)=1;
    a2((Tot+at-1)*rate:(Tot+at)*rate)=1;

    t=[1/rate:1/rate:length(ey1)/rate];
    figure(1);plot(ey1);hold on
    plot(newXarray)
    ss = ['_HMM_G=',num2str(G),'_'];
    

 %% OU process
elseif stimu == 'ou'
%     load('G:\Rona\noise\normalnoise.mat');
    Tot = 300;  
    dt = 50*10^-3; 
    dtau=50*10^-3; %step width 
    T = dtau:dtau:Tot;
    tau=G_tau;%0.1 0.3 0.6
    D = 4; %dynamical range
    at = 30;
    m = mean_lumin;
    a2=[];ey=[];ey1=[];
   for i = 1:length(newXarray)/3
        temp(i) = newXarray(i*3) +newXarray(i*3-1) +newXarray(i*3-2);
    end
    temp = 0.3*m/std(temp)*temp;
    temp = temp-mean(temp)+m; % X is the final stimuX
    X = temp;
    X(X > 1.95*mean_lumin) = 1.95*mean_lumin;
    X(X < 0.05*mean_lumin) = 0.05*mean_lumin;
    for i=1:length(X)
        ey1(rate*dtau*(i-1)+1:rate*dtau*i)=X(i);
    end
    std(X)/m
    ey0=m*ones(1,at*rate);%REST
    ey=[ey0 ey1];
    a2=zeros(1,length(ey));
    a2(at*rate:(at+1)*rate)=1;
    a2((Tot+at-1)*rate:(Tot+at)*rate)=1;
    t=[1/rate:1/rate:length(ey)/rate];
    figure(3);plot(t,ey);hold on 
    ss = ['_OU_tau=',num2str(tau*1000),'ms_'];


%% Load mat file
elseif stimu == 'ld'
    filename='HMM_G=30_output';
    load(['D:\Chou\Chou\20190509_output\',filename,'.mat']);
    figure(3);plot(t,ey);hold on 
    span=20; %change the smoothing span
    ss=[filename,'_'];
end
%% Noise %%%%%%%%%%%%%%%%%%%
nl=0; % noise level

eyf=ey;

[z, index] = unique(z);
ex = interp1(z,x(index),eyf,'linear');% ex=calibrate voltage
figure;plot(x(index),z);hold on; scatter (ex,eyf);
daq = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'SampleNum', length(eyf));
% daq.stop
daq_out = daqmx_Task('chan','Dev1/ao0:1' ,'rate',rate, 'Mode', 'f');
daq_in = daqmx_Task('chan','Dev1/ai0' ,'rate',rate, 'SampleNum', length(eyf));

A=[];
A(:,1) = a2(1:length(eyf));
A(:,2) = ex(1:length(eyf));

%%%% output %%%%%%%%%%
daq_out.write(A); 
daq_in.read;
callumin=daq_in.data*meature2true_transformer;
[b,a]=butter(2,10/rate,'low');
callumin_filter=filter(b,a,daq_in.data)*meature2true_transformer;
daq_in.wait;

close all;
daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_out.write(0);

figure(5) ; plot(ex);title(['calibrated voltage v.s. time']);
figure(6) ; plot(callumin);title(['lumin v.s. time']);hold on;plot(ey,'r');plot(eyf,'g');
figure(7) ; plot(callumin_filter);title(['lumin v.s. time']);hold on;plot(ey,'r');plot(eyf,'g');

ddd=date;
diode_path=['D:\leo\',ddd];
mkdir(diode_path)
save(['D:\leo\',ddd,'\diode_',ss,num2str(mean_lumin),'_',date,'.mat'],'callumin','callumin_filter','a2','ex','ey','eyf');

end
