function Xarray = Smooth_OU_generator(T,dt,Gvalue,rntest)
    %Gvalue is damping / only G will influence correlation time
    D = 2700000;%dynamical range
    Xarray = zeros(1,length(T));
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    for uu = 1:length(T)-1
          Xarray(uu+1) = (1-dt*Gvalue/(2.12)^2)*Xarray(uu)+sqrt(dt*D)*rntest(uu);
    end
    fs=60;		% Sampling rate
    filterOrder=6;		% Order of filter
    cutOffFreq=10;	% Cutoff frequency
    [b, a]=butter(filterOrder, cutOffFreq/(fs/2), 'low');
    Xarray=filter(b, a, Xarray);
%     Xarray = smooth(Xarray,0.01);
end