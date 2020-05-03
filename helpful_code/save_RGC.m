close all;
clear all;
load('rr.mat')
code_folder = pwd;
date = '20200409';
exp_folder = ['E:\',date];
exp_folder = 'D:\Leo\0409';
cd(exp_folder)
load('Analyzed_data\0224_Gollish_OnOff_movie_5min_Br50_Q100_6.5mW.mat')
load('Analyzed_data\sort\0224_cSTA_wf_3min_Q100.mat')
load('Analyzed_data\30Hz_27_RF_15min\unsort\RF_properties.mat')

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
    if sum(RF_properties(channel,[2,4])) ~= 0
        r.center_RF = RF_properties(channel,[2,4]);
    end
    
% %    load('predictive_channel\bright_bar.mat')
%     if ismember(channel,p_channel)
%         r.bright_bar_predictive = 1;
%     elseif ismember(channel,np_channel)
%         r.bright_bar_predictive = 0;
%     end
    RGCs{channel} = r;
end
save('RGC.mat','RGCs')