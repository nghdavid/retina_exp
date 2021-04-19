function img = transform_matrix(calibration_date,all_bar,degree)
    load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
    load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
    all_bars = repmat(all_bar,bar_le*2+1,1);
    a = zeros(mea_size_bm,mea_size_bm);
    a(mea_size_bm/2-floor(mea_size/2):mea_size_bm/2+floor(mea_size/2),mea_size_bm/2-floor(mea_size/2):mea_size_bm/2+floor(mea_size)/2)) = all_bars;
    rotate_all_bars = imrotate(a,degree,'nearest','crop');
    pic_size = size(rotate_all_bars,2);
    pic = (mea_size_bm-pic_size)/2;
    leftx_bar=leftx_bd+pic; %Left boundary of bar
    rightx_bar=rightx_bd-pic; %Right boundary of bar
    upy_bar = lefty_bd+pic;
    downy_bar = righty_bd-pic;
    img=zeros(screen_y,screen_x);%full screen pixel matrix %it's the LED screen size
    img(upy_bar-1:downy_bar-1,leftx_bar-1:rightx_bar-1) = rotate_all_bars;
end