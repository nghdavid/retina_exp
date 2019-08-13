clearvars -except rate volt lumin_filter 
daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_out.write(0);
rate=20000;
% load('E:\rona\20160318\map');
%%%%%%%%%%%%% step3:calibration %%%%%%%%%%%%%%%%%%%
x=volt;
y=(lumin_filter)';

%% Signal %%%%%%%%%%%%%%%%%%
% date = '20190329';

stimu = input('Stimulation? onoff(on)/tsta(ts)/csta(cs)/adaptation(ad)/hmm(hm)/ou(ou)/repeat(re)/osr(os)/jittertime(jt)/curve(cu)  ');

if stimu == 'on'
    %% ONOFF
    repeat = 7;
    rt = 5; % rest time
    OT = 2; % dim time
    T = 2; % bright time
    ns = 3; % # of  step in a loop
    period = rt+ns*(T+OT); % period of a loop
    m = 0;% onoff 0-0.18
    d = 0.15;% increment of lumin
    x1 = 1:period*rate*repeat;
    ey = zeros; 
    a2 = -0.1*ones;
    at = 3;%adaptation time
    aL=(m+d)/2;
    ey(1:at*rate)=aL;
    for i = 1:repeat 
        ey(at*rate+period*rate*(i-1)+1:at*rate+period*rate*(i-1)+rt*rate)= aL; %«e¤­¬í
%             a2(at*rate+period*rate*(i-1)+1:at*rate+period*rate*(i-1)+rt*rate)=-0.1;
        for j = 1:ns % how many a2 in a trial      
            ey(at*rate+period*rate*(i-1)+rt*rate+(j-1)*(T+OT)*rate+1:at*rate+period*rate*(i-1)+rt*rate+(j-1)*(T+OT)*rate+T*rate)=m+d;
            ey(at*rate+period*rate*(i-1)+rt*rate+(j-1)*(T+OT)*rate+T*rate+1:at*rate+period*rate*(i-1)+rt*rate+(j-1)*(T+OT)*rate+T*rate+OT*rate)=m;
            a2(at*rate+period*rate*(i-1)+rt*rate+(j-1)*(T+OT)*rate+1:at*rate+period*rate*(i-1)+rt*rate+(j-1)*(T+OT)*rate+T*rate)=1;        
            a2(at*rate+period*rate*(i-1)+rt*rate+(j-1)*(T+OT)*rate+T*rate+1:at*rate+period*rate*(i-1)+rt*rate+(j-1)*(T+OT)*rate+T*rate+OT*rate)=-0.1;
        end

    end
    x1 = 1:length(ey);
    figure;plot(x1,ey);
    ss = ['_onoff_'];
%% ContrastSTA
elseif stimu == 'cs'
    T = 180; %nth in sec
    unit = 0.050;  %time step unit in ~ms
    steps = T/unit;
    r=0.08;
    d = r*(rand(1,steps)-0.5);  %intensity
    at=30;
    m=0.05;
    ey1=[];ey=[];ey0=[];
    for i=1:steps
        ey1(rate*unit*(i-1)+1:rate*unit*i)=m+d(i);
    end
    ey0=m*ones(1,at*rate);%REST
    ey=[ey0 ey1]; 
    figure;plot(ey);
    a2=[0*ones(1,at*rate) ey1];
    ss = ['_cSTA_'];
%% Adaptation
elseif stimu == 'ad'
    t1 = 15; 
    t2 = 15;
    unit = 0.020;  %time step unit in ~ms
    r1 = 0.02;
    r2 = 0.002;
    at = 30;
    m = 0.05;
    ey1=[];temp=[];ey0=[];ey=[];a2=[];
    ey0=m*ones(1,at*rate);%REST
    for k = 1:60
        ey1=[];
        ey2=[];
        for i = 1:t1/unit
            ey1(rate*unit*(i-1)+1:rate*unit*i)=m+r1*(randn(1,1));
        end
        for j = 1:t2/unit
            ey2(rate*unit*(j-1)+1:rate*unit*j)=m+r2*(randn(1,1));
        end
        std(ey1)/m;
        std(ey2)/m;
        temp=[temp ey1 ey2]; 
    end
    temp=abs(temp);
   
    a2 = repmat([ones(1,t1*rate),zeros(1,t2*rate)],1,k);
    a2 = [zeros(1,at*rate) a2];
    ey = [ey0 temp];
    figure;plot(ey);
    hold on;plot(a2,'r')
    ss = ['_adapt_L1=',num2str(t1),'_'];
