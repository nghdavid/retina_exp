function detect_pt = find_detect_pt(img,num_point,sensitivity,show)
    %Function that find centers of points in the image
    CI=mat2gray(img);
    [centers, radii, ~] = imfindcircles(CI,[1 2],'ObjectPolarity','bright','Sensitivity',sensitivity,'Method','twostage');  %find the center, radius of the detected ccd dots
    %picking the right radius size influence the detect accuracy A LOT!!
    
    %Check the function does find correct numbers of points
    if size(num_point,2) ~= num_point
        error('Find not correct points')
    end
    
    %Show image
    if strcmp(show,'on')
        figure;imshow(CI); 
        centersStrong5 = centers(1:num_point,:);
        radiiStrong5 = radii(1:num_point);
        viscircles(centersStrong5, radiiStrong5,'EdgeColor','b'); %plot the detected dots image on the same picture
    end
    
    
   
    %generate detect point cell
    %understand this code by just seeing the matrixes~
    B = sortrows(centers);
    dump = sortrows(B,2);
    B=dump;
    
    Bcell = num2cell(B,2);
    detect_pt=zeros(2,N); %the reconstructed points
    dump = [];
    dump=Bcell(1:N,:);
    for w=1:N
        detect_pt(1,w)=dump{w}(1);
        detect_pt(2,w)=dump{w}(2);
    end

end