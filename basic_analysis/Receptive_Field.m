RF = cell(6, 60);
analyze_spikes = sorted_spikes;
%analyze_spikes = reconstruct_spikes;
fps = 60;
checkerboard =  bin_pos;
displaychannel = [8 21 30];
load('channel_pos.mat')
load('boundary_set.mat')

for k =displaychannel
    for i = 1:6 %for -50ms:300ms
        sum_checkerbard = zeros(length(bin_pos{1}));
        for j = 1:length(analyze_spikes{k})
            spike_time = analyze_spikes{k}(j); %s
            RF_frame = floor((spike_time - i*0.05)*60);
            if RF_frame > 0
                sum_checkerbard = sum_checkerbard + checkerboard{RF_frame};
            end
        end
        RF{i,k} = sum_checkerbard/length(analyze_spikes{k});
    end
end

for k =displaychannel
    figure;
    for i = 1:6
        x = (channel_pos(k,1)-meaCenter_x)*length(sum_checkerbard)/mea_size_bm + round(length(sum_checkerbard)/2);
        y = (channel_pos(k,2)-meaCenter_y)*length(sum_checkerbard)/mea_size_bm + round(length(sum_checkerbard)/2);
        subplot(2,3,i),imagesc(imgaussfilt(RF{i,k},1.5), [0,1]);colorbar;hold on;
        colormap(gray);
        scatter(x,y, 10, [1 0 0],'filled');
    end
end



%load('D:\0304v\videoworkspace\0319_Checkerboard_5min_Br50_Q100.mat')