%% TimeSTA
elseif  stimu == 'ts'
    T = 180; %nth in sec
    d = 0.15;  %intensity
    unit = 0.05;  %time step unit in ~ms
    steps = T/unit;
    flick = rand(1,steps)-0.5;
    flick(find(flick>0)) = 1;
    flick(find(flick<=0)) = 0;
    flick = flick*d;
    plot(1:steps,flick)
    ey=[];
    ratio = round(unit*rate);
    for in=1:length(flick)
        ey=[ey flick(in)*ones(1,ratio)];
    end
    a2=ey(1:T*rate);
    ey=ey(1:T*rate);
    figure;plot(ey);
        
%% intensity:HMM    
elseif stimu == 'hm'
%     load('G:\Rona\noise\normalnoise.mat');
    Tot = 300;  
    dt = 50*10^-3; 
    dtau = 50*10^-3; %step width 
    T = dtau:dtau:Tot;
    G = 3; % damping  
    w = G/(2*1.06);%w = G/(2w)=1.06;  
    D = 4; %dynamical range
    at = 30;
%     r = 0.14;%if G= 10 normal r =0.1
    m = 0.05;

    a2=[];ey=[];ey1=[];
    L = zeros(1,length(T));
    V = zeros(1,length(T));
    for t = 1:length(T)
        L(t+1) = L(t) + V(t)*dt;  %(th*(mu - X(t)))*dt + sqrt(dt)*randn; th = .01;  mu = 3;
        V(t+1) = (1-G*dt)*V(t) - w^2*L(t)*dt + sqrt(dt*D)*randn;
%         V(t+1) = (1-G*dt)*V(t) - w^2*L(t)*dt + sqrt(dt*D)*noise(t);
    end      
    L = 0.01*L/std(L);
    temp = L-mean(L)+m; % X is the final stimuX
    X = abs(temp);
    std(X)/m
    ey1=zeros(1,length(X));
    temp = X(2:1:length(X));%temp = X(2:dtau/dt:Tot/dt);
    temp2=repmat(temp,rate*dtau,1);
    ey1=temp2(:)';

    ey0=m*ones(1,at*rate);%REST
    ey=[ey0 ey1];
    a2=zeros(1,length(ey));
    a2(at*rate:(at+1)*rate)=1;
    a2((Tot+at-1)*rate:(Tot+at)*rate)=1;

    t=[1/rate:1/rate:length(ey)/rate];
    figure(1);plot(t,ey);hold on
%     figure(2);autocorr(ey1,20000);
    % %     a=L(1:length(L)-1)';b=L(2:length(L))';
    % %     [N,C]=hist3([a,b]); %20:dividing firing rate  6:# of stim
    % %     px=sum(N,1)/sum(sum(N)); % x:stim
    % %     py=sum(N,2)/sum(sum(N)); % y:word
    % %     pxy=N/sum(sum(N));
    % %     temp2=[];
    % %     for j=1:length(px)
    % %         for k=1:length(py)
    % %             temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2);
    % %         end
    % %     end
    % %     informationf=nansum(temp2(:)) 
    %     std(X)
    ss = ['_HMM_G=',num2str(G),'_'];
    
%% Curve
elseif stimu == 'cu'
Tot = 300;  
dt = 50*10^-3; 
dtau = 50*10^-3; %step width 
T = dtau:dtau:Tot;
G = 10; % damping  
w = G/(2*1.06);%w = G/(2w)=1.06;  
D = 4; %dynamical range
at = 30;
m = 0.05;

a2=[];ey=[];ey1=[];
L = zeros(1,length(T));
V = zeros(1,length(T));
for t = 1:length(T)
    L(t+1) = L(t) + V(t)*dt;  %(th*(mu - X(t)))*dt + sqrt(dt)*randn; th = .01;  mu = 3;
    V(t+1) = (1-G*dt)*V(t) - w^2*L(t)*dt + sqrt(dt*D)*randn;
%         V(t+1) = (1-G*dt)*V(t) - w^2*L(t)*dt + sqrt(dt*D)*noise(t);
end
L = 0.01*L/std(L);
temp = L-mean(L)+m; % X is the final stimuX
X = abs(temp);
std(X)/m
ey1=[];
for i= 1 : length(X)-1
    ey1((i-1)*rate*dtau+1:(i)*rate*dtau) = linspace(X(i),X(i+1),rate*dtau);
end

