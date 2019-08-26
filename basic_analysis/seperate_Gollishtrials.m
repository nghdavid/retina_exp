function[on_spikes,off_spikes] =seperate_Gollishtrials(Spikes,diode_on_start,diode_off_start,diode_end)
    %% This function cut each stimulus' spikes and add them up
    %diode_on_start stores when on starts
    %diode_off_start stores when off starts
    %diode_end is when whole onoff stimulus end
    on_spikes = cell(1,60);%It stores spikes under on stimulus that are subtracted and merged
    off_spikes = cell(1,60);%It stores spikes under off stimulus that are subtracted and merged
    for j = 1:length(Spikes) %running through each channel
        on_ss = [];
        off_ss = [];
        ss = Spikes{j};
        %Remove useless spikes
        ss(ss<diode_on_start(1)) = [];
        ss(ss>=diode_end)=[];%Notice that last in starts should be end of stimulus
        ss(ss==0)=[];
        for i = 1:length(ss)%running all spikes in a channel
            on_loc = find(ss(i)>diode_on_start);
            off_loc = find(ss(i)>diode_off_start);
            if isempty(on_loc) && isempty(off_loc)
                continue;
            elseif isempty(on_loc)%Off state, but it won't happen
                 off_ss = [off_ss ss(i)-diode_off_start(off_loc(end))];%Minus by the nearest off start location
            elseif isempty(off_loc)%On state
                 on_ss = [on_ss ss(i)-diode_on_start(on_loc(end))];%Minus by the nearest on start location
            elseif length(on_loc)> length(off_loc)%On state
                 on_ss = [on_ss ss(i)-diode_on_start(on_loc(end))];%Minus by the nearest on start location
            elseif length(on_loc)== length(off_loc)%Off state
                off_ss = [off_ss ss(i)-diode_off_start(off_loc(end))];%Minus by the nearest off start location
            else
            end
        end
        on_spikes{j} = on_ss;%On spiking time after being subtracted
        off_spikes{j} = off_ss;%Off spiking time after being subtracted
    end
    
end