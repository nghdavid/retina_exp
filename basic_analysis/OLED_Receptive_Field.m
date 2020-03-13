close all;
clear all;
code_folder = pwd;
load('oled_channel_pos.mat')
load('oled_boundary_set.mat')

displaychannel = 1:60;%Choose which channel to display
save_photo =1;%0 is no save RF photo, 1 is save
save_svd =1;%0 is no save svd photo, 1 is save


exp_folder = 'D:\Leo\0229';
cd(exp_folder)
try
    load('Analyzed_data\unsort\0224_cSTA_wf_3min_Q100.mat')
catch
    Filker_OnOff_Index = zeros(1,60);
    mkdir Analyzed_data
    mkdir Analyzed_data sort
    mkdir Analyzed_data unsort
end

name = '30Hz_27_RF';%Directory name
time_shift = 1:9;%for -50ms:-300ms
N = length(time_shift);
if  mod(sqrt(N),1) == 0 %if N is a perfact square
    N_middle_factor = [sqrt(N) sqrt(N)];
else
    K = flip(1:ceil(N/2));
    N_middle_factor = K(find(rem(N,K)==0));
end
num_shift = 1/30;%50ms
%% For unsorted spikes
load('merge\merge_0224_Checkerboard_30Hz_27_5min_Br50_Q100.mat')
analyze_spikes = reconstruct_spikes;
sorted = 0;
%% For sorted spikes
% load('sort_merge_spike\sort_merge_0224_Checkerboard_20Hz_27_5min_Br50_Q100.mat')
% unit = 1;
% complex_channel = [];
% analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,unit);
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
    if (U(1,2)*cSTA(k,end-round(num_shift/BinningInterval)) < 0) % asume that all channel are fast-OFF-slow-ON if there is no csta file.
        U(:,2) = -U(:,2);
        V(:,2) = -V(:,2);
    end
    space = reshape(V(:,2),[side_length,side_length]);%Reshape one dimensional spatial filter to two dimensional spatial filter
    
    %Calculate first component percentage
    power_component = diag(S).*diag(S)/sum(S(:).*S(:))*100;%Each component percentage
    power_first_component = power_component(1);
    power_2nd_component = power_component(2);
    disp(['channel',int2str(k),' 2nd_component power is ',num2str(power_2nd_component),'%'])
    
    %Calculate and plot temporal SVD
    figure(k+120)
    plot([0 time_shift*num_shift*1000] ,[0 U(:,2)'], 'LineWidth',3)
    title(['temporal filter from SVD channel ',int2str(k)])
    xlabel('time before spike(ms)')
    ylabel('relative intensity')
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    if save_svd
        if sorted
            saveas(fig,[exp_folder, '\FIG\RF\', name,'\sort','\temporal_svd_channel_', num2str(k)  '.tiff'])
        else
            saveas(fig,[exp_folder, '\FIG\RF\', name,'\unsort','\temporal_svd_channel_', num2str(k)  '.tiff'])
        end
        close(fig);
    end
    
    %Calculate electrode position and RF center from SVD
    electrode_x(k) = (oled_channel_pos(k,1)-meaCenter_x)*side_length/mea_size_bm + (side_length+1)/2;
    electrode_y(k) = (oled_channel_pos(k,2)-meaCenter_y)*side_length/mea_size_bm + (side_length+1)/2;
    num_spike =  length(analyze_spikes{k});
    if num_spike /stimulus_length > 0.3
        max_value  = max(space, [], 'all');
        closest_extrema(1,k) = ceil(find(space == max_value)/side_length);
        closest_extrema(2,k) = mod(find(space == max_value)-1, side_length)+1;
    end
    
    
    %Plot spatial SVD
    figure(k+60)
    imagesc(space);hold on;
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
        close(fig);
    end
    
    
end


%% plot RF & electrode position & RF center
for k =displaychannel
    %plot RF & electrode position & RF center
    figure(k);
    num_spike =  length(analyze_spikes{k});
    for i = time_shift
        subplot(N_middle_factor(2),N_middle_factor(1),i),imagesc(gauss_RF{i,k});hold on;
        pbaspect([1 1 1])
        title([num2str(-i*num_shift*1000),'ms']);
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
        close(fig);
    end
   
    
end
RFcenter = zeros(60,2);
for k = displaychannel
    RFcenter(k,1) = (closest_extrema(1,k) - (side_length+1)/2)/(side_length/mea_size_bm)+meaCenter_x;
    RFcenter(k,2) = (closest_extrema(2,k) - (side_length+1)/2)/(side_length/mea_size_bm)+meaCenter_y;
end
if sorted
    save([exp_folder,'\Analyzed_data\sort\RFcenter.mat'],'RFcenter');
else
    save([exp_folder,'\Analyzed_data\unsort\RFcenter.mat'],'RFcenter');
end
% titles and checkerboard size
RF_pixel_size = mea_size_bm/side_length*micro_per_pixel %mircometer


cd(code_folder)