temp = X(2:dtau/dt:Tot/dt+1);
temp2=repmat(temp,rate*dtau,1);
ey2=temp2(:)';

ey0=m*ones(1,at*rate);%REST
ey=[ey0 ey1];
a2=zeros(1,length(ey));
a2(at*rate:(at+1)*rate)=1;
a2((Tot+at-1)*rate:(Tot+at)*rate)=1;

t=[1/rate:1/rate:length(ey)/rate];
figure(1);plot(t,ey);hold on
ss = ['_curveHMM_G=',num2str(G),'_'];
 %% OU process
elseif stimu == 'ou'
%     load('G:\Rona\noise\normalnoise.mat');
    Tot = 300;  
    dt = 50*10^-3; 
    dtau=50*10^-3; %step width 
    T = dtau:dtau:Tot;
    tau=0.7;%0.1 0.3 0.6
    D = 4; %dynamical range
    at = 30;
    m = 0.05;
    a2=[];ey=[];ey1=[];
    L = zeros(1,length(T));
    for i = 1:length(T)-1
    L(i+1) = L(i) + (-L(i)/tau + randn*sqrt(D/dt))*dt;
%     L(i+1) = L(i) + (-L(i)/tau + noise(i)*sqrt(D/dt))*dt;
    end  
    L = 0.01*L/std(L);
    X = L-mean(L)+m; % X is the final stimuX
%     L = r*L;
%     X = L-mean(L)+m; % X is the final stimuX
    X = abs(X);
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
%     figure(4);autocorr(ey1,20000);

%     a=L(1:length(L)-1)';b=L(2:length(L))';
%     [N,C]=hist3([a,b]); %20:dividing firing rate  6:# of stim
%     px=sum(N,1)/sum(sum(N)); % x:stim
%     py=sum(N,2)/sum(sum(N)); % y:word
%     pxy=N/sum(sum(N));
%     temp2=[];
%     for j=1:length(px)
%         for k=1:length(py)
%             temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2);
%         end
%     end
%     informationf=nansum(temp2(:))
%     std(ey)
    ss = ['_OU_tau=',num2str(tau*1000),'ms_'];
%% repeat trials
elseif stimu == 're'
    load('G:\Rona\noise\normalnoise.mat');
    Tot = 15;  
    repeat = 20;
    dt = 50*10^-3; 
    dtau=50*10^-3; %step width 
    %     T = dtau:dtau:Tot;
    T = dt:dt:Tot;
    G = 10; % damping  
    w = G/(2*1.06);%w = G/(2w)=1.06;  
    D = 4; %dynamical range
    at = 15;
    r = 0.1;
    m=0.05;

    a2=[];ey=[];ey1=[];
    L = zeros(1,length(T));
    % %HMM
    V = zeros(1,length(T));
    for t = 1:length(T)-1
        L(t+1) = L(t) + V(t)*dt;  
        V(t+1) = (1-G*dt)*V(t) - w^2*L(t)*dt + sqrt(dt*D)*noise(t);
    end      
    L = r*L;

    %%OU
    % tau=0.6;
    % r=0.009;
    % for i = 1:length(T)-1
    %     L(i+1) = L(i) + (-L(i)/tau + noise(i)*sqrt(D/dt))*dt;
    % end      
    % L = r*L;

    %%rand
    % for i = 1:length(T)
    %     L(i) = 0.005*noise(i);
    % end      

    X = L-mean(L)+m; % X is the final stimuX
    X = abs(X);
    for i=1:length(X)
        ey1(rate*dtau*(i-1)+1:rate*dtau*i)=X(i);
    end
    a20=zeros(1,(Tot+at)*rate);
    a20(at*rate+1:(at+1)*rate)=1;
    a2=[a20];
    ey0=zeros(1,at*rate);
    ey=[ey0 ey1];
    for i=1:repeat-1
        ey=[ey ey0 ey1];
        a2=[a2 a20];
    end
    % ey1=ey1(1:T*rate);
    figure(2);plot(ey);hold on;
    std(ey)
    plot(a2,'r')

