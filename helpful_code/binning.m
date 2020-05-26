function isi2 = binning(bin_pos,type,StimuSN)
    if strcmp(type,'pos')
        TheStimuli=bin_pos;
    elseif strcmp(type,'v')
        x=bin_pos;
        TheStimuli = finite_diff(x ,4);
    end
    
    if strcmp(type,'abs')  
        nX=sort(TheStimuli,2);
        abin=length(nX)/StimuSN;
        isi2 = zeros(60,length(TheStimuli));
        for k = 1:60
            if sum(absolute_pos(k,:))>0
                intervals=[nX(k,abin:abin:end) inf]; % inf: the last term: for all rested values
                for jj=1:length(TheStimuli)
                    isi2(k,jj) = find(TheStimuli(k,jj)<=intervals,1);
                end
            end
        end
    elseif strcmp(type,'pos') || strcmp(type,'v')
        nX=sort(TheStimuli);
        abin=length(nX)/StimuSN;
        intervals=[nX(abin:abin:end) inf]; % inf: the last term: for all rested values
        temp=0; isi2=[];
        for jj=1:length(TheStimuli)
            isi2(jj) = find(TheStimuli(jj)<=intervals,1);
        end
    elseif strcmp(type,'pos&v')
        TheStimuli = zeros(2, length(bin_pos));
        TheStimuli(1,:)=bin_pos;
        x = TheStimuli(1,:);
        TheStimuli(2,:) = finite_diff(x ,4);
        nX1=sort(TheStimuli(1,:));
        nX2=sort(TheStimuli(2,:));
        abin=length(nX1)/StimuSN;
        intervals1=[nX1(abin:abin:end) inf]; % inf: the last term: for all rested values
        abin=length(nX2)/StimuSN;
        intervals2=[nX2(abin:abin:end) inf]; % inf: the last term: for all rested values
        temp=0; isi3=[]; isi2=[];
        for jj=1:length(TheStimuli)
            isi3(1,jj) = find(TheStimuli(1,jj)<=intervals1,1);
            isi3(2,jj) = find(TheStimuli(2,jj)<=intervals2,1);
        end
        isi2 = StimuSN*(isi3(1,:)-1) + isi3(2,:);
    end
end