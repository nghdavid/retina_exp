function Xarray = HMM_generator(T,dt,Gvalue,rntest)
    T=dt:dt:T;
    %Gvalue is damping / only G will influence correlation time
    D = 2700000;%dynamical range
    omega =Gvalue/2.12; %omega = G/(2w)=1.06; follow Bielak's overdamped dynamics/ 2015PNAS
    Xarray = zeros(1,length(T));
    Xarray(1,1)=0; % since the mean value of damped eq is zero
    Vx = zeros(1,length(T));
    %Use rntest(t)!!!
    for t = 1:length(T)-1
        Xarray(t+1) = Xarray(t) + Vx(t)*dt;
        Vx(t+1) = (1-Gvalue*dt)*Vx(t) - omega^2*Xarray(t)*dt + sqrt(dt*D)*rntest(t);
    end
end