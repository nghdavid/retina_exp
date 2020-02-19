clear all;
mea_size=189;
mea_size_bm=267; %bigger mea size , from luminance calibrated region
meaCenter_x=400;
meaCenter_y=300; 
flicker_loc = [293-20 293+20  800-32 800]

leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
rightx_bd=meaCenter_x+(mea_size_bm-1)/2;
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
righty_bd=meaCenter_y+(mea_size_bm-1)/2;
bar_le=floor((mea_size_bm-1)/2/sqrt(2)); %half of bar length / pixel number on LCD /total length = mea_size = 1919 um
bar_wid=8; %half of bar width / total length = 11*2+1=23 pixels = 65 um
% re_bar_wid=22;
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar
micro_per_pixel = 1430/188;



save('oled_boundary_set');