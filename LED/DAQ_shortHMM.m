function DAQ_shortHMM(stimu, G_tau, mean_lumin,seed_num,num_repeat,Tot)
%Tot is Stimulation length(second)
%seed_num is random seed(1~11) %30 sec is 9, 60 sec is 10
ddd=date;
diode_path_cal=['D:\leo\stimulus saving\',ddd,'\calibration'];
load([diode_path_cal,'\calibration',ddd])
%clearvars -except rate volt lumin_filter stimu G_tau true_lumin mean_lumin
daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_out.write(0);

% load('E:\rona\20160318\map');
%%%%%%%%%%%%% step3:calibration %%%%%%%%%%%%%%%%%%%
x=volt;
y=(lumin_filter)';
z=(true_lumin)';
%% Signal %%%%%%%%%%%%%%%%%%

seed_date = '0421';
seed_directory_name = [seed_date,' new video Br50\rn_workspace'];
cd(['C:\',seed_directory_name]);%New seed for HMM movie
all_file = dir('*.mat');%Load random seed
file = all_file(seed_num).name ;%3,7,9,11 is good
[~, name, ext] = fileparts(file);
filename = [name,ext];
load([filename]);
disp(['Random number is ',name])
rate=20000;
dt = 50*10^-3;%Refresh rate
dtau = 50*10^-3; %step width
T = dtau:dtau:Tot;
G = G_tau; % damping
w = G/(2*1.06);%w = G/(2w)=1.06;
D = 4; %dynamical range
at = 10;%adaptation time
L = zeros(1,length(T));%HMM intensity
V = zeros(1,length(T));
%HMM process
for t = 1:length(T)
    L(t+1) = L(t) + V(t)*dt;  %(th*(mu - X(t)))*dt + sqrt(dt)*randn; th = .01;  mu = 3;
    V(t+1) = (1-G*dt)*V(t) - w^2*L(t)*dt + sqrt(dt*D)*rntest(t);
end
L = 0.3*mean_lumin*L/std(L);%Normalization
X = L-mean(L)+mean_lumin;% X is the final stimuX (Shift mean light level)
X(X > 1.95*mean_lumin) = 1.95*mean_lumin;
X(X < 0.05*mean_lumin) = 0.05*mean_lumin;
% std(X)/mean_lumin
temp = X(2:1:length(X));%Get rid of first index
temp2=repmat(temp,rate*dtau,1);%Change 20000Hz to 20Hz
ey1=temp2(:)';%ey1 is 20 Hz stimulus
ey0=mean_lumin*ones(1,at*rate);%Adaptation time
ey=[ey0 ey1];
a2=zeros(1,length(ey));%Analog 2
a2(at*rate:(at+1)*rate)=1;%Onset pulse
a2((Tot+at-1)*rate:(Tot+at)*rate)=1;%Stop pulse
t=[1/rate:1/rate:length(ey)/rate];
figure(1);plot(t,ey);hold on
plot(t,a2*10)
ss = ['_short_HMM_G=',num2str(G),'_'];

a2 = repmat(a2,[1 num_repeat]);
ey = repmat(ey,[1 num_repeat]);
t=[1/rate:1/rate:length(ey)/rate];
figure(2);plot(t,ey);hold on
plot(t,a2*10)
xlabel('time (second)')
ylabel('Intensity')
title('Repeat of HMM sequence')
disp('This is repeat of short HMM sequence')
disp(['Number of repeats is ',num2str(num_repeat),' times'])
disp(['Each repeat is ',num2str(Tot),' sec'])
disp(['Resting time is ',num2str(at),' sec'])

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
save(['D:\leo\',ddd,'\diode_',ss,num2str(mean_lumin),'_',date,'.mat'],'callumin','callumin_filter','a2','ex','ey','eyf','name','num_repeat','Tot','mean_lumin');

end