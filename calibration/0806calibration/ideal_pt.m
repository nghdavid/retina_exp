%% direct error calculation
% N=8;
%generate the 64 ideal points first
ideal_pt=cell(N,N);

c1=detect_pt{floor(N/2),floor(N/2)};
c2=detect_pt{floor(N/2),floor(N/2)+2};
c3=detect_pt{floor(N/2)+2,round(N/2)};
c4=detect_pt{floor(N/2)+2,floor(N/2)+2};
c5 = detect_pt{floor(N/2)+1,floor(N/2)};
c6 = detect_pt{floor(N/2),floor(N/2)+1};
c7 = detect_pt{floor(N/2)+2,floor(N/2)+1};
c8 = detect_pt{floor(N/2)+1,floor(N/2)+1};
center_x=( c1(1)+c2(1)+c3(1)+c4(1) +c5(1)+c6(1)+c7(1)+c8(1))/8;
center_y=( c1(2)+c2(2)+c3(2)+c4(2) +c5(2)+c6(2)+c7(2)+c8(2))/8;
center_slope_row=((c2(2)-c1(2))/(c2(1)-c1(1)) + (c4(2)-c3(2))/(c4(1)-c3(1)))/2;
center_slope_col=((c3(2)-c1(2))/(c3(1)-c1(1)) + (c4(2)-c2(2))/(c4(1)-c2(1)))/2;
distance_pt_row=(c2(1)-c1(1) +c4(1)-c3(1))/2;
distance_pt_col=(c3(2)-c1(2) +c4(2)-c2(2))/2;

ideal_pt{1,1}=[ center_x- (c4(1)-c1(1))*3 center_y-(c4(2)-c1(2))*3]; %4.5 is for N=10 case
for r=1:N
    left_o(1)=ideal_pt{1,1}(1)+(r-1)*(c4(1)-c2(1)+c3(1)-c1(1))/2;
    left_o(2)=ideal_pt{1,1}(2)+(r-1)*(c4(2)-c2(2)+c3(2)-c1(2))/2;
    for c=1:N
        ideal_pt{r,c}(1)=left_o(1)+(c-1)*(c2(1)-c1(1)+c4(1)-c3(1))/2;
        ideal_pt{r,c}(2)=left_o(2)+(c-1)*(c2(2)-c1(2)+c4(2)-c3(2))/2;       
    end
end
