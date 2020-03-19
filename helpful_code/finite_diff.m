function dx = finite_diff(x , num)
%using central Finite difference method
%(https://en.wikipedia.org/wiki/Finite_difference_coefficient)
%maximum of num is 4
%dx([1:num end-num:end]) are incorrect. FYI, all 'exceeded x' are assumed to be mean(x).
m = mean(x);
if num == 2
    v = (-1*[m m x m m m m m m]+8*[m m m x m m m m m]-8*[m m m m m x m m m]+[m m m m m m x m m])/12;
elseif num == 4
    v = (-1*[x m m m m m m m m]+32/3*[ m x m m m m m m m]-56*[m m x m m m m m m]+224*[m m m x m m m m m]-224*[m m m m m x m m m]+56*[m m m m m m x m m]-32/3*[m m m m m m m x m]+[m m m m m m m m x])/280;
elseif num == 3
    v = ([ m x m m m m m m m]-9*[m m x m m m m m m]+45*[m m m x m m m m m]-45*[m m m m m x m m m]+9*[m m m m m m x m m]-1*[m m m m m m m x m])/60;
else
    v = ([m m m x m m m m m] - [ m m m m m x m m m])/2;
end
dx = v(5:end-4);
end