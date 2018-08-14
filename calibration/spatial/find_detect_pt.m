function detect_point = find_detect_pt(img,num_point,sensitivity,radius_range,show,ideal_point)
    %Function that find centers of points in the image
    CI=mat2gray(img);
    [centers, radii, ~] = imfindcircles(CI,radius_range,'ObjectPolarity','bright','Sensitivity',sensitivity,'Method','twostage');  %find the center, radius of the detected ccd dots
    %picking the right radius size influence the detect accuracy A LOT!!
    ii=0;
    correct_center = zeros(num_point^2,2);
    correct_radius = zeros(num_point^2,1);
    for x = 0:num_point-1
        up_y = ideal_point(2,x*num_point+num_point);
        down_y = ideal_point(2,x*num_point+1);
        avg_x = mean(ideal_point(1,x*num_point+1:x*num_point+num_point));
        for i = 1:size(centers,1)
            if centers(i,2)<down_y+100 && centers(i,2)>up_y-100 && abs(centers(i,1)-avg_x)<100
                ii = ii+1;
                correct_center(ii,:) = centers(i,:);
                correct_radius(ii) = radii(i);
            end

        end
    
    end
    %Show image
    if strcmp(show,'on')
        figure;imshow(CI); 
        centersStrong5 = correct_center;
        radiiStrong5 = correct_radius;
        viscircles(centersStrong5, radiiStrong5,'EdgeColor','b'); %plot the detected dots image on the same picture
    end
    
    %Check the function does find correct numbers of points
    if size(correct_center,1) ~= num_point
        error('Find not correct points')
    end
   
    %generate detect point cell
    %understand this code by just seeing the matrixes~
    B = sortrows(correct_center);


    for fori = 1:num_point
        dump = [];dump2 = [];
        dump = B(((fori-1)*num_point+1):fori*num_point,:);
        dump2 = sortrows(dump,2);
        B(((fori-1)*num_point+1):fori*num_point,:)=dump2;
    end
    Bcell = num2cell(B,2);
    detect_pt=cell(num_point,num_point); %the reconstructed points
    for fori = 1:num_point
        dump = [];
        dump=Bcell(((fori-1)*num_point+1):fori*num_point,:);
        for i=1:num_point
            detect_pt{(fori-1)*num_point+1+i-1}=dump{i};
        end
    end
    detect_point = zeros(2,num_point^2);
    for q = 0:num_point-1%x
        for a = 1:num_point%y
            detect_point(1,a+q*num_point) = detect_pt{a,q+1}(1);
            detect_point(2,a+q*num_point) = detect_pt{a,q+1}(2);  
        end
    end
    

end