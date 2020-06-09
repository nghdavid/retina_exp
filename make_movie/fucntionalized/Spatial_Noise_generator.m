function sN_indexnCentre = Spatial_Noise_generator(mea_range, num_dot);
mea_size = mea_range(5);
if num_dot == 1
    sN_indexnCentre = cell(1,3);
    all_pos = cell(mea_size-32);
    for i = 1:mea_size-32
        for j = 1:mea_size-32
            all_pos{i,j} = [mea_range(1)+16+i-1  mea_range(3)+16+j-1];
        end
    end
    sN_indexnCentre{3} = all_pos(:)';
    sN_indexnCentre{2} = all_pos{randi(length(all_pos)^2)};
    sN_indexnCentre{1} = zeros(mea_range(6),mea_range(7));
    sN_indexnCentre{1}((sN_indexnCentre{2}(1)-16:sN_indexnCentre{2}(1)+16) , (sN_indexnCentre{2}(2)-16:sN_indexnCentre{2}(2)+16)) = 1;
    return
else
    sN_indexnCentre = Spatial_Noise_generator(mea_range, num_dot-1);
    if ~isempty(sN_indexnCentre)
        part_pos = cell(1, (mea_size-32)^2-(65^2)*(num_dot-1));
        counter = 0;
        for i = 1:length(sN_indexnCentre{3})
            if sN_indexnCentre{3}{i}(1) <= sN_indexnCentre{2}(num_dot-1, 1)-33 || sN_indexnCentre{3}{i}(1) >= sN_indexnCentre{2}(num_dot-1, 1)+33 ...
                    || sN_indexnCentre{3}{i}(2) <= sN_indexnCentre{2}(num_dot-1, 2)-33 || sN_indexnCentre{3}{i}(2) >= sN_indexnCentre{2}(num_dot-1, 2)+33
                counter = counter+1;
                part_pos{counter} = sN_indexnCentre{3}{i};
            end
        end
        sN_indexnCentre{3} = part_pos;
        if length(part_pos) <= 0 %if there is no place for new dot
            sN_indexnCentre = [];
        else
            new_dot_center = part_pos{randi(length(part_pos))};
            sN_indexnCentre{2} = vertcat(sN_indexnCentre{2},new_dot_center);
            sN_indexnCentre{1}((new_dot_center(1)-16:new_dot_center(1)+16) , (new_dot_center(2)-16:new_dot_center(2)+16)) = 1;
        end
    end
end
end