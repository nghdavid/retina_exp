function Smooth_Xarray = Smooth_OU_generator(T,dt,Gvalue,rntest,cutOffFreq)
    close all;
    buff_time = 1;%Buffer for delay correction
    T=T+buff_time;
    T=dt:dt:T;
    %Gvalue is damping / only G will influence correlation time
    D = 2700000;%dynamical range
    Xarray = zeros(1,length(T));
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    for uu = 1:length(T)-1
          Xarray(uu+1) = (1-dt*Gvalue/(2.12)^2)*Xarray(uu)+sqrt(dt*D)*rntest(uu);
    end
    fs=60;% Sampling rate
    filterOrder=4;%Order of filter
    [b, a]=butter(filterOrder, cutOffFreq/(fs/2), 'low');% Butterworth filter
    %% Frequency response
%     figure;
%     [h, w]=freqz(b, a);
%     plot(w/pi*fs/2, abs(h), '.-'); title('Magnitude frequency response');
%     grid on
    %% Filter and make delay correction
    Smooth_Xarray = filter(b, a, Xarray);
    x = xcorr(Xarray, Smooth_Xarray);
    [~,I]=max(x);
    delay_correction = length(Xarray)-I;
    disp(['Before correction, the delay is ',num2str(delay_correction*dt),' sec'])
    Xarray = Xarray(1:end-buff_time/dt);
    Smooth_Xarray = Smooth_Xarray(delay_correction+1:end-buff_time/dt+delay_correction);
    %% Plot Original array and Smooth array
    figure(2)
    plot(T(1:end-buff_time/dt),Xarray,'b');hold on
    plot(T(1:end-buff_time/dt),Smooth_Xarray,'r')
    xlim([0 30])
    %% Check correction
    x = xcorr(Xarray, Smooth_Xarray);
    [~,I]=max(x);
    after_correction = length(Xarray)-I;
    disp(['After correction, the delay is  ',num2str(after_correction*dt) ,' sec'])
    %% Correction time
    acf = autocorr(Xarray,100);
    corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))*dt;
    disp(['Original correlation time is ',num2str(corr_time),' second'])
    
    acf = autocorr(Smooth_Xarray,100);
    corr_time = find(abs(acf-0.5) ==min(abs(acf-0.5)))*dt;
    disp(['Smooth correlation time is ',num2str(corr_time),' second'])
end