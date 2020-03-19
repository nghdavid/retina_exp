clear all;
close all;
%% All parameter
HMM = 1;
T = 20000;
dt=1/60;
bar_size = 5;
stimulus_range = 200;

G_HMM = 3;
G_OU = 2.45;

ratio_on = 4;
ratio_off = -2;
on_sigma = 10;
off_sigma = 40;

integration_time = 30;
size_curve = 10;

On_delay = 5;
Off_delay = 9;
%% Setup bar position and trajectory

if HMM
%% HMM trajectory

D_HMM = 2700000; %dynamical range
omega =G_HMM/2.12;   % omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
Xarray = zeros(1,T);
Xarray(1,1)=0; % since the mean value of damped eq is zero
Vx = zeros(1,T);
%Use rntest(t)!!!
for t = 1:T-1
    Xarray(t+1) = Xarray(t) + Vx(t)*dt;
    Vx(t+1) = (1-G_HMM*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D_HMM)*randn;
end
nrx= (stimulus_range-bar_size*2-1)/(max(Xarray)-min(Xarray));
Xarray2=Xarray*nrx;
Xarray3=Xarray2+bar_size+1-min(Xarray2);%rearrange the boundary values
newXarray=round(Xarray3);


else
%% OU trajectory

D_OU = 2700000; %dynamical range
omega =G_OU/2.12;   % omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
x = zeros(1,T);
x(1,1)=0; % since the mean value of damped eq is zero
for uu = 1:T-1
    x(uu+1) = (1-dt*G_OU/(2.12)^2)*x(uu)+sqrt(dt*D_OU)*randn;
end
% Normalize to proper moving range
nrx=(stimulus_range-bar_size*2-1)/(max(x)-min(x));
x2=x*nrx;
x3=x2+bar_size+1-min(x2);%rearrange the boundary values
newXarray=round(x3);


end

bar_position = zeros(T,stimulus_range);

for step = 1:T
   bar_position(step,newXarray(step)-bar_size:newXarray(step)+bar_size) = ones(1,2*bar_size+1); 
end

% figure(100)
% plot(1:T,newXarray-100);


%% Receptive field center surround filter


range = 1:stimulus_range;
On = ratio_on *gaussmf(range,[on_sigma stimulus_range/2]);
Off = ratio_off*gaussmf(range,[off_sigma stimulus_range/2]);
% figure(1)
% plot(range,On);hold on
% plot(range,Off);hold off
% figure(2)
% plot(range,On+Off);


%% On and Off temporal filter

On_temporal = zeros(1,integration_time);
Off_temporal = zeros(1,integration_time);
x = linspace(-1.0, 1.0, size_curve);
curve = -0.1*x.*x+1;
On_temporal(On_delay:On_delay+size_curve-1) = On_temporal(On_delay:On_delay+size_curve-1)+curve;
Off_temporal(Off_delay:Off_delay+size_curve-1) = Off_temporal(Off_delay:Off_delay+size_curve-1)+curve;
figure(3)
plot(1:integration_time,On_temporal);hold on
plot(1:integration_time,Off_temporal);hold off
xlabel('time before spike')
ylabel('weight')


%% Convolution of stimulus and receptive field
conv_on = zeros(1,T);
conv_off = zeros(1,T);
for t = 1:T
    conv_on(t) = sum(bar_position(t,:).*On);
    conv_off(t) = sum(bar_position(t,:).*Off);
end
% figure(4)
% plot(1:T,conv_on-min(conv_on));hold on
% plot(1:T,normalize(conv_off));hold on
% plot(1:T,normalize(newXarray-100),'k.');hold off
% xlabel('time')
% ylabel('Temporal change of center and surround')
% title('HMM trajectory and temporal change after Gaussian filter')
% legend('on','off','trajectory')
% 

%% Temporal filtering
temp_on =zeros(1,T-integration_time);
temp_off =zeros(1,T-integration_time);
for t = 1:T-integration_time
    temp_on(t) = sum(conv_on(t:t+integration_time-1).*fliplr(On_temporal));
    temp_off(t) = sum(conv_off(t:t+integration_time-1).*fliplr(Off_temporal));
