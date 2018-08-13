function detect_pt = find_detect_pt(img,num_point,sensitivity,show,ideal_point)
    %Function that find centers of points in the image
    CI=mat2gray(img);
    [centers, radii, ~] = imfindcircles(CI,[2 4],'ObjectPolarity','bright','Sensitivity',sensitivity,'Method','twostage');  %find the center, radius of the detected ccd dots
    %picking the right radius size influence the detect accuracy A LOT!!
    
    up_y = ideal_point(2,end);
    down_y = ideal_point(2,1);
    avg_x = mean(ideal_point(1,:));
    correct_center = zeros(num_point,2);
    correct_radius = zeros(num_point,1);
    ii=0;
    for i = 1:size(centers,1)
        if centers(i,2)<down_y+100 && centers(i,2)>up_y-100 && abs(centers(i,1)-avg_x)<100
            ii = ii+1;
            correct_center(ii,:) = centers(i,:);
            correct_radius(ii) = radii(i);
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
    dump = sortrows(B,2);
    B=dump;
    
    Bcell = num2cell(B,2);
    detect_pt=zeros(2,num_point); %the reconstructed points
    dump = [];
    dump=Bcell(1:num_point,:);
    for w=1:num_point
        detect_pt(1,w)=dump{w}(1);
        detect_pt(2,w)=dump{w}(2);
    end

end