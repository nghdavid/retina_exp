%% Project the x,y coordination of each dots that calibarted.
load('calibrate_pt.mat');

for k = 1:cal_size^2%Show N^2 points on monitor
                baseRect = [0 0 1 1];  % one pixel
                centeredRect = CenterRectOnPointd(baseRect, dotPositionMatrix{k}(1), dotPositionMatrix{k}(2));
                Screen('FillRect', w, 255, centeredRect);
end
Screen('Flip', w);

