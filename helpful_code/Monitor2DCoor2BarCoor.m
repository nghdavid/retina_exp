function newXpos = Monitor2DCoor2BarCoor(x,y,bar_direction,monitor_type)
%simple linear tranformation, x and y can be array
if strcmp(monitor_type, 'LCD')
    load('boundary_set.mat')
elseif strcmp(monitor_type, 'OLED')
    load('oled_boundary_set.mat')
end

if strcmp(bar_direction,'UD')
    newXpos =y;
elseif  strcmp(bar_direction,'RL')
    newXpos =x;
elseif  strcmp(bar_direction,'UR_DL')
    newXpos =(-x+ y+meaCenter_x-meaCenter_y)/sqrt(2)+meaCenter_x;
elseif  strcmp(bar_direction,'UL_DR')
    newXpos =(x+y-meaCenter_y-meaCenter_x)/sqrt(2)+meaCenter_x;
end
end