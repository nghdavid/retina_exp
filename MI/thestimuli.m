%absulote pos
TheStimuli=bin_pos;  %recalculated bar position

%velocity
TheStimuli = [];
TheStimuli(1) = 0;
TheStimuli(length(bin_pos)) = 0;
for i =2:(length(bin_pos)-1)
    TheStimuli(i) = ((bin_pos(i+1) + bin_pos(i))/2 - (bin_pos(i-1) + bin_pos(i))/2)*60/1000;
end
    
%distance
meaCenter_x=715; 
meaCenter_y=634; 
if type = "RL"
    TheStimuli= channel_pos(1) - bin_pos;
elseif type = "UD"
    TheStimuli= (channel_pos(2)-meaCenter_y) - (bin_pos-meaCenter_x);
elseif type = "UL-DR"
    TheStimuli= (channel_pos(1)-channel_pos(2)+meaCenter_y-meaCenter_x)/sqrt(2) - (bin_pos-meaCenter_x);
else 
    TheStimuli= (-channel_pos(1)-channel_pos(2)+meaCenter_y+meaCenter_x)/sqrt(2) - (bin_pos-meaCenter_x);
end