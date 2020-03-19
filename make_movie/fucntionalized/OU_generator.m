function Xarray = OU_generator(T,dt,Gvalue,rntest)
    T=dt:dt:T;
    %Gvalue is damping / only G will influence correlation time
    D = 2700000;%dynamical range
    Xarray = zeros(1,length(T));
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    for uu = 1:length(T)-1
          Xarray(uu+1) = (1-dt*Gvalue/(2.12)^2)*Xarray(uu)+sqrt(dt*D)*rntest(uu);
    end
    
end