%% OSR %%%%%%%
elseif stimu == 'os'
    rep = 20; %20 trials
    rest = 5; %5s inter-trial
    trial = 20; %20s trial
    w = 0.05; %pulse width =50ms
    p = 0.20; %period 
    allX(1:2:2*6000)= w;
    allX(2:2:2*6000)= p-w;%X; for OSR!
    ey1=[];
    for i=1:rep*2 %length(allX) for OSR!
        if mod(i,2)==0
           ey1=[ey1 zeros(1,round(allX(i)*rate))];
        else
           ey1=[ey1 ones(1,round(allX(i)*rate))];
        end
    end
    ey = [];
    for i = 1:trial
        ey = [ey ey1 zeros(1,round(rest*rate))];
    end
   
    a2 = ey;
    ey = 0.15*ey;
    figure; plot(ey);
    length(ey)/20000
    ss = ['_OSR_',num2str(p*1000),'_'];
%% OSR sudden change frequency recording different changing frequencies
elseif stimu == 'oc'
    rep = 20; %20 trials
    rest = 5; %5s inter-trial
    trial = 20; %20s trial
    pw = 0.05; %pulse width =50ms
    p0 = 0.20; %period 
    dp = 0.01; %value of pulse frequency changed every time
    A = [ones(1,round(pw*rate)) zeros(1,round((p0-pw)*rate))]; %one pulse for original frequency
    for k=1:trial
        B{k} = [ones(1,round(pw*rate)) zeros(1,round(((p0-pw)+dp*(k-1))*rate))]; %one pulse for increased frequency
    end
    
    ey1=[];  
  
    for k=1:trial
        ey1=[];
        for j=1:5
            for i=1:rep
                ey1=[ey1 A];
            end
            for i=1:rep
                ey1=[ey1 B{k}];
            end
            ey1=[ey1 ones(1,rest*rate)];
        end
        singleperiod{k}=ey1 ;
    end
    ey=[];
    for i=1:trial
    ey=[ey singleperiod{i}];
    end
   
    a2 = ey;
    ey = 0.15*ey;
    figure; plot(ey);
    length(ey)/20000
    ss = ['_OSR_SuddenChangeFrequency_',[num2str(p0*1000),'to',num2str((p0+dp*(trial-1))*1000)],'_'];
%% OSR sudden change frequency for only one second frequency
elseif stimu == 'ol'
    rep = 20; %20 pulses
    rest = 5; %5s inter-trial
    trial = 15; %20s trial
    pw = 0.05; %pulse width =50ms
    p0 = 0.20; %period 
    dp = 0.10; %value of pulse frequency changed every time
    tic
    A = [ones(1,round(pw*rate)) zeros(1,round((p0-pw)*rate))]; %one pulse for original frequency
    B = [ones(1,round(pw*rate)) zeros(1,round(((p0-pw)+dp)*rate))]; %one pulse for increased frequency
    ey1=[];
    
    for i=1:rep
        ey1=[ey1 A];
    end
    for i=1:rep
        ey1=[ey1 B];
    end
    ey1=[ey1 zeros(1,rest*rate)];
    ey=[];
    for i=1:trial
        ey=[ey ey1];
    end
    toc
    
    a2 = ey;
    ey = 0.15*ey;
    figure; plot(ey);
    length(ey)/20000
    ss = ['_OSR_SuddenChangeFrequency_',[num2str(p0*1000),'to',num2str((p0+dp)*1000)],'_'];
%% Continuous decreasing pulse period
elseif stimu == 'jk'
    fl=1;
    fh=30;
    ph=1/fl;
    pl=1/fh;
    duty=1/4;  % might be changeable
    num_pulse=3000;
    dp=(ph-pl)/num_pulse;
    rest=180;
    repeat=3;
    p=ph;
    t=[];
    ey1=[];
    ey=[];
    for i=1:num_pulse
        p=p-dp;
    	ey1=[ey1 ones(1,round(p*duty*rate)) zeros(1,round(p*(1-duty)*rate))];
    end
    for j=1:repeat
        ey=[ey ey1 zeros(1,round(rest*rate))];
    end
    ey = 0.15*ey;
    a2 = ey;
    t=1/rate:1/rate:length(ey)/rate;
    plot(t,ey)
    ss=['_DecrecingPeriodPulse_',num2str(fl),'hz_to',num2str(fh),'hz_'];
   
    
    %% HMM Step MI
