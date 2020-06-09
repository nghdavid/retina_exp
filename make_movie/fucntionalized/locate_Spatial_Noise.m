function locate_Spatial_Noise(calibration_date, num_dot);
    matrix_folder = 'C:\';
    load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
    load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
    mea_range = [leftx_bar rightx_bar meaCenter_y-floor(mea_size/2) meaCenter_y+floor(mea_size/2) mea_size screen_y screen_x];
    folder_name = [calibration_date,'Spatial_Noise_matrix'];
    mkdir ([matrix_folder,folder_name])
    mkdir ([matrix_folder,folder_name],num2str(num_dot))
    for i = 1:500
        sN_ic = [];
        while isempty(sN_ic)
            sN_ic = Spatial_Noise_generator(mea_range, num_dot);            
        end
        a = sN_ic{1};
        save([matrix_folder,'\',folder_name,'\',num2str(num_dot),'\',num2str(i),'.mat'],'a');
    end
end