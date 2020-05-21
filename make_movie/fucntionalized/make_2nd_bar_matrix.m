function make_2nd_bar_matrix(calibration_date,mean_lumin,rotation)
    %Rotation is degree that bar rotate
    %mean_lumin is luminance of bar
    matrix_folder = 'C:\';
    load(['C:\calibration\',calibration_date,'oled_calibration\calibration.mat'])
    load(['C:\calibration\',calibration_date,'oled_calibration\oled_boundary_set.mat']);
    monitor_mean_lumin = interp1(real_lum,lum,mean_lumin,'linear');
    folder_name = [calibration_date,'Bar_matrix_',num2str(mean_lumin),'mW'];
    mkdir ([matrix_folder,folder_name])
    try
        load([matrix_folder,'\',folder_name,'\',num2str(o),'\origin.mat'])
    catch
        img=zeros(screen_y,screen_x);
        temp_img = [zeros(1, floor(mea_size_bm^2/2)) ones(1, ceil(mea_size_bm^2/2))];
        temp_img = temp_img(randperm(mea_size_bm^2));
        temp_img = reshape(temp_img, [mea_size_bm, mea_size_bm]);
        img(lefty_bd:righty_bd,leftx_bd:rightx_bd) = temp_img*monitor_mean_lumin;
        save([matrix_folder,'\',folder_name,'\',num2str(o),'\origin.mat'],'img');
    end
    %rotation theta = 0 for RL theta
    %theta must between [0,pi]
    for o = rotation
        mkdir ([matrix_folder,folder_name],num2str(o))
        theta = o*pi/4;
        R_matrix = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];
        %find the moving bar
        Vertex = zeros(4,2);
        Vertex(1,:) = [-bar_wid  -bar_le];  %V1  V4
        Vertex(2,:) = [-bar_wid  +bar_le];  %V2  V3
        Vertex(3,:) = [+bar_wid  +bar_le];
        Vertex(4,:) = [+bar_wid  -bar_le];
        Vertex = R_matrix*Vertex';
        if theta > pi/2
            newVertex = Vertex(:,1);
            for i = 1:3
                Vertex(:,i) =Vertex(:,i+1);
            end
            Vertex(:,4) = newVertex;
        end
        if o == 0 || o == 2
            theBarIndexX = round(Vertex(1,1):Vertex(1,3))+meaCenter_x;
            theBarIndexY = round(Vertex(2,1):Vertex(2,3))+meaCenter_y;
        else
            [theBarIndexX, theBarIndexY] = write_2ndCalBar(img,Vertex,theta,mea_size_bm,calibration_date,monitor_mean_lumin); %a = the bar
        end

        for X = ceil(leftx_bar+bar_wid):floor(rightx_bar-bar_wid)
            a = img;
            barCenter = round(R_matrix*[X-meaCenter_x;0]) + [meaCenter_x;meaCenter_y];
            a(theBarIndexY+barCenter(2), theBarIndexX+barCenter(1)) = img(theBarIndexY, theBarIndexX)
            save([matrix_folder,'\',folder_name,'\',num2str(o),'\',num2str(X),'.mat'],'a');
        end
    end
end
