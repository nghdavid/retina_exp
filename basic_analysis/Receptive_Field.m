close all;
clear all;
code_folder = pwd;
load('channel_pos.mat')
load('boundary_set.mat')

displaychannel = 1:60;%Choose which channel to display
save_photo = 1;%0 is no save RF photo, 1 is save
save_svd = 1;%0 is no save svd photo, 1 is save

time_shift = 1:6;%for -50ms:-300ms
num_shift = 0.05;%50ms
exp_folder = 'E:\0709';
cd(exp_folder)
name = '20Hz_13x13_RF';%Directory name

%% For unsorted spikes
load('merge\merge_0507_Checkerboard_20Hz_13_5min_Br50_Q100.mat')
analyze_spikes = reconstruct_spikes;
sorted = 0;
%% For sorted spikes
% load('sort_merge_spike\sort_merge_0507_Checkerboard_20Hz_13_5min_Br50_Q100_re.mat')
% analyze_spikes = sorted_spikes;
% sorted = 1;

%% Create directory
mkdir FIG
cd FIG
mkdir RF
cd RF
mkdir(name)
cd (name)
mkdir sort
mkdir unsort

%% Delete useless channel
checkerboard = bin_pos;%Stimulus we use
null_channel = [];
stimulus_length = TimeStamps(2)-TimeStamps(1);

for j = 1:length(displaychannel)
    num_spike =  length(analyze_spikes{displaychannel (j)});
    if num_spike /stimulus_length <0.3%Cells with a low firing rate for checkerbox(<0.3HZ) were not considered
        null_channel = [null_channel j];
    end
end
disp(['useless channels are ',num2str(null_channel)])

displaychannel (null_channel) = [];


%% calculate RF
RF = cell(length(time_shift), 60);
gauss_RF = cell(length(time_shift), 60);
for k =displaychannel 
    analyze_spikes{k}(analyze_spikes{k}<1) = []; %remove all feild on effect
    for i =  time_shift  %for -50ms:-300ms
        sum_checkerboard = zeros(length(bin_pos{1}));
        for j = 1:length(analyze_spikes{k})
            spike_time = analyze_spikes{k}(j); %s
            RF_frame = floor((spike_time - i*num_shift)*60);
            if RF_frame > 0
                sum_checkerboard = sum_checkerboard + checkerboard{RF_frame};
            end
        end
        RF{i,k} = sum_checkerboard/length(analyze_spikes{k});
        gauss_RF{i,k} = imgaussfilt(RF{i,k},1.5);
    end
end
side_length = length(sum_checkerboard);%length of checkerboard

%% calculate SVD and plot SVD
electrode_x = zeros(1,60);%x positions of electrode
electrode_y = zeros(1,60);%y positions of electrode
closest_extrema = zeros(2,60);%closest positions of RF center to position of electrode

