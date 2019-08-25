function[on_spikes,off_spikes] =seperate_Gollishtrials(Spikes,diode_on_start,diode_off_start,diode_end)
    %This function cut each stimulus' spikes and add them up
    on_spikes = cell(1,60);
    off_spikes = cell(1,60);
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
                 off_ss = [off_ss ss(i)-diode_off_start(off_loc(end))];
            elseif isempty(off_loc)%On state
                 on_ss = [on_ss ss(i)-diode_on_start(on_loc(end))];
            elseif length(on_loc)> length(off_loc)%On state
                 on_ss = [on_ss ss(i)-diode_on_start(on_loc(end))];
            elseif length(on_loc)== length(off_loc)%Off state
                off_ss = [off_ss ss(i)-diode_off_start(off_loc(end))];
            else
            end
        end
        on_spikes{j} = on_ss;
        off_spikes{j} = off_ss;
    end
    
end