function ans  = rearrange_xy_serie(xy_serie, x_states, y_states, num_x_states, num_y_states)
if isempty(x_states)
    ans  = xy_serie;
else
    R = mod(num_y_states(end),length(x_states));
    N = floor(num_y_states(length(num_y_states))/length(x_states));
    if N <= num_x_states(1)
        new_xy_series =  [x_states; y_states(end)*ones(1,length(x_states))];
        xy_serie = [xy_serie repmat(new_xy_series, [1,N])];
        new_xy_series =  [x_states(end-R+1:end); y_states(end)*ones(1,R)];
        xy_serie = [xy_serie new_xy_series];
        y_states(end) = [];
        num_y_states(end) = [];
        num_x_states = num_x_states-N;
        num_x_states(length(x_states)-R+1:length(x_states)) = num_x_states(end-R+1:end)-1;
        I = find(num_x_states== 0);
        x_states(I) = [];
        num_x_states(I) = [];
        [num_x_states I] = sort(num_x_states);
        x_states = x_states(I);
        ans  = rearrange_xy_serie(xy_serie, x_states, y_states, num_x_states, num_y_states);
    else
        N =  num_x_states(1);
        new_xy_series =  [x_states; y_states(end)*ones(1,length(x_states))];
        xy_serie = [xy_serie repmat(new_xy_series, [1,N])];
        num_y_states(end) = num_y_states(end)-N*length(x_states);
        num_x_states = num_x_states-N;
        x_states(1) = [];
        num_x_states(1) = [];
        ans  = rearrange_xy_serie(xy_serie, x_states, y_states, num_x_states, num_y_states);
    end
end
end


