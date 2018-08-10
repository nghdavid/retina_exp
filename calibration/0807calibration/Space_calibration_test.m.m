%% code of testing the LED screen coordinate
GetClicks;
[x,y] = GetMouse(1)

%% initiate the PTB
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',1, [0 0 0]); %black background 
load('first_cal.mat')
load('second_cal.mat')
load('final_cal.mat')
%% test focus plane: see the edge of the black square is clear or not
baseRect = [0 0 550 550]; %the size of the rectangle
xCenter=670; %x coordination of the rectangel center
yCenter=460;
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
Screen('FillRect', w,  255,centeredRect); %255 is the luminance value
baseRect = [0 0 150 150];
xCenter=495; 
yCenter=450; 
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
Screen('FillRect', w, 0, centeredRect);
Screen('Flip', w);
 
%% decide mea region on LED screen
%full light screen
baseRect = [0 0 1250 1250];
xCenter=700;
yCenter=400;
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
Screen('FillRect', w, 150,centeredRect);  %be cardeful that all values have to be integer!!!

mea_size=433; %use odd number!
baseRect = [0 0 mea_size mea_size];  %use odd number!
meaCenter_x=630; 
meaCenter_y=573;  
centeredRect = CenterRectOnPointd(baseRect, meaCenter_x, meaCenter_y);
Screen('FillRect', w, 255,centeredRect); 
Screen('Flip', w);


%% draw dots(mea 64 dots)
%to see whether there is blurry dots > rearrange lens or position of microscope
dotPositionMatrix=[]; 
x_array=[]; y_array=[];
sdi=61; %distance btw each dot's center  
N=8;  %number of channels for one side
x_array=zeros(1,N);  %x coordination of the dots
y_array=zeros(1,N);

%start calculating the coordination of each dots
for i=0:N-1
    x_array(1,i+1)=round(meaCenter_x-3.5*sdi)+i*sdi;  %start from the lefttest x position
end
for i=0:N-1
    y_array(1,i+1)=round(meaCenter_y-3.5*sdi)+i*sdi;
end

%put into the matrix "dotPositionMatrix"
%  for q=0:N-1
%     for a=1:N
%         dotPositionMatrix(1,a+q*N)=x_array(q+1);
%         dotPositionMatrix(2,a+q*N)=y_array(a);
%     end
%  end
%  



 for q=0:N-1
    for a=1:N
        dotPositionMatrix(1,a+q*N)=x_array(q+1)-x_error02_1(q+1,a);
        dotPositionMatrix(2,a+q*N)=y_array(a)-y_error02_1(q+1,a);
    end
 end
 
 
 
 
 %draw gray background
baseRect = [0 0 1250 1250];
xCenter=700;
yCenter=400;
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
Screen('FillRect', w, 120,centeredRect);

%draw dots and show the image
dotSize=13; 
dotColors=[255];
Screen('DrawDots', w, dotPositionMatrix,dotSize, dotColors,[],2); %2 is to specify dot type(> circle)
Screen('Flip', w); 

%% Spatial calibration
%use mirror
%record an image from ccd
N = 8;
% img = imread('C:\Users\Hydrolab320\Desktop\Oct2017_calibration\64dots_gain0_expT500000.tif');
%img = imread('C:\Users\Hydrolab320\Desktop\0806calibration\64dots_gain0_expT700000.tif'); %read in the ccd image
img = imread('C:\Users\Hydrolab320\Desktop\0806calibration\64dots_gain0_expT800000_final.tif'); %read in the ccd image

CI0=mat2gray(img); %turn to gray image
figure;imshow(CI0); 
% CI=CI0(:,:,2); %RGB
CI=CI0;
[centers, radii, metric] = imfindcircles(CI,[8 18]);  %find the center, radius of the detected ccd dots
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
% N=8;
%generate the 64 ideal points first
ideal_pt=cell(N,N);

c1=detect_pt{round(N/2),round(N/2)};
c2=detect_pt{round(N/2),round(N/2)+1};
c3=detect_pt{round(N/2)+1,round(N/2)};
c4=detect_pt{round(N/2)+1,round(N/2)+1};

center_x=( c1(1)+c2(1)+c3(1)+c4(1) )/4;
center_y=( c1(2)+c2(2)+c3(2)+c4(2) )/4;
center_slope_row=((c2(2)-c1(2))/(c2(1)-c1(1)) + (c4(2)-c3(2))/(c4(1)-c3(1)))/2;
center_slope_col=((c3(2)-c1(2))/(c3(1)-c1(1)) + (c4(2)-c2(2))/(c4(1)-c2(1)))/2;
distance_pt_row=(c2(1)-c1(1) +c4(1)-c3(1))/2;
distance_pt_col=(c3(2)-c1(2) +c4(2)-c2(2))/2;

ideal_pt{1,1}=[ center_x- (c4(1)-c1(1))*3.5, center_y-(c4(2)-c1(2))*3.5]; %4.5 is for N=10 case
for r=1:N
    left_o(1)=ideal_pt{1,1}(1)+(r-1)*(c4(1)-c2(1)+c3(1)-c1(1))/2;
    left_o(2)=ideal_pt{1,1}(2)+(r-1)*(c4(2)-c2(2)+c3(2)-c1(2))/2;
    for c=1:N
        ideal_pt{r,c}(1)=left_o(1)+(c-1)*(c2(1)-c1(1)+c4(1)-c3(1))/2;
        ideal_pt{r,c}(2)=left_o(2)+(c-1)*(c2(2)-c1(2)+c4(2)-c3(2))/2;       
    end
end

%making error matrix: comparing ideal_pt and detect_pt
error=cell(N,N);
for i=1:N^2
    error{i}=sqrt((ideal_pt{i}(1)-detect_pt{i}(1))^2+(ideal_pt{i}(2)-detect_pt{i}(2))^2);
end

%plot the ideal_pt and detect_pt
figure; 
for kk=1:N
    for k=1:N
    plot(detect_pt{k,kk}(1), detect_pt{k,kk}(2),'r.','markersize', 10); hold on
    end
end
for ko=1:N
    for k=1:N
    plot(ideal_pt{k,ko}(1), ideal_pt{k,ko}(2),'b.','markersize', 10); hold on
    end
end

clearvars -except dotPositionMatrix detect_pt ideal_pt
save('C:\Users\Hydrolab320\Desktop\test_calibirate.mat')
