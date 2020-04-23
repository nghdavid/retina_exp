function information = minShuffle_MIfunc(Neurons,isi2,BinningInterval,backward,forward)
state = 1;
for j = unique(Neurons)
    Neurons(find(Neurons==j))= state;
    state = state + 1;
end
state = 1;
for j = unique(isi2)
    isi2(find(isi2==j))= state;
    state = state + 1;
end
dat=[];informationp=[];temp=backward+2;
    for i=1:backward+1 %past(t<0)
        x = Neurons((i-1)+forward+1:length(Neurons)-backward+(i-1))';
        y = isi2(forward+1:length(isi2)-backward)';
        dat{i}=find_serie_with_min_entropy(x', y')';
        norm=BinningInterval;

        N=hist3(dat{i},[max(Neurons) max(isi2)]); %20:dividing firing rate  6:# of stim
        py=sum(N,1)/sum(N, 'all'); 
        px=sum(N,2)/sum(N, 'all'); 
        pxy=N/sum(N, 'all'); 
        temp2=[];
        for j = 1:length(unique(Neurons))
            for k = unique(isi2)
              temp2(j,k)=pxy(j,k)*log( pxy(j,k)/ (py(k)*px(j)) )/log(2)/norm;
            end
        end
        informationp(backward+2-i)=nansum(temp2(:));
    end  

    dat=[];informationf=[];temp=0;sdat=[];
    for i=1:forward
        y =Neurons(forward+1-i:length(Neurons)-backward-i)';
        x = isi2(forward+1:length(isi2)-backward)';
        dat{i}=find_serie_with_min_entropy(x', y')';
        norm=BinningInterval;

        N=hist3(dat{i}, [max(Neurons) max(isi2)]); %20:dividing firing rate  6:# of stim
        py=sum(N,1)/sum(N, 'all'); 
        px=sum(N,2)/sum(N, 'all');
        pxy=N/sum(sum(N));
        temp2=[];
        for j =  unique(Neurons)
            for k =unique(isi2)
                temp2(j,k)=pxy(j,k)*log( pxy(j,k)/ (py(k)*px(j)) )/log(2)/norm;
            end
        end
        informationf(i)=nansum(temp2(:));
    end
    information=[informationp informationf];
end