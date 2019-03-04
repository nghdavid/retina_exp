function[spikes] = seperate_trials(spikes,starts)
    %This function cut each stimulus' spikes and add them up
    for j = 1:length(spikes)         %running through each channel
        ss = spikes{j};
        ss(ss<starts(1)) = [];
        ss(ss>=starts(end))=[];
        ss(ss==0)=[];
        for i = 1:length(ss)
            loc = find(ss(i)>starts);
            if isempty(loc);  continue;   end
            ss(i) = ss(i)-starts(loc(end));
        end
        spikes{j} = ss;
    end
end