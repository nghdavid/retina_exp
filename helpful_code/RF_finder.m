function RF = RF_finder(space)
MdataSize = length(space); % Size of nxn data matrix
x0 = [max(space, [], 'All'),MdataSize/2,MdataSize/4,MdataSize/2,MdataSize/4,0]; %Inital guess parameters
InterpolationMethod = 'nearest'; % 'nearest','linear','spline','cubic'
%%
[X,Y] = meshgrid(1:MdataSize);
xdata = zeros(size(X,1),size(Y,2),2);
xdata(:,:,1) = X;
xdata(:,:,2) = Y;
Z = space;
%% --- Fit---------------------
    % define lower and upper bounds [Amp,xo,wx,yo,wy,fi]
    lb = [0,1,0,1,0,-pi/4];
    ub = [realmax('double'),MdataSize,(MdataSize),MdataSize,(MdataSize),pi/4];
    [RF,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunctionRot,x0,xdata,Z,lb,ub);
end