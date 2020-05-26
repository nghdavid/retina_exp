function xy_serie = find_serie_with_min_entropy(x_serie, y_serie)
x_states = unique(x_serie);
y_states = unique(y_serie);
num_x_states = [];
num_y_states = [];
for i = x_states
num_x_states = [ num_x_states length(find(x_serie == i))];
end
for j = y_states
num_y_states = [ num_y_states length(find(y_serie == j))];
end
xy_serie = [];
[num_x_states I] = sort(num_x_states);
x_states = x_states(I);
[num_y_states I] = sort(num_y_states);
y_states = y_states(I);
xy_serie = rearrange_xy_serie(xy_serie, x_states, y_states, num_x_states, num_y_states);
end


