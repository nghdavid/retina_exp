function information = MIfunc(Neurons,isi2,BinningInterval,backward,forward)

dat=[];informationp=[];temp=backward+2;
    for i=1:backward+1 %past(t<0)
        x = Neurons((i-1)+forward+1:length(Neurons)-backward+(i-1))';
        y = isi2(forward+1:length(isi2)-backward)';
        dat{i}=[x,y];
        norm=BinningInterval;

        [N,C]=hist3(dat{i},[max(Neurons)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
        px=sum(N,1)/sum(sum(N)); 
        py=sum(N,2)/sum(sum(N)); 
        pxy=N/sum(sum(N));
        temp2=[];
        for j=1:length(px)
            for k=1:length(py)
              temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
            end
        end
        temp=temp-1;
        informationp(temp)=nansum(temp2(:));
        
    end  

    dat=[];informationf=[];temp=0;sdat=[];
    for i=1:forward
        x =Neurons(forward+1-i:length(Neurons)-backward-i)';
        y = isi2(forward+1:length(isi2)-backward)';
        dat{i}=[x,y];
        norm=BinningInterval;

        [N,C]=hist3(dat{i},[max(Neurons)+1,max(isi2)]); %20:dividing firing rate  6:# of stim
        px=sum(N,1)/sum(sum(N)); 
        py=sum(N,2)/sum(sum(N)); 
        pxy=N/sum(sum(N));
        temp2=[];
        for j=1:length(px)
            for k=1:length(py)
                temp2(k,j)=pxy(k,j)*log( pxy(k,j)/ (py(k)*px(j)) )/log(2)/norm;
            end
        end
        temp=temp+1;
        informationf(temp)=nansum(temp2(:));
        
    end

    information=[informationp informationf];
    
      
end