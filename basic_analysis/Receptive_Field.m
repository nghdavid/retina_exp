close all;
clear all;
code_folder = pwd;
load('channel_pos.mat')
load('boundary_set.mat')

displaychannel = 1:60;%1:60;%Choose which channel to display
displaychannel = [52];%1:60;%Choose which channel to display
save_photo =1;%0 is no save RF photo, 1 is save
save_svd =0;%0 is no save svd photo, 1 is save
save_center =0;
time_shift = 1:6;%for -50ms:-300ms
num_shift = 0.05;%50ms
exp_folder = 'E:\20190825';
cd(exp_folder)
name = '20Hz_13x13_RF';%Directory name
filename = '0507_Checkerboard_20Hz_13_5min_Br50_Q100';
%% For sorted spikes
load(['sort_merge_spike\sort_merge_',filename,'.mat'])
analyze_spikes = sorted_spikes;
sorted = 1;
%% For unsorted spikes
% load(['merge\merge_0507_',filename,'.mat'])
% analyze_spikes = reconstruct_spikes;
% sorted = 0;



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
    if U(1,2) >= 0 % asume that all channel are fast-OFF-slow-ON
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
%     figure(k+120)
%     %     plot(fliplr(time_shift*num_shift*-1000),fliplr(U(1,:)))
%     plot([0 time_shift*num_shift*1000] ,[0 U(:,2)'], 'LineWidth',3)
%     title(['temporal filter from SVD channel ',int2str(k)])
%     xlabel('time before spike(ms)')
%     ylabel('relative intensity')
%     set(gcf,'units','normalized','outerposition',[0 0 1 1])
%     fig = gcf;
%     fig.PaperPositionMode = 'auto';
%     if save_svd
%         if sorted
%             saveas(fig,[exp_folder, '\FIG\RF\', name,'\sort','\temporal_svd_channel', num2str(k)  '.tiff'])
%         else
%             saveas(fig,[exp_folder, '\FIG\RF\', name,'\unsort','\temporal_svd_channel', num2str(k)  '.tiff'])
%         end
%     end
    
    %Calculate electrode position and RF center from SVD
    
    %gauss_space = imgaussfilt(space,1.5);
    electrode_x(k) = (channel_pos(k,1)-meaCenter_x)*side_length/mea_size_bm + (side_length+1)/2;
    electrode_y(k) = (channel_pos(k,2)-meaCenter_y)*side_length/mea_size_bm + (side_length+1)/2;
    num_spike =  length(analyze_spikes{k});
    if num_spike /stimulus_length > 0.3
        max_value  = max(space(:));
        closest_extrema(1,k) = ceil(find(space == max_value)/side_length);
        closest_extrema(2,k) = mod(find(space == max_value)-1, side_length)+1;
    end
    
    
    %Plot spatial SVD
%     figure(k+60)
%     imagesc(space);hold on;
%     title(k)
%     pbaspect([1 1 1])
%     colormap(gray);
%     colorbar;
%     scatter(electrode_x(k),electrode_y(k), 50, 'r','filled');
%     if num_spike /stimulus_length > 1
%         scatter(closest_extrema(1,k),closest_extrema(2,k), 100, 'b' ,'o','filled')
%     end
%     set(gcf,'units','normalized','outerposition',[0 0 1 1])
%     fig = gcf;
%     fig.PaperPositionMode = 'auto';
%     if save_svd
%         if sorted
%             saveas(fig,[exp_folder, '\FIG\RF\', name,'\sort','\spatial_svd_channel', num2str(k)  '.tiff'])
%         else
%             saveas(fig,[exp_folder, '\FIG\RF\', name,'\unsort','\spatial_svd_channel', num2str(k)  '.tiff'])
%         end
%     end
    
    
end


%% plot RF & electrode position & RF center
for k =displaychannel
    %plot RF & electrode position & RF center
    figure(k);
    h =suptitle(int2str(k));
    set(h,'FontSize',10)
    num_spike =  length(analyze_spikes{k});
    for i = time_shift
        subplot(2,3,i),imagesc(gauss_RF{i,k});hold on;
        pbaspect([1 1 1])
        title([num2str(-i*50),'ms']);
        colormap(gray);
        colorbar;
        scatter(electrode_x(k),electrode_y(k), 10, 'r','filled');
        
        if num_spike /stimulus_length > 0.5
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
    if num_spike /stimulus_length > 0.5
       
        temporal_filter = zeros(1,length(time_shift));
        if closest_extrema(1,k) == 1
            center_leftbd = 1;
        else
            center_leftbd = closest_extrema(1,k)-1;
        end
        if closest_extrema(2,k) == 1
            center_upperbd = 1;
        else
            center_upperbd = closest_extrema(2,k)-1;
        end
        if closest_extrema(1,k) == side_length
            center_rightbd = 13;
        else
            center_rightbd = closest_extrema(1,k)+1;
        end
        if closest_extrema(2,k) == side_length
            center_lowerbd = 13;
        else
            center_lowerbd = closest_extrema(2,k)+1;
        end
        for i = time_shift
            
            temporal_filter(i) = mean(mean(gauss_RF{i,k}(center_leftbd:center_rightbd,center_upperbd:center_lowerbd)));
        end
        figure(k+180)
        %         plot(fliplr(time_shift*num_shift*-1000),fliplr(temporal_filter))
        plot(-[0 time_shift*num_shift*-1000],[0.5 temporal_filter],'LineWidth',3)
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

if save_center
if sorted
    RFcenter = zeros(60,2);
    for k = displaychannel
        RFcenter(k,1) = (closest_extrema(1,k) - (side_length+1)/2)/(side_length/mea_size_bm)+meaCenter_x;
        RFcenter(k,2) = (closest_extrema(2,k) - (side_length+1)/2)/(side_length/mea_size_bm)+meaCenter_y;
    end
    save([exp_folder,'\Analyzed_data\RFcenter.mat'],'RFcenter','RF_pixel_size');
end
end



cd(code_folder)