end
% 
% 
% figure(5)
% plot(1:T-integration_time,normalize(temp_on));hold on
% plot(integration_time+1:T,normalize(conv_on(integration_time+1:T)))
% xlabel('time')
% ylabel('Temporal change of ON')
% title('On temporal change before and after temporal filter')
% legend('After filter','Before filter')
% set(gcf,'units','normalized','outerposition',[0 0 1 1])
% 
% figure(6)
% plot(1:T-integration_time,normalize(temp_off));hold on
% plot(integration_time+1:T,normalize(conv_off(integration_time+1:T)))
% title('OFF temporal change before and after temporal filter')
% ylabel('Temporal change of Off')
% xlabel('time')
% legend('After filter','Before filter')
% set(gcf,'units','normalized','outerposition',[0 0 1 1])
% 

%% Subtraction of ON and OFF

Subtraction = temp_on + temp_off;


% figure(7)
% plot(1:T-integration_time,normalize(Subtraction));hold on;
% plot(integration_time+1:T,normalize(newXarray(integration_time+1:T)),'k.');hold off
% xlabel('time')
% ylabel('Subtraction of ON and OFF')
% title('Effect of subtraction')
% legend('Subtract','trajectory')
% set(gcf,'units','normalized','outerposition',[0 0 1 1])

figure(8)
plot(integration_time+1:T,temp_on);hold on;
plot(integration_time+1:T,temp_off);hold on;
plot(1:T-integration_time,Subtraction);hold off;
xlabel('time')
ylabel('Volt')
title('Comparison of ON and OFF')
legend('on','off','subtraction')
set(gcf,'units','normalized','outerposition',[0 0 1 1])


% Calculation of MI
% TheStimuli = temp_on;%newXarray(integration_time+1:T);
% StimuSN=30; %number of stimulus states
% nX=sort(TheStimuli);
% abin=length(nX)/StimuSN;
% intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
% temp=0; isi2=[];
% for jj=1:length(TheStimuli)
%     temp=temp+1;
%     isi2(temp) = find(TheStimuli(jj)<=intervals,1);
% end
% TheStimuli = Subtraction;
% backward = 100;
% forward = 100;
% BinningInterval =1;
% nX=sort(temp_on);
% abin=length(nX)/StimuSN;
% intervals=[nX(1:abin:end) inf]; % inf: the last term: for all rested values
% temp=0; Neurons=[];
% for jj=1:length(TheStimuli)
%     temp=temp+1;
%     Neurons(temp) = find(TheStimuli(jj)<=intervals,1);
% end
% 
% dat=[];informationp=[];temp=backward+2;
% for i=1:backward+1 %past(t<0)
%     x = Neurons((i-1)+forward+1:length(Neurons)-backward+(i-1))';
%     y = isi2(forward+1:length(isi2)-backward)';
%     dat{i}=[x,y];
%     norm=BinningInterval;
% 
%     [N,C]=hist3(dat{i},[max(Neurons)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
%     px=sum(N,1)/sum(sum(N)); 
%     py=sum(N,2)/sum(sum(N)); 
%     pxy=N/sum(sum(N));
%     temp2=[];
%     for j=1:length(px)
%         for k=1:length(py)
%           temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
%         end
%     end
%     temp=temp-1;
%     informationp(temp)=nansum(temp2(:));
% 
% end  
% 
% dat=[];informationf=[];temp=0;sdat=[];
% for i=1:forward
%     x =Neurons(forward+1-i:length(Neurons)-backward-i)';
%     y = isi2(forward+1:length(isi2)-backward)';
%     dat{i}=[x,y];
%     norm=BinningInterval;
% 
%     [N,C]=hist3(dat{i},[max(Neurons)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
%     px=sum(N,1)/sum(sum(N)); 
%     py=sum(N,2)/sum(sum(N)); 
%     pxy=N/sum(sum(N));
%     temp2=[];
%     for j=1:length(px)
%         for k=1:length(py)
%             temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
%         end
%     end
%     temp=temp+1;
%     informationf(temp)=nansum(temp2(:));
% 
% end
% figure(9)
% information=[informationp informationf];
% time=[-backward:forward];
% plot(time,information);
% xlabel('time shift')
% ylabel('MI(bits)')
