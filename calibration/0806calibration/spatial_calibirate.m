
Screen('Preference', 'SkipSyncTests', 1)
global rect w
[w, rect] = Screen('OpenWindow',1, [0 0 0]); %black background 

mea_size=433; %use odd number!
baseRect = [0 0 mea_size mea_size];  %use odd number!
meaCenter_x=631; 
meaCenter_y=605;  

%% draw dots(mea 64 dots)
%to see whether there is blurry dots > rearrange lens or position of microscope


x_array=[]; y_array=[];
sdi=31; %distance btw each dot's center  
N=8;  %number of channels for one side
dotPositionMatrix=zeros(2,225);
x_array=zeros(1,2*N-1);  %x coordination of the dots
y_array=zeros(1,2*N-1);


%start calculating the coordination of each dots
for i=0:2*N-2
    x_array(1,i+1)=round(meaCenter_x-7*sdi+i*sdi);  %start from the lefttest x position
end
for i=0:2*N-2
    y_array(1,i+1)=round(meaCenter_y-7*sdi+i*sdi);
end

%put into the matrix "dotPositionMatrix"
 for q=0:2*N-2
    for a=1:2*N-1
        dotPositionMatrix(1,a+q*(2*N-1))=x_array(q+1);
        dotPositionMatrix(2,a+q*(2*N-1))=y_array(a);
    end
 end

 
 
 %draw gray background
baseRect = [0 0 1250 1250];
xCenter=700;
yCenter=400;
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
Screen('FillRect', w, 0,centeredRect);

%draw dots and show the image
dotSize=0; 
dotColors=[255];
Screen('DrawDots', w, dotPositionMatrix,dotSize, dotColors,[],2); %2 is to specify dot type(> circle)
%Screen('DrawDots', w, dotPositionMatrix,5, [0],[],2); %2 is to specify dot type(> circle)

Screen('Flip', w);


N = 15;
% img = imread('C:\Users\Hydrolab320\Desktop\Oct2017_calibration\64dots_gain0_expT500000.tif');
img = imread('C:\Users\Hydrolab320\Desktop\0807calibration\64dots_gain0_expT10000000_dot1.tif'); %read in the ccd image
%img = imread('C:\Users\Hydrolab320\Desktop\0807calibration\64dots_gain0_expT2000000_dot8.tif');
img_hole = imread('C:\Users\Hydrolab320\Desktop\0807calibration\64dots_gain0_expT1000000_hole5.tif'); 
CI0=mat2gray(img); %turn to gray image
CI_hole=mat2gray(img_hole); %turn to gray image
figure;imshow(CI0); 
% CI=CI0(:,:,2); %RGB
CI=CI0;
%[centers, radii, metric] = imfindcircles(CI,[8 18],'ObjectPolarity','bright','Sensitivity',0.99,'Method','twostage');  %find the center, radius of the detected ccd dots
[centers, radii, metric] = imfindcircles(CI,[1 2],'ObjectPolarity','bright','Sensitivity',0.90,'Method','twostage');  %find the center, radius of the detected ccd dots
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
figure;imshow(CI_hole); hold on
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

ideal_pt{1,1}=[ center_x- (c4(1)-c1(1))*7, center_y-(c4(2)-c1(2))*7]; %4.5 is for N=10 case
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