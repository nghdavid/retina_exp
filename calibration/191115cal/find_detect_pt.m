function detect_point = find_detect_pt(img,N,sensitivity,radius_range,show)
    %Function that find centers of points in the image
    %CI=mat2gray(img-black_frame-black_frame_2 );
    CI=mat2gray(img);
    detected_num = 0;
    while detected_num ~= N^2%Stay in loop and increase sensitivity to find correct number of points
        [centers, radii, ~] = imfindcircles(CI,radius_range,'ObjectPolarity','bright','Sensitivity',sensitivity,'Method','twostage');  %find the center, radius of the detected ccd dots
        %picking the right radius size influence the detect accuracy A LOT!!
        %Show image
        if strcmp(show,'on')
            figure;imshow(CI); 
            centersStrong5 = centers;
            radiiStrong5 = radii;
            viscircles(centersStrong5, radiiStrong5,'EdgeColor','b'); %plot the detected dots image on the same picture
        end
        
        detected_num = size(centers,1);
        %Check the function does find correct numbers of points
        if detected_num < N^2
            sensitivity = sensitivity + 0.01;
        elseif detected_num > N^2
            sensitivity = sensitivity - 0.01;
        else
        end
    end
    
    %generate detect point matrix(2,N^2)
    %understand this code by just seeing the matrixes~
    B = sortrows(centers);
    for fori = 1:N
        dump = [];dump2 = [];
        dump = B(((fori-1)*N+1):fori*N,:);
        dump2 = sortrows(dump,2);
        B(((fori-1)*N+1):fori*N,:)=dump2;
    end
    Bcell = num2cell(B,2);
    detect_pt=cell(N,N); %the reconstructed points
    for fori = 1:N
        dump = [];
        dump=Bcell(((fori-1)*N+1):fori*N,:);
        for i=1:N
            detect_pt{(fori-1)*N+1+i-1}=dump{i};
        end
    end
    detect_point = zeros(2,N^2);
    for q = 0:N-1%x
        for a = 1:N%y
            detect_point(1,a+q*N) = detect_pt{N+1-a,q+1}(1);
            detect_point(2,a+q*N) = detect_pt{N+1-a,q+1}(2);  
        end
    end
    
end