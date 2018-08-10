function Error = errorMeasure(intensity)
    for i = 1:size(intensity,2)^2
        baseRect = [0 0 1 1];  % one pixel
        xCenter=matrix_lcd_pt{i}(1); %determine the x coordination on monitor for this point
        yCenter=matrix_lcd_pt{i}(2);
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        Screen('FillRect', w, intensity(i), centeredRect);
    end
    Screen('Flip', w);
    img = getsnapshot(vid);
    diff = (img(y1:y2,x1:x2)-selected_img_1st).^2;
    Error = sum(diff(:));
    
    
end