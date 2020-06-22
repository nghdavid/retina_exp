clear all;
mea_size=461;
mea_size_bm=529; %bigger mea size , from luminance calibrated region
meaCenter_x=714; 
meaCenter_y=629; 
re_bar_wid=22;
leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
bar_le=floor((mea_size_bm-1)/2/sqrt(2)); %half of bar length / pixel number on LCD /total length = mea_size = 1919 um
bar_wid=11; %half of bar width / total length = 11*2+1=23 pixels = 65 um
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar
rightx_bd = meaCenter_x+(mea_size_bm-1)/2;
long_bar_le = (mea_size_bm+1)/2;
save('boundary_set');