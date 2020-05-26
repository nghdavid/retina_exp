close all;
clear all;
load('rr.mat')
code_folder = pwd;
date = '20200418';
exp_folder = ['E:\',date];
cd(exp_folder)
load('Analyzed_data\sort\0224_Gollish_OnOff_movie_5min_Br50_Q100_6.5mW_re.mat')
load('Analyzed_data\sort\0224_cSTA_wf_3min_Q100_re.mat')
load('Analyzed_data\30Hz_27_RF_re\sort\RF_properties.mat')
load('predictive_channel\bright_bar.mat')
RGCs = cell(1,60);
for channel = 1:60
    r = RGC;
    r.channel = channel;
    r.date = date;
    if ~isnan(Flicker_OnOff_Index(channel))
        r.flicker_onoff_index = Flicker_OnOff_Index(channel);%cSTA result
    end
    if ~isnan(on_off_index(channel))
        r.onoff_index = on_off_index(channel);%Gollisch result
    end
%     if sum(RFcenter(channel,:)) ~= 0
%         r.center_RF = RFcenter(channel,:);
%     end
    if sum(RF_properties(channel,:)) ~= 0
        r.center_RF = [RF_properties(channel,2),RF_properties(channel,4)];
        r.RF_size = RF_properties(channel,7);
    end
    if ismember(channel,p_channel)
        r.bright_bar_predictive = 1;
    elseif ismember(channel,np_channel)
        r.bright_bar_predictive = 0;
    end
    RGCs{channel} = r;
end
save('RGC.mat','RGCs')