elseif stimu == 'sh'
    load('G:\Rona\noise\normalnoise.mat');
    rate = 1000;
    Tot = 150;  
    dt = 50*10^-3; 
    dtau=50*10^-3; %step width 
    T = dtau:dtau:Tot;
    T = dt:dt:Tot;
    G = 10; % damping  
    w = G/(2*1.06);%w = G/(2w)=1.06;  
    D = 4; %dynamical range
    at = 10;
    r = 0.1;
    m = 0.05;

    a2=[];ey=[];ey1=[];
    L = zeros(1,length(T));
    V = zeros(1,length(T));
    for t = 1:length(T)-1
        L(t+1) = L(t) + V(t)*dt;  %(th*(mu - X(t)))*dt + sqrt(dt)*randn; th = .01;  mu = 3;
            V(t+1) = (1-G*dt)*V(t) - w^2*L(t)*dt + sqrt(dt*D)*randn;
        V(t+1) = (1-G*dt)*V(t) - w^2*L(t)*dt + sqrt(dt*D)*noise(t);
    end      
    L = r*L;
    X = L-mean(L)+m; % X is the final stimuX
    X = abs(X);

    m=0;
    at=10;
    bt=0.05;
    rt=0;
    c=X;
    ey0=m*ones(1,at*rate);
    ey3 = m*ones(1,rt*rate);
    ey1=[];ey=[];
    for j=1:length(c)
        ey2 = c(j)*ones(1,bt*rate);
        ey1 = [ey1 ey2 ey3];
    end
    ey=[ey0 ey1];
    a2=ey-m;
    figure;plot(ey);
    hold on;plot(a2)

%% Step MI
% rate=20000;
% repeat=8*25;
% m=0.01;
% at=30;
% bt=0.5;
% rt=2.5;
% a=[0.005 0.01 0.015 0.02 0.025 0.03 0.035 0.04];
% c=[];
% for i=1:8:repeat
%     b=randperm(8);
%     c(i:i+7)=a(b)+m;
% end
% ey0=m*ones(1,at*rate);
% ey3 = m*ones(1,rt*rate);
% ey1=[];ey=[];
% for j=1:length(c)
%     ey2 = c(j)*ones(1,bt*rate);
%     ey1 = [ey1 ey2 ey3];
% end
% ey=[ey0 ey1];
% a2=ey-m;
% figure;plot(ey);
% hold on;plot(a2)

%% Time:HMM
elseif stimu == 'jt'
    rate = 1000;
    T = 300;  dt = 0.050;  T = 0:dt:T;
    X = zeros(1,length(T));
    V = zeros(1,length(T));
    G = 30; % damping  
    w = G/2.12;  
    D = 4; %dynamical range 
    for t = 1:length(T)
        X(t+1) = X(t) + V(t)*dt;  %(th*(mu - X(t)))*dt + sqrt(dt)*randn;th = .01;  mu = 3;
        V(t+1) = (1-G*dt)*V(t) - w^2*X(t)*dt + sqrt(dt*D)*randn;
    end   
    %         X = X(randperm(length(X)));
    X = 1*(X-mean(X)); %let mean(X)=150ms
    isi = 0.02*X/std(X)+0.15;
    % X(find(X<0)) = 0.15;
    allX(1:2:2*length(X))= 0.05;
    % allX(1:2:2*length(X))= 0.2-X;
    allX(2:2:2*length(X))= isi;
%     figure;plot(T,isi);
    std(isi)
    ey=[];
    for i=1:length(allX)
        if mod(i,2)==1
           ey=[ey 0.15*ones(1,round(allX(i)*rate))];
        else
           ey=[ey zeros(1,round(allX(i)*rate))];
        end
    end
    a2=ey(1:600*rate);
    ey=ey(1:600*rate);
%     figure;plot(ey); 
    ss = ['_tHMM_G=',num2str(G),'_'];
%% Sine   
elseif stimu == 'si'
    repeat =21;
    rt=5; % rest time
    at=30;
    T = 1; % period of sine 
    ns = 1; % # of  sine waves of a loop
    m = 0.01;% onoff 0-0.18  %<0.03
    d = 0.008;% increment of lumin
    period = rt+ns*T; % period of a loop
    x1 = 1:period*rate*repeat;
    ey=[];ey1 = [];ey2 = [];
    ey0=m*ones(1,at*rate);
    a2r=zeros(1,(at+rt)*rate);
    a2s = [];a2s1=[];a2s2=[];
    for i = 1:repeat 
        eys = d*(-1)*sin(2*pi*x1(1:round(ns*T*rate))/T/rate)+m; %sine
        eyr = m*ones(1,rt*rate); %rest
        ey1=[ey1 eyr eys];

        a2s1 = ones(1,T/2*rate);
        a2s2 = -ones(1,(T/2+rt)*rate);
        a2s = [a2s a2s1 a2s2];
    end
    ey=[ey0 ey1];
    a2=[a2r a2s];
    x1=1:length(ey);
