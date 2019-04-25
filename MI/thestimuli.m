function TheStimuli = thestimuli(stimuli_type, video_type, channel_num) 

if stimuli_type == 'pos'%absulote pos
    TheStimuli=bin_pos;  %recalculated bar position
    
elseif stimuli_type == 'vel'%velocity
    
    TheStimuli = [];
    TheStimuli(1) = 0;
    TheStimuli(length(bin_pos)) = 0;
    for i =2:(length(bin_pos)-1)
        TheStimuli(i) = ((bin_pos(i+1) + bin_pos(i))/2 - (bin_pos(i-1) + bin_pos(i))/2)/(1/60)*1.5/483;
    end
    figure; hist(TheStimuli);
elseif stimuli_type == 'bar_loc' % if the bar locate at the cannel or not (bool)
    
    load('boundary_set.mat')
    load('channel_pos.mat')
    
    if video_type == "RL"
        TheStimuli = abs(channel_pos(channel_num,1) - bin_pos) <= bar_wid && abs(channel_pos(channel_num,2) - meaCenter_y) <= bar_le ;
    elseif video_type == "UD"
        TheStimuli= abs((channel_pos(channel_num,2)-meaCenter_y) - (bin_pos-meaCenter_x)) <= bar_wid && abs(channel_pos(channel_num,1) - meaCenter_x) <= bar_le ;
    elseif video_type == "UL-DR"
        TheStimuli= abs((channel_pos(channel_num,1)+channel_pos(channel_num,2)-meaCenter_y-meaCenter_x)/sqrt(2) - (bin_pos-meaCenter_x)) <= bar_wid && abs((-channel_pos(channel_num,1)+channel_pos(channel_num,2)-meaCenter_y+meaCenter_x)/sqrt(2)) <= bar_le;
    else
        TheStimuli= abs((-channel_pos(channel_num,1)+channel_pos(channel_num,2)-meaCenter_y+meaCenter_x)/sqrt(2) - (bin_pos-meaCenter_x)) <= bar_wid && abs((channel_pos(channel_num,1)+channel_pos(channel_num,2)-meaCenter_y-meaCenter_x)/sqrt(2)) <= bar_le;
    end
else
end

end