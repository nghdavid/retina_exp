function [ideal_pt,ideal_distance_pt] = find_i_pt(frame,N,cal_size, pt_distance_per_pixel)
    %input image and find detect pt
    CI=mat2gray(frame); %turn to gray image
    figure;imshow(CI); 
    [centers, radii, ~] = imfindcircles(CI,[1 6],'ObjectPolarity','bright','Sensitivity',0.90,'Method','twostage');  %find the center, radius of the detected ccd dots
    %picking the right radius size influence the detect accuracy A LOT!!
    centersStrong5 = centers(1:length(centers),:);
    radiiStrong5 = radii(1:length(centers));
    viscircles(centersStrong5, radiiStrong5,'EdgeColor','b'); %plot the detected dots image on the same picture

    %generate detect point cell
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
    %1st conponent upward; 2nd coponent downward.
    for fori = 1:N
            dump = [];
            dump=Bcell(((fori-1)*N+1):fori*N,:);
            for i=1:N
                detect_pt{(fori-1)*N+1+i-1}=dump{i};
            end
    end

    %plot detected points on ccd image
    figure;imshow(CI0); hold on
    for kk=1:N
        for k=1:N  %check this plot's (x,y) coordinate is correct!!
        plot(detect_pt{k,kk}(1), detect_pt{k,kk}(2),'r.','markersize', 10); hold on
        end
    end
    title('reconstructed pts on ccd'); 

    %% direct error calculation
    ideal_pt=cell(cal_size,cal_size);

    c1 = detect_pt{floor(N/2)  ,floor(N/2)  };   %c1 c6 c3
    c2 = detect_pt{floor(N/2)+2,floor(N/2)  };   %c5    c8
    c3 = detect_pt{floor(N/2)  ,floor(N/2)+2};   %c2 c7 c4
    c4 = detect_pt{floor(N/2)+2,floor(N/2)+2};
    c5 = detect_pt{floor(N/2)+1,floor(N/2)  };
    c6 = detect_pt{floor(N/2)  ,floor(N/2)+1};
    c7 = detect_pt{floor(N/2)+2,floor(N/2)+1};
    c8 = detect_pt{floor(N/2)+1,floor(N/2)+2};
    c9 = detect_pt{floor(N/2)+1,floor(N/2)+1};

    center = c9;
    
    ideal_distance_pt = zeros(1,2);
    ideal_distance_pt(1) = (norm(c1-c6) + norm(c5-c9) + norm(c6-c3) + norm(c9-c8) + norm(c2-c7) + norm(c7-c4))/6/pt_distance_per_pixel;
    ideal_distance_pt(2) = (norm(c1-c5) + norm(c5-c2) + norm(c6-c9) + norm(c9-c7) + norm(c3-c8) + norm(c8-c4))/6/pt_distance_per_pixel;
    
    center_slope_row=((c2(2)-c1(2))/(c2(1)-c1(1)) + (c4(2)-c3(2))/(c4(1)-c3(1)) + (c7(2)-c6(2))/(c7(1)-c6(1)))/2 ;
    center_slope_col=((c3(2)-c1(2))/(c3(1)-c1(1)) + (c4(2)-c2(2))/(c4(1)-c2(1)) + (c8(2)-c5(2))/(c8(1)-c5(1)))/2;

    theta = ( atan(1/center_slope_row) - atan(center_slope_col) )/2;
    RR_matrix = [cos(theta) sin(theta) ; -sin(theta) cos(theta)];
    
    for r=1:cal_size
        for c=1:cal_size
            ideal_pt{r,c} = center + [(c-round(cal_size/2))*ideal_distance_pt(1) , (r-round(cal_size/2))*ideal_distance_pt(1) ];
        end
    end

    R_ideal_pt = cell(cal_size,cal_size);

    for r=1:cal_size
        for c=1:cal_size
             R_ideal_pt{r,c} = RR_matrix * (ideal_pt{r,c} - center)'  + center';
             ideal_pt{r,c} = R_ideal_pt{r,c}';
        end
    end
    
%     figure;
%     for kk=1:N
%         for k=1:N
%         plot(detect_pt{k,kk}(1), detect_pt{k,kk}(2),'r.','markersize', 10); hold on
%         end
%     end
%     for ko=1:cal_size
%         for k=1:cal_size
%             plot(R_ideal_pt{k,ko}(1), R_ideal_pt{k,ko}(2),'b.','markersize', 10); hold on
%         end
%     end


    
end
% 
% 