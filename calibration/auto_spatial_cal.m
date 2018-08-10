%% Setup video input
vid = videoinput('gige',1,'Mono8') %Open video
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);

set(vid, 'Exposureabs', 100);

frame = getsnapshot(vid);
image(frame);
%% Open phychotoolbox
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',2, [0 0 0]); %black background 


%% Set mea parameter
mea_size=433; %use odd number!
cal_size = 511;%number of channels for one side, should be an odd number
N = 7;%
baseRect = [0 0 mea_size mea_size];  %use odd number!
meaCenter_x=631; %%%%%%%%%%%%Check
meaCenter_y=605; %%%%%%%%%%%%Check 


x_array=[]; y_array=[];
dotPositionMatrix=zeros(2,cal_size^2);%Matrix that stores the position of every dot


%start calculating the x,y coordination of each dots
for i=0:cal_size-1
    x_array(1,i+1)= meaCenter_x - (cal_size-1)/2 + i;  %start from the lefttest x position
end
for i=0:cal_size-1
    y_array(1,i+1)=meaCenter_y - (cal_size-1)/2 + i;
end


%put x,y coordination into the matrix "dotPositionMatrix"
 for q=0:cal_size-1
    for a=1:cal_size
        dotPositionMatrix(1,a+q*cal_size)=x_array(q+1);
        dotPositionMatrix(2,a+q*cal_size)=y_array(a);
    end
 end

 



dotColors=[255];
%Show seven dots at one time and keep moving
for i = 1:cal_size%x coordination 
    for j = 1:cal_size/N%y coordination
        for z = 0:N-1%Seven points
            baseRect = [0 0 1 1];  % one pixel
            centeredRect = CenterRectOnPointd(baseRect, x_array(i), y_array(z*cal_size/N+j));
            Screen('FillRect', w, dotColors, centeredRect);
        end
        Screen('Flip', w);
        % Run ten times of calibration
        % Move seven points on monitor to let detect point to match ideal point
        for num_calibration = 1:10
            img = getsnapshot(vid);
            CI0=mat2gray(img);
            CI=CI0;
            [centers, radii, metric] = imfindcircles(CI,[1 2],'ObjectPolarity','bright','Sensitivity',0.95,'Method','twostage');  %find the center, radius of the detected ccd dots
            %picking the right radius size influence the detect accuracy A LOT!!
            centersStrong5 = centers(1:7,:);
            radiiStrong5 = radii(1:7);
            %viscircles(centersStrong5, radiiStrong5,'EdgeColor','b'); %plot the detected dots image on the same picture

            %generate detect point cell
            %understand this code by just seeing the matrixes~
            B = sortrows(centers);
            dump = sortrows(B,2);
            B=dump;

            Bcell = num2cell(B,2);
            detect_pt=cell(1,N); %the reconstructed points
            dump = [];
            dump=Bcell(1:N,:);
            for w=1:N
                detect_pt{w}=dump{w};
            end
            
            %Change position on the monitor 
            for k = 0:N-1
                ideal_x = ideal_pt{cal_size-k*cal_size/N+j,i}(1);
                ideal_y = ideal_pt{cal_size-k*cal_size/N+j,i}(2);
                detect_x =  detect_pt{k+1}(1);
                detect_y =  detect_pt{k+1}(2);
                if ideal_x > detect_x
                    dotPositionMatrix(1,i+(k*cal_size/N+j)*(cal_size-1)) = dotPositionMatrix(1,i+z*cal_size/N+k) +1 ;
   
                elseif ideal_x < detect_x
                    dotPositionMatrix(1,i+(k*cal_size/N+j)*(cal_size-1)) = dotPositionMatrix(1,i+z*cal_size/N+k) -1 ;
                else     
                end
                
                if ideal_y > detect_y
                    dotPositionMatrix(2,i+(k*cal_size/N+j)*(cal_size-1)) = dotPositionMatrix(2,i+z*cal_size/N+k) -1 ;
                elseif ideal_y < detect_y
                    dotPositionMatrix(2,i+(k*cal_size/N+j)*(cal_size-1)) = dotPositionMatrix(2,i+z*cal_size/N+k) +1 ;
                else 
                end
                
                baseRect = [0 0 1 1];  % one pixel

                centeredRect = CenterRectOnPointd(baseRect, dotPositionMatrix(1,i+(k*cal_size/N+j)*(cal_size-1)), dotPositionMatrix(2,i+(k*cal_size/N+j)*(cal_size-1)));
                Screen('FillRect', w, dotColors, centeredRect);
                
            end
            Screen('Flip', w);
        end
    end
end

%Screen('DrawDots', w, dotPositionMatrix,dotSize, dotColors,[],2); %2 is to specify dot type(> circle)
%Screen('DrawDots', w, dotPositionMatrix,6, [0],[],2); %2 is to specify dot type(> circle)

Screen('Flip', w);


N = 8;
% img = imread('C:\Users\Hydrolab320\Desktop\Oct2017_calibration\64dots_gain0_expT500000.tif');
img = imread('/Users/nghdavid/Desktop/00Calibration/Spatial_cal/64dots_gain0_expT500000.tif'); %read in the ccd image
CI0=mat2gray(img); %turn to gray image
figure;imshow(CI0); 
% CI=CI0(:,:,2); %RGB
CI=CI0;
[centers, radii, metric] = imfindcircles(CI,[8 18],'ObjectPolarity','bright','Sensitivity',0.7,'Method','twostage');  %find the center, radius of the detected ccd dots
%picking the right radius size influence the detect accuracy A LOT!!
centersStrong5 = centers(1:N^2,:);
radiiStrong5 = radii(1:N^2);
viscircles(centersStrong5, radiiStrong5,'EdgeColor','b'); %plot the detected dots image on the same picture
