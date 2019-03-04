function UD_spikes = get_UD(BinningSpike)
%%Function that get sum of BinningSpike for calculating MI of UD
%UD_spikes{1} is up
%UD_spikes{8} is down
    UD_spikes = cell(1,8);

    %Up and down part
    for i = [7 14]
       total_spikes = zeros(6,length(bin_pos));
       for j = 1:6
          total_spikes(j,:) = BinningSpike(i+(j-1)*8,:);
       end
       UD_spikes{i-6} = sum(total_spikes,1);
    end

    %middle part
    for i = 1:6
       total_spikes = zeros(8,length(bin_pos));
       start = 7+(i-2)*8;

       total_spikes(1,:) = BinningSpike(i,:);
       total_spikes(8,:) = BinningSpike(i+54,:);

       for j = 2:7
          total_spikes(j,:) = BinningSpike(i+7+(j-2)*8,:);
       end

       UD_spikes{i+1} = sum(total_spikes,1);
    end

end