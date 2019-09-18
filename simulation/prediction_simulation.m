%% Setup bar position and HMM trajectory

bar_size = 7;
G_HMM = 9;
T = 1000;
dt=1/60;
D_HMM = 2700000; %dynamical range
omega =G_HMM/2.12;   % omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
stimulus_range = 200;
Xarray = zeros(1,T);
Xarray(1,1)=0; % since the mean value of damped eq is zero
Vx = zeros(1,T);
%Use rntest(t)!!!
for t = 1:T-1
    Xarray(t+1) = Xarray(t) + Vx(t)*dt;
    Vx(t+1) = (1-G_HMM*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D_HMM)*randn;
end

nrx= (stimulus_range-bar_size*2)/(max(Xarray)-min(Xarray));
Xarray2=Xarray*nrx;
Xarray3=Xarray2+bar_size+1-min(Xarray2);%rearrange the boundary values
newXarray=round(Xarray3);


bar_position = zeros(T,stimulus_range);

for step = 1:T
   bar_position(step,newXarray(step)-bar_size:newXarray(step)+bar_size) = ones(1,2*bar_size+1); 
end

%% Receptive field center surround filter

sigma = 10;
range = 1:stimulus_range;
On_center = gaussmf(range,[sigma stimulus_range/2]);
Off_center = -0.3*gaussmf(range,[sigma*3 stimulus_range/2]);
% figure(1)
% plot(range,On_center);hold on
% plot(range,Off_center);hold off
% figure(2)
% plot(range,On_center+Off_center);

%% On and Off temporal filter
integration_time = 50;
size_curve = 10;
On_temporal = zeros(1,integration_time);
Off_temporal = zeros(1,integration_time);
x = linspace(-1.0, 1.0, size_curve);
curve = -x.*x+1;
On_temporal(5:5+size_curve-1) = On_temporal(5:5+size_curve-1)+curve;
Off_temporal(10:10+size_curve-1) = Off_temporal(5:5+size_curve-1)+curve;
figure(3)
plot(1:integration_time,On_temporal);hold on
plot(1:integration_time,Off_temporal);hold off
xlabel('time before spike')
ylabel('weight')
%% 