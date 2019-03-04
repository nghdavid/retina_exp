function RL_spikes = get_RL(BinningSpike)
%%Function that get sum of BinningSpike for calculating MI of RL
%RL_spikes{1} is left
%RL_spikes{8} is right
    RL_spikes = cell(1,8);

    %left and right part
    for i = [1 8]
       total_spikes = zeros(6,length(bin_pos));
       if i == 1
           for j = 1:6
              total_spikes(j,:) = BinningSpike(j,:);
           end
           RL_spikes{i} = sum(total_spikes,1);
       else
           for j = 1:6
               total_spikes(j,:) = BinningSpike(j+54,:);
           end
           RL_spikes{i} = sum(total_spikes,1);
       end
    end

    %middle part
    for i = 2:7
       total_spikes = zeros(8,length(bin_pos));
       start = 7+(i-2)*8;
       row = 1;
       for j = start:start+7
          total_spikes(row,:) = BinningSpike(j,:);
          row = row +1;
       end
       RL_spikes{i} = sum(total_spikes,1);
    end

end