for k =displaychannel 
    %calculate SVD
    reshape_RF = zeros(side_length^2,length(time_shift));
    for i =  time_shift %for -50ms:-300ms
        reshape_RF(:,i) = reshape(gauss_RF{i,k},[side_length^2,1]);
    end
    [U,S,V] = svd(reshape_RF');%U is temporal filter, V is one dimensional spatial filter, S are singular values
    space = reshape(V(:,1),[side_length,side_length]);%Reshape one dimensional spatial filter to two dimensional spatial filter
    
    %Calculate first component percentage
    power_component = diag(S)/sum(S(:))*100;%Each component percentage
    power_first_component = power_component(1);
    disp(['channel',int2str(k),' first_component power is ',num2str(power_first_component),'%'])
    
    %Calculate and plot temporal SVD
    figure(k+120)
    plot(fliplr(time_shift*num_shift*-1000),fliplr(U(1,:)))
    title(['temporal filter from SVD channel ',int2str(k)])
    xlabel('time before spike(ms)')
    ylabel('relative intensity')
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
     if save_svd 
        if sorted
            saveas(fig,[exp_folder, '\FIG\RF\', name,'\sort','\temporal_svd_channel', num2str(k)  '.tiff'])
        else
            saveas(fig,[exp_folder, '\FIG\RF\', name,'\unsort','\temporal_svd_channel', num2str(k)  '.tiff'])
        end
     end
    
    %Calculate electrode position and RF center from SVD
    
    gauss_space = imgaussfilt(space,1.5);
    electrode_x(k) = (channel_pos(k,1)-meaCenter_x)*side_length/mea_size_bm + (side_length+1)/2;
    electrode_y(k) = (channel_pos(k,2)-meaCenter_y)*side_length/mea_size_bm + (side_length+1)/2;
    num_spike =  length(analyze_spikes{k});
    if num_spike /stimulus_length > 1
        [xymax,smax,xymin,smin] = extrema2(gauss_space);
        x = ceil(smax/side_length);
        y = mod(smax-1, side_length)+1;
        extreme_x = x';
        extreme_y = y';
        x = ceil(smin/side_length);
        y = mod(smin-1, side_length)+1;
        extreme_x = [extreme_x x'];
        extreme_y = [extreme_y y'];
        closest_dis = side_length^2*2;
        for j = 1:length(extreme_x)
            dis = (electrode_x(k)-extreme_x(j))^2 + (electrode_y(k)-extreme_y(j))^2;
            if dis <=  closest_dis
                closest_dis = dis;
                closest_extrema(:,k) = [extreme_x(j) extreme_y(j)];
            end
        end
    end
    
    
    %Plot spatial SVD
    figure(k+60)
    imagesc(gauss_space);hold on;
    title(k)
    pbaspect([1 1 1])
    colormap(gray);
    colorbar;
    scatter(electrode_x(k),electrode_y(k), 50, 'r','filled');
    if num_spike /stimulus_length > 1
         scatter(closest_extrema(1,k),closest_extrema(2,k), 100, 'b' ,'o','filled')
    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    if save_svd 
        if sorted
            saveas(fig,[exp_folder, '\FIG\RF\', name,'\sort','\spatial_svd_channel', num2str(k)  '.tiff'])
        else
            saveas(fig,[exp_folder, '\FIG\RF\', name,'\unsort','\spatial_svd_channel', num2str(k)  '.tiff'])
        end
    end
    
    
end


%% plot RF & electrode position & RF center
RF_center = cell(60 , length(time_shift));
for k =displaychannel
    %plot RF & electrode position & RF center
    figure(k);
    num_spike =  length(analyze_spikes{k});
    for i = time_shift
        subplot(2,3,i),imagesc(gauss_RF{i,k});hold on;
        pbaspect([1 1 1])
        title([num2str(-i*50),'ms']);
        colormap(gray);
        colorbar;
        scatter(electrode_x(k),electrode_y(k), 10, 'r','filled');
        
        if num_spike /stimulus_length > 1
         scatter(closest_extrema(1,k),closest_extrema(2,k), 50, 'b' ,'o','filled')
        end
        
    end
    
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    if save_photo
        if sorted
            saveas(fig,[exp_folder, '\FIG\RF\', name,'\sort','\channel', num2str(k)  '.tiff'])
        else
            saveas(fig,[exp_folder, '\FIG\RF\', name,'\unsort','\channel', num2str(k)  '.tiff'])
        end
    end
    
    %Calculate and plot temporal filter
    if num_spike /stimulus_length > 1
        figure(k+180)
        temporal_filter = zeros(1,length(time_shift));
        for i = time_shift
            temporal_filter(i) = gauss_RF{i,k}(closest_extrema(1,k),closest_extrema(2,k));
        end
        plot(fliplr(time_shift*num_shift*-1000),fliplr(temporal_filter))
        title(['temporal filter of RF channel ',int2str(k)])
        xlabel('time before spike(ms)')
        ylabel('relative intensity')
        set(gcf,'units','normalized','outerposition',[0 0 1 1])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        if save_svd 
            if sorted
                saveas(fig,[exp_folder, '\FIG\RF\', name,'\sort','\temporal_filter_channel', num2str(k)  '.tiff'])
            else
                saveas(fig,[exp_folder, '\FIG\RF\', name,'\unsort','\temporal_filter_channel', num2str(k)  '.tiff'])
            end
        end
    end
    
end
%titles and checkerboard size
RF_pixel_size = mea_size_bm/side_length*micro_per_pixel %mircometer


cd(code_folder)