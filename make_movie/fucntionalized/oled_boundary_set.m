clear all;
folder = 'C:\calibration\20200219oled_calibration\';
mea_size=189;
screen_x = 1280;%Monitor x size
screen_y = 1024;%Monitor y size
mea_size_bm=267; %bigger mea size , from luminance calibrated region
meaCenter_x=400;
meaCenter_y=300; 
flicker_loc = [500-35 500+35  1230 1280];
leftx_bd=meaCenter_x-(mea_size_bm-1)/2; %the first x position of the bigger mea region(luminance calibrated region) on LED screen
rightx_bd=meaCenter_x+(mea_size_bm-1)/2;
lefty_bd=meaCenter_y-(mea_size_bm-1)/2;
righty_bd=meaCenter_y+(mea_size_bm-1)/2;
bar_le=floor((mea_size-1)/2); %half of bar length / pixel number on LCD /total length = mea_size = 1919 um
bar_wid=8; %half of bar width / total length = 8*2+1=17 pixels =  129um
re_bar_wid=16;
leftx_bar=ceil(meaCenter_x-(mea_size_bm-1)/2/sqrt(2)); %Left boundary of bar
rightx_bar=floor(meaCenter_x+(mea_size_bm-1)/2/sqrt(2)); %Right boundary of bar
micro_per_pixel = 1430/188;
save([folder,'oled_boundary_set']);