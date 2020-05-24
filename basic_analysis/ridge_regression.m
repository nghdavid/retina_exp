close all;
clear all;
exp_folder = 'E:\20200418';
cd(exp_folder);
load(['predictive_channel\bright_bar.mat'])
cd ([exp_folder,'\sort_merge_spike\MI'])
all_file = subdir('*.mat');% change the type of the files which you want to select, subdir or dir.
n_file = length(all_file);
roi = [p_channel,np_channel];
roi = 17;
for z =1:n_file %choose file
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    load([directory,filename]);
    name=[name];
    z
    name
    BinningTime =diode_BT;
    BinningSpike = zeros(60,length(BinningTime));
    analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,1);
    for i = 1:60  % i is the channel number
        [n,~] = hist(analyze_spikes{i},BinningTime) ;  %yk_spikes is the spike train made from"Merge_rePos_spikes"
        BinningSpike(i,:) = n ;
    end
    %% == 2. Upsample to get finer timescale representation of stim and spikes === 
    bin_pos = rescale(bin_pos,-1,1);
    nT = length(bin_pos);
    upsampfactor = 1; % divide each time bin by this factor
    dtStimhi = BinningInterval/upsampfactor; % use bins 100 time bins finer
    ttgridhi = (dtStimhi/2:dtStimhi:nT*BinningInterval)'; % fine time grid for upsampled stim
    stimtrain = interp1((1:nT)*BinningInterval,bin_pos',ttgridhi,'nearest','extrap');
    nThi = nT*upsampfactor;  % length of upsampled stimulus
    sps = hist(analyze_spikes{roi},ttgridhi)';
    %% === 4. Fit the linear-Gaussian model using ML ====================
    ntrain = length(sps);
    spstrain = sps;
    ntfilt = 10*upsampfactor; 
    dtStimhi = BinningInterval/upsampfactor;
    ttk = (-ntfilt+1:0)*dtStimhi;
    Xtrain = [ones(ntrain,1),....
    hankel([zeros(ntfilt-1,1);stimtrain(1:end-ntfilt+1)],...
    stimtrain(end-ntfilt+1:end))];
    filtML = (Xtrain'*Xtrain)\(Xtrain'*spstrain);
    paddedStim = [zeros(ntfilt-1,1); stimtrain]; % pad early bins of stimulus with zero
    Xdsgn = hankel(paddedStim(1:end-ntfilt+1), stimtrain(end-ntfilt+1:end));
    sta = (Xdsgn'*spstrain)/ntrain;
    % Plot it
    ttk = (-ntfilt+1:0)*BinningInterval; % time bins for STA (in seconds)
%     plot(ttk, sta); axis tight;
%     title('STA'); xlabel('time before spike (s)');
%     
    figure
    plot(ttk,filtML(2:end));hold on;
    xlabel('time before spike');
    
    
    %% === 5. Ridge regression: linear-Gaussian model ======================
    % Set up grid of lambda values (ridge parameters)
    lamvals = 2.^(0:15); % it's common to use a log-spaced set of values
    nlam = length(lamvals);

    % Build design matrix for test data
%     Xtest = [ones(ntest,1), hankel([zeros(ntfilt-1,1); stimtest(1:end-ntfilt+1)], ...
%         stimtest(end-ntfilt+1:end))];

    % Precompute some quantities (X'X and X'*y) for training and test data
    XXtr = Xtrain'*Xtrain;
    XYtr = Xtrain'*spstrain;  % spike-triggered average, training data
    Imat = eye(ntfilt+1); % identity matrix of size of filter + const
    Imat(1,1) = 0; % don't apply penalty to constant coeff

    % Allocate space for train and test errors
    msetrain = zeros(nlam,1);  % training error
%     msetest = zeros(nlam,1);   % test error
    w_ridge = zeros(ntfilt+1,nlam); % filters for each lambda

    % Now compute MAP estimate for each ridge parameter
%     clf; plot(ttk,ttk*0,'k-'); hold on;
    for jj = 1:nlam

        % Compute ridge regression estimate
        w = (XXtr+lamvals(jj)*Imat) \ XYtr; 

        % Compute MSE
        msetrain(jj) = (mean((spstrain-Xtrain*w).^2)); % training error
%         msetest(jj) = (mean((spstest-Xtest*w).^2)); % test error
        % store the filter
        w_ridge(:,jj) = w;
        % plot it
        plot(ttk,w(2:end));
        title(['ridge estimate: lambda = ', num2str(lamvals(jj))]);
        xlabel('time before spike (s)'); drawnow; pause(.2);
    end
    hold off;
end