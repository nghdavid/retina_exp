clear all;
oled_channel_pos = zeros(60,2);
load('oled_boundary_set.mat')
for i = 1:6
    oled_channel_pos(i,1) = meaCenter_x + 3.5*200/micro_per_pixel;
    oled_channel_pos(i,2) = meaCenter_y + (i+1-4.5)*200/micro_per_pixel;
end
for i = 1:8
    oled_channel_pos(i+6,1) = meaCenter_x + 2.5*200/micro_per_pixel;
    oled_channel_pos(i+6,2) = meaCenter_y + (i-4.5)*200/micro_per_pixel;
end
for i = 1:8
    oled_channel_pos(i+14,1) = meaCenter_x + 1.5*200/micro_per_pixel;
    oled_channel_pos(i+14,2) = meaCenter_y + (i-4.5)*200/micro_per_pixel;
end
for i = 1:8
    oled_channel_pos(i+22,1) = meaCenter_x + 0.5*200/micro_per_pixel;
    oled_channel_pos(i+22,2) = meaCenter_y + (i-4.5)*200/micro_per_pixel;
end
for i = 1:8
    oled_channel_pos(i+30,1) = meaCenter_x - 0.5*200/micro_per_pixel;
    oled_channel_pos(i+30,2) = meaCenter_y + (i-4.5)*200/micro_per_pixel;
end
for i = 1:8
    oled_channel_pos(i+38,1) = meaCenter_x - 1.5*200/micro_per_pixel;
    oled_channel_pos(i+38,2) = meaCenter_y + (i-4.5)*200/micro_per_pixel;
end
for i = 1:8
    oled_channel_pos(i+46,1) = meaCenter_x - 2.5*200/micro_per_pixel;
    oled_channel_pos(i+46,2) = meaCenter_y + (i-4.5)*200/micro_per_pixel;
end
for i = 1:6
    oled_channel_pos(i+54,1) = meaCenter_x - 3.5*200/micro_per_pixel;
    oled_channel_pos(i+54,2) = meaCenter_y + (i+1-4.5)*200/micro_per_pixel;
end
save('oled_channel_pos.mat')
