function ans  = rearrange_xy_serie(xy_serie, x_states, y_states, num_x_states, num_y_states)
if isempty(x_states)
    ans  = xy_serie;
else
    if num_y_states(end) <= length(x_states)
        new_xy_series =  [x_states(length(x_states)-num_y_states(end)+1:length(x_states)); y_states(end)*ones(1,num_y_states(end))];
        xy_serie = [xy_serie new_xy_series];
        num_x_states(length(x_states)-num_y_states(end)+1:length(x_states)) = num_x_states(length(x_states)-num_y_states(end)+1:length(x_states))-1;
        y_states(end) = [];
        num_y_states(end) = [];
        I = find(num_x_states== 0);
        x_states(I) = [];
        num_x_states(I) = [];
        [num_x_states I] = sort(num_x_states);
        x_states = x_states(I);
        ans  = rearrange_xy_serie(xy_serie, x_states, y_states, num_x_states, num_y_states);
    else %%
        new_xy_series =  [x_states; y_states(end)*ones(1,length(x_states))];
        xy_serie = [xy_serie new_xy_series];
        num_y_states(end) = num_y_states(end)-length(x_states);
        num_x_states = num_x_states-1;
        I = find(num_x_states== 0);
        x_states(I) = [];
        num_x_states(I) = [];
        ans  = rearrange_xy_serie(xy_serie, x_states, y_states, num_x_states, num_y_states);
    end
end
end


