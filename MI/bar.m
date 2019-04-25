%% This code changes bar position to light or dark state in each channel

load('boundary_set.mat')
load('channel_pos.mat')
RL_points = zeros(1,8);
UD_points = zeros(1,8);

for i = 1:4
    RL_points(5-i) = meaCenter_x-mea_size/14*(2*i-1);
    UD_points(5-i) = meaCenter_y-mea_size/14*(2*i-1);
    RL_points(i+4) = meaCenter_x+mea_size/14*(2*i-1);
    UD_points(i+4) = meaCenter_y+mea_size/14*(2*i-1);
end


%% RL part
RL_matrix = zeros(length(bin_pos),8);%matrix that stores light or dark as 1,0. 
num = 1;
for pos = bin_pos
    is_cover = zeros(1,8);%It represent each column status(light or dark as 1,0)
    x_position = pos;
    for i = 1:8
       if  abs(x_position-RL_points(i)) <= bar_wid+1%Check the bar lights on channel. Minus 1 because electrode size is about 3 pixels
           is_cover(i) = 1;
       end
    end
    RL_matrix(num,:) = is_cover;
    num = num + 1;
end

%% UD part
UD_matrix = zeros(length(bin_pos),8);%matrix that stores light or dark as 0,1
num = 1;
for pos = bin_pos
    is_cover = zeros(1,8);
    y_position = pos;
    for i = 1:8
        is_cover = zeros(1,8);
       if  abs(y_position-UD_points(i)) <= bar_wid-1
           is_cover(i) = 1;
       end
    end
    UD_matrix(num,:) = is_cover;
    num = num + 1;
end

matrix = 