%     figure;plot(ey);hold on;plot(a2)
    ss = ['_sine_',num2str(T),'s_',num2str(m),'_',num2str(d),'_'];
 %% Step    
elseif stimu == 'st'
    repeat = 20;
    rt = 5; % rest time
    deltaT = 0; 
    bt = 0.5; % bright time
    m = 0.01;
    d = 0.014;% increment of lumin
    ey = [];
    a2 = [];
    at = 30;%adaptation time
    ey0=m*ones(1,at*rate);%REST
    ey1=linspace(m,m+d,deltaT*rate);
    ey2=(m+d)*ones(1,bt*rate);
    ey3=m*ones(1,rt*rate);
    eys=[ey1 ey2 ey3];
    ey=[ey0 eys];

%     a20=zeros(1,at*rate);
%     a21=ones(1,deltaT*rate);
%     a22=zeros(1,(bt+rt)*rate);
%     a2s=[a21 a22];
%     a2=[a20 a2s];
    for i = 1:repeat-1
%         a2=[a2 a2s];
        ey=[ey eys];
    end
    a2=[];
    a2=10*ey;
    x1=1/rate:1/rate:length(ey)/rate;
    figure(1);hold on;plot(x1,ey);
    ss = ['_stepdiffmd_m=',num2str(m),'_d=',num2str(d),'_'];

elseif stimu == 'sp'
    repeat =20;
    rt=5; % rest time
    T = 1.8; % period of sine 
    ns = 1; % # of waves of a loop
    m = 0.010;% onoff 0-0.18  %<0.03
    d = 0.005;% increment of lumin
    period = rt+ns*T; % period of a loop
    x1 = 1:period*rate*repeat;
    ey = [];
    a2 = [];
    at = 0;%adaptation time
    ey(1:at*rate)=m;
    for i = 1:repeat 
        ey(at*rate+period*rate*(i-1)+1:at*rate+period*rate*(i-1)+rt*rate)=m;
        ey(at*rate+round(period*rate*(i-1)+rt*rate)+1:at*rate+round((period*(i-1)+rt+T/2)*rate))=m+d;
        ey(at*rate+round((period*(i-1)+rt+T/2)*rate)+1:at*rate+period*rate*i)=m-d;
        a2(at*rate+period*rate*(i-1)+1:at*rate+period*rate*(i-1)+rt*rate)=-0.1;
        a2(at*rate+round(period*rate*(i-1)+rt*rate+1):at*rate+round(i*period*rate))=1;         
    end
     x1=1:length(ey);
     figure;plot(x1,ey,x1,a2,'r')

%% Load mat file
elseif stimu == 'ld'
    filename='HMM_G=2.5_output';
    load(['D:\Chou\Chou\output data 20190124\',filename,'.mat']);
    figure(3);plot(t,ey);hold on 
    span=20; %change the smoothing span
    ss=[filename,'_'];
end
%% Noise %%%%%%%%%%%%%%%%%%%
         %%% White Noise %%%
%         load('G:\Rona\noise\whitenoise.mat');
        nl=0; % noise level
%         nf=1; % noise freq.=rate/nf
%         n=repmat(noise,nf,1);
%         n=n(1:end);                                
% % 
% eyf=[];
% eyf(1:at*rate)=ey0;
% eyf(at*rate+1:length(ey))=ey1 + nl*n(1:length(ey1));
% figure;plot(eyf);hold on;plot(a2,'r');plot(eyf,'g');
eyf=ey;


ex = interp1(y,x,eyf,'spline');% ex=calibrate voltage
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
callumin=daq_in.data;
[b,a]=butter(2,10/rate,'low');
callumin_filter=filter(b,a,daq_in.data) ;
daq_in.wait;

close all;
daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_out.write(0);

figure(5) ; plot(ex);title(['calibrated voltage v.s. time']);
figure(6) ; plot(callumin);title(['lumin v.s. time']);hold on;plot(ey,'r');plot(eyf,'g');
% figure(7) ; plot(callumin_filter);title(['lumin v.s. time']);hold on;plot(ey,'r');plot(eyf,'g');

ddd=date;
diode_path=['D:\Chou\stimulus saving\',ddd];
mkdir(diode_path)
save(['D:\Chou\stimulus saving\',ddd,'\diode_',ss,date,'.mat'],'callumin','callumin_filter','a2','ex','ey','eyf');
