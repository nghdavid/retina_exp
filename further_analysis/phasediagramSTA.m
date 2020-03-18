close all;
clear all;
code_folder = pwd;
exp_folder = 'D:\Leo\0229';
sorted = 0;
unit = 0;
displaychannel =[18 48];
forward = 10;%90 bins before spikes for calculating STA%1500ms
backward = 15;%90 bins after spikes for calculating STA
frame_to_save = [10 17]; %-100ms &16.7ms

cd(exp_folder);
mkdir FIG
mkdir FIG phasediagram
cd FIG/phasediagram
if sorted
    mkdir sort
    cd(exp_folder);
    cd sort_merge_spike
else
    mkdir unsort
    cd(exp_folder);
    cd merge
end
all_file = subdir('*.mat') ; % change the type of the files which you want to select, subdir or dir.
n_file = length(all_file) ;

for z =19:23%:n_file %choose file
    
    file = all_file(z).name ;
    [pathstr, name, ext] = fileparts(file);
    directory = [pathstr,'\'];
    filename = [name,ext];
    if (strcmp(filename(12),'H') || strcmp(filename(12),'O')) && sorted == 0
    elseif (strcmp(filename(17),'H') || strcmp(filename(17),'O')) && sorted
    else
        continue
    end
    load([directory,filename]);
    name=[name];
    z
    name
    
    % put your stimulus here!!
    TheStimuli = zeros(2, length(bin_pos));
    TheStimuli(1,:)=bin_pos;
    TheStimuli(1,:) = (TheStimuli(1,:) - mean(TheStimuli(1,:)))/std(TheStimuli(1,:));
    TheStimuli(2,:) = finite_diff(TheStimuli(1,:) ,4);
    TheStimuli(2,:) = (TheStimuli(2,:) - mean(TheStimuli(2,:)))/std(TheStimuli(2,:));
    time=[-forward :backward]*BinningInterval;
    % Binning
    bin=BinningInterval*10^3; %ms
    BinningTime =diode_BT;
    
    %% BinningSpike and calculate STA
    BinningSpike = zeros(60,length(BinningTime));
    analyze_spikes = cell(1,60);
    if sorted
        analyze_spikes = get_multi_unit(exp_folder,sorted_spikes,unit);
    else
        analyze_spikes = reconstruct_spikes;
    end

    sum_n = zeros(1,60);
    phase_STD = cell(31,60); %spike-trigger-distribuion
    
    time_shift = [1:backward+forward+1];
    num_shift = BinningInterval;

    for k =displaychannel
        analyze_spikes{k}(analyze_spikes{k}<1) = []; %remove all feild on effect
        if length(analyze_spikes{k})/ (length(TheStimuli)*BinningInterval) >1
            for i =  time_shift  %for -250ms:250ms
                for j = 1:length(analyze_spikes{k})
                    spike_time = analyze_spikes{k}(j); %s
                    RF_frame = floor((spike_time - (backward+1-i)*num_shift)*60);
                    if RF_frame > 0 && RF_frame < length(TheStimuli)
                        phace_pt = TheStimuli(: , RF_frame);
                        phase_STD{i,k} = [phase_STD{i,k} phace_pt];
                    end
                end
            end
        else
            displaychannel(displaychannel==k) = [];
        end
    end
    %%%
    %%% # of bin of stimuli = 10*10 (pos*v)
    %%% # of coutour = 4 
    %%%
%     x = (max(TheStimuli(1,:))-min(TheStimuli(1,:)))*[0.5:1:9.5]/10+min(TheStimuli(1,:));
%     y = (max(TheStimuli(2,:))-min(TheStimuli(2,:)))*[0.5:1:9.5]/10+min(TheStimuli(2,:));
    x = -2.5:0.625:2.5;
    y = -2.5:0.625:2.5;
    N_st = hist3(TheStimuli' ,'Ctrs',{x  y})';
    
    for k =displaychannel
        for frame = frame_to_save
            figure(frame);
            %     x = linspace(min(TheStimuli(1,:)), max(TheStimuli(1,:)), 10);
            %     y = linspace(min(TheStimuli(2,:)), max(TheStimuli(2,:)), 10);
            N = hist3(phase_STD{frame,k}','Ctrs',{x y})';
            Mm = contourf(x, y, N_st/sum(N_st,  'all'), 4);
            mmm  = Mm2mmm(Mm, Mm(1,1), Mm(2,1)+2);
            contourf(x, y, N/sum(N,  'all'), mmm, 'LineColor','none'); hold on;
            colormap  winter;
            caxis([min(N_st/ sum(N_st,  'all'), [], 'all') max(N_st/ sum(N_st,  'all'), [], 'all')]);
            colorbar;
            contour(x, y, N_st/ sum(N_st,  'all'), 4, 'Color', 'k');
            title([ 'ch.',  num2str(k), ',', num2str( -round((backward+1-frame)*num_shift*1000)),'ms']);
            axis square
            %if ~isempty(find(frame_to_save == frame))
            %mkdir(['ch.',  num2str(k)])
            set(gca,'fontsize',12); hold on
            set(gcf,'units','normalized','outerposition',[0 0 1 1])
            fig =gcf;
            fig.PaperPositionMode = 'auto';
            fig.InvertHardcopy = 'off';
            if sorted
                saveas(fig,[exp_folder,'/FIG/phasediagram/sort/',name(12:end),'_ch.',  num2str(k), '_',  num2str( -round((backward+1-frame)*num_shift*1000)),'ms', '.tif'])
            else
                saveas(fig,[exp_folder,'/FIG/phasediagram/unsort/',name(12:end),'_ch.',  num2str(k), '_',  num2str( -round((backward+1-frame)*num_shift*1000)),'ms', '.tif'])
            end
            %close(gcf)
            hold off;
        end
    end
 
end
% quiver(x,y,u,v)
%plot(TheStimuli(1,:), TheStimuli(2,:))

function mmm = Mm2mmm(Mm, mmm, x)
    if x > length(Mm)
        return
    end
    mmm = [mmm Mm(1,x)] ;
    x = Mm(2, x)+x+1;
    mmm =  Mm2mmm(Mm, mmm, x);
end
