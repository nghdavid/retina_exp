function [MI2 MI3 Redundancy] = PIfunc(Neurons,isi2, isi3,BinningInterval,backward,forward)
Neurons = Neurons +1 -1*min(Neurons);
dat=[];informationp=[];temp=backward+2;
informationp2=[];
informationp3=[];
for i=1:backward+1 %past(t<0)
    x = Neurons((i-1)+forward+1:length(Neurons)-backward+(i-1))';
    y2 = isi2(forward+1:length(isi2)-backward)';
    y3 = isi3(forward+1:length(isi3)-backward)';
    dat2{i}=[x,y2];
    dat3{i}=[x,y3];
    norm=BinningInterval;
    N2=hist3(dat2{i},[max(Neurons) max(isi2)]); %20:dividing firing rate  6:# of stim
    N3 = hist3(dat3{i},[max(Neurons) max(isi3)]); %20:dividing firing rate  6:# of stim
    py2=sum(N2,1)/sum(N2, 'all');
    py3=sum(N3,1)/sum(N3, 'all');
    px=sum(N3,2)/sum(N3, 'all');
    pxy2=N2/sum(N2, 'all');
    pxy3=N3/sum(N3, 'all');
    temp2=[];
    temp3=[];
    temp = 0;
    for j = 1:length(unique(Neurons))
        for k = unique(isi2)
            temp2(j,k)=pxy2(j,k)*log( pxy2(j,k)/ (py2(k)*px(j)) )/log(2)/norm;
        end
        for k = unique(isi3)
            temp3(j,k)=pxy3(j,k)*log( pxy3(j,k)/ (py3(k)*px(j)) )/log(2)/norm;
        end
        temp = temp + min(nansum(temp2(j,:)), nansum(temp3(j,:)));
    end
    informationp(backward+2-i)=temp;
    informationp2(backward+2-i)=nansum(temp2(:));
    informationp3(backward+2-i)=nansum(temp3(:));
end

dat=[];informationf=[];temp=0;sdat=[];
informationf2=[];
informationf3=[];
for i=1:forward
    x =Neurons(forward+1-i:length(Neurons)-backward-i)';
    y2 = isi2(forward+1:length(isi2)-backward)';
    y3 = isi3(forward+1:length(isi3)-backward)';
    dat2{i}=[x,y2];
    dat3{i}=[x,y3];
    norm=BinningInterval;
    
    N2=hist3(dat2{i},[max(Neurons) max(isi2)]); %20:dividing firing rate  6:# of stim
    N3 = hist3(dat3{i},[max(Neurons) max(isi3)]); %20:dividing firing rate  6:# of stim
    py2=sum(N2,1)/sum(N2, 'all');
    py3=sum(N3,1)/sum(N3, 'all');
    px=sum(N3,2)/sum(N3, 'all');
    pxy2=N2/sum(N2, 'all');
    pxy3=N3/sum(N3, 'all');
    temp2=[];
    temp3=[];
    temp = 0;
    for j = 1:length(unique(Neurons))
        for k = unique(isi2)
            temp2(j,k)=pxy2(j,k)*log( pxy2(j,k)/ (py2(k)*px(j)) )/log(2)/norm;
        end
        for k = unique(isi3)
            temp3(j,k)=pxy3(j,k)*log( pxy3(j,k)/ (py3(k)*px(j)) )/log(2)/norm;
        end
        temp = temp + min(nansum(temp2(j,:)), nansum(temp3(j,:)));
    end
    informationf(i)=temp;
    informationf2(i)=nansum(temp2(:));
    informationf3(i)=nansum(temp3(:));
end
Redundancy=[informationp informationf];
MI2 = [informationp2 informationf2];
MI3 = [informationp3 informationf3];
end